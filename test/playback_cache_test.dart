import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/playback_cache.dart';
import 'package:iwrqk/app/components/plugin/pl_player/utils/playback_monitor.dart';

void main() {
  test('new and invalid preferences preserve the original memory budget', () {
    for (final value in [null, 'removed', 600]) {
      final preload = PlaybackPreload.fromSetting(value);
      expect(preload, PlaybackPreload.seconds30);
      expect(preload.forwardBytes + preload.backwardBytes, 40 << 20);
      expect(preload.properties['cache-on-disk'], 'no');
    }
    for (final preload in PlaybackPreload.values) {
      expect(PlaybackPreload.fromSetting(preload.name), preload);
    }
  });

  test('full preload preserves backward packets in temporary storage', () {
    final properties = PlaybackPreload.entireVideo.properties;
    expect(properties['cache-on-disk'], 'yes');
    expect(int.parse(properties['cache-secs']!), greaterThan(24 * 3600));
    expect(
      properties['demuxer-max-back-bytes'],
      properties['demuxer-max-bytes'],
    );
    expect(properties['demuxer-seekable-cache'], 'yes');
    expect(PlaybackPreload.entireVideo.eager, isTrue);
    expect(PlaybackPreload.seconds30.eager, isFalse);
  });

  test(
    'cache fullness follows the selected limits, including native JSON bytes',
    () {
      final state = {
        'cache-duration': 31,
        'fw-bytes': 8 << 20,
        'total-bytes': 9 << 20,
      };
      expect(
        PlaybackSample.fromState(
          state,
          preload: PlaybackPreload.seconds30,
        ).cacheFull,
        isTrue,
      );
      final longer = PlaybackSample.fromState(
        state,
        preload: PlaybackPreload.minutes3,
      );
      expect(longer.cacheFull, isFalse);
      expect(longer.loadedBytes, 9 << 20);
      expect(
        PlaybackSample.fromState({
          'fw-bytes': 32 << 20,
        }, preload: PlaybackPreload.seconds30).cacheFull,
        isTrue,
      );
      final disk = PlaybackSample.fromState({
        'eof': true,
        'fw-bytes': 2000,
        'file-cache-bytes': 20 << 20,
      }, preload: PlaybackPreload.entireVideo);
      expect(disk.cacheFull, isTrue);
      expect(disk.reading, isFalse);
      expect(disk.loadedBytes, 20 << 20);
    },
  );
}
