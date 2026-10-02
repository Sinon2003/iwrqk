import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../../components/multiple_selection.dart';
import '../../../../components/network_image.dart';
import '../../../../const/iwara.dart';
import '../controller.dart';

class PlaylistPreview extends StatelessWidget {
  final String playlistId;
  final String title;
  final int videosCount;
  final bool requireMyself;

  /// Whether the page is in selection mode, and this playlist ticked.
  final bool selecting;
  final bool checked;

  /// Replaces opening the playlist, as ticking does in selection mode.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PlaylistPreview({
    super.key,
    required this.playlistId,
    required this.title,
    required this.videosCount,
    this.requireMyself = false,
    this.selecting = false,
    this.checked = false,
    this.onTap,
    this.onLongPress,
  });

  Future<void> _open() async {
    final deleted = await Get.toNamed(
      "/playlistDetail?playlistId=$playlistId&requireMyself=$requireMyself",
      arguments: {"title": title},
    );
    if (deleted == true && Get.isRegistered<PlaylistsPreviewController>()) {
      Get.find<PlaylistsPreviewController>().refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? _open,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 116),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 168),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const NetworkImg(
                          imageUrl: IwaraConst.defaultCoverUrl,
                          aspectRatio: 16 / 9,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  CheckedOverlay(selecting: selecting, checked: checked),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2.5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17.5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                          Text(
                            videosCount == 1
                                ? t.playlist.videos_count(
                                    numVideo: "$videosCount",
                                  )
                                : t.playlist.videos_count_plural(
                                    numVideo: "$videosCount",
                                  ),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context).colorScheme.outline,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 24,
                      color: Theme.of(context).colorScheme.outline,
                    ),
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
