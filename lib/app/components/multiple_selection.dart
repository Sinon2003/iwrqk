import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

/// Multiple selection for a page that lists records: whether the page is in
/// selection mode, and which records are ticked, by id.
mixin MultipleSelection on GetxController {
  final RxBool _enableMultipleSelection = false.obs;
  bool get enableMultipleSelection => _enableMultipleSelection.value;
  set enableMultipleSelection(bool value) =>
      _enableMultipleSelection.value = value;

  /// Lists read this inside an `Obx`, so ticking a record redraws it.
  final RxSet<String> checked = <String>{}.obs;
  int get checkedCount => checked.length;

  void toggleChecked(String id) {
    if (!checked.remove(id)) checked.add(id);
  }

  /// Ticks the [ids] that were not ticked and unticks the ones that were.
  /// Records outside [ids], such as those on another tab, keep their state.
  void invertChecked(Iterable<String> ids) {
    final shown = ids.toSet();
    final ticked = shown.intersection(checked);
    checked
      ..removeAll(ticked)
      ..addAll(shown.difference(ticked));
  }

  void exitMultipleSelection() {
    enableMultipleSelection = false;
    checked.clear();
  }
}

/// The app bar of a page in selection mode: how many records are ticked, and
/// what to do with them.
AppBar selectionAppBar(
  BuildContext context, {
  required int count,
  required VoidCallback onClose,
  required VoidCallback onInvert,
  required VoidCallback onDelete,
}) {
  return AppBar(
    titleSpacing: 0,
    centerTitle: false,
    leading: IconButton(
      onPressed: onClose,
      icon: const Icon(Icons.close_outlined),
    ),
    title: Text(
      t.records.selected_num(num: count),
      style: Theme.of(context).textTheme.titleMedium,
    ),
    actions: [
      TextButton(onPressed: onInvert, child: Text(t.records.select_inverse)),
      TextButton(
        // Nothing ticked, nothing to delete.
        onPressed: count == 0 ? null : onDelete,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        child: Text(t.records.delete),
      ),
      const SizedBox(width: 6),
    ],
  );
}
