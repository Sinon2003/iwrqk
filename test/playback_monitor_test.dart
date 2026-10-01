import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/components/plugin/pl_player/utils/playback_monitor.dart';
import 'package:iwrqk/app/utils/parallel_range_proxy.dart';
import 'package:media_kit/media_kit.dart';

class _PlayerStream implements PlayerStream {
  _PlayerStream(this.buffering);
  @override
  final Stream<bool> buffering;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Player implements Player {
  _Player(Stream<bool> buffering) : stream = _PlayerStream(buffering);
  @override
  final PlayerStream stream;
  @override
  PlayerState state = PlayerState(
    position: const Duration(seconds: 10),
    playing: true,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('estimates sustained speed without selecting a cache burst', () {
    expect(PlaybackMonitor.estimate([100, 110, 120, 10000]), 120);
    expect(PlaybackMonitor.estimate([0, double.nan, double.infinity]), isNull);
  });

  testWidgets(
    'a stall reduction is never overwritten by earlier speed samples',
    (tester) async {
      final buffering = StreamController<bool>();
      final events = <String>[];
      var window = 0;
      final monitor = PlaybackMonitor(
        _Player(buffering.stream),
        readSample: () => PlaybackSample(
          TransferSpeed(1000, DateTime(2026).add(Duration(seconds: window++))),
        ),
        onSpeed: (_) => events.add('speed'),
        onStall: () => events.add('stall'),
        lastSeekAt: () => null,
      )..start();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      buffering.add(true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(events, ['speed', 'stall']);
      await tester.pump(const Duration(seconds: 15));
      monitor.dispose();
      expect(events, ['speed', 'stall']);
      unawaited(buffering.close());
      await tester.pump();
    },
  );

  testWidgets('discard pending async samples when playback is disposed', (
    tester,
  ) async {
    final buffering = StreamController<bool>();
    final pending = Completer<PlaybackSample?>();
    final values = <double>[];
    final monitor = PlaybackMonitor(
      _Player(buffering.stream),
      readSample: () => pending.future,
      onSpeed: values.add,
      onStall: () {},
      lastSeekAt: () => null,
    )..start();
    await tester.pump(const Duration(seconds: 3));
    monitor.dispose();
    pending.complete(PlaybackSample(TransferSpeed(1000, DateTime.now())));
    await tester.pump();
    expect(values, isEmpty);
    unawaited(buffering.close());
    await tester.pump();
  });

  testWidgets('stops measuring when the bounded cache fills', (tester) async {
    final buffering = StreamController<bool>();
    final values = <double>[];
    var calls = 0;
    final monitor = PlaybackMonitor(
      _Player(buffering.stream),
      readSample: () {
        calls++;
        return PlaybackSample(
          TransferSpeed(
            calls <= 2 ? 2e6 : 190e3,
            DateTime(2026).add(Duration(seconds: calls)),
          ),
          cacheFull: calls >= 3,
        );
      },
      onSpeed: values.add,
      onStall: () {},
      lastSeekAt: () => null,
    )..start();
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(calls, 3);
    expect(values, [2e6]);
    monitor.dispose();
    unawaited(buffering.close());
    await tester.pump();
  });

  testWidgets('repeated upstream windows are not additional evidence', (
    tester,
  ) async {
    final buffering = StreamController<bool>();
    final values = <double>[];
    final sample = PlaybackSample(TransferSpeed(50e6, DateTime(2026)));
    final monitor = PlaybackMonitor(
      _Player(buffering.stream),
      readSample: () => sample,
      onSpeed: values.add,
      onStall: () {},
      lastSeekAt: () => null,
    )..start();
    for (var i = 0; i < 13; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(values, isEmpty);
    monitor.dispose();
    unawaited(buffering.close());
    await tester.pump();
  });

  testWidgets('brief buffering, seeks, pause and end do not lower quality', (
    tester,
  ) async {
    final buffering = StreamController<bool>();
    final player = _Player(buffering.stream);
    DateTime? seek;
    var stalls = 0;
    final monitor = PlaybackMonitor(
      player,
      readSample: () => null,
      onSpeed: (_) {},
      onStall: () => stalls++,
      lastSeekAt: () => seek,
    )..start();
    buffering.add(true);
    await tester.pump(const Duration(seconds: 1));
    buffering.add(false);
    await tester.pump(const Duration(seconds: 3));
    seek = DateTime.now();
    buffering.add(true);
    await tester.pump(const Duration(seconds: 3));
    seek = null;
    player.state = player.state.copyWith(playing: false);
    buffering.add(true);
    await tester.pump(const Duration(seconds: 3));
    player.state = player.state.copyWith(playing: true, completed: true);
    buffering.add(true);
    await tester.pump(const Duration(seconds: 3));
    expect(stalls, 0);
    monitor.dispose();
    unawaited(buffering.close());
    await tester.pump();
  });
}
