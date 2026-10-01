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

  Widget _buildSourceTabBar(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
      child: TabBar(
        controller: controller.sourceController,
        tabs: [
          Tab(
            icon: const Icon(Icons.cloud_outlined),
            text: t.records.cloud_history,
          ),
          Tab(
            icon: const Icon(Icons.smartphone),
            text: t.records.local_history,
          ),
        ],
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
      child: TabBar.secondary(
        controller: controller,
        isScrollable: true,
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
            title: Text(t.user.history),
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
        body: Column(
          children: [
            _buildSourceTabBar(context),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: TabBarView(
                  controller: controller.sourceController,
                  // Swipes switch the inner tabs; the source switches by tab.
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCloudHistory(context),
                    _buildLocalHistory(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
