import 'package:flutter/material.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../data/enums/translation_engine.dart';
import 'iwr_markdown.dart';
import 'translation_engine_picker.dart';

class TranslatedContent extends StatelessWidget {
  final String translatedContent;
  final TranslationEngine engine;

  /// Shows a button in the header when set: collapse below the original, or
  /// show the original again when [inPlace].
  final VoidCallback? onCollapse;

  /// Shown in place of the original instead of below it.
  final bool inPlace;
  final bool selectable;

  const TranslatedContent({
    super.key,
    required this.translatedContent,
    required this.engine,
    this.onCollapse,
    this.inPlace = false,
    this.selectable = true,
  });

  Widget _buildCollapseButton(BuildContext context) {
    if (inPlace) {
      return TextButton(
        onPressed: onCollapse,
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        child: Text(t.translation.show_original),
      );
    }
    return IconButton(
      onPressed: onCollapse,
      tooltip: t.translation.hide,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.expand_less,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!inPlace) const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.translate,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: t.translation.powered_by,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: engine.displayName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onCollapse != null) _buildCollapseButton(context),
          ],
        ),
        const Divider(),
        SizedBox(
          width: double.infinity,
          child: IwrMarkdown(selectable: selectable, data: translatedContent),
        ),
      ],
    );
  }
}
