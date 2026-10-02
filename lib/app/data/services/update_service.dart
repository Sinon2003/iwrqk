import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/display_util.dart';
import '../../utils/log_util.dart';
import '../../utils/path_util.dart';
import '../models/app_release.dart';
import '../providers/config_provider.dart';
import '../providers/storage_provider.dart';

/// What the user answered when offered an update.
enum _Answer { update, later, skip }

/// Updates the app from this project's releases without leaving it: the user
/// is shown what a release brings, and on their word the APK for this device
/// downloads in the app and the system installer opens to install it over
/// the current version.
class UpdateService extends GetxService with WidgetsBindingObserver {
  static const _dialogTag = "update";

  /// How long the check on launch waits before asking the site again.
  static const checkInterval = Duration(hours: 24);

  /// How long "later" keeps a version from being offered on launch.
  static const laterInterval = Duration(days: 3);

  /// Download progress from 0 to 1 while an update downloads.
  final Rxn<double> progress = Rxn();

  AppRelease? _release;
  String _currentVersion = "";
  CancelToken? _cancelToken;

  /// A finished download waiting for the app to come back to the
  /// foreground, as Android does not open the installer from the background.
  String? _pendingInstall;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final path = _pendingInstall;
    if (state == AppLifecycleState.resumed && path != null) {
      _pendingInstall = null;
      _install(path);
    }
  }

  /// Looks for a newer release because the user asked, and offers it.
  Future<void> checkForUpdate() async {
    if (progress.value != null) {
      _showProgress();
      return;
    }
    _currentVersion = (await PackageInfo.fromPlatform()).version;
    final result = await ConfigProvider.getLatestRelease();
    if (!result.success) {
      LogUtil.error('Check update failed', result.message);
      SmartDialog.showToast(t.message.update.check_update_failed);
      return;
    }
    final release = result.data!;
    if (compareVersion(_currentVersion, release.version) >= 0) {
      SmartDialog.showToast(t.message.update.already_latest_version);
      return;
    }
    final asset = await _assetForDevice(release);
    if (asset == null) {
      // A release without a fitting APK: its page has what there is.
      launchUrlString(release.pageUrl, mode: LaunchMode.externalApplication);
      return;
    }
    if (await _offer(release, asset, onLaunch: false) == _Answer.update) {
      await _download(release, asset);
    }
  }

  /// Offers a release with new features when the app opens, unasked.
  ///
  /// Releases that only fix things wait for the user to check. A version put
  /// off with "later" is offered again after [laterInterval], a skipped one
  /// never, and the site is asked at most once per [checkInterval]. [canAsk]
  /// tells whether the user is still where a dialog would not interrupt.
  Future<void> offerOnLaunch({required bool Function() canAsk}) async {
    if (progress.value != null) return;
    final config = StorageProvider.config;
    final now = DateTime.now();
    final checkedAt = _time(config[StorageKey.updateCheckedAt]);
    if (checkedAt != null && now.difference(checkedAt).abs() < checkInterval) {
      return;
    }
    try {
      _currentVersion = (await PackageInfo.fromPlatform()).version;
      final result = await ConfigProvider.getLatestRelease();
      if (!result.success) return;
      final release = result.data!;
      final asset =
          shouldOffer(
            current: _currentVersion,
            latest: release.version,
            skipped: config[StorageKey.updateSkippedVersion],
            laterVersion: config[StorageKey.updateLaterVersion],
            laterUntil: _time(config[StorageKey.updateLaterUntil]),
            now: now,
          )
          ? await _assetForDevice(release)
          : null;
      if (asset == null) {
        config[StorageKey.updateCheckedAt] = now.millisecondsSinceEpoch;
        return;
      }
      // The next launch asks again when this one has moved on.
      if (!canAsk()) return;
      config[StorageKey.updateCheckedAt] = now.millisecondsSinceEpoch;

      switch (await _offer(release, asset, onLaunch: true)) {
        case _Answer.update:
          await _download(release, asset);
        case _Answer.later:
          // Counted from the answer; the dialog may have been open a while.
          config[StorageKey.updateLaterVersion] = release.version;
          config[StorageKey.updateLaterUntil] = DateTime.now()
              .add(laterInterval)
              .millisecondsSinceEpoch;
        case _Answer.skip:
          config[StorageKey.updateSkippedVersion] = release.version;
      }
    } catch (e, stackTrace) {
      LogUtil.warning('Update check on launch failed', e, stackTrace);
    }
  }

  static DateTime? _time(dynamic milliseconds) => milliseconds is int
      ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
      : null;

  /// Whether the check on launch offers [latest] to an app at [current].
  @visibleForTesting
  static bool shouldOffer({
    required String current,
    required String latest,
    required DateTime now,
    String? skipped,
    String? laterVersion,
    DateTime? laterUntil,
  }) {
    if (!isFeatureRelease(current, latest)) return false;
    if (latest == skipped) return false;
    final putOff =
        latest == laterVersion &&
        laterUntil != null &&
        now.isBefore(laterUntil);
    return !putOff;
  }

  /// Whether [latest] is ahead of [current] in its first or second number,
  /// as releases with new features are; the third counts fixes.
  @visibleForTesting
  static bool isFeatureRelease(String current, String latest) {
    final from = _numbers(current);
    final to = _numbers(latest);
    if (from == null || to == null) return false;
    return to[0] > from[0] || (to[0] == from[0] && to[1] > from[1]);
  }

  /// The three numbers of an "X.Y.Z" version, or null when it is not one.
  static List<int>? _numbers(String version) {
    final numbers = [
      for (final part in version.replaceFirst('v', '').split('.'))
        int.tryParse(part),
    ];
    if (numbers.length != 3 || numbers.contains(null)) return null;
    return numbers.cast<int>();
  }

  /// Shows what [release] brings and asks what to do with it. On launch the
  /// user can also put it off or skip it; closing the dialog puts it off.
  Future<_Answer> _offer(
    AppRelease release,
    AppReleaseAsset asset, {
    required bool onLaunch,
  }) async {
    final changelog = release.changelog(
      chinese: LocaleSettings.currentLocale.languageCode == "zh",
    );
    final answer = await Get.dialog<_Answer>(
      AlertDialog(
        // Wide enough for the three answers to sit on one line.
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(t.message.update.update_available),
        content: SizedBox(
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.message.update.current_version(version: _currentVersion)),
              Text(t.message.update.latest_version(version: release.version)),
              Text(
                t.message.update.download_size(
                  size: DisplayUtil.getDisplayFileSizeWithUnit(asset.size),
                ),
              ),
              if (changelog.isNotEmpty) ...[
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: SingleChildScrollView(child: Text(changelog)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (onLaunch)
            TextButton(
              onPressed: () => Get.back(result: _Answer.skip),
              child: Text(t.message.update.skip_version),
            ),
          TextButton(
            onPressed: () => Get.back(result: _Answer.later),
            child: Text(
              onLaunch ? t.message.update.later : t.notifications.cancel,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: _Answer.update),
            child: Text(t.message.update.update_now),
          ),
        ],
      ),
    );
    return answer ?? _Answer.later;
  }

  /// Stops a download in progress.
  void cancel() {
    _cancelToken?.cancel();
  }

  /// The APK built for this device's processor, or the universal one.
  Future<AppReleaseAsset?> _assetForDevice(AppRelease release) async {
    if (!Platform.isAndroid) return null;
    final abis = (await DeviceInfoPlugin().androidInfo).supportedAbis;
    for (final abi in [...abis, "universal"]) {
      for (final asset in release.assets) {
        if (asset.name == "iwrqk-${release.version}-$abi.apk") return asset;
      }
    }
    return null;
  }

  Future<void> _download(AppRelease release, AppReleaseAsset asset) async {
    final file = File("${PathUtil.tempDir.path}/updates/${asset.name}");
    // A finished download of this version needs no second one.
    if (await file.exists() && await file.length() == asset.size) {
      await _install(file.path);
      return;
    }
    final partial = File("${file.path}.part");
    await partial.parent.create(recursive: true);
    // Earlier versions' downloads have served their purpose.
    await for (final old in partial.parent.list()) {
      await old.delete(recursive: true);
    }

    _release = release;
    progress.value = 0;
    _cancelToken = CancelToken();
    _showProgress();
    try {
      await ConfigProvider.download(
        asset.url,
        partial.path,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          final size = total > 0 ? total : asset.size;
          if (size > 0) progress.value = received / size;
        },
      );
      if (await partial.length() != asset.size) {
        throw const FileSystemException("Incomplete download");
      }
      await partial.rename(file.path);
    } catch (e) {
      if (await partial.exists()) await partial.delete();
      if (!(e is DioException && CancelToken.isCancel(e))) {
        LogUtil.error('Update download failed', e);
        SmartDialog.showToast(t.message.update.download_failed);
      }
      return;
    } finally {
      progress.value = null;
      SmartDialog.dismiss(tag: _dialogTag);
    }

    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      await _install(file.path);
    } else {
      _pendingInstall = file.path;
    }
  }

  Future<void> _install(String path) async {
    final result = await OpenFile.open(
      path,
      type: "application/vnd.android.package-archive",
    );
    if (result.type != ResultType.done) {
      LogUtil.error('Opening the installer failed', result.message);
      SmartDialog.showToast(t.message.update.install_failed);
    }
  }

  /// The download's progress; what the release brings was shown before it.
  void _showProgress() {
    final release = _release;
    if (release == null) return;
    SmartDialog.show(
      tag: _dialogTag,
      clickMaskDismiss: false,
      builder: (context) => AlertDialog(
        title: Text(t.message.update.latest_version(version: release.version)),
        content: SizedBox(
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => LinearProgressIndicator(value: progress.value)),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  t.message.update.downloading(
                    percent: ((progress.value ?? 0) * 100).floor(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: cancel, child: Text(t.notifications.cancel)),
          TextButton(
            onPressed: () => SmartDialog.dismiss(tag: _dialogTag),
            child: Text(t.message.update.download_in_background),
          ),
        ],
      ),
    );
  }

  /// Compares "X.Y.Z" versions; a leading "v" is ignored.
  static int compareVersion(String a, String b) {
    List<String> numberA = a.replaceFirst('v', '').split('.');
    List<String> numberB = b.replaceFirst('v', '').split('.');

    if (numberA.length != numberB.length) {
      return 0;
    }

    for (int i = 0; i < numberA.length; i++) {
      int a = int.parse(numberA[i]);
      int b = int.parse(numberB[i]);
      if (a > b) {
        return 1;
      } else if (a < b) {
        return -1;
      }
    }

    return 0;
  }
}
