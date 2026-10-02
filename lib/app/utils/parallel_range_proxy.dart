import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'log_util.dart';
import 'transfer_baseline.dart';

/// Start with a continuous request. Keep parallel ranges only when a short
/// trial improves throughput. HttpOverrides and the system VPN still apply.
class ParallelRangeProxy {
  ParallelRangeProxy({
    this.chunkSize = 4 << 20,
    this.parallel = 4,
    this.preferredPort = 38291,
    this.stallTimeout = const Duration(seconds: 5),
    this.openTimeout = const Duration(seconds: 10),
    this.sampleDuration = const Duration(seconds: 3),
    bool Function(Uri upstream)? allowUpstream,
  }) : assert(chunkSize > 0),
       assert(parallel > 0),
       _allowUpstream = allowUpstream ?? _isIwaraFile;

  static final ParallelRangeProxy instance = ParallelRangeProxy();

  /// Maximum trial chunk size; small values also support deterministic tests.
  final int chunkSize;
  final int parallel;
  final int preferredPort;
  final Duration stallTimeout;
  final Duration openTimeout;
  final Duration sampleDuration;
  final bool Function(Uri upstream) _allowUpstream;

  HttpServer? _server;
  Future<HttpServer>? _starting;
  HttpClient? _httpClient;
  final Set<_Reader> _readers = {};
  final Map<String, TransferSpeed> _speeds = {};
  final Map<String, int> _extraConnections = {};

  HttpClient get _client => _httpClient ??= HttpClient()
    ..autoUncompress = false
    ..connectionTimeout = openTimeout
    ..idleTimeout = const Duration(seconds: 15);

  static bool _isIwaraFile(Uri uri) =>
      uri.scheme == "https" &&
      uri.userInfo.isEmpty &&
      (uri.host == "iwara.tv" || uri.host.endsWith(".iwara.tv"));

  bool serves(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && _allowUpstream(uri);
  }

  /// Playback can skip a trial when one connection exceeds the selected
  /// file's average bitrate with room to spare. Old persisted URLs still work.
  Future<String> wrap(
    String url, {
    Duration? duration,
    bool eager = false,
  }) async {
    if (!serves(url)) throw ArgumentError("Not served by this proxy");
    final server = await start();
    _speeds.remove(url);
    final encoded = base64Url.encode(utf8.encode(url));
    final seconds = duration?.inSeconds ?? 0;
    final parameters = {
      if (seconds > 0) 'duration': '$seconds',
      if (eager) 'eager': '1',
    };
    final query = parameters.isEmpty
        ? ''
        : '?${Uri(queryParameters: parameters).query}';
    return "http://${server.address.address}:${server.port}/v/$encoded$query";
  }

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

  /// Distinct upstream windows, including connection and retry time. Do not
  /// count repeated reads of the same window as independent measurements.
  TransferSpeed? sampleFor(String upstream) {
    final sample = _speeds[upstream];
    if (sample == null ||
        DateTime.now().difference(sample.measuredAt) >
            const Duration(seconds: 3)) {
      return null;
    }
    return sample;
  }

  double? speedFor(String upstream) => sampleFor(upstream)?.bytesPerSecond;

  // Each reader keeps its ordinary connection. Only speculative connections
  // share a host budget; a busy host never queues a new playback behind files.
  int _reserve(Uri upstream, int wanted) {
    final key = upstream.origin;
    final used = _extraConnections[key] ?? 0;
    final count = min(wanted, parallel - 1 - used);
    if (count > 0) _extraConnections[key] = used + count;
    return count;
  }

  void _release(Uri upstream, int count) {
    final key = upstream.origin;
    final remaining = (_extraConnections[key] ?? 0) - count;
    if (remaining <= 0) {
      _extraConnections.remove(key);
    } else {
      _extraConnections[key] = remaining;
    }
  }

