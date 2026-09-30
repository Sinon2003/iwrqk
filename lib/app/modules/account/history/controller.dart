import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/enums/types.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/services/account_service.dart';
import 'widgets/history_media_preview_list/controller.dart';
import 'widgets/site_history_list/controller.dart';

/// History comes from two places: the site, which records what the account
/// watched on every device but cannot be edited, and this device, which
/// works without logging in and can be searched and cleared.
class HistoryController extends GetxController
    with GetTickerProviderStateMixin {
  Map<String, HistoryMediaPreviewListController> childrenControllers = {};
  late List<String> childrenControllerTags;

  final RxBool _enableMultipleSelection = false.obs;
  bool get enableMultipleSelection => _enableMultipleSelection.value;
  set enableMultipleSelection(bool value) =>
      _enableMultipleSelection.value = value;

  List checkedList = [];

  final RxInt _checkedCount = 0.obs;
  int get checkedCount => _checkedCount.value;
  set checkedCount(int value) => _checkedCount.value = value;

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

    tabController = TabController(length: 3, vsync: this);

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
      if (!showingLocal && enableMultipleSelection) {
        enableMultipleSelection = false;
        checkedList.clear();
        checkedCount = 0;
      }
    });

    siteHistoryTags.forEach((type, tag) {
      Get.lazyPut(() => SiteHistoryListController(type), tag: tag);
    });

    childrenControllerTags = List.generate(3, (index) => "history_list_$index");

    for (String tag in childrenControllerTags) {
      Get.lazyPut(() => HistoryMediaPreviewListController(), tag: tag);
    }
  }

  void toggleChecked(String id, [bool all = false]) {
    if (checkedList.contains(id)) {
      checkedList.remove(id);
      checkedCount--;
    } else {
      checkedList.add(id);
      checkedCount++;
    }
    update();
  }

  void toggleCheckedAll() {
    childrenControllers[childrenControllerTags[tabController.index]]
        ?.toggleCheckedAll();
    update();
  }

  void deleteChecked() async {
    for (String id in checkedList) {
      await StorageProvider.historyList.deleteWhere(
        (element) => element.id == id,
      );
    }
    checkedList.clear();
    checkedCount = 0;
    await refreshHistoryList();
  }

  Future<void> refreshHistoryList() async {
    for (String tag in childrenControllerTags) {
      await childrenControllers[tag]?.refreshData(showSplash: true);
    }
  }

  Future<void> cleanHistoryList() async {
    await StorageProvider.historyList.clean();
    await refreshHistoryList();
  }
}
