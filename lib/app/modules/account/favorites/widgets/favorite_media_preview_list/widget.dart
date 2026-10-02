import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/widget.dart';
import '../../../../../components/media_preview/media_flat_preview.dart';
import '../../../../../components/multiple_selection.dart';
import '../../../../../data/enums/types.dart';
import '../../../../../data/models/media/media.dart';
import '../../controller.dart';
import 'controller.dart';

class FavoriteMediaPreviewList extends StatefulWidget {
  final MediaType mediaType;
  final String tag;

  const FavoriteMediaPreviewList({
    super.key,
    required this.mediaType,
    required this.tag,
  });

  @override
  State<FavoriteMediaPreviewList> createState() =>
      _FavoriteMediaPreviewListState();
}

class _FavoriteMediaPreviewListState extends State<FavoriteMediaPreviewList>
    with AutomaticKeepAliveClientMixin {
  final FavoritesController _parentController = Get.find();
  late FavoriteMediaPreviewListController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FavoriteMediaPreviewListController>(tag: widget.tag);
    _controller.initConfig(widget.mediaType);
    _parentController.childrenControllers[widget.tag] = _controller;
  }

  Widget _buildFavoriteMediaPreview(MediaModel media) {
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
                  return _buildFavoriteMediaPreview(data[index]);
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
