import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:iwrqk/i18n/strings.g.dart';

/// Why a request got no usable answer.
enum NetworkFailureCause { handshake, addressLookup, connection, timeout }

/// A request that failed for network reasons, worded for the person using
/// the app instead of as an exception.
///
/// A failed request cannot determine whether other sites or a replacement VPN
/// node work. Describe that request without additional probes or cached verdicts.
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

    if (causeOf(error) == null) return null;
    return NetworkFailure(t.error.network.offline);
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
}
