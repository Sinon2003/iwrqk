import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'log_util.dart';

/// Serves Iwara video files from 127.0.0.1 and fetches them from the server
/// with several ranged requests at once, for playback and downloads.
///
/// The site sends a video over one connection. On routes that throttle each
/// connection, parallel ranges use more of the bandwidth. Clients still see
/// one ordinary seekable file.
///
/// A local URL carries its upstream URL, so a paused download can resume
/// after a restart. Only https URLs on iwara.tv are served, so other apps
/// cannot use this as an open proxy.
class ParallelRangeProxy {
  ParallelRangeProxy({
    this.chunkSize = 1 << 20,
    this.parallel = 4,
    this.preferredPort = 38291,
    this.stallTimeout = const Duration(seconds: 15),
    bool Function(Uri upstream)? allowUpstream,
  }) : _allowUpstream = allowUpstream ?? _isIwaraFile;

  static final ParallelRangeProxy instance = ParallelRangeProxy();

  /// Size of one ranged request to the server.
  final int chunkSize;

  /// Ranged requests in flight for one reader.
  final int parallel;

  /// A fixed port keeps local URLs valid across restarts; any free port is
  /// used when it is taken.
  final int preferredPort;

  /// How long a request may go without receiving anything before it is
  /// dropped and retried. Connections through a VPN sometimes stall without
  /// failing, and one stalled chunk would hold up the whole reader.
  final Duration stallTimeout;

  final bool Function(Uri upstream) _allowUpstream;

  static bool _isIwaraFile(Uri uri) =>
      uri.scheme == "https" &&
      (uri.host == "iwara.tv" || uri.host.endsWith(".iwara.tv"));

  HttpServer? _server;
  Future<HttpServer>? _starting;
  final Map<String, int> _lengths = {};

  /// Keeps connections alive between chunks: a new TLS handshake for every
  /// chunk would cost more than parallelism gains on slow routes. Created on
  /// first use, after the app's proxy override is installed.
  HttpClient? _httpClient;
  HttpClient get _client => _httpClient ??= HttpClient()
    ..autoUncompress = false
    ..maxConnectionsPerHost = parallel
    ..idleTimeout = const Duration(seconds: 15);

  /// Whether [url] can be served through this proxy.
  bool serves(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && _allowUpstream(uri);
  }

  /// Returns the local URL that serves [url], which must pass [serves].
  Future<String> wrap(String url) async {
    if (!serves(url)) {
      throw ArgumentError.value(url, "url", "Not served by this proxy");
    }
    final server = await start();
    final encoded = base64Url.encode(utf8.encode(url));
    return "http://${server.address.address}:${server.port}/v/$encoded";
  }

