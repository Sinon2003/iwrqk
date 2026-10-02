import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/app_bar_switcher.dart';
import '../../../components/multiple_selection.dart';
import '../../../data/enums/types.dart';
import 'controller.dart';
import 'history_search/page.dart';
import 'widgets/history_media_preview_list/widget.dart';
import 'widgets/site_history_list/widget.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  /// The title says whose history is showing and opens the choice between
  /// the two. It needs no room of its own next to the buttons, and the menu
  /// has space to say what each one is.
  Widget _buildSourceTitle(BuildContext context) {
    final theme = Theme.of(context);
    final sources = [
      (
        index: HistoryController.cloudTab,
        icon: Icons.cloud_outlined,
        title: t.records.cloud_history_title,
        label: t.records.cloud_history,
        description: t.records.cloud_history_desc,
      ),
      (
        index: HistoryController.localTab,
        icon: Icons.smartphone,
        title: t.records.local_history_title,
        label: t.records.local_history,
        description: t.records.local_history_desc,
      ),
    ];
    final current = sources[controller.showingLocal ? 1 : 0];

    return MenuAnchor(
      menuChildren: [
        for (final source in sources)
          MenuItemButton(
            leadingIcon: Icon(source.icon),
            trailingIcon: Icon(
              Icons.check,
              color: source.index == current.index
                  ? theme.colorScheme.primary
                  : Colors.transparent,
            ),
            onPressed: () =>
                controller.sourceController.animateTo(source.index),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(source.label),
                    Text(
                      source.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      builder: (context, menu, _) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => menu.isOpen ? menu.close() : menu.open(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(current.title, overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTabBar(
    BuildContext context, {
    TabController? controller,
    required List<String> labels,
  }) {
    return Container(
      padding: MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
        splashBorderRadius: BorderRadius.circular(8),
        tabs: [for (final label in labels) Tab(text: label)],
      ),
    );
  }

  /// What the site recorded for the account; it cannot be edited.
  Widget _buildCloudHistory(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildTypeTabBar(context, labels: [t.nav.videos, t.nav.images]),
          Expanded(
            child: TabBarView(
              children: [
                SiteHistoryList(
                  tag: controller.siteHistoryTags[MediaType.video]!,
                ),
                SiteHistoryList(
                  tag: controller.siteHistoryTags[MediaType.image]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalHistory(BuildContext context) {
    return Column(
      children: [
        _buildTypeTabBar(
          context,
          controller: controller.tabController,
          labels: [t.filter.all, t.nav.videos, t.nav.images],
        ),
        Expanded(
          child: TabBarView(
            controller: controller.tabController,
            children: [
              HistoryMediaPreviewList(
                tag: controller.childrenControllerTags[0],
              ),
              HistoryMediaPreviewList(
                filterType: MediaType.video,
                tag: controller.childrenControllerTags[1],
              ),
              HistoryMediaPreviewList(
                filterType: MediaType.image,
                tag: controller.childrenControllerTags[2],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBarSwitcher(
          visible: controller.enableMultipleSelection,
          primary: AppBar(
            title: _buildSourceTitle(context),
            // Searching and deleting only work on this device's history.
            actions: [
              if (controller.showingLocal) ...[
                IconButton(
                  onPressed: () => Get.to(() => const HistorySearchPage()),
                  icon: const Icon(Icons.search),
                ),
                PopupMenuButton<String>(
                  onSelected: (String type) {
                    switch (type) {
                      case 'all':
                        controller.cleanHistoryList();
                        break;
                      case 'multiple':
                        controller.enableMultipleSelection = true;
                        break;
                      default:
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'all',
                          child: Text(t.records.delete_all),
                        ),
                        PopupMenuItem<String>(
                          value: 'multiple',
                          child: Text(t.records.multiple_selection_mode),
                        ),
                      ],
                ),
              ],
            ],
          ),
          secondary: selectionAppBar(
            context,
            count: controller.checkedCount,
            onClose: controller.exitMultipleSelection,
            onInvert: controller.invertSelection,
            onDelete: controller.deleteChecked,
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: TabBarView(
            controller: controller.sourceController,
            // Swipes switch the inner tabs; the source switches by its menu.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCloudHistory(context),
              _buildLocalHistory(context),
            ],
          ),
        ),
      ),
    );
  }
}
