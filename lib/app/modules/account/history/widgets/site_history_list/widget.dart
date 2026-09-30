import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/widget.dart';
import '../../../../../components/media_preview/media_flat_preview.dart';
import '../../../../../data/models/media/media.dart';
import 'controller.dart';

class SiteHistoryList extends StatefulWidget {
  final String tag;

  const SiteHistoryList({super.key, required this.tag});

  @override
  State<SiteHistoryList> createState() => _SiteHistoryListState();
}

class _SiteHistoryListState extends State<SiteHistoryList>
    with AutomaticKeepAliveClientMixin {
  late final SiteHistoryListController _controller = Get.find(tag: widget.tag);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IwrRefresh<MediaModel>(
      controller: _controller,
      scrollController: _scrollController,
      requireLogin: true,
      builder: (data, scrollController) => CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => MediaFlatPreview(media: data[index]),
              childCount: data.length,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
