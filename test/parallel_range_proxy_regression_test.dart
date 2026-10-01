// Regressions from the transfer review. Real-sized chunks must exceed socket buffers.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/components/plugin/pl_player/utils/playback_monitor.dart';
import 'package:iwrqk/app/utils/parallel_range_proxy.dart';
import 'package:iwrqk/app/utils/quality_picker.dart';

/// A ranged file server whose every connection sends [piece] bytes per
/// [tick], like a route that throttles each connection on its own.
class _Origin {
  _Origin({
    this.tick = Duration.zero,
    this.cutAfter,
    this.piece = 1024,
    int size = 128 * 1024,
  }) : data = Uint8List(size) {
    for (var i = 0; i < size; i++) {
      data[i] = ((i * 7) ^ (i ~/ 997)) & 255;
    }
  }

  final Duration tick;

  /// Drops the connection this many bytes into every longer response.
  final int? cutAfter;
  final int piece;
  final Uint8List data;
  final ranges = <(int, int)>[];

  /// How much of each range the reader has taken, and those numbers at the
  /// moment each range was served in full.
  final written = <(int, int), int>{};
  final servedAt = <(int, int), Map<(int, int), int>>{};
  late HttpServer server;
  int active = 0, maxActive = 0;

  String get url => 'http://127.0.0.1:${server.port}/video';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      var closed = false;
      unawaited(
        request.response.done.then(
          (_) {
            closed = true;
          },
          onError: (_) {
            closed = true;
          },
        ),
      );
      active++;
      maxActive = max(maxActive, active);
      try {
        final selected = ParallelRangeProxy.parseRange(
          request.headers.value(HttpHeaders.rangeHeader),
          data.length,
        )!;
        final (start, end) = selected;
        ranges.add(selected);
        request.response
          ..statusCode = HttpStatus.partialContent
          ..contentLength = end - start + 1
          ..headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes $start-$end/${data.length}',
          );
        final cut = cutAfter;
        if (cut != null && end - start + 1 > cut) {
          final socket = await request.response.detachSocket();
          socket.add(Uint8List.sublistView(data, start, start + cut));
          await socket.flush();
          socket.destroy();
          return;
        }
        for (var at = start; at <= end && !closed; at += piece) {
          if (tick != Duration.zero) await Future<void>.delayed(tick);
          if (closed) break;
          final next = min(at + piece, end + 1);
          request.response.add(Uint8List.sublistView(data, at, next));
          await request.response.flush();
          written[selected] = next - start;
        }
        if (!closed) {
          servedAt[selected] = Map.of(written);
          await request.response.close();
        }
      } catch (_) {
        // The proxy abandons requests when it changes its mind.
      } finally {
        active--;
      }
    });
  }

  Future<void> close() => server.close(force: true);
}

Future<(int, Uint8List)> _read(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = BytesBuilder(copy: false);
    await for (final part in response) {
      bytes.add(part);
    }
    return (response.statusCode, bytes.takeBytes());
  } finally {
    client.close(force: true);
  }
}

ParallelRangeProxy _proxy({
  int chunkSize = 8192,
  Duration sampleDuration = const Duration(milliseconds: 20),
  Duration openTimeout = const Duration(seconds: 10),
}) => ParallelRangeProxy(
  chunkSize: chunkSize,
  sampleDuration: sampleDuration,
  openTimeout: openTimeout,
  preferredPort: 0,
  allowUpstream: (u) => u.host == '127.0.0.1',
);