  /// The upstream URL behind [url] when it came from [wrap], otherwise null.
  static String? upstreamOf(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != InternetAddress.loopbackIPv4.address) {
      return null;
    }
    return _decode(uri);
  }

  static String? _decode(Uri local) {
    final segments = local.pathSegments;
    if (segments.length != 2 || segments.first != "v") return null;
    try {
      return utf8.decode(base64Url.decode(segments[1]));
    } on FormatException {
      return null;
    }
  }

  /// Starts serving if needed; [wrap] does this too.
  Future<HttpServer> start() {
    final running = _server;
    if (running != null) return Future.value(running);
    return _starting ??= () async {
      HttpServer server;
      try {
        server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          preferredPort,
        );
      } on SocketException {
        server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      }
      server.listen(_handle);
      _server = server;
      _starting = null;
      return server;
    }();
  }

  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
    _lengths.clear();
    _httpClient?.close(force: true);
    _httpClient = null;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    final upstreamUrl = _decode(request.uri);
    final upstream = upstreamUrl == null ? null : Uri.tryParse(upstreamUrl);
    if (upstream == null || !_allowUpstream(upstream)) {
      response.statusCode = HttpStatus.forbidden;
      await response.close();
      return;
    }

    final Socket socket;
    final int start;
    final int end;
    try {
      final total = await _lengthOf(upstream);
      final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
      final range = parseRange(rangeHeader, total);
      if (range == null) {
        response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        response.headers.set(HttpHeaders.contentRangeHeader, "bytes */$total");
        await response.close();
        return;
      }
      (start, end) = range;

      response.statusCode = rangeHeader == null
          ? HttpStatus.ok
          : HttpStatus.partialContent;
      response.persistentConnection = false;
      response.headers
        ..contentType = ContentType("video", "mp4")
        ..contentLength = end - start + 1
        ..set(HttpHeaders.acceptRangesHeader, "bytes");
      if (rangeHeader != null) {
        response.headers.set(
          HttpHeaders.contentRangeHeader,
          "bytes $start-$end/$total",
        );
      }
      if (request.method == "HEAD") {
        await response.close();
        return;
      }
      // The body goes to the socket itself: HttpResponse hides a reader that
      // went away, and the fetches for it have to stop.
      socket = await response.detachSocket();
    } catch (e, stackTrace) {
      LogUtil.warning(
        "Parallel proxy failed to open ${_logName(upstream)}",
        e,
        stackTrace,
      );
      try {
        response.statusCode = HttpStatus.badGateway;
        await response.close();
      } catch (_) {}
      return;
    }
    await _pipe(upstream, start, end, socket);
  }

  /// Writes bytes [start]..[end] in order while up to [parallel] chunks are
  /// fetched at once, and stops when the reader goes away.
  Future<void> _pipe(Uri upstream, int start, int end, Socket socket) async {
    final pending = Queue<_Chunk>();
    var readerGone = false;
    void stop() {
      readerGone = true;
      for (final chunk in pending) {
        chunk.cancel();
      }
    }

    // Readers send nothing after the request; the stream ends when they
    // disconnect, which players do on every seek.
    socket.listen(
      null,
      onDone: stop,
      onError: (_) => stop(),
      cancelOnError: true,
    );

    var next = start;
    void fillAhead() {
      while (pending.length < parallel && next <= end && !readerGone) {
        final to = min(next + chunkSize - 1, end);
        pending.add(_Chunk(_client, upstream, next, to, stallTimeout));
        next = to + 1;
      }
    }

    try {
      fillAhead();
      while (pending.isNotEmpty && !readerGone) {
        await socket.addStream(pending.first.stream);
        pending.removeFirst();
        fillAhead();
      }
      if (!readerGone) {
        await socket.close();
        return;
      }
    } catch (e, stackTrace) {
      if (!readerGone && e is! SocketException) {
        LogUtil.warning(
          "Parallel proxy failed for ${_logName(upstream)}",
          e,
          stackTrace,
        );
      }
      stop();
    }
    // Cut short, so a partial body never looks complete.
    socket.destroy();
  }

  /// Leaves out the query, which holds the link's signature.
  static String _logName(Uri upstream) => "${upstream.host}${upstream.path}";

  /// The file size, from a one-byte ranged request: the file servers answer
  /// HEAD with 405.
  Future<int> _lengthOf(Uri upstream) async {
    final key = upstream.toString();
    final known = _lengths[key];
    if (known != null) return known;

    final request = await _client.getUrl(upstream);
    request.headers.set(HttpHeaders.rangeHeader, "bytes=0-0");
    final HttpClientResponse response;
    try {
      response = await request.close().timeout(stallTimeout);
    } on TimeoutException {
      request.abort();
      rethrow;
    }
    // Only the headers matter, so the connection is dropped right away.
    await _discard(response);
    final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
    final total = int.tryParse(contentRange?.split("/").last ?? "");
    if (response.statusCode != HttpStatus.partialContent || total == null) {
      throw HttpException("Ranges not supported (${response.statusCode})");
    }
    if (_lengths.length >= 64) _lengths.remove(_lengths.keys.first);
    return _lengths[key] = total;
  }

  /// Parses a `Range` header against a file of [total] bytes: null header
  /// means the whole file; returns null when the range cannot be served.
  @visibleForTesting
  static (int, int)? parseRange(String? header, int total) {
    if (header == null) return (0, total - 1);
    final match = RegExp(r"^bytes=(\d*)-(\d*)$").firstMatch(header.trim());
    if (match == null) return null;
    final startText = match.group(1)!;
    final endText = match.group(2)!;
    if (startText.isEmpty) {
      // A suffix range: the last N bytes.
      final length = int.tryParse(endText);
      if (length == null || length == 0) return null;
      return (max(0, total - length), total - 1);
    }
    final start = int.parse(startText);
    final end = endText.isEmpty
        ? total - 1
        : min(int.parse(endText), total - 1);
    if (start > end || start >= total) return null;
    return (start, end);
  }
}

