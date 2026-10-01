import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../utils/parallel_range_proxy.dart';
import '../../../../utils/log_util.dart';

/// Watches an online playback for the automatic resolution choice: how fast
/// the video downloads while the player fills its buffer, and whether
/// playback stalls afterwards.
class PlaybackMonitor {
  PlaybackMonitor(
    this._player, {
    required this.onSpeed,
    required this.onStall,
    required this.lastSeekAt,
    this.readSpeed,
    this.readSample,
  });

  final Player _player;

  /// Receives a conservative estimate, in bytes per second.
  final void Function(double bytesPerSecond) onSpeed;

  /// Called at most once, when playback stops to wait for data.
  final void Function() onStall;

  /// When playback last jumped; waiting for data right after is expected.
  final DateTime? Function() lastSeekAt;

  /// For accelerated playback, measure distinct upstream windows, not localhost.
  final FutureOr<TransferSpeed?> Function()? readSpeed;

  @visibleForTesting
  final FutureOr<PlaybackSample?> Function()? readSample;

  /// The player downloads fastest while it fills its buffer, early on.
  static const _samples = 12;

  Timer? _sampler;
  StreamSubscription<bool>? _buffering;
  Timer? _stallTimer;
  int _sampled = 0;
  final List<double> _speeds = [];
  bool _stalled = false;
  bool _disposed = false;
  bool _reading = false;
  bool _reported = false;
  DateTime? _lastMeasurement;

  void start() {
    _sampler = Timer.periodic(const Duration(seconds: 1), (_) => _sample());
    _buffering = _player.stream.buffering.listen(_onBuffering);
  }

  void dispose() {
    if (_disposed) return;
    _report();
    _disposed = true;
    _sampler?.cancel();
    _buffering?.cancel();
    _stallTimer?.cancel();
  }

  Future<void> _sample() async {
    if (_disposed || _stalled || _reported || _reading) return;
    if (_sampled++ >= _samples) {
      _report();
      return;
    }
    if (!_player.state.playing || _player.state.completed) return;
    if (_recentSeek()) return;
    _reading = true;
    try {
      final sample = readSample != null
          ? await readSample!()
          : await _readSample();
      if (_disposed ||
          _stalled ||
          _reported ||
          sample == null ||
          _recentSeek()) {
        return;
      }
      final measurement = sample.speed;
      if (measurement != null &&
          measurement.measuredAt != _lastMeasurement &&
          measurement.bytesPerSecond.isFinite &&
          measurement.bytesPerSecond > 0) {
        _lastMeasurement = measurement.measuredAt;
        _speeds.add(measurement.bytesPerSecond);
      }
      // Keep the last filling window, then stop. Later reads merely replenish
      // the bounded cache at the video's bitrate, regardless of link capacity.
      if (sample.cacheFull) _report();
    } catch (_) {
      // The player went away between samples.
    } finally {
      _reading = false;
    }
  }

  Future<PlaybackSample?> _readSample() async {
    final platform = _player.platform;
    if (platform is! NativePlayer) return null;
    final values = await Future.wait([
      platform.getProperty('demuxer-cache-idle'),
      platform.getProperty('demuxer-cache-duration'),
      platform.getProperty('demuxer-cache-state/fw-bytes'),
    ]);
    final full =
        values[0] == 'yes' ||
        (double.tryParse(values[1]) ?? 0) >= 27 ||
        (int.tryParse(values[2]) ?? 0) >= 28 * 1024 * 1024;
    TransferSpeed? speed;
    if (readSpeed != null) {
      speed = await readSpeed!();
    } else {
      final rate = double.tryParse(await platform.getProperty('cache-speed'));
      if (rate != null) speed = TransferSpeed(rate, DateTime.now());
    }
    return PlaybackSample(speed, cacheFull: full);
  }

  void _report() {
    if (_reported) return;
    _reported = true;
    _sampler?.cancel();
    if (!_stalled && _speeds.length >= 2) {
      final speed = estimate(_speeds);
      if (speed != null) onSpeed(speed);
    }
    LogUtil.debug(
      'Playback sampling finished: ${_speeds.length} filling windows',
    );
    _speeds.clear();
  }

  @visibleForTesting
  static double? estimate(List<double> samples) {
    final valid = samples.where((s) => s.isFinite && s > 0).toList()..sort();
    // The second fastest window rejects one isolated burst without allowing
    // many consumption-limited samples to drown out the initial buffer fill.
    return valid.length < 2 ? null : valid[valid.length - 2];
  }

  bool _recentSeek() {
    final seek = lastSeekAt();
    return seek != null &&
        DateTime.now().difference(seek) < const Duration(seconds: 3);
  }

  void _onBuffering(bool buffering) {
    if (!buffering) {
      _stallTimer?.cancel();
      _stallTimer = null;
      return;
    }
    if (_stalled || _disposed) return;
    // The first load and waiting after a seek are not stalls.
    if (_player.state.position < const Duration(seconds: 2)) return;
    if (_recentSeek() || !_player.state.playing || _player.state.completed) {
      return;
    }
    _stallTimer ??= Timer(const Duration(seconds: 2), () {
      _stallTimer = null;
      if (_disposed ||
          _stalled ||
          _recentSeek() ||
          !_player.state.playing ||
          _player.state.completed ||
          _player.state.buffer - _player.state.position >
              const Duration(seconds: 2)) {
        return;
      }
      // Brief rebuffering, pause and seeks must not poison the next choice.
      // Settle earlier samples before lowering the estimate, never afterwards.
      _report();
      _stalled = true;
      onStall();
    });
  }
}

class PlaybackSample {
  const PlaybackSample(this.speed, {this.cacheFull = false});
  final TransferSpeed? speed;
  final bool cacheFull;
}
