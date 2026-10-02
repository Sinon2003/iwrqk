import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/dialogs/confirm_destructive.dart';
import '../../../components/multiple_selection.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/user_service.dart';
import '../../../utils/display_util.dart';
import 'widgets/playlist_detail_media_preview_list/controller.dart';

class PlaylistDetailController extends GetxController with MultipleSelection {
  final UserService _userService = Get.find();

  late String playlistId;
  late bool requireMyself;
  late String? title;

  late PlaylistDetailMediaPreviewListController childController;

  late String listTag;

  @override
  void onInit() {
    super.onInit();

    playlistId = Get.parameters["playlistId"]!;
    requireMyself =
        Get.parameters["requireMyself"] != null &&
        Get.parameters["requireMyself"] == "true";
    title = Get.arguments["title"];

    listTag = "playlist_detail_media_preview_list_$playlistId";

    Get.lazyPut(() => PlaylistDetailMediaPreviewListController(), tag: listTag);
  }

  void invertSelection() {
    invertChecked(childController.data.map((media) => media.id));
  }

  Future<void> removeFromPlaylist(String id) async {
    await _userService.removeFromPlaylist(id, [playlistId]);
  }

  Future<void> removeAllFromPlaylist() async {
    if (!await confirmDestructive(t.records.delete_all_playlist_confirm)) {
      return;
    }
    childController.showLoading();
    await childController.removeAllFromPlaylist();
  }

  Future<void> deleteChecked() async {
    if (checked.isEmpty) return;
    if (!await confirmDestructive(
      t.records.delete_selected_confirm(num: checkedCount),
    )) {
      return;
    }
    final ids = checked.toList();
    exitMultipleSelection();
    childController.showLoading();
    for (String id in ids) {
      await removeFromPlaylist(id);
    }
    await refreshPlaylist();
  }

  /// Deletes the playlist itself; the videos in it stay. Closes the page with
  /// `true` so the playlists page reloads.
  Future<void> deletePlaylist() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(t.playlist.delete),
        content: Text(t.playlist.delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(t.notifications.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(t.notifications.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ApiProvider.deletePlaylist(playlistId);
    if (!result.success) {
      SmartDialog.showToast(DisplayUtil.getErrorMessage(result.message!));
      return;
    }
    SmartDialog.showToast(t.message.playlist.playlist_deleted);
    Get.back(result: true);
  }

  Future<void> refreshPlaylist() async {
    childController.refreshData(showSplash: true);
  }

  Future<String?> getPlaylistName() {
    return ApiProvider.getPlaylistName(playlistId: playlistId).then((value) {
      if (value.success) {
        title = value.data;
        return value.data;
      }
      return null;
    });
  }
}
