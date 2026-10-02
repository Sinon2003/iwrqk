import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/dialogs/confirm_destructive.dart';
import '../../../components/multiple_selection.dart';
import '../../../data/enums/types.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/services/account_service.dart';
import 'widgets/history_media_preview_list/controller.dart';
import 'widgets/site_history_list/controller.dart';

/// History comes from two places: the site, which records what the account
/// watched on every device but cannot be edited, and this device, which
/// works without logging in and can be searched and cleared.
class HistoryController extends GetxController
    with GetTickerProviderStateMixin, MultipleSelection {
  Map<String, HistoryMediaPreviewListController> childrenControllers = {};
  late List<String> childrenControllerTags;

  /// The tabs of this device's history, by what they show; null is all.
  static const List<MediaType?> localTabs = [
    null,
    MediaType.video,
    MediaType.image,
  ];

  late TabController tabController;

  /// Switches between the site's history and this device's.
  late TabController sourceController;
  static const cloudTab = 0;
  static const localTab = 1;

  final RxBool _showingLocal = false.obs;
  bool get showingLocal => _showingLocal.value;

  final siteHistoryTags = {
    for (final type in [MediaType.video, MediaType.image])
      type: "site_history_list_${type.name}",
  };

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: localTabs.length, vsync: this);

    // The site only has history for accounts.
    final isLogin = Get.find<AccountService>().isLogin;
    sourceController = TabController(
      length: 2,
      vsync: this,
      initialIndex: isLogin ? cloudTab : localTab,
    );
    _showingLocal.value = sourceController.index == localTab;
    sourceController.addListener(() {
      _showingLocal.value = sourceController.index == localTab;
      // Selecting only applies to this device's history.
      if (!showingLocal && enableMultipleSelection) exitMultipleSelection();
    });

    siteHistoryTags.forEach((type, tag) {
      Get.lazyPut(() => SiteHistoryListController(type), tag: tag);
    });

    childrenControllerTags = List.generate(
      localTabs.length,
      (index) => "history_list_$index",
    );

    for (String tag in childrenControllerTags) {
      Get.lazyPut(() => HistoryMediaPreviewListController(), tag: tag);
    }
  }

  /// Every tab holds the whole history and hides what is not its type, so
  /// only the records this tab shows are inverted.
  void invertSelection() {
    final list =
        childrenControllers[childrenControllerTags[tabController.index]];
    if (list == null) return;
    final type = localTabs[tabController.index];
    invertChecked([
      for (final item in list.data)
        if (type == null || item.type == type) item.id,
    ]);
  }

  Future<void> deleteChecked() async {
    if (checked.isEmpty) return;
    if (!await confirmDestructive(
      t.records.delete_selected_confirm(num: checkedCount),
    )) {
      return;
    }
    final ids = checked.toSet();
    exitMultipleSelection();
    await StorageProvider.historyList.deleteWhere(
      (element) => ids.contains(element.id),
    );
    await refreshHistoryList();
  }

  Future<void> refreshHistoryList() async {
    for (String tag in childrenControllerTags) {
      await childrenControllers[tag]?.refreshData(showSplash: true);
    }
  }

  Future<void> cleanHistoryList() async {
    if (!await confirmDestructive(t.records.delete_all_history_confirm)) return;
    await StorageProvider.historyList.clean();
    await refreshHistoryList();
  }
}