/// Drops a response without reading its body, which may be the whole file.
Future<void> _discard(HttpClientResponse response) async {
  (await response.detachSocket()).destroy();
}

/// One ranged request, started at once. Its bytes wait in [stream] until the
/// writer gets to it, and then pass straight through as they arrive.
class _Chunk {
  _Chunk(this._client, this._upstream, this.from, this.to, this._stallTimeout) {
    _run();
  }

  final HttpClient _client;
  final Uri _upstream;
  final int from;
  final int to;
  final Duration _stallTimeout;
  final StreamController<List<int>> _data = StreamController();
  HttpClientRequest? _request;
  void Function(Object error)? _failAttempt;
  int _received = 0;
  bool _cancelled = false;

  Stream<List<int>> get stream => _data.stream;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _request?.abort();
    _failAttempt?.call(const HttpException("Cancelled"));
    _data.close();
  }

  Future<void> _run() async {
    Object? lastError;
    for (var attempt = 0; attempt < 3 && !_cancelled; attempt++) {
      try {
        await _fetchRest();
        if (!_cancelled) _data.close();
        return;
      } catch (e) {
        lastError = e;
      }
    }
    if (_cancelled) return;
    _data.addError(lastError!);
    _data.close();
  }

  /// Passes on the bytes not received yet. Gives up when the server sends
  /// nothing for [_stallTimeout], which also frees the connection.
  Future<void> _fetchRest() async {
    final request = _request = await _client.getUrl(_upstream);
    if (_cancelled) {
      request.abort();
      return;
    }
    // A retry continues after the bytes already passed on.
    request.headers.set(
      HttpHeaders.rangeHeader,
      "bytes=${from + _received}-$to",
    );
    final HttpClientResponse response;
    try {
      response = await request.close().timeout(_stallTimeout);
    } on TimeoutException {
      request.abort();
      rethrow;
    }
    if (response.statusCode != HttpStatus.partialContent) {
      await _discard(response);
      throw HttpException("Unexpected status ${response.statusCode}");
    }

    final done = Completer<void>();
    late final StreamSubscription<List<int>> subscription;
    Timer? watchdog;
    void finish([Object? error]) {
      watchdog?.cancel();
      _failAttempt = null;
      if (done.isCompleted) return;
      if (error == null) {
        done.complete();
      } else {
        subscription.cancel();
        done.completeError(error);
      }
    }

    void rearm() {
      watchdog?.cancel();
      watchdog = Timer(
        _stallTimeout,
        () => finish(TimeoutException("No data", _stallTimeout)),
      );
    }

    _failAttempt = finish;
    subscription = response.listen(
      (part) {
        if (_cancelled) return;
        _data.add(part);
        _received += part.length;
        rearm();
      },
      onError: finish,
      onDone: () => finish(
        from + _received == to + 1
            ? null
            : HttpException("Got $_received of ${to - from + 1} bytes"),
      ),
      cancelOnError: true,
    );
    rearm();
    await done.future;
  }
}
