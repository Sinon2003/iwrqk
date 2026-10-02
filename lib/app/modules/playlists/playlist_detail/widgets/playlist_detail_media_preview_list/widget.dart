import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/widget.dart';
import '../../../../../components/media_preview/media_flat_preview.dart';
import '../../../../../components/multiple_selection.dart';
import '../../../../../data/models/media/media.dart';
import '../../controller.dart';
import 'controller.dart';

class PlaylistDetailMediaPreviewList extends StatefulWidget {
  final String tag;
  final PlaylistDetailController parentController;
  final String playlistId;
  final bool requireMyself;

  const PlaylistDetailMediaPreviewList({
    super.key,
    required this.tag,
    required this.parentController,
    required this.playlistId,
    required this.requireMyself,
  });

  @override
  State<PlaylistDetailMediaPreviewList> createState() =>
      _PlaylistDetailMediaPreviewListState();
}

class _PlaylistDetailMediaPreviewListState
    extends State<PlaylistDetailMediaPreviewList>
    with AutomaticKeepAliveClientMixin {
  late PlaylistDetailController _parentController;
  late PlaylistDetailMediaPreviewListController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _parentController = widget.parentController;
    _controller = Get.find(tag: widget.tag);
    _controller.initConfig(widget.playlistId);
    _parentController.childController = _controller;
  }

  Widget _buildPlaylistMediaPreview(MediaModel media) {
    return Obx(() {
      bool checked = _parentController.checked.contains(media.id);

      return MediaFlatPreview(
        media: media,
        onTap: _parentController.enableMultipleSelection
            ? () => _parentController.toggleChecked(media.id)
            : null,
        onLongPress: _parentController.enableMultipleSelection
            ? null
            : () {
                _parentController.enableMultipleSelection = true;
                _parentController.toggleChecked(media.id);
              },
        coverOverlay: CheckedOverlay(
          selecting: _parentController.enableMultipleSelection,
          checked: checked,
        ),
      );
    });
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
            Obx(
              () => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildPlaylistMediaPreview(data[index]);
                }, childCount: data.length),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
