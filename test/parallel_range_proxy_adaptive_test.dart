import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/parallel_range_proxy.dart';

class _Origin {
  _Origin({
    this.tick = Duration.zero,
    this.shared = false,
    this.ignoreRange = false,
    this.wrongRange = false,
    this.chunked = false,
  });

  final Duration tick;
  final bool shared, ignoreRange, wrongRange, chunked;
  final data = Uint8List.fromList(
    List.generate(128 * 1024, (i) => ((i * 7) ^ (i ~/ 997)) & 255),
  );
  final ranges = <(int, int)>[];
  final methods = <String>[];
  late HttpServer server;
  Future<void> _turn = Future.value();
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
        methods.add(request.method);
        final selected = ParallelRangeProxy.parseRange(
          request.headers.value(HttpHeaders.rangeHeader),
          data.length,
        );
        if (selected == null) {
          request.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
          request.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes */${data.length}',
          );
          await request.response.close();
          return;
        }
        final (from, to) = selected;
        ranges.add(selected);
        final start = ignoreRange || wrongRange ? 0 : from;
        final end = ignoreRange ? data.length - 1 : start + to - from;
        request.response.statusCode = ignoreRange
            ? HttpStatus.ok
            : HttpStatus.partialContent;
        if (!chunked) request.response.contentLength = end - start + 1;
        if (!ignoreRange) {
          request.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes $start-$end/${data.length}',
          );
        }
        for (var at = start; at <= end && !closed; at += 1024) {
          if (tick != Duration.zero) {
            if (shared) {
              _turn = _turn.then((_) => Future<void>.delayed(tick));
              await _turn;
            } else {
              await Future<void>.delayed(tick);
            }
          }
          if (closed) break;
          request.response.add(
            Uint8List.sublistView(data, at, min(at + 1024, end + 1)),
          );
          await request.response.flush();
        }
        if (!closed) await request.response.close();
      } catch (_) {
        // Abandoning the original request when a trial begins is expected.
      } finally {
        active--;
      }
    });
  }

  Future<void> close() => server.close(force: true);
}

Future<(int, Uint8List)> _read(
  String url, {
  String? range,
  String? ifRange,
}) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
    if (ifRange != null) {
      request.headers.set(HttpHeaders.ifRangeHeader, ifRange);
    }
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

ParallelRangeProxy _proxy() => ParallelRangeProxy(
  chunkSize: 8192,
  sampleDuration: const Duration(milliseconds: 20),
  preferredPort: 0,
  allowUpstream: (u) => u.host == '127.0.0.1',
);

class _NeverConnect extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..connectionFactory = (uri, host, port) {
          if (uri.host == '127.0.0.2') {
            return Completer<ConnectionTask<Socket>>().future;
          }
          return Socket.startConnect(host ?? uri.host, port ?? uri.port);
        };
}

