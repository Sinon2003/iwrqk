import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/app_bar_switcher.dart';
import '../../../components/dialogs/edit_playlis_dialog/widget.dart';
import '../../../components/multiple_selection.dart';
import 'controller.dart';
import 'widgets/playlist_detail_media_preview_list/widget.dart';

class PlaylistDetailPage extends StatefulWidget {
  const PlaylistDetailPage({super.key});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final PlaylistDetailController controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: controller.requireMyself
            ? AppBarSwitcher(
                visible: controller.enableMultipleSelection,
                primary: AppBar(
                  title: controller.title != null
                      ? Text(controller.title!)
                      : FutureBuilder<String?>(
                          future: controller.getPlaylistName(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return Text(t.playlist.title);
                              }
                              return Text(snapshot.data!);
                            }
                            return Text(t.notifications.loading);
                          },
                        ),
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (String type) {
                        switch (type) {
                          case 'all':
                            controller.removeAllFromPlaylist();
                            break;
                          case 'multiple':
                            controller.enableMultipleSelection = true;
                            break;
                          case 'editTitle':
                            Get.dialog(
                              EditPlaylistDialog(
                                onChanged: () {
                                  controller.getPlaylistName().then((value) {
                                    setState(() {});
                                  });
                                },
                                editId: controller.playlistId,
                                isEdit: true,
                              ),
                            );
                            break;
                          case 'deletePlaylist':
                            controller.deletePlaylist();
                            break;
                          default:
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'all',
                              child: Text(t.records.delete_all),
                            ),
                            PopupMenuItem<String>(
                              value: 'multiple',
                              child: Text(t.records.multiple_selection_mode),
                            ),
                            PopupMenuItem<String>(
                              value: 'editTitle',
                              child: Text(t.playlist.edit_title),
                            ),
                            PopupMenuItem<String>(
                              value: 'deletePlaylist',
                              child: Text(
                                t.playlist.delete,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
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
              )
            : AppBar(
                title: controller.title != null
                    ? Text(controller.title!)
                    : FutureBuilder<String?>(
                        future: controller.getPlaylistName(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return Text(t.playlist.title);
                            }
                            return Text(snapshot.data!);
                          }
                          return Text(t.notifications.loading);
                        },
                      ),
              ),
        body: PlaylistDetailMediaPreviewList(
          parentController: controller,
          tag: controller.listTag,
          requireMyself: controller.requireMyself,
          playlistId: controller.playlistId,
        ),
      ),
    );
  }
}
