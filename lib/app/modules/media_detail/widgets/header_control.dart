import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/plugin/pl_player/index.dart';
import '../../../data/models/download_task.dart';
import '../../../routes/pages.dart';
import '../controller.dart';

class HeaderControl extends StatefulWidget implements PreferredSizeWidget {
  const HeaderControl({
    this.controller,
    this.videoDetailCtr,
    this.floating,
    super.key,
  });
  final PlPlayerController? controller;
  final MediaDetailController? videoDetailCtr;
  final Floating? floating;

  @override
  State<HeaderControl> createState() => _HeaderControlState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _HeaderControlState extends State<HeaderControl> {
  static const TextStyle titleStyle = TextStyle(fontSize: 16);
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  double buttonSpace = 8;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller!;
    const TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 12);
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      primary: false,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      title: Row(
        children: [
          ComBtn(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            fuc: () => <Set<void>>{
              if (widget.controller!.isFullScreen.value)
                <void>{widget.controller!.triggerFullScreen(status: false)}
              else
                <void>{
                  if (MediaQuery.of(context).orientation ==
                      Orientation.landscape)
                    {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]),
                    },
                  Get.back(),
                },
            },
          ),
          SizedBox(width: buttonSpace),
          ComBtn(
            icon: const Icon(Icons.home, color: Colors.white),
            fuc: () async {
              // 销毁播放器实例
              await widget.controller!.dispose(type: 'all');
              if (!context.mounted) return;
              Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            },
          ),
          SizedBox(width: buttonSpace),
          Expanded(
            // Offline pages have no media loaded, only the download record.
            child: Text(
              widget.videoDetailCtr == null
                  ? ""
                  : widget.videoDetailCtr!.isOffline
                  ? widget.videoDetailCtr!.taskData.offlineMedia.title
                  : widget.videoDetailCtr!.media.title,
              style: titleStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(width: buttonSpace),
          if (GetPlatform.isAndroid) ...<Widget>[
            ComBtn(
              icon: const Icon(
                Icons.picture_in_picture,
                size: 20,
                color: Colors.white,
              ),
              fuc: () async {
                widget.controller!.hiddenControls(false);

                bool canUsePiP = false;
                try {
                  canUsePiP = await widget.floating!.isPipAvailable;
                } on PlatformException catch (_) {
                  canUsePiP = false;
                }
                if (canUsePiP) {
                  final Rational aspectRatio =
                      widget.videoDetailCtr?.aspectRatio ??
                      const Rational(16, 9);
                  await widget.floating!.enable(
                    ImmediatePiP(aspectRatio: aspectRatio),
                  );
                }
              },
            ),
            SizedBox(width: buttonSpace),
          ],
          if (MediaQuery.of(context).orientation == Orientation.landscape) ...[
            Obx(
              () => SizedBox(
                height: 34,
                child: TextButton(
                  onPressed: () => showOptions(quality: false, fit: false),
                  child: Text('${controller.playbackSpeed}X', style: textStyle),
                ),
              ),
            ),
            SizedBox(width: buttonSpace),
            SizedBox(
              height: 34,
              child: TextButton(
                onPressed: widget.videoDetailCtr!.isOffline
                    ? null
                    : () => showOptions(speed: false, fit: false),
                child: Text(
                  widget.videoDetailCtr!.isOffline
                      ? (widget.videoDetailCtr!.taskData as VideoDownloadTask)
                            .resolutionName
                      : widget
                            .videoDetailCtr!
                            .resolutions[widget.videoDetailCtr!.resolutionIndex]
                            .name,
                  style: textStyle,
                ),
              ),
            ),
          ],
          ComBtn(
            icon: const Icon(Icons.more_vert_outlined, color: Colors.white),
            fuc: () => showOptions(),
          ),
        ],
      ),
    );
  }

  /// Offers what can be changed while the video plays, each as a row of
  /// choices that take effect on a tap.
  ///
  /// In landscape it comes in from the right and leaves the picture in view;
  /// a sheet at the bottom would cover most of it and show three rows. Held
  /// upright it is a sheet as tall as what it holds.
  void showOptions({bool quality = true, bool speed = true, bool fit = true}) {
    Widget options(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _buildOptions(context, quality: quality, speed: speed, fit: fit),
    );

    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        builder: (context) => SafeArea(child: options(context)),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, _) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          left: false,
          child: SizedBox(
            width: (MediaQuery.sizeOf(context).width * 0.5).clamp(0, 360),
            height: double.infinity,
            child: options(context),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => Align(
        alignment: Alignment.centerRight,
        child: SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildOptions(
    BuildContext context, {
    required bool quality,
    required bool speed,
    required bool fit,
  }) {
    final player = widget.controller!;
    final detail = widget.videoDetailCtr!;
    void close() => Navigator.of(context).pop();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quality)
          // A download has the one resolution it was saved in.
          detail.isOffline
              ? _buildChoices<String>(
                  context,
                  icon: Icons.hd,
                  title: t.player.quality,
                  values: [
                    (detail.taskData as VideoDownloadTask).resolutionName,
                  ],
                  isCurrent: (_) => true,
                  label: (name) => name,
                  onPick: null,
                )
              : _buildChoices<int>(
                  context,
                  icon: Icons.hd,
                  title: t.player.quality,
                  values: List.generate(detail.resolutions.length, (i) => i),
                  isCurrent: (index) => index == detail.resolutionIndex,
                  label: (index) => detail.resolutions[index].name,
                  onPick: (index) {
                    close();
                    // Only this video; the default is the preferred quality
                    // in the app settings.
                    detail.resolutionIndex = index;
                    detail.updatePlayer();
                  },
                ),
        if (speed)
          _buildChoices<double>(
            context,
            icon: Icons.speed,
            title: t.player.playback_speed,
            values: player.speedsList,
            isCurrent: (value) => value == player.playbackSpeed,
            label: (value) => '${value}X',
            onPick: (value) {
              close();
              player.setPlaybackSpeed(value);
            },
          ),
        if (fit)
          _buildChoices<Map<String, dynamic>>(
            context,
            icon: Icons.aspect_ratio,
            title: t.player.aspect_ratio,
            values: player.videoFitType,
            isCurrent: (value) => value['attr'] == player.videoFit.value,
            label: (value) => value['desc'],
            onPick: (value) {
              close();
              player.videoFit.value = value['attr'];
              player.videoFitDEsc.value = value['desc'];
              player.setVideoFit();
            },
          ),
      ],
    );
  }

  /// One thing to choose: what it is, and its values side by side with the
  /// one in use marked. Without [onPick] it only shows what is in use.
  Widget _buildChoices<T>(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<T> values,
    required bool Function(T value) isCurrent,
    required String Function(T value) label,
    required void Function(T value)? onPick,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final value in values)
                ChoiceChip(
                  label: Text(label(value)),
                  selected: isCurrent(value),
                  showCheckmark: false,
                  onSelected: onPick == null ? null : (_) => onPick(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