void main() {
  test(
    'a resumed request preserves If-Range so changed files restart',
    () async {
      final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      source.listen((request) async {
        final oldEntity =
            request.headers.value(HttpHeaders.ifRangeHeader) == '"old"';
        request.response
          ..statusCode = oldEntity ? HttpStatus.ok : HttpStatus.partialContent
          ..contentLength = oldEntity ? 5 : 2
          ..headers.set(HttpHeaders.etagHeader, '"new"');
        if (!oldEntity) {
          request.response.headers.set(
            HttpHeaders.contentRangeHeader,
            'bytes 3-4/5',
          );
        }
        request.response.add(oldEntity ? [5, 4, 3, 2, 1] : [2, 1]);
        await request.response.close();
      });
      final proxy = _proxy();
      try {
        final (status, bytes) = await _read(
          await proxy.wrap('http://127.0.0.1:${source.port}/video'),
          range: 'bytes=3-',
          ifRange: '"old"',
        );
        expect(status, HttpStatus.ok);
        expect(bytes, [5, 4, 3, 2, 1]);
      } finally {
        await proxy.close();
        await source.close(force: true);
      }
    },
  );
  test(
    'bounds opening a connection, not only waiting for its headers',
    () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        final proxy = ParallelRangeProxy(
          preferredPort: 0,
          stallTimeout: const Duration(milliseconds: 50),
          openTimeout: const Duration(milliseconds: 50),
          allowUpstream: (_) => true,
        );
        try {
          final timer = Stopwatch()..start();
          final (status, bytes) = await _read(
            await proxy.wrap('http://127.0.0.2:1/file'),
          );
          expect(status, HttpStatus.badGateway);
          expect(bytes, isEmpty);
          expect(timer.elapsed, lessThan(const Duration(seconds: 2)));
        } finally {
          await proxy.close();
        }
      }, _NeverConnect());
    },
  );
  test(
    'short reads reuse their real response without a length probe',
    () async {
      final origin = _Origin();
      await origin.start();
      final proxy = _proxy();
      try {
        final (status, bytes) = await _read(
          await proxy.wrap(origin.url),
          range: 'bytes=100-200',
        );
        expect(status, HttpStatus.partialContent);
        expect(bytes, origin.data.sublist(100, 201));
        expect(origin.ranges, [(100, 200)]);
      } finally {
        await proxy.close();
        await origin.close();
      }
    },
  );

  test(
    'keeps an ordered parallel trial on a per-connection bottleneck',
    () async {
      final origin = _Origin(tick: const Duration(milliseconds: 3));
      await origin.start();
      final proxy = _proxy();
      try {
        final (_, bytes) = await _read(await proxy.wrap(origin.url));
        expect(sha256.convert(bytes), sha256.convert(origin.data));
        expect(origin.ranges.first, (0, origin.data.length - 1));
        expect(origin.ranges.length, greaterThan(4));
        expect(origin.maxActive, greaterThan(1));
      } finally {
        await proxy.close();
        await origin.close();
      }
    },
  );

  test(
    'returns to a continuous suffix when parallelism has no benefit',
    () async {
      final origin = _Origin(
        tick: const Duration(milliseconds: 5),
        shared: true,
      );
      await origin.start();
      final proxy = _proxy();
      try {
        final (_, bytes) = await _read(await proxy.wrap(origin.url));
        expect(sha256.convert(bytes), sha256.convert(origin.data));
        expect(origin.ranges.last.$1, greaterThan(0));
        expect(origin.ranges.last.$2, origin.data.length - 1);
        expect(
          origin.ranges.where((r) => r.$2 < origin.data.length - 1).length,
          2,
        );
      } finally {
        await proxy.close();
        await origin.close();
      }
    },
  );

  test('does not probe a playback already faster than its bitrate', () async {
    final origin = _Origin(tick: const Duration(milliseconds: 10));
    await origin.start();
    final proxy = _proxy();
    try {
      final url = await proxy.wrap(
        origin.url,
        duration: const Duration(seconds: 120),
      );
      expect(ParallelRangeProxy.upstreamOf(url), origin.url);
      final (_, bytes) = await _read(url);
      expect(sha256.convert(bytes), sha256.convert(origin.data));
      expect(origin.ranges, [(0, origin.data.length - 1)]);
      expect(proxy.speedFor(origin.url), greaterThan(0));
    } finally {
      await proxy.close();
      await origin.close();
    }
  });

  test('rejects an equal-length response from the wrong position', () async {
    final origin = _Origin(wrongRange: true);
    await origin.start();
    final proxy = _proxy();
    try {
      final (status, bytes) = await _read(
        await proxy.wrap(origin.url),
        range: 'bytes=2048-4095',
      );
      expect(status, HttpStatus.badGateway);
      expect(bytes, isEmpty);
    } finally {
      await proxy.close();
      await origin.close();
    }
  });

  for (final chunked in [false, true]) {
    test('streams a Range-ignoring server (chunked: $chunked)', () async {
      final origin = _Origin(ignoreRange: true, chunked: chunked);
      await origin.start();
      final proxy = _proxy();
      try {
        final (status, bytes) = await _read(await proxy.wrap(origin.url));
        expect(status, HttpStatus.ok);
        expect(sha256.convert(bytes), sha256.convert(origin.data));
        expect(origin.ranges.length, 1);
      } finally {
        await proxy.close();
        await origin.close();
      }
    });
  }

  test(
    'answers HEAD with total length without relying on upstream HEAD',
    () async {
      final origin = _Origin();
      await origin.start();
      final proxy = _proxy();
      final client = HttpClient();
      try {
        final request = await client.headUrl(
          Uri.parse(await proxy.wrap(origin.url)),
        );
        final response = await request.close();
        expect(response.statusCode, HttpStatus.ok);
        expect(response.contentLength, origin.data.length);
        await response.drain<void>();
        expect(origin.methods, ['GET']);
        expect(origin.ranges, [(0, 0)]);
      } finally {
        client.close(force: true);
        await proxy.close();
        await origin.close();
      }
    },
  );

  test('refuses unsupported HTTP methods before contacting upstream', () async {
    final origin = _Origin();
    await origin.start();
    final proxy = _proxy();
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse(await proxy.wrap(origin.url)),
      );
      final response = await request.close();
      expect(response.statusCode, HttpStatus.methodNotAllowed);
      await response.drain<void>();
      expect(origin.ranges, isEmpty);
    } finally {
      client.close(force: true);
      await proxy.close();
      await origin.close();
    }
  });

  test(
    'rejects empty files and overflowing range numbers without throwing',
    () {
      expect(ParallelRangeProxy.parseRange(null, 0), isNull);
      expect(
        ParallelRangeProxy.parseRange('bytes=9999999999999999999999999-', 100),
        isNull,
      );
    },
  );
}
