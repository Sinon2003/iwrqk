import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/app_bar_switcher.dart';
import '../../../components/dialogs/edit_playlis_dialog/widget.dart';
import '../../../components/multiple_selection.dart';
import 'controller.dart';
import 'widgets/playlists_preview_list/widget.dart';

class PlaylistsPreviewPage extends GetView<PlaylistsPreviewController> {
  const PlaylistsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBarSwitcher(
          visible: controller.enableMultipleSelection,
          primary: AppBar(
            title: Text(t.user.playlists),
            actions: [
              if (controller.requireMyself)
                IconButton(
                  onPressed: () {
                    Get.dialog(
                      EditPlaylistDialog(
                        onChanged: () {
                          controller.refreshData();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
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
        body: PlaylistsPreviewList(
          userId: controller.userId,
          requireMyself: controller.requireMyself,
          tag: controller.tag,
        ),
      ),
    );
  }
}