  Future<HttpServer> start() {
    final running = _server;
    if (running != null) return Future.value(running);
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  Future<HttpServer> _start() async {
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
    return _server = server;
  }

  Future<void> close() async {
    for (final reader in _readers.toList()) {
      reader.cancel();
    }
    await _server?.close(force: true);
    _server = null;
    _speeds.clear();
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
    if (request.method != "GET" && request.method != "HEAD") {
      response.statusCode = HttpStatus.methodNotAllowed;
      response.headers.set(HttpHeaders.allowHeader, "GET, HEAD");
      await response.close();
      return;
    }

    final reader = _Reader();
    _readers.add(reader);
    final timer = Stopwatch()..start();
    Socket? socket;
    _Chunk? initial;
    var sent = 0;
    var trialUsed = false;
    var reserved = 0;
    final meter = _TransferMeter((sample) {
      if (_speeds.length >= 64) _speeds.remove(_speeds.keys.first);
      _speeds[upstreamUrl!] = sample;
    });

    try {
      final head = request.method == "HEAD";
      final rangeHeader = head
          ? null
          : request.headers.value(HttpHeaders.rangeHeader);
      // The real response supplies both metadata and data. A separate one-byte
      // length probe would add another DNS/TLS/request round trip.
      (HttpClientRequest, HttpClientResponse)? firstResponse;
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          firstResponse = await _open(
            _client,
            upstream,
            head ? "bytes=0-0" : rangeHeader ?? "bytes=0-",
            openTimeout,
            reader,
            validator: request.headers.value(HttpHeaders.ifRangeHeader),
          );
          break;
        } on TimeoutException {
          if (attempt == 2 || reader.cancelled) rethrow;
        } on SocketException {
          if (attempt == 2 || reader.cancelled) rethrow;
        }
      }
      final opened = firstResponse!;
      final source = opened.$2;
      final range = _ContentRange.parse(
        source.headers.value(HttpHeaders.contentRangeHeader),
      );
      final ranged = source.statusCode == HttpStatus.partialContent;
      if (ranged) {
        final expected = range == null
            ? null
            : parseRange(head ? "bytes=0-0" : rangeHeader, range.total);
        if (range == null || expected != (range.start, range.end)) {
          await _discard(source);
          throw const _InvalidRange();
        }
        try {
          _validateResponse(source, range.start, range.end, range.total);
        } catch (_) {
          await _discard(source);
          rethrow;
        }
      }

      // If Range is ignored, preserve an ordinary response and stream it.
      // Never advertise range support for bytes that were not actually ranged.
      response.statusCode = ranged
          ? (rangeHeader == null ? HttpStatus.ok : HttpStatus.partialContent)
          : source.statusCode;
      response.persistentConnection = false;
      for (final name in [
        HttpHeaders.contentTypeHeader,
        HttpHeaders.contentEncodingHeader,
        HttpHeaders.etagHeader,
        HttpHeaders.lastModifiedHeader,
      ]) {
        final value = source.headers.value(name);
        if (value != null) response.headers.set(name, value);
      }
      final length = ranged
          ? (head ? range!.total : range!.end - range.start + 1)
          : source.contentLength;
      if (length >= 0) response.contentLength = length;
      if (ranged) {
        response.headers.set(HttpHeaders.acceptRangesHeader, "bytes");
        if (rangeHeader != null) {
          final selected = parseRange(rangeHeader, range!.total);
          if (selected == null) throw const _InvalidRange();
          response.headers.set(
            HttpHeaders.contentRangeHeader,
            "bytes ${selected.$1}-${selected.$2}/${range.total}",
          );
        }
      } else if (source.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
        final value = source.headers.value(HttpHeaders.contentRangeHeader);
        if (value != null) {
          response.headers.set(HttpHeaders.contentRangeHeader, value);
        }
      }
      if (head) {
        await _discard(source);
        await response.close();
        return;
      }
      if (!ranged) {
        await response.addStream(source.timeout(stallTimeout));
        await response.close();
        return;
      }
      socket = await response.detachSocket();
      socket.listen(
        null,
        onDone: reader.cancel,
        onError: (_) => reader.cancel(),
        cancelOnError: true,
      );

      final total = range!.total;
      final end = range.end;
      var cursor = range.start;
      final validator = source.headers.value(HttpHeaders.etagHeader);
      initial = _Chunk(
        _client,
        upstream,
        cursor,
        end,
        total,
        stallTimeout,
        reader,
        validator: validator,
        openTimeout: openTimeout,
        opened: opened,
        prefetch: false,
        onBytes: meter.add,
      );
      final sample = Stopwatch()..start();
      final recent = TransferBaseline(sampleDuration);
      var sampleBytes = 0;
      var trialSize = chunkSize;
      double baseline = 0;
      final seconds = int.tryParse(
        request.uri.queryParameters["duration"] ?? "",
      );
      final requiredSpeed =
          request.uri.queryParameters['eager'] != '1' &&
              seconds != null &&
              seconds > 0
          ? total / seconds * 1.5
          : null;
      var canTrial = parallel > 1;

      await for (final part in initial.stream) {
        if (reader.cancelled) break;
        final write = Stopwatch()..start();
        socket.add(part);
        await socket.flush();
        // A full player cache is backpressure, not a slow route.
        if (write.elapsedMilliseconds > 100) {
          meter.reset();
          canTrial = false;
        }
        cursor += part.length;
        sent += part.length;
        sampleBytes += part.length;
        if (recent.expired(sample.elapsed)) canTrial = false;
        final current = canTrial
            ? recent.add(part.length, sample.elapsed)
            : null;
        if (canTrial &&
            current != null &&
            sampleBytes >= min(chunkSize, 512 * 1024)) {
          baseline = current;
          if (requiredSpeed != null && baseline >= requiredSpeed) {
            canTrial = false;
            continue;
          }
          trialSize = (baseline * 2).round().clamp(
            min(chunkSize, 1 << 20),
            chunkSize,
          );
          if (end - cursor + 1 >= trialSize * 2) {
            reserved = _reserve(upstream, 1);
            if (reserved > 0) {
              trialUsed = true;
              break;
            }
          }
          canTrial = false;
        }
      }
      initial.cancel();
      if (!reader.cancelled && cursor <= end) {
        var width = min(2, parallel);
        var previous = baseline;
        var single = false;
        while (cursor <= end && !reader.cancelled) {
          meter.reset();
          final chunks = <_Chunk>[];
          final phase = Stopwatch()..start();
          final phaseStart = cursor;
          var next = cursor;
          for (var i = 0; i < (single ? 1 : width) && next <= end; i++) {
            final to = single ? end : min(next + trialSize - 1, end);
            chunks.add(
              _Chunk(
                _client,
                upstream,
                next,
                to,
                total,
                stallTimeout,
                reader,
                validator: validator,
                openTimeout: openTimeout,
                prefetch: !single,
                onBytes: meter.add,
              ),
            );
            next = to + 1;
          }
          try {
            for (final chunk in chunks) {
              await for (final part in chunk.stream) {
                if (reader.cancelled) break;
                final write = Stopwatch()..start();
                socket.add(part);
                await socket.flush();
                if (write.elapsedMilliseconds > 100) {
                  meter.reset();
                  single = true;
                }
                cursor += part.length;
                sent += part.length;
              }
            }
          } catch (_) {
            if (single || reader.cancelled) rethrow;
            // Retry only the unserved suffix as one continuous request.
            single = true;
            continue;
          } finally {
            for (final chunk in chunks) {
              chunk.cancel();
            }
            if (single) {
              _release(upstream, reserved);
              reserved = 0;
            }
          }
          final speed =
              (cursor - phaseStart) / (phase.elapsedMicroseconds / 1e6);
          if (!single) {
            if (speed < baseline * 1.15 || speed < previous * 0.85) {
              single = true;
            } else {
              previous = speed;
              reserved += _reserve(
                upstream,
                min(parallel, width * 2) - 1 - reserved,
              );
              width = 1 + reserved;
            }
          }
          if (single && reserved > 0) {
            _release(upstream, reserved);
            reserved = 0;
          }
        }
      }
      if (reader.cancelled) {
        socket.destroy();
      } else {
        await socket.close();
      }
      LogUtil.debug(
        "Transfer ${upstream.host}: $sent bytes in "
        "${timer.elapsedMilliseconds} ms, parallel trial: $trialUsed",
      );
    } catch (e, stackTrace) {
      if (!reader.cancelled) {
        // Exception strings can contain signed URLs.
        LogUtil.warning(
          "Transfer failed for ${upstream.host} (${e.runtimeType})",
          null,
          stackTrace,
        );
      }
      if (socket == null) {
        try {
          response.statusCode = HttpStatus.badGateway;
          response.contentLength = 0;
          await response.close();
        } catch (_) {}
      }
      socket?.destroy();
    } finally {
      initial?.cancel();
      reader.cancel();
      _readers.remove(reader);
      _release(upstream, reserved);
    }
  }

  @visibleForTesting
  static (int, int)? parseRange(String? header, int total) {
    if (total <= 0) return null;
    if (header == null) return (0, total - 1);
    final match = RegExp(
      r"^bytes=([0-9]*)-([0-9]*)$",
    ).firstMatch(header.trim());
    if (match == null) return null;
    final first = match.group(1)!;
    final last = match.group(2)!;
    if (first.isEmpty) {
      final length = int.tryParse(last);
      if (length == null || length <= 0) return null;
      return (max(0, total - length), total - 1);
    }
    final start = int.tryParse(first);
    final requestedEnd = last.isEmpty ? total - 1 : int.tryParse(last);
    if (start == null || requestedEnd == null) return null;
    final end = min(requestedEnd, total - 1);
    if (start > end || start >= total) return null;
    return (start, end);
  }
}

