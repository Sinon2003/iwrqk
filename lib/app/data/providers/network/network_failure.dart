import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:iwrqk/i18n/strings.g.dart';

/// Why a request got no usable answer.
enum NetworkFailureCause { handshake, addressLookup, connection, timeout }

/// A request that failed for network reasons, worded for the person using
/// the app instead of as an exception.
///
/// The message says whether the network or proxy is down or only Iwara is
/// out of reach, which calls for different fixes, and ends with the
/// technical cause. Most people reach the site through a proxy, where a
/// failing node shows up as a TLS handshake cut short.
class NetworkFailure implements Exception {
  const NetworkFailure(this.message);

  final String message;

  @override
  String toString() => message;

  /// Describes [error] when it is a network failure or a server error;
  /// returns null for anything else.
  static Future<NetworkFailure?> describe(Object error) async {
    if (error is DioException && error.type == DioExceptionType.badResponse) {
      final status = error.response?.statusCode;
      if (status == null) return null;
      return NetworkFailure(t.error.network.server(status: status));
    }

    final cause = causeOf(error);
    if (cause == null) return null;
    final causeName = switch (cause) {
      NetworkFailureCause.handshake => t.error.network.cause_handshake,
      NetworkFailureCause.addressLookup => t.error.network.cause_lookup,
      NetworkFailureCause.connection => t.error.network.cause_connection,
      NetworkFailureCause.timeout => t.error.network.cause_timeout,
    };
    return NetworkFailure(
      await othersReachable()
          ? t.error.network.site_unreachable(cause: causeName)
          : t.error.network.offline(cause: causeName),
    );
  }

  /// Classifies [error]; null when it is not a network failure.
  static NetworkFailureCause? causeOf(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return NetworkFailureCause.timeout;
        case DioExceptionType.badCertificate:
          return NetworkFailureCause.handshake;
        case DioExceptionType.connectionError:
          final inner = error.error;
          return (inner == null ? null : causeOf(inner)) ??
              NetworkFailureCause.connection;
        case DioExceptionType.unknown:
          final inner = error.error;
          return inner == null ? null : causeOf(inner);
        case DioExceptionType.badResponse:
        case DioExceptionType.cancel:
          return null;
      }
    }
    if (error is TlsException) return NetworkFailureCause.handshake;
    if (error is TimeoutException) return NetworkFailureCause.timeout;
    if (error is SocketException) {
      return error.message.contains("Failed host lookup")
          ? NetworkFailureCause.addressLookup
          : NetworkFailureCause.connection;
    }
    if (error is HttpException) return NetworkFailureCause.connection;
    if (error is http.ClientException) {
      // The http package wraps socket errors and keeps only their text.
      final text = error.message;
      if (text.contains("HandshakeException") ||
          text.contains("TlsException")) {
        return NetworkFailureCause.handshake;
      }
      if (text.contains("Failed host lookup")) {
        return NetworkFailureCause.addressLookup;
      }
      if (text.contains("TimeoutException")) return NetworkFailureCause.timeout;
      return NetworkFailureCause.connection;
    }
    return null;
  }

  /// Asks an unrelated site for a tiny answer.
  @visibleForTesting
  static Future<bool> Function() probeOthers = _probeOthers;

  static Future<bool>? _probe;
  static DateTime? _probedAt;

  @visibleForTesting
  static void forgetProbe() {
    _probe = null;
    _probedAt = null;
  }

  /// Whether an unrelated site answers, which tells a dead network or proxy
  /// from Iwara alone being out of reach. Failures come in bursts, so one
  /// answer serves the next half minute.
  static Future<bool> othersReachable() {
    final probedAt = _probedAt;
    final probe = _probe;
    if (probe != null &&
        probedAt != null &&
        DateTime.now().difference(probedAt) < const Duration(seconds: 30)) {
      return probe;
    }
    _probedAt = DateTime.now();
    return _probe = probeOthers();
  }

  static Future<bool> _probeOthers() async {
    const timeout = Duration(seconds: 4);
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(
        Uri.parse("https://www.gstatic.com/generate_204"),
      );
      final response = await request.close().timeout(timeout);
      await response.drain<void>();
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
