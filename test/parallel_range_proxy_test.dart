import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/parallel_range_proxy.dart';

/// A server that serves [data] with Range support, like the video nodes. It
/// answers 403 under /expired, like a link past its expiry time, and under
/// /flaky for anything after the first 5000 bytes. The first ranged request
/// under /stall gets half its bytes and then hangs, and the first under
/// /silent never gets an answer, like connections that stall.
Future<HttpServer> startUpstream(
  Uint8List data, {
  Duration delay = Duration.zero,
  void Function()? onRequest,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final stalled = <String>{};
  server.listen((request) async {
    onRequest?.call();
    final range = ParallelRangeProxy.parseRange(
      request.headers.value(HttpHeaders.rangeHeader),
      data.length,
    )!;
    final (start, end) = range;
    if (request.uri.path == '/expired' ||
        (request.uri.path == '/flaky' && start >= 5000)) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }
    final path = request.uri.path;
    if (path == '/flaky' && start < 5000 && end >= 5000) {
      request.response
        ..statusCode = HttpStatus.partialContent
        ..contentLength = end - start + 1
        ..headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${data.length}',
        );
      final socket = await request.response.detachSocket();
      socket.add(data.sublist(start, 5000));
      await socket.flush();
      socket.destroy();
      return;
    }
    if ((path == '/stall' || path == '/silent') &&
        end > start &&
        stalled.add(path)) {
      if (path == '/stall') {
        request.response
          ..statusCode = HttpStatus.partialContent
          ..contentLength = end - start + 1
          ..headers.set(
            HttpHeaders.contentRangeHeader,
            "bytes $start-$end/${data.length}",
          )
          ..add(data.sublist(start, start + (end - start + 1) ~/ 2));
        await request.response.flush();
      }
      return;
    }
    await Future.delayed(delay);
    request.response
      ..statusCode = HttpStatus.partialContent
      ..headers.set(
        HttpHeaders.contentRangeHeader,
        "bytes $start-$end/${data.length}",
      )
      ..add(data.sublist(start, end + 1));
    await request.response.close();
  });
  return server;
}

Future<(int, String?, List<int>)> get(String url, [String? range]) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
    final response = await request.close();
    final bytes = <int>[];
    await for (final part in response) {
      bytes.addAll(part);
    }
    return (
      response.statusCode,
      response.headers.value(HttpHeaders.contentRangeHeader),
      bytes,
    );
  } finally {
    client.close();
  }
}

