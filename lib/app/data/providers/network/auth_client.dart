import 'dart:async';

import 'package:http/http.dart' as http;

/// One authentication attempt owns its connections and one time budget, shared
/// by login and token exchange. Retrying creates a fresh client after a route
/// change; timing out also closes the underlying requests, not just the UI.
class AuthClient {
  AuthClient({http.Client? client, this.timeout = const Duration(seconds: 20)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final Stopwatch _watch = Stopwatch()..start();
  final Completer<void> _cancelled = Completer<void>();
  bool _closed = false;

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    if (_closed) throw http.ClientException('Authentication attempt closed');
    final remaining = timeout - _watch.elapsed;
    if (remaining <= Duration.zero) {
      close();
      throw TimeoutException('Authentication timed out', timeout);
    }
    return Future.any<http.Response>([
      _client.post(url, headers: headers, body: body),
      _cancelled.future.then(
        (_) => throw http.ClientException('Authentication attempt closed'),
      ),
    ]).timeout(
      remaining,
      onTimeout: () {
        close();
        throw TimeoutException('Authentication timed out', timeout);
      },
    );
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _cancelled.complete();
    _client.close();
  }
}
