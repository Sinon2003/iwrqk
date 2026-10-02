import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/components/app_bar_switcher.dart';
import 'package:iwrqk/app/components/multiple_selection.dart';

class _Page extends GetxController with MultipleSelection {}

void main() {
  test('ticks and unticks a record', () {
    final page = _Page();
    page.toggleChecked('a');
    expect(page.checked, {'a'});
    expect(page.checkedCount, 1);
    page.toggleChecked('a');
    expect(page.checked, isEmpty);
  });

  test('inverts only the records it is given', () {
    final page = _Page();
    page
      ..toggleChecked('shown-1')
      ..toggleChecked('other-tab');
    page.invertChecked(['shown-1', 'shown-2', 'shown-3']);
    // What another tab shows stays as it was.
    expect(page.checked, {'other-tab', 'shown-2', 'shown-3'});
    page.invertChecked(['shown-1', 'shown-2', 'shown-3']);
    expect(page.checked, {'other-tab', 'shown-1'});
  });

  test('leaving selection mode clears the ticks', () {
    final page = _Page()
      ..enableMultipleSelection = true
      ..toggleChecked('a');
    page.exitMultipleSelection();
    expect(page.enableMultipleSelection, isFalse);
    expect(page.checkedCount, 0);
  });

  test('tells listeners about every change', () {
    final page = _Page();
    final counts = <int>[];
    final watch = page.checked.listen((ids) => counts.add(ids.length));
    page.toggleChecked('a');
    page.invertChecked(['a', 'b', 'c']);
    page.exitMultipleSelection();
    watch.cancel();
    expect(counts.last, 0);
    expect(counts, contains(1));
    expect(counts, contains(2));
  });

  testWidgets('the back key leaves selection mode before the page', (
    tester,
  ) async {
    final page = _Page();
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: Text('home')),
        routes: {
          '/records': (context) => Obx(
            () => Scaffold(
              appBar: AppBarSwitcher(
                visible: page.enableMultipleSelection,
                primary: AppBar(title: const Text('records')),
                secondary: selectionAppBar(
                  context,
                  count: page.checkedCount,
                  onClose: page.exitMultipleSelection,
                  onInvert: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        },
      ),
    );
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/records');
    await tester.pumpAndSettle();

    page
      ..enableMultipleSelection = true
      ..toggleChecked('a');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(page.enableMultipleSelection, isFalse);
    expect(page.checked, isEmpty);
    expect(find.text('records'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets(
    'the cover overlay ticks ticked records, in selection mode only',
    (tester) async {
      var taps = 0;
      Future<void> pumpRow({required bool selecting, required bool checked}) {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InkWell(
                onTap: () => taps++,
                child: SizedBox(
                  width: 160,
                  height: 90,
                  child: Stack(
                    children: [
                      CheckedOverlay(selecting: selecting, checked: checked),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      double shown() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
      double tick() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      await pumpRow(selecting: false, checked: true);
      expect(shown(), 0);

      await pumpRow(selecting: true, checked: false);
      await tester.pumpAndSettle();
      expect(shown(), 1);
      expect(tick(), 0);

      await pumpRow(selecting: true, checked: true);
      await tester.pumpAndSettle();
      expect(tick(), 1);

      // The row under it still gets the tap that ticks or unticks.
      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    },
  );
}
