import 'package:animations/animations.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/modules/settings/controller.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../components/load_empty.dart';
import 'controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchController _controller = Get.put(SearchController());

  Widget _buildHistoryClip(BuildContext context, int index) {
    String keyword = _controller.searchHistoryList[index].keyword;
    bool editing = _controller.editingHistory;

    // The delete button sits in the padding: taps outside a Stack's bounds
    // are not delivered, so it must not stick out of this widget.
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: InkWell(
              onTap: () {
                if (editing) {
                  _controller.stopEditingHistory();
                  return;
                }
                String currentText = _controller.searchEditingController.text;
                _controller.searchEditingController.text = keyword;
                currentText = _controller.searchEditingController.text;
                _controller.showSearchSuffix = true;
                _controller.searchFocusNode.requestFocus();
                _controller.searchEditingController.selection =
                    TextSelection.fromPosition(
                      TextPosition(offset: currentText.length),
                    );
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _controller.startEditingHistory();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (editing)
          Positioned(
            top: 0,
            right: 0,
            child: _buildDeleteButton(context, keyword),
          ),
      ],
    );
  }

  /// The badge sits on the item's top-right corner; the touch area is larger
  /// than the badge and reaches into the item.
  Widget _buildDeleteButton(BuildContext context, String keyword) {
    return Tooltip(
      message: t.records.delete,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          _controller.deleteSearchHistoryItem(keyword);
        },
        child: SizedBox(
          width: 28,
          height: 28,
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        titleSpacing: 0,
        actions: [
          Hero(
            tag: 'searchTag',
            child: IconButton(
              onPressed: _controller.submit,
              icon: const Icon(Icons.search, size: 22),
            ),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          focusNode: _controller.searchFocusNode,
          controller: _controller.searchEditingController,
          textInputAction: TextInputAction.search,
          onTap: _controller.stopEditingHistory,
          onChanged: _controller.onSearchTextChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                size: 22,
                color: Theme.of(context).colorScheme.outline,
              ),
              onPressed: _controller.clearSearchText,
            ),
          ),
          onSubmitted: (_) => _controller.submit(),
        ),
      ),
      body: Obx(
        () => PopScope(
          // While editing, the back key only leaves the editing mode.
          canPop: !_controller.editingHistory,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _controller.stopEditingHistory();
          },
          child: GestureDetector(
            // Tapping a blank area leaves the editing mode.
            onTap: _controller.editingHistory
                ? _controller.stopEditingHistory
                : null,
            child: _buildHistoryList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: false,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          // As tall as a TextButton's touch target, so the items do not move
          // when the Done button appears.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.user.history,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.searchHistoryList.length >
                        _controller.maxExpandedClipsCount)
                      TextButton(
                        onPressed: _controller.toggleClipsExpanded,
                        child: Text(
                          _controller.clipsExpanded
                              ? t.common.collapse
                              : t.common.expand,
                        ),
                      ),
                    if (_controller.editingHistory)
                      TextButton(
                        onPressed: _controller.stopEditingHistory,
                        child: Text(t.search.history.done),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_controller.searchHistoryList.isNotEmpty)
          Wrap(
            children: List.generate(
              _controller.clipsExpanded
                  ? _controller.searchHistoryList.length
                  : _controller.maxExpandedClipsCount,
              (index) => _buildHistoryClip(context, index),
            ),
          ),
        if (_controller.searchHistoryList.isEmpty)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const LoadEmpty(),
          )
        else
          TextButton.icon(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text(t.search.history.delete),
                  content: Text(t.message.are_you_sure_to_do_that),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        t.notifications.cancel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _controller.clearSearchHistoryList();
                        Get.back();
                      },
                      child: Text(t.notifications.confirm),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(t.search.history.delete),
          ),
        SizedBox(height: Get.height * 0.1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      onClosed: (_) => _controller.stopEditingHistory(),
      closedElevation: 0,
      openElevation: 0,
      openColor: Theme.of(context).colorScheme.surface,
      middleColor: Theme.of(context).colorScheme.surface,
      closedColor: Theme.of(context).colorScheme.surface,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      closedBuilder: (context, action) {
        return SizedBox(
          height: 44,
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.onInverseSurface.withAlpha(255),
            child: InkWell(
              splashColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              onTap: action,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => Text(
                        SettingsController.switchToAiSite.value
                            ? '${t.nav.search} (AI)'
                            : t.nav.search,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
      openBuilder: (context, action) => _buildHistoryPage(),
    );
  }
}