class _Reader {
  bool cancelled = false;
  final Set<HttpClientRequest> requests = {};
  final Set<_Chunk> chunks = {};
  void cancel() {
    if (cancelled) return;
    cancelled = true;
    for (final request in requests.toList()) {
      request.abort();
    }
    for (final chunk in chunks.toList()) {
      chunk.cancel();
    }
  }
}

class TransferSpeed {
  const TransferSpeed(this.bytesPerSecond, this.measuredAt);
  final double bytesPerSecond;
  final DateTime measuredAt;
}

/// Count arrivals from all upstream chunks, including prefetched ones, over
/// wall time. Never subtract consumer waits and inflate the remaining rate.
class _TransferMeter {
  _TransferMeter(this.report);
  final void Function(TransferSpeed) report;
  final Stopwatch _watch = Stopwatch()..start();
  int _bytes = 0;

  void add(int bytes) {
    _bytes += bytes;
    if (_watch.elapsedMilliseconds < 1000 || _bytes < 64 * 1024) return;
    report(
      TransferSpeed(
        _bytes / (_watch.elapsedMicroseconds / 1e6),
        DateTime.now(),
      ),
    );
    reset();
  }

  void reset() {
    _bytes = 0;
    _watch.reset();
  }
}

Future<(HttpClientRequest, HttpClientResponse)> _open(
  HttpClient client,
  Uri upstream,
  String range,
  Duration timeout,
  _Reader reader, {
  String? validator,
  bool Function()? cancelled,
  void Function(HttpClientRequest)? onRequest,
}) async {
  final watch = Stopwatch()..start();
  var expired = false;
  final request = await client
      .getUrl(upstream)
      .then((request) {
        if (expired || reader.cancelled || (cancelled?.call() ?? false)) {
          request.abort();
          throw const HttpException("Cancelled request");
        }
        return request;
      })
      .timeout(
        timeout,
        onTimeout: () {
          expired = true;
          throw TimeoutException("Opening upstream", timeout);
        },
      );
  reader.requests.add(request);
  onRequest?.call(request);
  request.headers
    ..set(HttpHeaders.rangeHeader, range)
    ..set(HttpHeaders.acceptEncodingHeader, "identity");
  if (validator != null && !validator.startsWith("W/")) {
    request.headers.set(HttpHeaders.ifRangeHeader, validator);
  }
  try {
    final remaining = timeout - watch.elapsed;
    if (remaining <= Duration.zero) {
      throw TimeoutException("Opening upstream", timeout);
    }
    return (request, await request.close().timeout(remaining));
  } catch (_) {
    request.abort();
    reader.requests.remove(request);
    rethrow;
  }
}

