import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/playback_bandwidth.dart';

void main() {
  const url = 'https://a.iwara.tv/file?signature=private';
  final now = DateTime(2026, 10, 2);

  test('scopes estimates by CDN and transfer mode without keeping URLs', () {
    final history = PlaybackBandwidth()
      ..record(url, 2e6, accelerated: true, now: now);
    expect(history.speedFor(url, accelerated: true, now: now), 2e6);
    expect(history.speedFor(url, accelerated: false, now: now), isNull);
    expect(
      history.speedFor('https://b.iwara.tv/video', accelerated: true, now: now),
      1.6e6,
    );
    expect(
      history.speedFor(
        'https://a.iwara.tv/another',
        accelerated: true,
        now: now,
      ),
      2e6,
    );
    expect(history.toJson().toString(), isNot(contains('signature')));
    final restored = PlaybackBandwidth.fromJson(history.toJson());
    expect(restored.speedFor(url, accelerated: true, now: now), 2e6);
  });

  test('expires old estimates and handles clock changes', () {
    final history = PlaybackBandwidth()
      ..record(url, 2e6, accelerated: false, now: now);
    expect(
      history.speedFor(
        url,
        accelerated: false,
        now: now.add(PlaybackBandwidth.lifetime),
      ),
      isNull,
    );
    expect(
      history.speedFor(
        url,
        accelerated: false,
        now: now.subtract(const Duration(seconds: 1)),
      ),
      isNull,
    );
    history.record(
      url,
      1e5,
      accelerated: false,
      now: now.add(const Duration(minutes: 6)),
    );
    expect(
      history.speedFor(
        url,
        accelerated: false,
        now: now.add(const Duration(minutes: 6)),
      ),
      1e5,
    );
  });

  test('a known slow CDN overrides a faster recent fallback', () {
    final history = PlaybackBandwidth()
      ..record(url, 1e5, accelerated: false, now: now)
      ..record(
        'https://b.iwara.tv/video',
        2e6,
        accelerated: false,
        now: now.add(const Duration(seconds: 1)),
      );
    expect(
      history.speedFor(
        url,
        accelerated: false,
        now: now.add(const Duration(seconds: 1)),
      ),
      1e5,
    );
    expect(
      history.speedFor(
        'https://c.iwara.tv/video',
        accelerated: false,
        now: now.add(const Duration(seconds: 1)),
      ),
      1.6e6,
    );
  });

  test('ignores invalid or legacy unscoped estimates', () {
    for (final json in [
      null,
      2e6,
      {'version': 0},
      {'version': 1, 'samples': []},
    ]) {
      expect(
        PlaybackBandwidth.fromJson(json).speedFor(url, accelerated: false),
        isNull,
      );
    }
    final history = PlaybackBandwidth();
    for (final speed in [double.nan, double.infinity, 0.0, -1.0]) {
      history.record(url, speed, accelerated: false, now: now);
    }
    expect(history.speedFor(url, accelerated: false, now: now), isNull);
  });

  test('a sustained stall reduces the affected route only', () {
    final history = PlaybackBandwidth()
      ..record(url, 2e6, accelerated: false, now: now)
      ..record(url, 3e6, accelerated: true, now: now)
      ..stall(url, 'Source', accelerated: false, sourceBitrate: 10e6, now: now);
    expect(
      history.speedFor(url, accelerated: false, now: now),
      lessThan(10e6 / 8 / .7),
    );
    expect(history.speedFor(url, accelerated: true, now: now), 3e6);
  });
}
