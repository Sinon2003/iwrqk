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

import '../../utils/log_util.dart';
import '../../utils/path_util.dart';
import '../models/app_release.dart';
import '../providers/config_provider.dart';

/// Updates the app from this project's releases without leaving it: the APK
/// for this device downloads in the app, then the system installer opens to
/// install it over the current version.
class UpdateService extends GetxService with WidgetsBindingObserver {
  static const _dialogTag = "update";

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

  /// Looks for a newer release and, when there is one, starts updating.
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
    _release = release;
    await _download(asset);
  }

  /// Stops a download in progress.
  void cancel() {
    _cancelToken?.cancel();
  }

  /// The APK built for this device's processor, or the universal one.
  Future<AppReleaseAsset?> _assetForDevice(AppRelease release) async {
    final abis = Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).supportedAbis
        : <String>[];
    for (final abi in [...abis, "universal"]) {
      for (final asset in release.assets) {
        if (asset.name == "iwrqk-${release.version}-$abi.apk") return asset;
      }
    }
    return null;
  }

  Future<void> _download(AppReleaseAsset asset) async {
    final file = File("${PathUtil.tempDir.path}/updates/${asset.name}");
    // A finished download of this version needs no second one.
    if (await file.exists() && await file.length() == asset.size) {
      await _install(file.path);
      return;
    }
    final partial = File("${file.path}.part");
    await partial.parent.create(recursive: true);

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

  void _showProgress() {
    final release = _release;
    if (release == null) return;
    final changelog = release.changelog(
      chinese: LocaleSettings.currentLocale.languageCode == "zh",
    );
    SmartDialog.show(
      tag: _dialogTag,
      clickMaskDismiss: false,
      builder: (context) => AlertDialog(
        title: Text(t.message.update.update_available),
        content: SizedBox(
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.message.update.current_version(version: _currentVersion)),
              Text(t.message.update.latest_version(version: release.version)),
              const SizedBox(height: 16),
              Obx(() => LinearProgressIndicator(value: progress.value)),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  t.message.update.downloading(
                    percent: ((progress.value ?? 0) * 100).floor(),
                  ),
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
