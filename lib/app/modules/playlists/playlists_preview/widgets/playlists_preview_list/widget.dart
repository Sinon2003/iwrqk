import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/widget.dart';
import '../../../../../data/models/playlist/playlist.dart';
import '../../controller.dart';
import '../playlist_preview.dart';
import 'controller.dart';

class PlaylistsPreviewList extends StatefulWidget {
  final String userId;
  final bool requireMyself;
  final String tag;

  const PlaylistsPreviewList({
    super.key,
    required this.userId,
    required this.tag,
    this.requireMyself = false,
  });

  @override
  State<PlaylistsPreviewList> createState() => _PlaylistsPreviewListState();
}

class _PlaylistsPreviewListState extends State<PlaylistsPreviewList>
    with AutomaticKeepAliveClientMixin {
  final PlaylistsPreviewController _parentController = Get.find();
  late PlaylistsPreviewListController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlaylistsPreviewListController>(tag: widget.tag);
    _controller.initConfig(widget.userId, widget.requireMyself);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IwrRefresh(
      controller: _controller,
      scrollController: _scrollController,
      builder: (data, scrollController) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                PlaylistModel playlist = _controller.data[index];

                // Only the owner's playlists can be ticked, to delete them.
                return Obx(
                  () => PlaylistPreview(
                    playlistId: playlist.id,
                    title: playlist.title,
                    videosCount: playlist.numVideos,
                    requireMyself: widget.requireMyself,
                    selecting: _parentController.enableMultipleSelection,
                    checked: _parentController.checked.contains(playlist.id),
                    onTap: _parentController.enableMultipleSelection
                        ? () => _parentController.toggleChecked(playlist.id)
                        : null,
                    onLongPress:
                        !widget.requireMyself ||
                            _parentController.enableMultipleSelection
                        ? null
                        : () {
                            _parentController.enableMultipleSelection = true;
                            _parentController.toggleChecked(playlist.id);
                          },
                  ),
                );
              }, childCount: _controller.data.length),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
