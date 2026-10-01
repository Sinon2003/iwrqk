import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
}
