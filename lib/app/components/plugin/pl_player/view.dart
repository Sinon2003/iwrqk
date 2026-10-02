import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../data/providers/storage_provider.dart';
import 'controller.dart';
import 'models/duration.dart';
import 'models/fullscreen_mode.dart';
import 'utils.dart';
import 'widgets/app_bar_ani.dart';
import 'widgets/backward_seek.dart';
import 'widgets/bottom_control.dart';
import 'widgets/common_btn.dart';
import 'widgets/forward_seek.dart';

class PLVideoPlayer extends StatefulWidget {
  const PLVideoPlayer({
    required this.controller,
    this.headerControl,
    this.bottomControl,
    this.inPip = false,
    super.key,
  });

  final bool inPip;
  final PlPlayerController controller;
  final PreferredSizeWidget? headerControl;
  final PreferredSizeWidget? bottomControl;

  @override
  State<PLVideoPlayer> createState() => _PLVideoPlayerState();
}

class _PLVideoPlayerState extends State<PLVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late VideoController videoController;
  final PLVideoPlayerController _ctr = Get.put(PLVideoPlayerController());

  // bool _mountSeekBackwardButton = false;
  // bool _mountSeekForwardButton = false;
  // bool _hideSeekBackwardButton = false;
  // bool _hideSeekForwardButton = false;

  // double _brightnessValue = 0.0;
  // bool _brightnessIndicator = false;
  Timer? _brightnessTimer;

  // double _volumeValue = 0.0;
  // bool _volumeIndicator = false;
  Timer? _volumeTimer;

  double _distance = 0.0;
  // 初始手指落下位置
  // double _initTapPositoin = 0.0;

  // bool _volumeInterceptEventStream = false;

  GStorageConfig setting = StorageProvider.config;
  late FullScreenMode mode;
  late int defaultBtmProgressBehavior;
  late bool enableQuickDouble;
  late bool enableBackgroundPlay;
  late double screenWidth;

  // 用于记录上一次全屏切换手势触发时间，避免误触
  DateTime? lastFullScreenToggleTime;

  void onDoubleTapSeekBackward() {
    _ctr.onDoubleTapSeekBackward();
  }

  void onDoubleTapSeekForward() {
    _ctr.onDoubleTapSeekForward();
  }

  // 双击播放、暂停
  void onDoubleTapCenter() {
    final PlPlayerController controller = widget.controller;
    controller.videoPlayerController!.playOrPause();
  }

  void doubleTapFuc(String type) {
    if (!enableQuickDouble) {
      onDoubleTapCenter();
      return;
    }
    switch (type) {
      case 'left':
        // 双击左边区域 👈
        onDoubleTapSeekBackward();
        break;
      case 'center':
        onDoubleTapCenter();
        break;
      case 'right':
        // 双击右边区域 👈
        onDoubleTapSeekForward();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    screenWidth = Get.size.width;
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    videoController = widget.controller.videoController!;
    widget.controller.headerControl = widget.headerControl;
    widget.controller.bottomControl = widget.bottomControl;

    enableQuickDouble = setting.get(
      PLPlayerConfigKey.enableQuickDouble,
      defaultValue: true,
    );
    enableBackgroundPlay = setting.get(
      PLPlayerConfigKey.enableBackgroundPlay,
      defaultValue: false,
    );
    Future.microtask(() async {
      try {
        FlutterVolumeController.updateShowSystemUI(true);
        _ctr.volumeValue.value = (await FlutterVolumeController.getVolume())!;
        FlutterVolumeController.addListener((double value) {
          if (mounted && !_ctr.volumeInterceptEventStream.value) {
            _ctr.volumeValue.value = value;
          }
        });
      } catch (_) {}
    });

    Future.microtask(() async {
      try {
        _ctr.brightnessValue.value = await ScreenBrightness().application;
        ScreenBrightness().onApplicationScreenBrightnessChanged.listen((
          double value,
        ) {
          if (mounted) {
            _ctr.brightnessValue.value = value;
          }
        });
      } catch (_) {}
    });
  }

  Future<void> setVolume(double value) async {
    try {
      FlutterVolumeController.updateShowSystemUI(false);
      await FlutterVolumeController.setVolume(value);
    } catch (_) {}
    _ctr.volumeValue.value = value;
    _ctr.volumeIndicator.value = true;
    _ctr.volumeInterceptEventStream.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _ctr.volumeIndicator.value = false;
        _ctr.volumeInterceptEventStream.value = false;
      }
    });
  }

  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
    } catch (_) {}
    _ctr.brightnessIndicator.value = true;
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _ctr.brightnessIndicator.value = false;
      }
    });
    widget.controller.brightness.value = value;
  }

  @override
  void dispose() {
    animationController.dispose();
    FlutterVolumeController.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlPlayerController c = widget.controller;
    final Color colorTheme = Theme.of(context).colorScheme.primary;
    const TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 12);
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Obx(
          () => Video(
            controller: videoController,
            controls: NoVideoControls,
            pauseUponEnteringBackgroundMode: !enableBackgroundPlay,
            resumeUponEnteringForegroundMode: true,
            fit: c.videoFit.value,
          ),
        ),

        /// 长按倍速 toast
        Obx(
          () => Align(
            alignment: Alignment.topCenter,
            child: FractionalTranslation(
              translation: const Offset(0.0, 0.3), // 上下偏移量（负数向上偏移）
              child: AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: c.doubleSpeedStatus.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x88000000),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 32,
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          text: t.player.double_speed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          children: const [
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.fast_forward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        /// 时间进度 toast
        Obx(
          () => Align(
            alignment: Alignment.topCenter,
            child: FractionalTranslation(
              translation: const Offset(0.0, 1.0), // 上下偏移量（负数向上偏移）
              child: AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: c.isSliderMoving.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: IntrinsicWidth(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x88000000),
                      borderRadius: BorderRadius.circular(64.0),
                    ),
                    height: 34.0,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return Text(
                            c.sliderTempPosition.value.inMinutes >= 60
                                ? printDurationWithHours(
                                    c.sliderTempPosition.value,
                                  )
                                : printDuration(c.sliderTempPosition.value),
                            style: textStyle,
                          );
                        }),
                        const SizedBox(width: 2),
                        const Text('/', style: textStyle),
                        const SizedBox(width: 2),
                        Obx(
                          () => Text(
                            c.duration.value.inMinutes >= 60
                                ? printDurationWithHours(c.duration.value)
                                : printDuration(c.duration.value),
                            style: textStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        /// 音量🔊 控制条展示
        Obx(
          () => Align(
            child: AnimatedOpacity(
              curve: Curves.easeInOut,
              opacity: _ctr.volumeIndicator.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x88000000),
                  borderRadius: BorderRadius.circular(64.0),
                ),
                height: 34.0,
                width: 70.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 34.0,
                      width: 28.0,
                      alignment: Alignment.centerRight,
                      child: Icon(
                        _ctr.volumeValue.value == 0.0
                            ? Icons.volume_off
                            : _ctr.volumeValue.value < 0.5
                            ? Icons.volume_down
                            : Icons.volume_up,
                        color: const Color(0xFFFFFFFF),
                        size: 20.0,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${(_ctr.volumeValue.value * 100.0).round()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// 亮度🌞 控制条展示
        Obx(
          () => Align(
            child: AnimatedOpacity(
              curve: Curves.easeInOut,
              opacity: _ctr.brightnessIndicator.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x88000000),
                  borderRadius: BorderRadius.circular(64.0),
                ),
                height: 34.0,
                width: 70.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 30.0,
                      width: 28.0,
                      alignment: Alignment.centerRight,
                      child: Icon(
                        _ctr.brightnessValue.value < 1.0 / 3.0
                            ? Icons.brightness_low
                            : _ctr.brightnessValue.value < 2.0 / 3.0
                            ? Icons.brightness_medium
                            : Icons.brightness_high,
                        color: const Color(0xFFFFFFFF),
                        size: 18.0,
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    Expanded(
                      child: Text(
                        '${(_ctr.brightnessValue.value * 100.0).round()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Obx(() {
        //   if (c.buffered.value == Duration.zero) {
        //     return Positioned.fill(
        //       child: Container(
        //         color: Colors.black,
        //         child: Center(
        //           child: Image.asset(
        //             'assets/images/loading.gif',
        //             height: 25,
        //           ),
        //         ),
        //       ),
        //     );
        //   } else {
        //     return Container();
        //   }
        // }),

        /// 手势
        Positioned.fill(
          left: 16,
          top: 25,
          right: 15,
          bottom: 15,
          child: GestureDetector(
            onTap: () {
              c.controls = !c.showControls.value;
            },
            onDoubleTapDown: (TapDownDetails details) {
              if (c.controlsLock.value) {
                return;
              }
              final double totalWidth = MediaQuery.sizeOf(context).width;
              final double tapPosition = details.localPosition.dx;
              final double sectionWidth = totalWidth / 3;
              String type = 'left';
              if (tapPosition < sectionWidth) {
                type = 'left';
              } else if (tapPosition < sectionWidth * 2) {
                type = 'center';
              } else {
                type = 'right';
              }
              doubleTapFuc(type);
            },
            onLongPressStart: (LongPressStartDetails detail) {
              HapticFeedback.lightImpact();
              c.setDoubleSpeedStatus(true);
            },
            onLongPressEnd: (LongPressEndDetails details) {
              c.setDoubleSpeedStatus(false);
            },

            /// 水平位置 快进 live模式下禁用
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              // live模式下禁用 锁定时🔒禁用
              if (c.controlsLock.value) {
                return;
              }
              // final double tapPosition = details.localPosition.dx;
              final int curSliderPosition =
                  c.sliderPosition.value.inMilliseconds;
              final double scale = 90000 / MediaQuery.sizeOf(context).width;
              final Duration pos = Duration(
                milliseconds:
                    curSliderPosition + (details.delta.dx * scale).round(),
              );
              final Duration result = pos.clamp(
                Duration.zero,
                c.duration.value,
              );
              c.onUpdatedSliderProgress(result);
              c.onChangedSliderStart();
              // _initTapPositoin = tapPosition;
            },
            onHorizontalDragEnd: (DragEndDetails details) {
              if (c.controlsLock.value) {
                return;
              }
              c.onChangedSliderEnd();
              c.seekTo(c.sliderPosition.value, type: 'slider');
            },
            // 垂直方向 音量/亮度调节
            onVerticalDragUpdate: (DragUpdateDetails details) async {
              final double totalWidth = MediaQuery.sizeOf(context).width;
              final double tapPosition = details.localPosition.dx;
              final double sectionWidth = totalWidth / 3;
              final double delta = details.delta.dy;

              /// 锁定时禁用
              if (c.controlsLock.value) {
                return;
              }
              if (lastFullScreenToggleTime != null &&
                  DateTime.now().difference(lastFullScreenToggleTime!) <
                      const Duration(milliseconds: 500)) {
                return;
              }
              if (tapPosition < sectionWidth) {
                // 左边区域 👈
                final double level =
                    (c.isFullScreen.value
                        ? Get.size.height
                        : screenWidth * 9 / 16) *
                    3;
                final double brightness =
                    _ctr.brightnessValue.value - delta / level;
                final double result = brightness.clamp(0.0, 1.0);
                setBrightness(result);
              } else if (tapPosition < sectionWidth * 2) {
                // 全屏
                final double dy = details.delta.dy;
                const double threshold = 7.0; // 滑动阈值
                if (dy > _distance && dy > threshold) {
                  if (c.isFullScreen.value) {
                    lastFullScreenToggleTime = DateTime.now();
                    // 下滑退出全屏
                    await widget.controller.triggerFullScreen(status: false);
                  }
                  _distance = 0.0;
                } else if (dy < _distance && dy < -threshold) {
                  if (!c.isFullScreen.value) {
                    lastFullScreenToggleTime = DateTime.now();
                    // 上滑进入全屏
                    await widget.controller.triggerFullScreen();
                  }
                  _distance = 0.0;
                }
                _distance = dy;
              } else {
                // 右边区域 👈
                final double level =
                    (c.isFullScreen.value
                        ? Get.size.height
                        : screenWidth * 9 / 16) *
                    3;
                final double volume = _ctr.volumeValue.value - delta / level;
                final double result = volume.clamp(0.0, 1.0);
                setVolume(result);
              }
            },
            onVerticalDragEnd: (DragEndDetails details) {},
          ),
        ),

        // 头部、底部控制条
        SafeArea(
          top: false,
          bottom: false,
          child: Obx(
            () => Visibility(
              visible: !widget.inPip,
              child: Column(
                children: [
                  if (widget.headerControl != null || c.headerControl != null)
                    ClipRect(
                      child: AppBarAni(
                        controller: animationController,
                        visible: !c.controlsLock.value && c.showControls.value,
                        position: 'top',
                        child: widget.headerControl ?? c.headerControl!,
                      ),
                    ),
                  const Spacer(),
                  ClipRect(
                    child: AppBarAni(
                      controller: animationController,
                      visible: !c.controlsLock.value && c.showControls.value,
                      position: 'bottom',
                      child:
                          widget.bottomControl ??
                          BottomControl(
                            controller: widget.controller,
                            triggerFullScreen:
                                widget.controller.triggerFullScreen,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// 进度条
        Obx(() {
          final int value = c.sliderPositionSeconds.value;
          final int max = c.durationSeconds.value;
          final int buffer = c.bufferedSeconds.value;

          if (c.showControls.value) {
            return const SizedBox.shrink();
          }

          if (value > max || max <= 0) {
            return const SizedBox.shrink();
          }

          return Positioned(
            bottom: -1.5,
            left: 0,
            right: 0,
            child: ProgressBar(
              progress: Duration(seconds: value),
              buffered: Duration(seconds: buffer),
              total: Duration(seconds: max),
              progressBarColor: colorTheme,
              baseBarColor: Colors.white.withAlpha((0.2 * 255).round()),
              bufferedBarColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha((0.4 * 255).round()),
              timeLabelLocation: TimeLabelLocation.none,
              thumbColor: colorTheme,
              barHeight: 3,
              thumbRadius: 0.0,
              // onDragStart: (duration) {
              //   c.onChangedSliderStart();
              // },
              // onDragEnd: () {
              //   c.onChangedSliderEnd();
              // },
              // onDragUpdate: (details) {
              //   print(details);
              // },
              // onSeek: (duration) {
              //   feedBack();
              //   c.onChangedSlider(duration.inSeconds.toDouble());
              //   c.seekTo(duration);
              // },
            ),
            // SlideTransition(
            //     position: Tween<Offset>(
            //       begin: Offset.zero,
            //       end: const Offset(0, -1),
            //     ).animate(CurvedAnimation(
            //       parent: animationController,
            //       curve: Curves.easeInOut,
            //     )),
            //     child: ),
          );
        }),

        // 锁
        Obx(
          () => Align(
            alignment: Alignment.centerLeft,
            child: FractionalTranslation(
              translation: const Offset(1, 0.0),
              child: Visibility(
                visible: c.showControls.value,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.black26, Colors.transparent],
                    ),
                  ),
                  child: ComBtn(
                    icon: Icon(
                      c.controlsLock.value ? Icons.lock : Icons.lock_open,
                      color: Colors.white,
                    ),
                    fuc: () => c.onLockControl(!c.controlsLock.value),
                  ),
                ),
              ),
            ),
          ),
        ),
        //
        Obx(() {
          if (c.dataStatus.loading || c.isBuffering.value) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.black26, Colors.transparent],
                  ),
                ),
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            return const SizedBox();
          }
        }),

        /// 点击 快进/快退
        Obx(
          () => Visibility(
            visible:
                _ctr.mountSeekBackwardButton.value ||
                _ctr.mountSeekForwardButton.value,
            child: Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: _ctr.mountSeekBackwardButton.value
                        ? TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: _ctr.hideSeekBackwardButton.value
                                  ? 0.0
                                  : 1.0,
                            ),
                            duration: const Duration(milliseconds: 500),
                            builder:
                                (
                                  BuildContext context,
                                  double value,
                                  Widget? child,
                                ) => Opacity(opacity: value, child: child),
                            onEnd: () {
                              if (_ctr.hideSeekBackwardButton.value) {
                                _ctr.hideSeekBackwardButton.value = false;
                                _ctr.mountSeekBackwardButton.value = false;
                              }
                            },
                            child: BackwardSeekIndicator(
                              onChanged: (Duration value) {
                                // _seekBarDeltaValueNotifier.value = -value;
                              },
                              onSubmitted: (Duration value) {
                                _ctr.hideSeekBackwardButton.value = true;
                                final Player player =
                                    widget.controller.videoPlayerController!;
                                Duration result = player.state.position - value;
                                result = result.clamp(
                                  Duration.zero,
                                  player.state.duration,
                                );
                                player.seek(result);
                                widget.controller.play();
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width / 4,
                    ),
                  ),
                  Expanded(
                    child: _ctr.mountSeekForwardButton.value
                        ? TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: _ctr.hideSeekForwardButton.value ? 0.0 : 1.0,
                            ),
                            duration: const Duration(milliseconds: 500),
                            builder:
                                (
                                  BuildContext context,
                                  double value,
                                  Widget? child,
                                ) => Opacity(opacity: value, child: child),
                            onEnd: () {
                              if (_ctr.hideSeekForwardButton.value) {
                                _ctr.hideSeekForwardButton.value = false;
                                _ctr.mountSeekForwardButton.value = false;
                              }
                            },
                            child: ForwardSeekIndicator(
                              onChanged: (Duration value) {
                                // _seekBarDeltaValueNotifier.value = value;
                              },
                              onSubmitted: (Duration value) {
                                _ctr.hideSeekForwardButton.value = true;
                                final Player player =
                                    widget.controller.videoPlayerController!;
                                Duration result = player.state.position + value;
                                result = result.clamp(
                                  Duration.zero,
                                  player.state.duration,
                                );
                                player.seek(result);
                                widget.controller.play();
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PLVideoPlayerController extends GetxController {
  RxBool mountSeekBackwardButton = false.obs;
  RxBool mountSeekForwardButton = false.obs;
  RxBool hideSeekBackwardButton = false.obs;
  RxBool hideSeekForwardButton = false.obs;

  RxDouble brightnessValue = 0.0.obs;
  RxBool brightnessIndicator = false.obs;

  RxDouble volumeValue = 0.0.obs;
  RxBool volumeIndicator = false.obs;

  RxDouble distance = 0.0.obs;
  // 初始手指落下位置
  RxDouble initTapPositoin = 0.0.obs;

  RxBool volumeInterceptEventStream = false.obs;

  // 双击快进 展示样式
  void onDoubleTapSeekForward() {
    mountSeekForwardButton.value = true;
  }

  void onDoubleTapSeekBackward() {
    mountSeekBackwardButton.value = true;
  }
}
