import 'quality_picker.dart';

/// Recent passive observations, scoped to a CDN host and transfer mode. A VPN
/// node can change outside the app, so old observations expire quickly.
class PlaybackBandwidth {
  static const lifetime = Duration(minutes: 5);
  final Map<String, (double, DateTime)> _samples = {};

  String _key(String url, bool accelerated) =>
      '${accelerated ? "parallel" : "direct"}:${Uri.parse(url).host}';

  double? speedFor(
    String url, {
    required bool accelerated,
    DateTime? now,
    bool allowOtherHosts = true,
  }) {
    final at = now ?? DateTime.now();
    bool fresh((double, DateTime) sample) {
      final age = at.difference(sample.$2);
      return age >= Duration.zero && age < lifetime;
    }

    final key = _key(url, accelerated);
    final sample = _samples[key];
    if (sample != null && fresh(sample)) return sample.$1;
    if (!allowOtherHosts) return null;
    // Iwara assigns different CDN hosts to variants and rotates them on reopen.
    // For an unseen host, use the latest route observation with a further 20%
    // margin. A known host's slower observation always takes precedence.
    final mode = key.split(':').first;
    final recent =
        _samples.entries
            .where(
              (entry) => entry.key.startsWith('$mode:') && fresh(entry.value),
            )
            .toList()
          ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    return recent.isEmpty ? null : recent.first.value.$1 * .8;
  }

  void record(
    String url,
    double speed, {
    required bool accelerated,
    DateTime? now,
  }) {
    if (!speed.isFinite || speed <= 0) return;
    final at = now ?? DateTime.now();
    final previous = speedFor(
      url,
      accelerated: accelerated,
      now: at,
      allowOtherHosts: false,
    );
    _put(url, accelerated, QualityPicker.blend(previous, speed), at);
  }

  void stall(
    String url,
    String resolution, {
    required bool accelerated,
    double? sourceBitrate,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final speed = QualityPicker.afterStall(
      speedFor(url, accelerated: accelerated, now: at),
      resolution,
      sourceBitrate: sourceBitrate,
    );
    _put(url, accelerated, speed, at);
  }

  void _put(String url, bool accelerated, double speed, DateTime at) {
    final key = _key(url, accelerated);
    _samples.remove(key);
    if (_samples.length >= 8) _samples.remove(_samples.keys.first);
    _samples[key] = (speed, at);
  }

  PlaybackBandwidth();

  PlaybackBandwidth.fromJson(dynamic json) {
    // The legacy unscoped numeric estimate can be a cache burst or a bitrate.
    // Only restore observations made with the passive sampler below.
    if (json is! Map || json['version'] != 1 || json['samples'] is! Map) return;
    for (final entry in (json['samples'] as Map).entries.take(8)) {
      final value = entry.value;
      if (entry.key is! String || value is! Map) continue;
      final speed = value['speed'];
      final at = value['at'];
      if (speed is! num || !speed.isFinite || speed <= 0 || at is! String) {
        continue;
      }
      final time = DateTime.tryParse(at);
      if (time != null) _samples[entry.key] = (speed.toDouble(), time);
    }
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'samples': {
      for (final entry in _samples.entries)
        entry.key: {
          'speed': entry.value.$1,
          'at': entry.value.$2.toIso8601String(),
        },
    },
  };
}
