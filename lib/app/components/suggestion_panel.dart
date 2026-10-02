import 'dart:math' as math;

import 'package:flutter/material.dart';

/// What a field suggests for what is typed in it, as a panel hanging from
/// the field: the options view of the field's `RawAutocomplete`.
///
/// The panel is as wide as the field and as high as its rows. Rows that do
/// not fit between the field and the keyboard are scrolled to.
class SuggestionPanel<T extends Object> extends StatefulWidget {
  const SuggestionPanel({
    super.key,
    required this.options,
    required this.itemBuilder,
    required this.onPick,
  });

  /// What is suggested. Another set of suggestions is shown from its top.
  final Iterable<T> options;

  /// What a suggestion looks like.
  final Widget Function(BuildContext context, T option) itemBuilder;

  /// Called with the suggestion that was tapped.
  final void Function(T option) onPick;

  @override
  State<SuggestionPanel<T>> createState() => _SuggestionPanelState<T>();
}

class _SuggestionPanelState<T extends Object> extends State<SuggestionPanel<T>>
    with WidgetsBindingObserver {
  /// How far the panel reaches up over the field. The lower corners of the
  /// field are round, and this way the two read as one box.
  static const double _overlap = 12;

  /// The space kept free under the panel.
  static const double _gap = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The keyboard coming or going changes the room under the field.
  @override
  void didChangeMetrics() => setState(() {});

  /// How much of the room given to the panel lies under the keyboard or the
  /// system's bar at the bottom.
  ///
  /// The framework ends the room above both, going by their sizes when the
  /// field was last built. The keyboard may have come up since without the
  /// field being built again, so the view is asked how things are now.
  double _covered(BuildContext context) {
    final view = MediaQueryData.fromView(View.of(context));
    final taken = math.max(view.viewInsets.bottom, view.viewPadding.bottom);
    final known =
        MediaQuery.paddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;
    return math.max(0.0, taken - known);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final options = widget.options;

    return Transform.translate(
      offset: const Offset(0, -_overlap),
      child: Padding(
        padding: EdgeInsets.only(bottom: _covered(context) + _gap - _overlap),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          color: colorScheme.secondaryContainer,
          clipBehavior: Clip.antiAlias,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            // The rows scroll on their own, and the page under them does not
            // hear of it. A page that puts the keyboard away when it is
            // dragged would take the focus from the field, and the
            // suggestions would go with it.
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => true,
              child: ListView.builder(
                key: ObjectKey(options),
                primary: false,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => widget.onPick(option),
                    child: widget.itemBuilder(context, option),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
