import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/widget.dart';
import '../../../../../data/enums/types.dart';
import '../../controller.dart';
import '../history_media_preview.dart';
import 'controller.dart';

class HistoryMediaPreviewList extends StatefulWidget {
  final MediaType? filterType;
  final String tag;
  final String? keyword;

  const HistoryMediaPreviewList({
    super.key,
    this.filterType,
    required this.tag,
    this.keyword,
  });

  @override
  State<HistoryMediaPreviewList> createState() =>
      _HistoryMediaPreviewListState();
}

class _HistoryMediaPreviewListState extends State<HistoryMediaPreviewList>
    with AutomaticKeepAliveClientMixin {
  final HistoryController _parentController = Get.find();
  late HistoryMediaPreviewListController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HistoryMediaPreviewListController>(tag: widget.tag);
    _parentController.childrenControllers[widget.tag] = _controller;
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
                  final item = data[index];

                  if (widget.keyword != null) {
                    if (widget.keyword!.isEmpty ||
                        !item.contains(widget.keyword!)) {
                      return const SizedBox.shrink();
                    }
                  }

                  if (widget.filterType != null) {
                    if (widget.filterType != item.type) {
                      return const SizedBox.shrink();
                    }
                  }

                  // The list builds its rows lazily, outside the Obx around
                  // it, so each row watches the selection itself.
                  return Obx(
                    () => HistoryMediaPreview(
                      historyController: _parentController,
                      checked: _parentController.checked.contains(item.id),
                      media: item,
                      showType: widget.filterType == null,
                      onLongPress: _parentController.enableMultipleSelection
                          ? null
                          : () {
                              _parentController.enableMultipleSelection = true;
                              _parentController.toggleChecked(item.id);
                            },
                      onTap: () {
                        if (_parentController.enableMultipleSelection) {
                          _parentController.toggleChecked(item.id);
                        } else {
                          Get.toNamed(
                            "/mediaDetail?id=${item.id}",
                            arguments: {
                              "mediaType": item.type == MediaType.video
                                  ? MediaType.video
                                  : MediaType.image,
                            },
                          );
                        }
                      },
                    ),
                  );
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
