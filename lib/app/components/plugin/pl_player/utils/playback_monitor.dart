import 'dart:async';
import 'dart:math';

import 'package:media_kit/media_kit.dart';

/// Watches an online playback for the automatic resolution choice: how fast
/// the video downloads while the player fills its buffer, and whether
/// playback stalls afterwards.
class PlaybackMonitor {
  PlaybackMonitor(
    this._player, {
    required this.onSpeed,
    required this.onStall,
    required this.lastSeekAt,
  });

  final Player _player;

  /// Receives the fastest download speed seen, in bytes per second.
  final void Function(double bytesPerSecond) onSpeed;

  /// Called at most once, when playback stops to wait for data.
  final void Function() onStall;

  /// When playback last jumped; waiting for data right after is expected.
  final DateTime? Function() lastSeekAt;

  /// The player downloads fastest while it fills its buffer, early on.
  static const _samples = 12;

  Timer? _sampler;
  StreamSubscription<bool>? _buffering;
  int _sampled = 0;
  double _fastest = 0;
  bool _stalled = false;

  void start() {
    _sampler = Timer.periodic(const Duration(seconds: 1), (_) => _sample());
    _buffering = _player.stream.buffering.listen(_onBuffering);
  }

  void dispose() {
    // A few samples are still a fair measure when the page closes early.
    if (_sampled >= 3) _report();
    _sampler?.cancel();
    _buffering?.cancel();
  }

  Future<void> _sample() async {
    if (_sampled++ >= _samples) {
      _report();
      return;
    }
    final platform = _player.platform;
    if (platform is! NativePlayer) return;
    try {
      final speed = double.tryParse(await platform.getProperty('cache-speed'));
      if (speed != null) _fastest = max(_fastest, speed);
    } catch (_) {
      // The player went away between samples.
    }
  }

  void _report() {
    _sampler?.cancel();
    if (_fastest > 0) onSpeed(_fastest);
    _fastest = 0;
  }

  void _onBuffering(bool buffering) {
    if (!buffering || _stalled) return;
    // The first load and waiting after a seek are not stalls.
    if (_player.state.position < const Duration(seconds: 2)) return;
    final seek = lastSeekAt();
    if (seek != null &&
        DateTime.now().difference(seek) < const Duration(seconds: 3)) {
      return;
    }
    _stalled = true;
    onStall();
  }
}
