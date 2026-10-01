import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    await _currentList?.unfavoriteAll();
  }

  void deleteChecked() async {
    childrenControllers.forEach((_, ctr) {
      ctr.showLoading();
    });
    for (String id in checked.toList()) {
      await unfavoriteMedia(id);
    }
    checked.clear();
    await refreshFavoritelist();
  }

  /// Deleting puts every list into its loading state, so every list reloads.
  Future<void> refreshFavoritelist() async {
    for (final list in childrenControllers.values) {
      list.refreshData(showSplash: true);
    }
  }
}
