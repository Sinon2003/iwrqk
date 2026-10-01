import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/dialogs/confirm_delete.dart';
import '../../../components/multiple_selection.dart';
import '../../../data/enums/download_task_status.dart';
import '../../../data/models/download_task.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/services/download_service.dart';
import 'widgets/downloads_media_preview_list/controller.dart';

class DownloadsController extends GetxController
    with GetSingleTickerProviderStateMixin, MultipleSelection {
  final DownloadService downloadService = Get.find();

  Map<String, DownloadsMediaPreviewListController> childrenControllers = {};
  late List<String> childrenControllerTags;

  late TabController tabController;

  static const completedTab = 0;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: 2, vsync: this);

    childrenControllerTags = List.generate(
      2,
      (index) => "downloads_list_$index",
    );

    for (String tag in childrenControllerTags) {
      Get.lazyPut(() => DownloadsMediaPreviewListController(), tag: tag);
    }
  }

  /// Whether [taskId] belongs on the tab of finished downloads; everything
  /// else is on the other one.
  bool isCompleted(String taskId) =>
      downloadService.downloadTasksStatus[taskId]?.value.status ==
      DownloadTaskStatus.complete;

  /// Both tabs hold every task and hide the other tab's, so only the tasks
  /// this tab shows are inverted.
  void invertSelection() {
    final list =
        childrenControllers[childrenControllerTags[tabController.index]];
    if (list == null) return;
    final completed = tabController.index == completedTab;
    invertChecked([
      for (final task in list.data)
        if (isCompleted(task.taskId) == completed) task.hash,
    ]);
  }

  Future<void> deleteChecked() async {
    if (checked.isEmpty) return;
    if (!await confirmDelete(
      t.download.delete_selected_confirm(num: checkedCount),
    )) {
      return;
    }
    final hashes = checked.toSet();
    exitMultipleSelection();
    await _delete((task) => hashes.contains(task.hash));
  }

  Future<void> deleteAll() async {
    if (!await confirmDelete(t.download.delete_all_confirm)) return;
    await _delete((task) => true);
  }

  /// Deletes the downloads that match, with their tasks and files.
  Future<void> _delete(bool Function(VideoDownloadTask task) test) async {
    // Only the two tabs: a search page that has closed left its list behind.
    for (final tag in childrenControllerTags) {
      childrenControllers[tag]?.showLoading();
    }
    final records = StorageProvider.downloadVideoRecords;
    for (final task in records.get().where(test)) {
      await downloadService.removeTask(task.taskId);
    }
    await records.deleteWhere(test);
    await refreshDownloadsList();
  }

  Future<void> refreshDownloadsList() async {
    for (String tag in childrenControllerTags) {
      await childrenControllers[tag]?.refreshData(showSplash: true);
    }
  }
}
