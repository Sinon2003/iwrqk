import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/translation_engine_picker.dart';
import '../../../data/enums/translation_engine.dart';
import '../../../data/services/config_service.dart';

/// Chooses which engines are offered when long-pressing Translate. The
/// default engine stays enabled.
class TranslationEnginesDialog extends StatefulWidget {
  const TranslationEnginesDialog({super.key});

  @override
  State<TranslationEnginesDialog> createState() =>
      _TranslationEnginesDialogState();
}

class _TranslationEnginesDialogState extends State<TranslationEnginesDialog> {
  final ConfigService _configService = Get.find();
  late final Set<TranslationEngine> _enabled = {
    ..._configService.enabledTranslationEngines,
  };

  @override
  Widget build(BuildContext context) {
    final defaultEngine = _configService.translationEngine;

    return AlertDialog(
      title: Text(t.settings.enabled_translation_engines),
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
          children: TranslationEngine.values.map((engine) {
            final isDefault = engine == defaultEngine;
            return CheckboxListTile(
              value: isDefault || _enabled.contains(engine),
              onChanged: isDefault
                  ? null
                  : (bool? checked) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (checked == true) {
                          _enabled.add(engine);
                        } else {
                          _enabled.remove(engine);
                        }
                      });
                    },
              title: Row(
                children: [
                  Flexible(child: Text(engine.displayName)),
                  if (isDefault)
                    TranslationEngineTag(text: t.translation.default_tag),
                ],
              ),
              subtitle: Text(engine.note),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            t.notifications.cancel,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        TextButton(
          onPressed: () {
            _configService.enabledTranslationEngines = _enabled.toList();
            Get.back();
          },
          child: Text(t.notifications.confirm),
        ),
      ],
    );
  }
}
