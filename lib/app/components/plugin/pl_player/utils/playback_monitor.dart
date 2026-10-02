import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../utils/parallel_range_proxy.dart';
import '../../../../utils/playback_cache.dart';
import '../../../../utils/log_util.dart';

/// Learns from real buffer fills. Once full, check infrequently for new network
/// activity; cached playback and pauses cannot renew an old bandwidth sample.
class PlaybackMonitor {
  PlaybackMonitor(
    this._player, {
    required this.onSpeed,
    required this.onStall,
    required this.lastSeekAt,
    this.readSpeed,
    this.readSample,
    this.preload = PlaybackPreload.seconds30,
    DateTime? startedAt,
  }) : _startedAt = startedAt ?? DateTime.now();

  final Player _player;
  final void Function(double bytesPerSecond) onSpeed;
  final void Function() onStall;
  final DateTime? Function() lastSeekAt;
  final PlaybackPreload preload;
  final DateTime _startedAt;

  /// Accelerated playback measures the upstream, never the localhost burst.
  final FutureOr<TransferSpeed?> Function()? readSpeed;

  @visibleForTesting
  final FutureOr<PlaybackSample?> Function()? readSample;

  static const _samples = 12;
  Timer? _sampler;
  StreamSubscription<bool>? _buffering;
  Timer? _stallTimer;
  int _sampled = 0, _idleTicks = 0;
  final List<double> _speeds = [];
  bool _stalled = false, _disposed = false, _reading = false;
  bool _reported = false, _initial = true;
  DateTime? _lastMeasurement;
  double? _cacheEnd;

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
    if (_disposed || _stalled || _reading) return;
    if (!_player.state.playing || _player.state.completed || _recentSeek()) {
      return;
    }
    // These are local property reads, not requests or speed-test downloads.
    if (_reported && ++_idleTicks < 15) return;
    _idleTicks = 0;
    if (!_reported && _sampled++ >= _samples) {
      _report();
      return;
    }
    _reading = true;
    try {
      final sample = readSample != null
          ? await readSample!()
          : await _readSample();
      if (_disposed ||
          _stalled ||
          sample == null ||
          _recentSeek() ||
          !_player.state.playing ||
          _player.state.completed) {
        return;
      }
      final previousEnd = _cacheEnd;
      _cacheEnd = sample.cacheEnd ?? _cacheEnd;
      if (_reported) {
        // Seeing a nonzero cached rate is insufficient: the cache must actually
        // be advancing while the demuxer reads, outside a seek.
        if (!sample.reading ||
            sample.cacheEnd == null ||
            previousEnd == null ||
            sample.cacheEnd! <= previousEnd) {
          return;
        }
        _reported = false;
        _sampled = 1;
      }
      final measurement = sample.speed;
      final advancing =
          sample.cacheEnd != null &&
          previousEnd != null &&
          sample.cacheEnd! > previousEnd;
      if ((_initial || advancing) &&
          measurement != null &&
          measurement.measuredAt != _lastMeasurement &&
          measurement.bytesPerSecond.isFinite &&
          measurement.bytesPerSecond > 0) {
        _lastMeasurement = measurement.measuredAt;
        _speeds.add(measurement.bytesPerSecond);
      }
      if (sample.cacheFull) {
        final elapsed =
            DateTime.now().difference(_startedAt).inMicroseconds / 1e6;
        // Packet bytes already cached provide a conservative end-to-end floor,
        // even when a fast route fills the whole buffer in less than one window.
        final floor = _initial && sample.loadedBytes > 0 && elapsed > 0
            ? sample.loadedBytes / max(elapsed, .25)
            : null;
        _report(full: true, fillingFloor: floor);
      }
    } catch (_) {
      // A source can close while native properties are being read.
    } finally {
      _reading = false;
    }
  }

  Future<PlaybackSample?> _readSample() async {
    final platform = _player.platform;
    if (platform is! NativePlayer) return null;
    final raw = await platform.getProperty('demuxer-cache-state');
    Map<String, dynamic> state = {};
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) state = parsed;
    } on FormatException {
      // Older backends may only expose the individual properties.
    }
    if (state.isEmpty) {
      state = {
        'idle': await platform.getProperty('demuxer-cache-idle') == 'yes',
        'cache-duration': double.tryParse(
          await platform.getProperty('demuxer-cache-duration'),
        ),
        'raw-input-rate': double.tryParse(
          await platform.getProperty('cache-speed'),
        ),
      };
    }
    final speed = readSpeed != null
        ? await readSpeed!()
        : TransferSpeed(
            PlaybackSample.number(state['raw-input-rate']),
            DateTime.now(),
          );
    return PlaybackSample.fromState(state, preload: preload, speed: speed);
  }

  void _report({bool full = false, double? fillingFloor}) {
    if (_reported) return;
    _reported = true;
    // A brief refill is often consumption-limited. It cannot replace an
    // earlier capacity observation with the video's bitrate.
    final speed = !_initial && _speeds.length < 3
        ? null
        : estimate(_speeds, fillingFloor: full ? fillingFloor : null);
    if (!_stalled && speed != null) onSpeed(speed);
    LogUtil.debug(
      'Playback sampling finished: ${_speeds.length} filling windows',
    );
    _speeds.clear();
    _initial = false;
  }

  @visibleForTesting
  static double? estimate(List<double> samples, {double? fillingFloor}) {
    final valid = samples.where((s) => s.isFinite && s > 0).toList()..sort();
    if (valid.length >= 3) return valid[valid.length - 2];
    if (fillingFloor != null && fillingFloor.isFinite && fillingFloor > 0) {
      // Short fills cannot use the second-highest rule: it selects startup.
      // Bound a single peak by bytes that really arrived since opening.
      return valid.isEmpty ? fillingFloor : min(valid.last, fillingFloor);
    }
    return valid.length == 2 ? valid.first : null;
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
      _report();
      _stalled = true;
      onStall();
    });
  }
}

class PlaybackSample {
  const PlaybackSample(
    this.speed, {
    this.cacheFull = false,
    this.loadedBytes = 0,
    this.reading = false,
    this.cacheEnd,
  });

  final TransferSpeed? speed;
  final bool cacheFull;
  final double loadedBytes;
  final bool reading;
  final double? cacheEnd;

  /// Read the parent JSON property: some shipped mpv versions return an empty
  /// string for node subpaths such as demuxer-cache-state/fw-bytes.
  factory PlaybackSample.fromState(
    Map<String, dynamic> state, {
    required PlaybackPreload preload,
    TransferSpeed? speed,
  }) {
    final idle = state['idle'] == true;
    final eof = state['eof'] == true;
    final seconds = preload.seconds;
    final full =
        idle ||
        eof ||
        (seconds != null && number(state['cache-duration']) >= seconds * .95) ||
        number(state['fw-bytes']) >= preload.forwardBytes * .95;
    return PlaybackSample(
      speed,
      cacheFull: full,
      loadedBytes: number(
        state[preload.diskCache ? 'file-cache-bytes' : 'total-bytes'],
      ),
      reading: !idle && !eof,
      cacheEnd: state['cache-end'] is num ? number(state['cache-end']) : null,
    );
  }

  static double number(dynamic value) =>
      value is num && value.isFinite && value > 0 ? value.toDouble() : 0;
}