class _ContentRange {
  _ContentRange(this.start, this.end, this.total);
  final int start, end, total;
  static _ContentRange? parse(String? value) {
    final match = RegExp(
      r"^bytes ([0-9]+)-([0-9]+)/([0-9]+)$",
    ).firstMatch(value ?? "");
    if (match == null) return null;
    final start = int.tryParse(match.group(1)!);
    final end = int.tryParse(match.group(2)!);
    final total = int.tryParse(match.group(3)!);
    if (start == null ||
        end == null ||
        total == null ||
        start > end ||
        end >= total) {
      return null;
    }
    return _ContentRange(start, end, total);
  }
}

class _InvalidRange implements Exception {
  const _InvalidRange();
}

void _validateResponse(
  HttpClientResponse response,
  int from,
  int to,
  int total, {
  String? validator,
}) {
  final range = _ContentRange.parse(
    response.headers.value(HttpHeaders.contentRangeHeader),
  );
  if (response.statusCode != HttpStatus.partialContent ||
      range == null ||
      range.start != from ||
      range.end != to ||
      range.total != total ||
      (response.contentLength >= 0 &&
          response.contentLength != to - from + 1) ||
      (response.headers.value(HttpHeaders.contentEncodingHeader) ??
              "identity") !=
          "identity" ||
      (validator != null &&
          response.headers.value(HttpHeaders.etagHeader) != validator)) {
    throw const _InvalidRange();
  }
}

