import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/app_bar_switcher.dart';
import '../../../components/multiple_selection.dart';
import 'controller.dart';
import 'downloads_search/page.dart';
import 'widgets/downloads_media_preview_list/widget.dart';

class DownloadsPage extends GetView<DownloadsController> {
  const DownloadsPage({super.key});

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
      child: TabBar(
        controller: controller.tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
        splashBorderRadius: BorderRadius.circular(8),
        tabs: [
          Tab(text: t.download.finished),
          Tab(text: t.download.downloading),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBarSwitcher(
          visible: controller.enableMultipleSelection,
          primary: AppBar(
            title: Text(t.user.downloads),
            actions: [
              IconButton(
                onPressed: () => Get.to(() => const DownloadsSearchPage()),
                icon: const Icon(Icons.search),
              ),
              PopupMenuButton<String>(
                onSelected: (String type) {
                  switch (type) {
                    case 'all':
                      controller.deleteAll();
                      break;
                    case 'multiple':
                      controller.enableMultipleSelection = true;
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  DownloadsMediaPreviewList(
                    showCompleted: true,
                    tag: controller.childrenControllerTags[0],
                  ),
                  DownloadsMediaPreviewList(
                    tag: controller.childrenControllerTags[1],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
