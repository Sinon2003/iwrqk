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
/// what to do with them. While it shows, the back key leaves selection mode
/// like its close button, and only the next press leaves the page.
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
    leading: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onClose();
      },
      child: IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close_outlined),
      ),
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

/// Dims a record's cover while the page is in selection mode and ticks the
/// selected ones. It fills the `Stack` it is placed in.
class CheckedOverlay extends StatelessWidget {
  const CheckedOverlay({
    super.key,
    required this.selecting,
    required this.checked,
  });

  final bool selecting;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: selecting ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black.withValues(
                alpha: selecting && checked ? 0.6 : 0,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 34,
                height: 34,
                child: AnimatedScale(
                  scale: checked ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color:
                          (theme.brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.black)
                              .withValues(alpha: 0.8),
                    ),
                    child: Icon(Icons.check, color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
