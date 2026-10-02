import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../const/widget.dart';
import '../../utils/quality_picker.dart';
import '../../utils/playback_cache.dart';
import '../../utils/playback_bandwidth.dart';
import '../enums/translation_display_mode.dart';
import '../enums/translation_engine.dart';
import '../models/account/settings/filter_setting.dart';
import '../providers/storage_provider.dart';

abstract class DynamicConfigKey {
  static const String firstRun = "firstRun";

  static const String themeMode = "themeMode";
  static const String enableDynamicColor = "enableDynamicColor";
  static const String customColor = "customColor";

  static const String workMode = "workMode";
}

abstract class ConfigKey {
  static const String localeCode = "localeCode";

  static const String displayMode = "displayMode";

  static const String playerSetting = "playerSetting";

  static const String notificationPlayer = "notificationPlayer";

  static const String enablePreview = "enablePreview";

  static const String enableDiscordRichPresence = "enableDiscordRichPresence";

  static const String translationEngine = "translationEngine";
  static const String enabledTranslationEngines = "enabledTranslationEngines";
  static const String translationDisplayMode = "translationDisplayMode";

  static const String acceleratedTransfer = "acceleratedTransfer";

  static const String preferredQuality = "preferredQuality";
  static const String playbackThroughput = "playbackThroughput";
  static const String playbackBandwidth = "playbackBandwidth";
  static const String playbackPreload = "playbackPreload";
}

class ConfigService extends GetxService {
  final GStorageConfig setting = StorageProvider.config;

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;
  set themeMode(ThemeMode themeMode) {
    _themeMode.value = themeMode;
    Get.changeThemeMode(themeMode);
    setting[DynamicConfigKey.themeMode] = themeMode.index;
  }

  final RxBool _enableDynamicColor = false.obs;
  bool get enableDynamicColor => _enableDynamicColor.value;
  set enableDynamicColor(bool value) {
    _enableDynamicColor.value = value;
    setting[DynamicConfigKey.enableDynamicColor] = value;
  }

  final RxInt _customColor = 0.obs;
  int get customColor => _customColor.value;
  set customColor(int value) {
    _customColor.value = value;
    setting[DynamicConfigKey.customColor] = value;
  }

  final RxBool _workMode = false.obs;
  bool get workMode => _workMode.value;
  set workMode(bool workMode) {
    _workMode.value = workMode;
    setting[DynamicConfigKey.workMode] = workMode;
  }

  final RxBool _enablePreview = true.obs;
  bool get enablePreview => _enablePreview.value;
  set enablePreview(bool value) {
    _enablePreview.value = value;
    setting[ConfigKey.enablePreview] = value;
  }

  final Rx<TranslationEngine> _translationEngine = TranslationEngine.google.obs;
  TranslationEngine get translationEngine => _translationEngine.value;
  set translationEngine(TranslationEngine engine) {
    _translationEngine.value = engine;
    setting[ConfigKey.translationEngine] = engine.name;
    // The default engine is always enabled.
    if (!_enabledTranslationEngines.contains(engine)) {
      enabledTranslationEngines = [..._enabledTranslationEngines, engine];
    }
  }

  final RxList<TranslationEngine> _enabledTranslationEngines = TranslationEngine
      .values
      .toList()
      .obs;
  List<TranslationEngine> get enabledTranslationEngines =>
      _enabledTranslationEngines;
  set enabledTranslationEngines(List<TranslationEngine> engines) {
    final enabled = {...engines, translationEngine};
    _enabledTranslationEngines.value = TranslationEngine.values
        .where(enabled.contains)
        .toList();
    setting[ConfigKey.enabledTranslationEngines] = _enabledTranslationEngines
        .map((engine) => engine.name)
        .toList();
  }

  final Rx<TranslationDisplayMode> _translationDisplayMode =
      TranslationDisplayMode.replace.obs;
  TranslationDisplayMode get translationDisplayMode =>
      _translationDisplayMode.value;
  set translationDisplayMode(TranslationDisplayMode mode) {
    _translationDisplayMode.value = mode;
    setting[ConfigKey.translationDisplayMode] = mode.name;
  }

  /// Experimental: plays and downloads videos through a local proxy that
  /// uses parallel ranges only when a throughput trial shows a benefit.
  final RxBool _acceleratedTransfer = false.obs;
  bool get acceleratedTransfer => _acceleratedTransfer.value;
  set acceleratedTransfer(bool value) {
    _acceleratedTransfer.value = value;
    setting[ConfigKey.acceleratedTransfer] = value;
  }

  /// Which resolution to play; see [QualityPicker] for the values.
  final RxString _preferredQuality = QualityPicker.auto.obs;
  String get preferredQuality => _preferredQuality.value;
  set preferredQuality(String value) {
    _preferredQuality.value = value;
    setting[ConfigKey.preferredQuality] = value;
  }

