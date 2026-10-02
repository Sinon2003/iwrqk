import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iwrqk/app/data/providers/network/auth_client.dart';

class _Client extends http.BaseClient {
  _Client(this.inner);
  final http.Client inner;
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      inner.send(request);
  @override
  void close() {
    closed = true;
    inner.close();
  }
}

void main() {
  final url = Uri.parse('https://example.test/login');

  test('a stalled connection times out and is closed', () async {
    final client = _Client(
      MockClient((_) => Completer<http.Response>().future),
    );
    final auth = AuthClient(
      client: client,
      timeout: const Duration(milliseconds: 80),
    );
    await expectLater(auth.post(url), throwsA(isA<TimeoutException>()));
    expect(client.closed, isTrue);
  });

  test('login and token exchange share the same time budget', () async {
    var calls = 0;
    final client = _Client(
      MockClient((_) async {
        calls++;
        if (calls == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 180));
          return http.Response('{}', 200);
        }
        return Completer<http.Response>().future;
      }),
    );
    final auth = AuthClient(
      client: client,
      timeout: const Duration(milliseconds: 300),
    );
    final watch = Stopwatch()..start();
    await auth.post(url);
    await expectLater(auth.post(url), throwsA(isA<TimeoutException>()));
    expect(calls, 2);
    expect(watch.elapsed, lessThan(const Duration(milliseconds: 450)));
    expect(client.closed, isTrue);
  });

  test('cancel completes a pending request before its deadline', () async {
    final client = _Client(
      MockClient((_) => Completer<http.Response>().future),
    );
    final auth = AuthClient(client: client);
    final result = expectLater(
      auth.post(url),
      throwsA(isA<http.ClientException>()),
    );
    auth.close();
    await result;
    expect(client.closed, isTrue);
  });

  test(
    'the deadline includes receiving the body and closes the actual socket',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final disconnected = Completer<void>();
      server.listen((request) async {
        await request.drain<void>();
        request.response.contentLength = 100;
        final socket = await request.response.detachSocket();
        socket.listen(
          (_) {},
          onError: (_) {},
          onDone: () {
            socket.destroy();
            if (!disconnected.isCompleted) disconnected.complete();
          },
        );
        socket.add([123]);
        await socket.flush();
      });
      final auth = AuthClient(timeout: const Duration(milliseconds: 200));
      try {
        await expectLater(
          auth.post(Uri.parse('http://127.0.0.1:${server.port}/login')),
          throwsA(isA<TimeoutException>()),
        );
        await disconnected.future.timeout(const Duration(seconds: 2));
      } finally {
        auth.close();
        await server.close(force: true);
      }
    },
  );
}
