import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/dialogs/confirm_delete.dart';
import '../../../components/multiple_selection.dart';
import '../../../data/services/user_service.dart';
import 'widgets/favorite_media_preview_list/controller.dart';

class FavoritesController extends GetxController
    with GetSingleTickerProviderStateMixin, MultipleSelection {
  final UserService _userService = Get.find();

  Map<String, FavoriteMediaPreviewListController> childrenControllers = {};
  late List<String> childrenControllerTags;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: 2, vsync: this);

    childrenControllerTags = List.generate(
      2,
      (index) => "favorite_list_$index",
    );

    for (String tag in childrenControllerTags) {
      Get.lazyPut(() => FavoriteMediaPreviewListController(), tag: tag);
    }
  }

  FavoriteMediaPreviewListController? get _currentList =>
      childrenControllers[childrenControllerTags[tabController.index]];

  void invertSelection() {
    final list = _currentList;
    if (list == null) return;
    invertChecked(list.data.map((media) => media.id));
  }

  Future<void> unfavoriteMedia(String id) async {
    await _userService.unfavoriteMedia(id);
  }

  Future<void> unfavoriteAll() async {
    if (!await confirmDelete(t.records.delete_all_favorites_confirm)) return;
    await _currentList?.unfavoriteAll();
  }

  Future<void> deleteChecked() async {
    if (checked.isEmpty) return;
    if (!await confirmDelete(
      t.records.delete_selected_confirm(num: checkedCount),
    )) {
      return;
    }
    final ids = checked.toList();
    exitMultipleSelection();
    childrenControllers.forEach((_, ctr) {
      ctr.showLoading();
    });
    for (String id in ids) {
      await unfavoriteMedia(id);
    }
    await refreshFavoritelist();
  }

  /// Deleting puts every list into its loading state, so every list reloads.
  Future<void> refreshFavoritelist() async {
    for (final list in childrenControllers.values) {
      list.refreshData(showSplash: true);
    }
  }
}
