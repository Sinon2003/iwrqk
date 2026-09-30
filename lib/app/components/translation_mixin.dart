import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../data/enums/translation_display_mode.dart';
import '../data/enums/translation_engine.dart';
import '../data/providers/translate_provider.dart';
import '../data/services/config_service.dart';
import 'translation_engine_picker.dart';

/// Translation state for a widget showing user content: results are cached
/// per engine, and a shown translation can be collapsed and expanded again.
/// The display setting decides whether it goes below the original or in its
/// place.
mixin TranslationMixin<T extends StatefulWidget> on State<T> {
  final ConfigService _configService = Get.find();
  final Map<TranslationEngine, String> _translations = {};

  /// Engine of the translation being shown; null before the first one.
  TranslationEngine? translationEngine;
  bool translationVisible = false;
  bool translating = false;

  String? get translatedContent => _translations[translationEngine];
  bool get hasTranslation => translatedContent != null;
  bool get canChooseTranslationEngine =>
      _configService.enabledTranslationEngines.length > 1;

  bool get _replacesOriginal =>
      _configService.translationDisplayMode == TranslationDisplayMode.replace;

  /// Whether the translation is shown in place of the original.
  bool get showTranslationInPlace =>
      hasTranslation && translationVisible && _replacesOriginal;

  /// Whether the translation is shown below the original.
  bool get showTranslationBelow =>
      hasTranslation && translationVisible && !_replacesOriginal;

  /// Label for the action that translates, collapses or expands.
  String get translationActionLabel {
    if (translating) return t.translation.translating;
    if (!hasTranslation) return t.common.translate;
    if (!translationVisible) return t.translation.show;
    return _replacesOriginal ? t.translation.show_original : t.translation.hide;
  }

  /// Shows the translation from [engine], or the default engine, fetching it
  /// only when it is not cached yet.
  Future<void> translate(String text, {TranslationEngine? engine}) async {
    final selected = engine ?? _configService.translationEngine;
    if (_translations.containsKey(selected)) {
      setState(() {
        translationEngine = selected;
        translationVisible = true;
      });
      return;
    }
    if (translating) return;

    setState(() => translating = true);
    final result = await TranslateProvider.translate(
      text: text,
      engine: selected,
    );
    if (!mounted) return;

    setState(() {
      translating = false;
      if (result.success) {
        _translations[selected] = result.data!;
        translationEngine = selected;
        translationVisible = true;
      }
    });
    if (!result.success) {
      SmartDialog.showToast(t.translation.failed(engine: selected.displayName));
    }
  }

  /// Translates on first use, then collapses or expands the translation.
  void toggleTranslation(String text) {
    if (hasTranslation) {
      setState(() => translationVisible = !translationVisible);
    } else {
      translate(text);
    }
  }

  void hideTranslation() {
    setState(() => translationVisible = false);
  }

  Future<void> chooseEngineAndTranslate(String text) async {
    final engine = await showTranslationEnginePicker(
      context,
      current: translationEngine,
    );
    if (engine != null && mounted) {
      translate(text, engine: engine);
    }
  }
}
