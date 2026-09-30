import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/components/translated_content.dart';
import 'package:iwrqk/app/data/enums/translation_engine.dart';
import 'package:iwrqk/i18n/strings.g.dart';

Future<void> pumpContent(WidgetTester tester, TranslatedContent content) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: content)),
    ),
  );
}

void main() {
  testWidgets('below the original: collapses with an icon button', (
    tester,
  ) async {
    var collapsed = false;
    await pumpContent(
      tester,
      TranslatedContent(
        translatedContent: 'Hello',
        engine: TranslationEngine.google,
        onCollapse: () => collapsed = true,
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text(t.translation.show_original), findsNothing);
    await tester.tap(find.byTooltip(t.translation.hide));
    expect(collapsed, isTrue);
  });

  testWidgets('in place: offers to show the original', (tester) async {
    var collapsed = false;
    await pumpContent(
      tester,
      TranslatedContent(
        translatedContent: 'Hello',
        engine: TranslationEngine.google,
        onCollapse: () => collapsed = true,
        inPlace: true,
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.byTooltip(t.translation.hide), findsNothing);
    await tester.tap(find.text(t.translation.show_original));
    expect(collapsed, isTrue);
  });
}
