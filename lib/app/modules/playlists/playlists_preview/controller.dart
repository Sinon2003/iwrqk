import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/dialogs/confirm_destructive.dart';
import '../../../components/multiple_selection.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/display_util.dart';
import 'widgets/playlists_preview_list/controller.dart';

class PlaylistsPreviewController extends GetxController with MultipleSelection {
  late String userId;
  late bool requireMyself;

  late String tag;
  late PlaylistsPreviewListController _targetController;

  @override
  void onInit() {
    super.onInit();

    userId = Get.parameters["userId"]!;
    requireMyself =
        Get.parameters["requireMyself"] != null &&
        Get.parameters["requireMyself"] == "true";

    tag = "playlists_$userId";

    Get.lazyPut(() => PlaylistsPreviewListController(), tag: tag);

    _targetController = Get.find<PlaylistsPreviewListController>(tag: tag);
  }

  Future<void> refreshData() {
    return _targetController.refreshData(showSplash: true);
  }

  void invertSelection() {
    invertChecked(_targetController.data.map((playlist) => playlist.id));
  }

  /// Deletes the ticked playlists; the videos in them stay.
  Future<void> deleteChecked() async {
    if (checked.isEmpty) return;
    if (!await confirmDestructive(
      t.playlist.delete_selected_confirm(num: checkedCount),
    )) {
      return;
    }
    final ids = checked.toList();
    exitMultipleSelection();
    _targetController.showLoading();
    String? failure;
    for (final id in ids) {
      final result = await ApiProvider.deletePlaylist(id);
      if (!result.success) {
        failure = result.message;
        break;
      }
    }
    SmartDialog.showToast(
      failure == null
          ? t.message.playlist.playlist_deleted
          : DisplayUtil.getErrorMessage(failure),
    );
    await refreshData();
  }
}
