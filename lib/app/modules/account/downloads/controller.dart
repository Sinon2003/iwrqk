import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/multiple_selection.dart';
import '../../../data/enums/download_task_status.dart';
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

  Future<void> deleteTask(String taskId) async {
    String? path = await downloadService.getTaskFilePath(taskId);
    await downloadService.deleteTaskRecord(taskId);

    if (path == null) return;

    File downloadFile = File(path);
    if (await downloadFile.exists()) {
      await downloadFile.delete();
    }
    Directory downloadDir = downloadFile.parent;
    if (await downloadDir.exists() && downloadDir.listSync().isEmpty) {
      await downloadDir.delete();
    }
  }

  void deleteChecked() async {
    for (String hash in checked.toList()) {
      await deleteTask(
        StorageProvider.downloadVideoRecords
            .findWhere((element) => element.hash == hash)
            .taskId,
      );
      StorageProvider.downloadVideoRecords.deleteWhere(
        (element) => element.hash == hash,
      );
    }
    checked.clear();
    await refreshDownloadsList();
  }

  Future<void> refreshDownloadsList() async {
    for (String tag in childrenControllerTags) {
      await childrenControllers[tag]?.refreshData(showSplash: true);
    }
  }

  Future<void> cleanDownloadVideoRecords() async {
    await StorageProvider.downloadVideoRecords.clean();
    await refreshDownloadsList();
  }
}
