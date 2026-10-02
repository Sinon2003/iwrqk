import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/parallel_range_proxy.dart';

// Every connection shares a 64 KiB / 16 ms token budget. The first response
// starts its body, stalls for 2.4 s, then reaches the same steady shared rate.
class _Origin {
  _Origin({int size = 16 << 20}) : data = Uint8List(size) {
    for (var i = 0; i < size; i++) {
      data[i] = ((i * 7) ^ (i ~/ 997)) & 255;
    }
  }
  final Uint8List data;
  final ranges = <(int, int)>[];
  final _waiters = Queue<Completer<void>>();
  late HttpServer server;
  late Timer _timer;
  final clock = Stopwatch()..start();
  Duration? firstBody, lastBody;
  int sent = 0, active = 0, maxActive = 0;

  String get url => 'http://127.0.0.1:${server.port}/video';
  double get bodySpeed =>
      sent / ((lastBody! - firstBody!).inMicroseconds / 1e6);

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_waiters.isNotEmpty) _waiters.removeFirst().complete();
    });
    server.listen((request) async {
      var closed = false;
      unawaited(
        request.response.done.then(
          (_) => closed = true,
          onError: (_) => closed = true,
        ),
      );
      active++;
      maxActive = max(maxActive, active);
      try {
        final (from, to) = ParallelRangeProxy.parseRange(
          request.headers.value(HttpHeaders.rangeHeader),
          data.length,
        )!;
        ranges.add((from, to));
        final first = ranges.length == 1;
        request.response
          ..statusCode = HttpStatus.partialContent
          ..contentLength = to - from + 1
          ..headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes $from-$to/${data.length}',
          )
          ..headers.set(HttpHeaders.etagHeader, '"review-fixture"');
        var bodyStart = from;
        if (first) {
          request.response.add(Uint8List.sublistView(data, from, from + 1));
          await request.response.flush();
          bodyStart++;
          await Future<void>.delayed(const Duration(milliseconds: 2400));
        }
        for (var at = bodyStart; at <= to && !closed; at += 64 << 10) {
          final token = Completer<void>();
          _waiters.add(token);
          await token.future;
          if (closed) break;
          final bytes = Uint8List.sublistView(
            data,
            at,
            min(at + (64 << 10), to + 1),
          );
          firstBody ??= clock.elapsed;
          lastBody = clock.elapsed;
          sent += bytes.length;
          request.response.add(bytes);
          await request.response.flush();
        }
        if (!closed) await request.response.close();
      } catch (_) {
        // Cancelling the initial continuous request before a trial is normal.
      } finally {
        active--;
      }
    });
  }

  Future<void> close() async {
    await server.close(force: true);
    _timer.cancel();
    while (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    }
  }
}

Future<(Uint8List, Duration)> _read(String url) async {
  final client = HttpClient();
  final watch = Stopwatch()..start();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-');
    final response = await request.close();
    expect(response.statusCode, HttpStatus.partialContent);
    final bytes = BytesBuilder(copy: false);
    await for (final part in response) {
      bytes.add(part);
    }
    return (bytes.takeBytes(), watch.elapsed);
  } finally {
    client.close(force: true);
  }
}

void main() {
  for (final eager in [false, true]) {
    test(
      'slow startup does not invent parallel gain (eager: $eager)',
      () async {
        final origin = _Origin(size: eager ? 32 << 20 : 16 << 20);
        await origin.start();
        final proxy = ParallelRangeProxy(
          preferredPort: 0,
          allowUpstream: (u) => u.host == '127.0.0.1',
        );
        try {
          final url = await proxy.wrap(
            origin.url,
            duration: const Duration(seconds: 16),
            eager: eager,
          );
          final (actual, _) = await _read(url);
          expect(sha256.convert(actual), sha256.convert(origin.data));
          if (!eager) {
            expect(origin.ranges, [(0, origin.data.length - 1)]);
          } else {
            // Full preloading can try parallel even when single playback is
            // already smooth, but it must discard a trial without a real gain.
            expect(origin.ranges.length, 4);
            expect(
              origin.ranges.where((r) => r.$2 < origin.data.length - 1).length,
              2,
            );
            expect(origin.ranges.last.$2, origin.data.length - 1);
          }
        } finally {
          await proxy.close();
          await origin.close();
        }
      },
    );
  }
}
