import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/iwr_refresh/widget.dart';
import '../../../components/media_preview/media_flat_preview.dart';
import '../../../data/enums/types.dart';
import '../../../data/models/media/media.dart';
import 'controller.dart';

/// The watch history the site keeps for the account, across devices and the
/// website; the history page itself only covers this device.
class SiteHistoryPage extends StatelessWidget {
  const SiteHistoryPage({super.key});

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
      child: TabBar(
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
        splashBorderRadius: BorderRadius.circular(8),
        tabs: [
          Tab(text: t.nav.videos),
          Tab(text: t.nav.images),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.records.site_history)),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildTabBar(context),
            const Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: TabBarView(
                  children: [
                    _SiteHistoryList(type: MediaType.video),
                    _SiteHistoryList(type: MediaType.image),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SiteHistoryList extends StatefulWidget {
  final MediaType type;

  const _SiteHistoryList({required this.type});

  @override
  State<_SiteHistoryList> createState() => _SiteHistoryListState();
}

class _SiteHistoryListState extends State<_SiteHistoryList>
    with AutomaticKeepAliveClientMixin {
  late final SiteHistoryListController _controller = Get.find(
    tag: widget.type.name,
  );
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
