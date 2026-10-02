import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/components/suggestion_panel.dart';

/// A page as the app has them: a field with suggestions at the top of a
/// scroll view that puts the keyboard away when it is dragged.
///
/// What is typed is suggested back with a number after it, [count] times.
class _Page extends StatelessWidget {
  const _Page({
    required this.focusNode,
    required this.controller,
    this.count = 40,
    this.safeArea = false,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final int count;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final Widget body = CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: RawAutocomplete<String>(
              focusNode: focusNode,
              textEditingController: controller,
              optionsBuilder: (value) => [
                if (value.text.isNotEmpty)
                  for (var i = 0; i < count; i++) '${value.text} $i',
              ],
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) =>
                      TextField(controller: controller, focusNode: focusNode),
              optionsViewBuilder: (context, onSelected, options) =>
                  SuggestionPanel<String>(
                    options: options,
                    itemBuilder: (context, option) =>
                        ListTile(title: Text(option)),
                    onPick: onSelected,
                  ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: 50,
          itemBuilder: (context, index) => ListTile(title: Text('row $index')),
        ),
      ],
    );

    return MaterialApp(
      home: Scaffold(body: safeArea ? SafeArea(child: body) : body),
    );
  }
}

void main() {
  late FocusNode focusNode;
  late TextEditingController controller;

  setUp(() {
    focusNode = FocusNode();
    controller = TextEditingController();
  });

  tearDown(() {
    focusNode.dispose();
    controller.dispose();
  });

  final panel = find.byType(SuggestionPanel<String>);
  final box = find.descendant(of: panel, matching: find.byType(Card));

  /// A phone held upright, where one pixel is one unit of layout.
  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  ScrollPosition rows(WidgetTester tester) => tester
      .state<ScrollableState>(
        find.descendant(of: panel, matching: find.byType(Scrollable)),
      )
      .position;

  testWidgets('its rows scroll and the page keeps the field in focus', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(
      _Page(focusNode: focusNode, controller: controller),
    );
    await type(tester, 'a');
    expect(find.text('a 0'), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);

    await tester.drag(find.text('a 3'), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Dragging the page would have taken the focus, and the suggestions with
    // it.
    expect(focusNode.hasFocus, isTrue);
    expect(panel, findsOneWidget);
    expect(rows(tester).pixels, greaterThan(0));
  });

  testWidgets('dragging the page under it still puts the keyboard away', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(
      _Page(focusNode: focusNode, controller: controller, count: 2),
    );
    await type(tester, 'a');
    expect(focusNode.hasFocus, isTrue);

    await tester.drag(find.text('row 6'), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(focusNode.hasFocus, isFalse);
    expect(panel, findsNothing);
  });

  testWidgets('another set of suggestions is shown from its top', (
    tester,
  ) async {
    usePhone(tester);
    await tester.pumpWidget(
      _Page(focusNode: focusNode, controller: controller),
    );
    await type(tester, 'a');
    await tester.drag(find.text('a 3'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(rows(tester).pixels, greaterThan(0));

    await tester.enterText(find.byType(TextField), 'ab');
    await tester.pumpAndSettle();

    expect(rows(tester).pixels, 0);
    expect(find.text('ab 0').hitTestable(), findsOneWidget);
  });

  testWidgets('it is as high as its rows when they fit', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      _Page(focusNode: focusNode, controller: controller, count: 2),
    );
    await type(tester, 'a');

    final last = find.ancestor(
      of: find.text('a 1'),
      matching: find.byType(ListTile),
    );
    expect(tester.getRect(box).bottom, tester.getRect(last).bottom);
    expect(rows(tester).maxScrollExtent, 0);
  });

  testWidgets('it ends above the keyboard and follows it', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      _Page(focusNode: focusNode, controller: controller),
    );
    await type(tester, 'a');
    expect(tester.getRect(box).bottom, 800 - 16);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.getRect(box).bottom, 800 - 300 - 16);

    tester.view.resetViewInsets();
    await tester.pump();
    expect(tester.getRect(box).bottom, 800 - 16);
  });

  for (final safeArea in [false, true]) {
    testWidgets('it ends above the bar of the system (safe area: $safeArea)', (
      tester,
    ) async {
      usePhone(tester);
      tester.view.padding = const FakeViewPadding(bottom: 24);
      tester.view.viewPadding = const FakeViewPadding(bottom: 24);
      await tester.pumpWidget(
        _Page(focusNode: focusNode, controller: controller, safeArea: safeArea),
      );
      await type(tester, 'a');
      expect(tester.getRect(box).bottom, 800 - 24 - 16);

      // With the keyboard up the bar is behind it.
      tester.view.padding = FakeViewPadding.zero;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      expect(tester.getRect(box).bottom, 800 - 300 - 16);
    });
  }

  testWidgets('a tapped suggestion is picked', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      _Page(focusNode: focusNode, controller: controller),
    );
    await type(tester, 'a');

    await tester.tap(find.text('a 2'));
    await tester.pumpAndSettle();

    expect(controller.text, 'a 2');
  });
}
