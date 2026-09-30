import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../data/enums/translation_engine.dart';
import '../data/services/config_service.dart';

extension TranslationEngineText on TranslationEngine {
  String get displayName => switch (this) {
    TranslationEngine.google => t.translation.engines.google,
    TranslationEngine.volcengine => t.translation.engines.volcengine,
    TranslationEngine.tencent => t.translation.engines.tencent,
    TranslationEngine.yandex => t.translation.engines.yandex,
  };

  String get note => switch (this) {
    TranslationEngine.google => t.translation.engine_notes.google,
    TranslationEngine.volcengine => t.translation.engine_notes.volcengine,
    TranslationEngine.tencent => t.translation.engine_notes.tencent,
    TranslationEngine.yandex => t.translation.engine_notes.yandex,
  };
}

class TranslationEngineTag extends StatelessWidget {
  final String text;

  const TranslationEngineTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Lets the user pick one of the enabled engines. [current] is the engine of
/// the translation already shown, if any.
Future<TranslationEngine?> showTranslationEnginePicker(
  BuildContext context, {
  TranslationEngine? current,
}) {
  final ConfigService configService = Get.find();

  return showModalBottomSheet<TranslationEngine>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              t.translation.choose_engine,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final engine in configService.enabledTranslationEngines)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Row(
                children: [
                  Flexible(child: Text(engine.displayName)),
                  if (engine == configService.translationEngine)
                    TranslationEngineTag(text: t.translation.default_tag),
                ],
              ),
              subtitle: Text(engine.note),
              trailing: engine == current
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(engine),
            ),
        ],
      ),
    ),
  );
}