Future<void> _discard(HttpClientResponse response) async {
  (await response.detachSocket()).destroy();
}

/// A bounded speculative chunk, or a backpressured continuous stream.
class _Chunk {
  _Chunk(
    this.client,
    this.upstream,
    this.from,
    this.to,
    this.total,
    this.timeout,
    this.reader, {
    this.validator,
    required this.openTimeout,
    this.opened,
    this.prefetch = true,
    this.onBytes,
  }) {
    reader.chunks.add(this);
    _run();
  }
  final HttpClient client;
  final Uri upstream;
  final int from, to, total;
  final Duration timeout;
  final Duration openTimeout;
  final _Reader reader;
  final String? validator;
  final bool prefetch;
  final void Function(int)? onBytes;
  (HttpClientRequest, HttpClientResponse)? opened;
  late final StreamController<List<int>> _data = StreamController(
    onListen: _resume,
    onPause: _pause,
    onResume: _resume,
    onCancel: cancel,
  );
  StreamSubscription<List<int>>? _subscription;
  HttpClientRequest? _request;
  Timer? _watchdog;
  Completer<void>? _attempt;
  int _received = 0;
  bool _cancelled = false;
  Stream<List<int>> get stream => _data.stream;

  void _pause() {
    _watchdog?.cancel();
    if (!(_subscription?.isPaused ?? true)) _subscription?.pause();
  }

  void _resume() {
    if (_subscription?.isPaused ?? false) _subscription?.resume();
    _arm();
  }

  void _arm() {
    _watchdog?.cancel();
    if (_cancelled ||
        _subscription == null ||
        (_subscription?.isPaused ?? false)) {
      return;
    }
    _watchdog = Timer(
      timeout,
      () => _finish(TimeoutException("No upstream data", timeout)),
    );
  }

  void _finish([Object? error]) {
    _watchdog?.cancel();
    final attempt = _attempt;
    if (attempt == null || attempt.isCompleted) return;
    if (error == null) {
      attempt.complete();
    } else {
      _subscription?.cancel();
      _request?.abort();
      attempt.completeError(error);
    }
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _watchdog?.cancel();
    _subscription?.cancel();
    _request?.abort();
    _finish(const HttpException("Cancelled"));
    reader.chunks.remove(this);
    if (!_data.isClosed) _data.close();
  }

  Future<void> _run() async {
    Object? failure;
    var failures = 0;
    while (failures < 3 && !_cancelled && !reader.cancelled) {
      final before = _received;
      try {
        final result =
            opened ??
            await _open(
              client,
              upstream,
              "bytes=${from + _received}-$to",
              openTimeout,
              reader,
              validator: validator,
              cancelled: () => _cancelled,
              onRequest: (request) => _request = request,
            );
        opened = null;
        _request = result.$1;
        final response = result.$2;
        try {
          _validateResponse(
            response,
            from + _received,
            to,
            total,
            validator: validator,
          );
        } catch (_) {
          await _discard(response);
          rethrow;
        }
        if (_cancelled || reader.cancelled) {
          await _discard(response);
          return;
        }
        _attempt = Completer<void>();
        _subscription = response.listen(
          (part) {
            if (_cancelled) return;
            if (_received + part.length > to - from + 1) {
              _finish(const _InvalidRange());
              return;
            }
            _received += part.length;
            onBytes?.call(part.length);
            _data.add(part);
            _arm();
          },
          onError: _finish,
          onDone: () => _finish(
            _received == to - from + 1
                ? null
                : const HttpException("Incomplete range"),
          ),
          cancelOnError: true,
        );
        if (_data.hasListener ? _data.isPaused : !prefetch) {
          _pause();
        } else {
          _arm();
        }
        await _attempt!.future;
        _watchdog?.cancel();
        reader.requests.remove(_request);
        if (!_data.isClosed) _data.close();
        reader.chunks.remove(this);
        return;
      } catch (e) {
        failure = e;
        failures = _received > before ? 0 : failures + 1;
        _watchdog?.cancel();
        reader.requests.remove(_request);
        if (e is _InvalidRange) break;
      }
    }
    if (!_cancelled && !reader.cancelled && !_data.isClosed) {
      _data.addError(failure ?? const HttpException("Transfer cancelled"));
      _data.close();
    }
    reader.chunks.remove(this);
  }
}
