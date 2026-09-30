import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../components/translation_engine_picker.dart';
import '../../data/enums/translation_display_mode.dart';
import '../../data/enums/translation_engine.dart';
import '../../data/providers/storage_provider.dart';
import '../../data/services/update_service.dart';
import '../../utils/log_util.dart';
import '../../utils/quality_picker.dart';
import '../home/controller.dart';
import 'controller.dart';
import 'widgets/custom_color_page.dart';
import 'widgets/display_mode_dialog.dart';
import 'widgets/proxy_dialog.dart';
import 'widgets/translation_engines_dialog.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  Widget _buildMultiSetting<T>(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required T currentOption,
    required Map<T, String> options,
    required void Function(T) onSelected,
  }) {
    Rx<T> selected = currentOption.obs;

    return _buildButton(
      context,
      title: title,
      description: description,
      iconData: iconData,
      onPressed: () {
        Get.dialog(
          AlertDialog(
            title: Text(title),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            content: Container(
              width: Get.width * 0.8,
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                children: options.entries
                    .map(
                      (entry) => Obx(
                        () => RadioListTile<T>(
                          value: entry.key,
                          title: Text(entry.value),
                          groupValue: selected.value,
                          onChanged: (T? value) {
                            if (value != null) {
                              HapticFeedback.mediumImpact();
                              selected.value = value;
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  t.notifications.cancel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  onSelected(selected.value);
                  Get.back();
                },
                child: Text(t.notifications.confirm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required bool value,
    required void Function(bool) onChanged,
    bool restartRequired = false,
  }) {
    void onSwitch(bool value) {
      onChanged(value);
      if (restartRequired) {
        SmartDialog.showToast(t.message.restart_required);
      }
      HapticFeedback.mediumImpact();
    }

    return ListTile(
      enableFeedback: true,
      onTap: () {
        onSwitch(!value);
      },
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      leading: Icon(iconData, size: 28),
      trailing: Switch(value: value, onChanged: onSwitch),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required void Function() onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        leading: Icon(iconData, size: 28),
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    return _buildMultiSetting<ThemeMode>(
      context,
      title: t.settings.theme,
      description: t.settings.theme_desc,
      iconData: Icons.wb_sunny,
      currentOption: controller.getCurrentTheme(),
      options: {
        ThemeMode.system: t.theme.system,
        ThemeMode.light: t.theme.light,
        ThemeMode.dark: t.theme.dark,
      },
      onSelected: (value) {
        controller.setThemeMode(value);
      },
    );
  }

  Widget _buildDynamicColorSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.dynamic_color,
        description: t.settings.dynamic_color_desc,
        iconData: Icons.palette,
        value: controller.configService.enableDynamicColor,
        onChanged: (value) {
          controller.configService.enableDynamicColor = value;
        },
      ),
    );
  }

  Widget _buildCustomColorButton(BuildContext context) {
    return _buildButton(
      context,
      title: t.settings.custom_color,
      description: t.settings.custom_color_desc,
      iconData: Icons.colorize,
      onPressed: () {
        Get.to(() => const CustomColorPage());
      },
    );
  }

  Widget _buildWorkModeSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.work_mode,
        description: t.settings.work_mode_desc,
        iconData: Icons.work,
        value: controller.workMode,
        onChanged: (value) {
          controller.workMode = value;
        },
      ),
    );
  }

  Widget _buildAnimatedPreviewSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.animated_preview,
        description: t.settings.animated_preview_desc,
        iconData: Icons.smart_display,
        value: controller.enablePreview,
        onChanged: (value) {
          controller.enablePreview = value;
        },
      ),
    );
  }

  Widget _buildAcceleratedTransferSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.accelerated_transfer,
        description: t.settings.accelerated_transfer_desc,
        iconData: Icons.speed,
        value: controller.configService.acceleratedTransfer,
        onChanged: (value) {
          controller.configService.acceleratedTransfer = value;
        },
      ),
    );
  }

  Widget _buildPreferredQualitySetting(BuildContext context) {
    String optionName(String option) => switch (option) {
      QualityPicker.auto => t.settings.quality_auto,
      QualityPicker.highest => t.settings.quality_highest,
      QualityPicker.smoothest => t.settings.quality_smoothest,
      _ => t.settings.quality_fixed(name: option),
    };
    String optionDescription(String option) => switch (option) {
      QualityPicker.auto => t.settings.quality_auto_desc,
      QualityPicker.highest => t.settings.quality_highest_desc,
      QualityPicker.smoothest => t.settings.quality_smoothest_desc,
      _ => t.settings.quality_fixed_desc(name: option),
    };

    return Obx(
      () => _buildMultiSetting<String>(
        context,
        title: t.settings.preferred_quality,
        description: optionDescription(
          controller.configService.preferredQuality,
        ),
        iconData: Icons.high_quality,
        currentOption: controller.configService.preferredQuality,
        options: {
          for (final option in [
            QualityPicker.auto,
            QualityPicker.highest,
            QualityPicker.smoothest,
            ...QualityPicker.fixedChoices,
          ])
            option: optionName(option),
        },
        onSelected: (value) {
          controller.configService.preferredQuality = value;
        },
      ),
    );
  }

  Widget _buildAutoPlaySetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.autoplay,
        description: t.settings.autoplay_desc,
        iconData: Icons.play_circle,
        value: controller.autoPlay,
        onChanged: (value) {
          controller.autoPlay = value;
        },
      ),
    );
  }

  Widget _buildBackgroundPlaySetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.background_play,
        description: t.settings.background_play_desc,
        iconData: Icons.music_video,
        value: controller.backgroundPlay,
        onChanged: (value) {
          controller.backgroundPlay = value;
        },
      ),
    );
  }

  Widget _buildDiscordRichPresenceSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.discord_rich_presence,
        description: t.settings.discord_rich_presence_desc,
        iconData: Icons.games,
        value: controller.enableDiscordRichPresence,
        onChanged: (value) {
          controller.enableDiscordRichPresence = value;
        },
      ),
    );
  }

  Widget _buildDownloadPathSetting(BuildContext context) {
    return Obx(
      () => _buildButton(
        context,
        title: t.settings.download_path,
        description: controller.downloadPathText,
        iconData: Icons.download,
        onPressed: controller.changeDownloadPath,
      ),
    );
  }

  Widget _buildLoggingSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.enable_logging,
        description: t.settings.enable_logging_desc,
        iconData: Icons.assignment_late,
        value: controller.enableLogging,
        restartRequired: true,
        onChanged: (value) {
          controller.enableLogging = value;
        },
      ),
    );
  }

  Widget __buildClearLogsButton(BuildContext context) {
    return Obx(
      () => _buildButton(
        context,
        title: t.settings.clear_log,
        description: t.settings.clear_log_desc(size: controller.logSize),
        iconData: Icons.delete,
        onPressed: () {
          Get.dialog(
            AlertDialog(
              title: Text(t.settings.clear_log),
              content: Text(t.message.are_you_sure_to_do_that),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    t.notifications.cancel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearLogs();
                    Get.back();
                  },
                  child: Text(t.notifications.confirm),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerboseLoggingSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.enable_verbose_logging,
        description: t.settings.enable_verbose_logging_desc,
        iconData: Icons.description,
        value: controller.enableVerboseLogging,
        restartRequired: true,
        onChanged: (value) {
          controller.enableVerboseLogging = value;
        },
      ),
    );
  }

  Widget _buildMediaScanSetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.allow_media_scan,
        description: t.settings.allow_media_scan_desc,
        iconData: Icons.folder_open,
        value: controller.allowMediaScan,
        onChanged: (value) {
          controller.allowMediaScan = value;
          controller.downloadService.allowMediaScan(value);
        },
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    return _buildMultiSetting<String>(
      context,
      title: t.settings.language,
      description: t.settings.language_desc,
      iconData: Icons.translate,
      currentOption: controller.getCurrentLocalecode(),
      options: t.locales,
      onSelected: (value) {
        controller.setLanguage(AppLocaleUtils.parse(value));
      },
    );
  }

  Widget _buildTranslationEngineSetting(BuildContext context) {
    return Obx(
      () => _buildMultiSetting<TranslationEngine>(
        context,
        title: t.settings.default_translation_engine,
        description: t.settings.default_translation_engine_desc(
          engine: controller.configService.translationEngine.displayName,
        ),
        iconData: Icons.g_translate,
        currentOption: controller.configService.translationEngine,
        options: {
          for (final engine
              in controller.configService.enabledTranslationEngines)
            engine: engine.displayName,
        },
        onSelected: (value) {
          controller.configService.translationEngine = value;
        },
      ),
    );
  }

  Widget _buildEnabledTranslationEnginesSetting(BuildContext context) {
    return Obx(
      () => _buildButton(
        context,
        title: t.settings.enabled_translation_engines,
        description: t.settings.enabled_translation_engines_desc(
          engines: controller.configService.enabledTranslationEngines
              .map((engine) => engine.displayName)
              .join(" · "),
        ),
        iconData: Icons.checklist,
        onPressed: () {
          Get.dialog(const TranslationEnginesDialog());
        },
      ),
    );
  }

  Widget _buildTranslationDisplayModeSetting(BuildContext context) {
    String modeName(TranslationDisplayMode mode) => switch (mode) {
      TranslationDisplayMode.below => t.translation.display_modes.below,
      TranslationDisplayMode.replace => t.translation.display_modes.replace,
    };

    return Obx(
      () => _buildMultiSetting<TranslationDisplayMode>(
        context,
        title: t.settings.translation_display_mode,
        description: t.settings.translation_display_mode_desc(
          mode: modeName(controller.configService.translationDisplayMode),
        ),
        iconData: Icons.view_agenda,
        currentOption: controller.configService.translationDisplayMode,
        options: {
          for (final mode in TranslationDisplayMode.values)
            mode: modeName(mode),
        },
        onSelected: (value) {
          controller.configService.translationDisplayMode = value;
        },
      ),
    );
  }

  Widget _buildCheckUpdateButton(BuildContext context) {
    final UpdateService updateService = Get.find();
    return Obx(() {
      final progress = updateService.progress.value;
      return _buildButton(
        context,
        title: t.settings.check_update,
        description: progress == null
            ? t.settings.check_update_desc
            : t.message.update.downloading(percent: (progress * 100).floor()),
        iconData: Icons.system_update_alt,
        onPressed: controller.checkLatestVersion,
      );
    });
  }

  Widget _buildLicenseButton(BuildContext context) {
    return _buildButton(
      context,
      title: t.settings.third_party_license,
      description: t.settings.third_party_license,
      iconData: Icons.info,
      onPressed: () async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        showLicensePage(
          context: Get.context!,
          applicationName: "IwrQk",
          applicationVersion: currentVersion,
          applicationLegalese: "Iwara Quick!",
        );
      },
    );
  }

  Widget _buildDisplayModeButton(BuildContext context) {
    return _buildButton(
      context,
      title: t.settings.display_mode,
      description: t.settings.display_mode_desc,
      iconData: Icons.tv,
      onPressed: () {
        Get.dialog(const DisplayModeDialog());
      },
    );
  }

  Widget _buildEnableProxySetting(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.enable_proxy,
        description: t.settings.enable_proxy_desc,
        iconData: Icons.wifi,
        value: controller.enableProxy,
        restartRequired: true,
        onChanged: (value) {
          controller.enableProxy = value;
        },
      ),
    );
  }

  Widget _buildSetProxyButton(BuildContext context) {
    return _buildButton(
      context,
      title: t.settings.proxy,
      description: t.settings.proxy_desc,
      iconData: Icons.dns,
      onPressed: () {
        Get.dialog(ProxyDialog());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.user.settings)),
      body: ListView(
        children: [
          SettingTitle(title: t.settings.appearance),
          _buildThemeSetting(context),
          _buildDynamicColorSetting(context),
          Obx(
            () => Visibility(
              visible: !controller.configService.enableDynamicColor,
              child: _buildCustomColorButton(context),
            ),
          ),
          _buildLanguageSetting(context),
          if (GetPlatform.isAndroid) _buildDisplayModeButton(context),
          _buildWorkModeSetting(context),
          _buildAnimatedPreviewSetting(context),
          _buildSwitchToAISite(context),
          SettingTitle(title: t.settings.translation),
          _buildTranslationEngineSetting(context),
          _buildEnabledTranslationEnginesSetting(context),
          _buildTranslationDisplayModeSetting(context),
          SettingTitle(title: t.settings.network),
          _buildEnableProxySetting(context),
          _buildSetProxyButton(context),
          SettingTitle(title: t.settings.player),
          _buildPreferredQualitySetting(context),
          _buildAutoPlaySetting(context),
          _buildBackgroundPlaySetting(context),
          if (GetPlatform.isWindows || GetPlatform.isLinux)
            _buildDiscordRichPresenceSetting(context),
          SettingTitle(title: t.settings.download),
          _buildDownloadPathSetting(context),
          if (GetPlatform.isAndroid) _buildMediaScanSetting(context),
          SettingTitle(title: t.settings.experimental),
          _buildAcceleratedTransferSetting(context),
          SettingTitle(title: t.settings.logging),
          _buildLoggingSetting(context),
          __buildClearLogsButton(context),
          _buildVerboseLoggingSetting(context),
          SettingTitle(title: t.settings.about),
          _buildCheckUpdateButton(context),
          _buildLicenseButton(context),
        ],
      ),
    );
  }

  Widget _buildSwitchToAISite(BuildContext context) {
    return Obx(
      () => _buildSwitchSetting(
        context,
        title: t.settings.to_ai_site,
        description: t.settings.to_ai_site_desc,
        iconData: Icons.smart_toy_rounded,
        onChanged: (value) {
          SettingsController.switchToAiSite.value = value;
          StorageProvider.config[StorageKey.toAiSite] = value;
          // Refresh all home page tabs when switching AI site
          _refreshHomePageTabs();
        },
        value: SettingsController.switchToAiSite.value,
      ),
    );
  }

  Future<void> _refreshHomePageTabs() async {
    try {
      // Get HomeController if it exists
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();

        // Refresh all media grid tab controllers (Videos, Images, Subscriptions)
        for (var mediaController in homeController.mediaGridTabControllers) {
          mediaController.refreshCurrentTab();
        }

        // Refresh forum tab controller
        homeController.forumTabController.refreshData(showSplash: false);
      }
    } catch (e) {
      LogUtil.error('Failed to refresh home page tabs', e);
    }
  }
}

class SettingTitle extends StatelessWidget {
  final String title;

  const SettingTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
