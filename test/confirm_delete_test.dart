import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/components/dialogs/confirm_delete.dart';
import 'package:iwrqk/i18n/strings.g.dart';

/// Opens the dialog and answers it with the button called [answer], or by
/// tapping outside it when [answer] is null.
Future<bool> ask(WidgetTester tester, String? answer) async {
  await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
  final result = confirmDelete('Delete this download?');
  await tester.pumpAndSettle();
  expect(find.text('Delete this download?'), findsOneWidget);
  if (answer == null) {
    await tester.tapAt(const Offset(5, 5));
  } else {
    await tester.tap(find.text(answer));
  }
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('goes ahead only when the delete button is tapped', (
    tester,
  ) async {
    expect(await ask(tester, t.records.delete), isTrue);
  });

  testWidgets('cancelling keeps everything', (tester) async {
    expect(await ask(tester, t.notifications.cancel), isFalse);
  });

  testWidgets('dismissing the dialog counts as cancelling', (tester) async {
    expect(await ask(tester, null), isFalse);
  });
}