void main() {
  group('parseRange', () {
    test('reads open, closed and suffix ranges', () {
      expect(ParallelRangeProxy.parseRange(null, 100), (0, 99));
      expect(ParallelRangeProxy.parseRange('bytes=10-', 100), (10, 99));
      expect(ParallelRangeProxy.parseRange('bytes=10-19', 100), (10, 19));
      expect(ParallelRangeProxy.parseRange('bytes=90-200', 100), (90, 99));
      expect(ParallelRangeProxy.parseRange('bytes=-30', 100), (70, 99));
    });

    test('rejects ranges it cannot serve', () {
      expect(ParallelRangeProxy.parseRange('bytes=100-', 100), isNull);
      expect(ParallelRangeProxy.parseRange('bytes=20-10', 100), isNull);
      expect(ParallelRangeProxy.parseRange('items=0-1', 100), isNull);
    });
  });

  test('serves only https files on iwara.tv by default', () {
    final proxy = ParallelRangeProxy();
    expect(proxy.serves('https://camellya.iwara.tv/view?filename=a.mp4'), true);
    expect(proxy.serves('http://camellya.iwara.tv/view'), false);
    expect(proxy.serves('https://iwara.tv.example.com/view'), false);
    expect(proxy.serves('https://notiwara.tv/view'), false);
  });

  group('proxy', () {
    // Small chunks so one request spans many parallel fetches.
    final proxy = ParallelRangeProxy(
      chunkSize: 1000,
      parallel: 4,
      preferredPort: 0,
      allowUpstream: (uri) => uri.host == '127.0.0.1',
    );
    final data = Uint8List.fromList(List.generate(25000, (i) => i * 7 % 256));
    late HttpServer upstream;
    late String upstreamUrl;
    late String url;

    setUpAll(() async {
      upstream = await startUpstream(data);
      upstreamUrl = 'http://127.0.0.1:${upstream.port}/video.mp4';
      url = await proxy.wrap(upstreamUrl);
    });

    tearDownAll(() async {
      await proxy.close();
      await upstream.close(force: true);
    });

    test('serves the whole file in order', () async {
      final (status, _, bytes) = await get(url);
      expect(status, HttpStatus.ok);
      expect(bytes, data);
    });

    test('serves a range across chunk boundaries', () async {
      final (status, contentRange, bytes) = await get(url, 'bytes=1500-7499');
      expect(status, HttpStatus.partialContent);
      expect(contentRange, 'bytes 1500-7499/25000');
      expect(bytes, data.sublist(1500, 7500));
    });

    test('serves a seek to the middle until the end', () async {
      final (_, contentRange, bytes) = await get(url, 'bytes=12345-');
      expect(contentRange, 'bytes 12345-24999/25000');
      expect(bytes, data.sublist(12345));
    });

    test('maps its URLs back to the upstream', () {
      expect(ParallelRangeProxy.upstreamOf(url), upstreamUrl);
      expect(ParallelRangeProxy.upstreamOf(upstreamUrl), isNull);
    });

    test('reports a failing upstream instead of an empty file', () async {
      final expired = await proxy.wrap(
        'http://127.0.0.1:${upstream.port}/expired',
      );
      final (status, _, bytes) = await get(expired);
      expect(status, HttpStatus.forbidden);
      expect(bytes, isEmpty);
    });

    test('cuts the connection when the upstream fails midway', () async {
      final flaky = await proxy.wrap('http://127.0.0.1:${upstream.port}/flaky');
      await expectLater(get(flaky), throwsA(isA<HttpException>()));
    });

    test('retries a request that stalls or never answers', () async {
      // One connection at a time, so a stalled one has to be let go first.
      final strict = ParallelRangeProxy(
        chunkSize: 1000,
        parallel: 1,
        preferredPort: 0,
        stallTimeout: const Duration(milliseconds: 200),
        openTimeout: const Duration(milliseconds: 200),
        allowUpstream: (uri) => uri.host == '127.0.0.1',
      );
      addTearDown(strict.close);
      for (final path in ['/stall', '/silent']) {
        final url = await strict.wrap('http://127.0.0.1:${upstream.port}$path');
        final (status, _, bytes) = await get(url);
        expect(status, HttpStatus.ok, reason: path);
        expect(bytes, data, reason: path);
      }
    });

    test('refuses upstreams it does not serve', () async {
      final encoded = base64Url.encode(utf8.encode('https://example.com/x'));
      final forged = url.replaceFirst(RegExp(r'/v/.*$'), '/v/$encoded');
      final (status, _, _) = await get(forged);
      expect(status, HttpStatus.forbidden);
      expect(() => proxy.wrap('https://example.com/x'), throwsArgumentError);
    });
  });

  test('stops fetching when the reader goes away', () async {
    var requests = 0;
    final slow = await startUpstream(
      Uint8List(50000),
      delay: const Duration(milliseconds: 30),
      onRequest: () => requests++,
    );
    final proxy = ParallelRangeProxy(
      chunkSize: 1000,
      preferredPort: 0,
      allowUpstream: (_) => true,
    );
    final url = Uri.parse(
      await proxy.wrap('http://127.0.0.1:${slow.port}/video.mp4'),
    );

    // Hang up once the response starts, like a player seeking elsewhere.
    final socket = await Socket.connect(url.host, url.port);
    socket.write('GET ${url.path} HTTP/1.1\r\nHost: ${url.host}\r\n\r\n');
    await socket.first;
    socket.destroy();
    await Future.delayed(const Duration(milliseconds: 600));

    // Reading it all takes a length probe and 50 chunks; a hang-up stops
    // the fetches before the first chunk is even written.
    expect(requests, lessThanOrEqualTo(5));
    await proxy.close();
    await slow.close(force: true);
  });
}