  PlaybackBandwidth _playbackBandwidth = PlaybackBandwidth();
  final Rx<PlaybackPreload> _playbackPreload = PlaybackPreload.seconds30.obs;
  PlaybackPreload get playbackPreload => _playbackPreload.value;
  set playbackPreload(PlaybackPreload value) {
    _playbackPreload.value = value;
    setting[ConfigKey.playbackPreload] = value.name;
  }

  double? playbackSpeedFor(String url) =>
      _playbackBandwidth.speedFor(url, accelerated: acceleratedTransfer);

  void recordPlaybackSpeed(
    String url,
    double bytesPerSecond, {
    required bool accelerated,
  }) {
    _playbackBandwidth.record(url, bytesPerSecond, accelerated: accelerated);
    setting[ConfigKey.playbackBandwidth] = _playbackBandwidth.toJson();
  }

  void recordPlaybackStall(
    String url,
    String resolution, {
    required bool accelerated,
    double? sourceBitrate,
  }) {
    _playbackBandwidth.stall(
      url,
      resolution,
      accelerated: accelerated,
      sourceBitrate: sourceBitrate,
    );
    setting[ConfigKey.playbackBandwidth] = _playbackBandwidth.toJson();
  }

  final RxDouble _gridChildAspectRatio = 1.0.obs;
  double get gridChildAspectRatio => _gridChildAspectRatio.value;
  set gridChildAspectRatio(double gridChildAspectRatio) {
    _gridChildAspectRatio.value = gridChildAspectRatio;
  }

  final Rx<FilterSettingModel> _filterSetting = FilterSettingModel().obs;
  FilterSettingModel get filterSetting => _filterSetting.value;
  set filterSetting(FilterSettingModel filterSetting) {
    _filterSetting.value = filterSetting;
  }

  int crossAxisCount = 2;

  void calculateGridChildAspectRatio(Size size, Orientation orientation) {
    int number = size.width / WidgetConst.mediaPreviewPerferedWidth ~/ 1;

    if (orientation == Orientation.landscape) {
      number = size.width / WidgetConst.mediaPreviewPerferedWidth ~/ 1;
    } else {
      number = 2;
    }

    if (number <= 0) return;

    var width = (size.width - (number + 1) * 8) / number;
    var height =
        width * 9 / 16 +
        WidgetConst.mediaPreviewTitleHeight * Get.textScaleFactor;

    gridChildAspectRatio = width / height;
    crossAxisCount = number;
  }

  void setLocale(AppLocale locale) {
    LocaleSettings.setLocale(locale);
    setting[ConfigKey.localeCode] = locale.languageTag;
  }

  void resetEasyRefresh() {
    EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
      dragText: t.refresh.drag_to_load,
      armedText: t.refresh.release_to_load,
      readyText: t.notifications.loading,
      processingText: t.notifications.loading,
      processedText: t.refresh.success,
      noMoreText: t.refresh.no_more,
      failedText: t.refresh.failed,
      messageText: t.refresh.last_load,
    );
  }

  @override
  void onInit() {
    super.onInit();

    _enableDynamicColor.value = setting.get(
      DynamicConfigKey.enableDynamicColor,
      defaultValue: true,
    );
    _customColor.value = setting.get(
      DynamicConfigKey.customColor,
      defaultValue: 10,
    );
    _themeMode.value = ThemeMode
        .values[setting.get(DynamicConfigKey.themeMode, defaultValue: 0)];

    _workMode.value = setting.get(
      DynamicConfigKey.workMode,
      defaultValue: false,
    );

    _enablePreview.value = setting.get(
      ConfigKey.enablePreview,
      defaultValue: true,
    );

    _translationEngine.value =
        TranslationEngine.fromName(setting.get(ConfigKey.translationEngine)) ??
        TranslationEngine.google;
    final List? enabledEngineNames = setting.get(
      ConfigKey.enabledTranslationEngines,
    );
    if (enabledEngineNames != null) {
      final enabled = {
        ...enabledEngineNames
            .map((name) => TranslationEngine.fromName(name as String?))
            .whereType<TranslationEngine>(),
        _translationEngine.value,
      };
      _enabledTranslationEngines.value = TranslationEngine.values
          .where(enabled.contains)
          .toList();
    }
    _translationDisplayMode.value =
        TranslationDisplayMode.fromName(
          setting.get(ConfigKey.translationDisplayMode),
        ) ??
        TranslationDisplayMode.replace;

    _acceleratedTransfer.value = setting.get(
      ConfigKey.acceleratedTransfer,
      defaultValue: false,
    );

    _preferredQuality.value = setting.get(
      ConfigKey.preferredQuality,
      defaultValue: QualityPicker.auto,
    );
    _playbackBandwidth = PlaybackBandwidth.fromJson(
      setting.get(ConfigKey.playbackBandwidth),
    );
    _playbackPreload.value = PlaybackPreload.fromSetting(
      setting.get(ConfigKey.playbackPreload),
    );
  }
}