void main() {
  test('limits extra connections without blocking ordinary readers', () async {
    final origin = _Origin(tick: const Duration(milliseconds: 10));
    await origin.start();
    final proxy = _proxy();
    try {
      final url = await proxy.wrap(origin.url);
      final results = await Future.wait([
        for (var i = 0; i < 6; i++) _read(url),
      ]);
      for (final (status, bytes) in results) {
        expect(status, HttpStatus.ok);
        expect(sha256.convert(bytes), sha256.convert(origin.data));
      }
      // Closing the abandoned initial requests can overlap one server tick.
      expect(origin.maxActive, lessThanOrEqualTo(6 + 3 + 3));
      expect(
        origin.ranges.any((range) => range.$2 < origin.data.length - 1),
        isTrue,
      );
    } finally {
      await proxy.close();
      await origin.close();
    }
  });

  test('bounds retries when all attempts make no progress', () async {
    final origin = _Origin(cutAfter: 0);
    await origin.start();
    final proxy = _proxy();
    try {
      await expectLater(
        _read(await proxy.wrap(origin.url)),
        throwsA(isA<HttpException>()),
      );
      expect(origin.ranges.length, 3);
    } finally {
      await proxy.close();
      await origin.close();
    }
  });

  test(
    'P6 discards an invalid initial response before accepting more readers',
    () async {
      final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final disconnected = Completer<void>();
      source.listen((request) async {
        request.response
          ..statusCode = HttpStatus.partialContent
          ..contentLength = 1024
          ..headers.set(HttpHeaders.contentRangeHeader, 'bytes 0-1023/1024')
          ..headers.set(HttpHeaders.contentEncodingHeader, 'gzip');
        final socket = await request.response.detachSocket();
        socket.listen(
          (_) {},
          onError: (_) {},
          onDone: () {
            socket.destroy();
            if (!disconnected.isCompleted) disconnected.complete();
          },
        );
      });
      final proxy = _proxy();
      try {
        final (status, _) = await _read(
          await proxy.wrap('http://127.0.0.1:${source.port}/video'),
        );
        expect(status, HttpStatus.badGateway);
        await disconnected.future.timeout(const Duration(seconds: 2));
      } finally {
        await proxy.close();
        await source.close(force: true);
      }
    },
  );

  // Samples as the bounded player cache produces them on a 2 MB/s link at
  // 540p (about 190 KB/s): the 30-second buffer is full after three seconds,
  // and from then on mpv reads at the bitrate. Derived, not captured.
  test('P1 automatic quality learns the link speed, not the bitrate', () {
    final speed = PlaybackMonitor.estimate([
      2.0e6,
      2.1e6,
      1.1e6,
      for (var i = 0; i < 9; i++) 190e3,
    ])!;
    expect(speed, greaterThan(1e6));
    expect(
      QualityPicker.pick(
        ['Source', '540', '360'],
        QualityPicker.auto,
        throughput: speed,
      ),
      0,
    );
  });

  test(
    'P2 reads the next range while the one before it is delivered',
    () async {
      // Ranges of the real size (4 MiB), which socket buffers cannot hold.
      final origin = _Origin(
        tick: const Duration(milliseconds: 1),
        piece: 64 << 10,
        size: 16 << 20,
      );
      await origin.start();
      final proxy = _proxy(chunkSize: 4 << 20);
      try {
        final (_, bytes) = await _read(await proxy.wrap(origin.url));
        expect(sha256.convert(bytes), sha256.convert(origin.data));
        expect(origin.ranges.length, greaterThan(2));
        // The first two ranges of the trial follow the continuous request.
        final pair = origin.ranges.sublist(1, 3)
          ..sort((a, b) => a.$1.compareTo(b.$1));
        final ahead = origin.servedAt[pair[0]]![pair[1]] ?? 0;
        expect(ahead, greaterThan((pair[1].$2 - pair[1].$1 + 1) * 3 ~/ 4));
      } finally {
        await proxy.close();
        await origin.close();
      }
    },
  );

  test('P3 gives every reader of a host a connection', () async {
    final origin = _Origin(tick: const Duration(milliseconds: 5));
    await origin.start();
    // No trial: this is about six continuous requests, one more than the
    // app's limit of five downloads.
    final proxy = _proxy(
      sampleDuration: const Duration(minutes: 1),
      openTimeout: const Duration(milliseconds: 100),
    );
    try {
      final url = await proxy.wrap(origin.url);
      final results = await Future.wait([
        for (var i = 0; i < 6; i++) _read(url),
      ]);
      for (final (status, bytes) in results) {
        expect(status, HttpStatus.ok);
        expect(sha256.convert(bytes), sha256.convert(origin.data));
      }
    } finally {
      await proxy.close();
      await origin.close();
    }
  });

  test('P4 keeps resuming while every attempt brings more', () async {
    // Eight cuts in one file, each after 16 KiB of progress.
    final origin = _Origin(cutAfter: 16 * 1024);
    await origin.start();
    final proxy = _proxy();
    try {
      final (status, bytes) = await _read(await proxy.wrap(origin.url));
      expect(status, HttpStatus.ok);
      expect(sha256.convert(bytes), sha256.convert(origin.data));
    } finally {
      await proxy.close();
      await origin.close();
    }
  });

  test('P5 hangs up on a reader that closed its side', () async {
    final origin = _Origin(tick: const Duration(milliseconds: 5));
    await origin.start();
    final proxy = _proxy();
    try {
      final url = Uri.parse(await proxy.wrap(origin.url));
      final socket = await Socket.connect(url.host, url.port);
      final started = Completer<void>();
      final ended = Completer<void>();
      socket.listen(
        (_) {
          if (!started.isCompleted) started.complete();
        },
        onError: (_) {},
        onDone: ended.complete,
      );
      socket.write('GET ${url.path} HTTP/1.1\r\nHost: ${url.host}\r\n\r\n');
      await started.future;
      // A reader that is done sends FIN and waits for the other side's.
      unawaited(socket.close());
      await ended.future.timeout(const Duration(seconds: 2));
      socket.destroy();
    } finally {
      await proxy.close();
      await origin.close();
    }
  });
}
