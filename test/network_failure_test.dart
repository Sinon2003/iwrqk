import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:iwrqk/app/data/providers/network/network_failure.dart';
import 'package:iwrqk/i18n/strings.g.dart';

DioException dioException(DioExceptionType type, {Object? error, int? status}) {
  final options = RequestOptions(path: '/videos');
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  // What a failing proxy node produces: the connection opens, then the
  // handshake is cut.
  const cutHandshake = HandshakeException(
    'Connection terminated during handshake',
  );

  group('causeOf', () {
    test('recognizes a handshake cut short', () {
      expect(
        NetworkFailure.causeOf(cutHandshake),
        NetworkFailureCause.handshake,
      );
    });

    test('tells lookups, refused connections and timeouts apart', () {
      expect(
        NetworkFailure.causeOf(
          const SocketException("Failed host lookup: 'apiq.iwara.tv'"),
        ),
        NetworkFailureCause.addressLookup,
      );
      expect(
        NetworkFailure.causeOf(const SocketException('Connection refused')),
        NetworkFailureCause.connection,
      );
      expect(
        NetworkFailure.causeOf(TimeoutException('too slow')),
        NetworkFailureCause.timeout,
      );
    });

    test('reads the text the http package keeps of a socket error', () {
      expect(
        NetworkFailure.causeOf(
          http.ClientException("SocketException: Failed host lookup: 'x'"),
        ),
        NetworkFailureCause.addressLookup,
      );
      expect(
        NetworkFailure.causeOf(http.ClientException('Connection reset')),
        NetworkFailureCause.connection,
      );
    });

    test('looks inside Dio exceptions', () {
      expect(
        NetworkFailure.causeOf(
          dioException(DioExceptionType.unknown, error: cutHandshake),
        ),
        NetworkFailureCause.handshake,
      );
      expect(
        NetworkFailure.causeOf(dioException(DioExceptionType.receiveTimeout)),
        NetworkFailureCause.timeout,
      );
      expect(
        NetworkFailure.causeOf(dioException(DioExceptionType.connectionError)),
        NetworkFailureCause.connection,
      );
    });

    test('leaves other errors alone', () {
      expect(NetworkFailure.causeOf(const FormatException('bad JSON')), isNull);
      expect(
        NetworkFailure.causeOf(
          dioException(
            DioExceptionType.unknown,
            error: const FormatException('bad JSON'),
          ),
        ),
        isNull,
      );
    });
  });

  group('describe', () {
    test('describes the failed request without probing other sites', () async {
      final failure = await NetworkFailure.describe(cutHandshake);
      expect(failure!.message, t.error.network.offline);
    });

    test('uses the requested concise Chinese message for timeouts', () async {
      await LocaleSettings.setLocale(AppLocale.zhCn);
      addTearDown(() => LocaleSettings.setLocale(AppLocale.en));
      final failure = await NetworkFailure.describe(
        TimeoutException('too slow'),
      );
      expect(failure!.message, '网络或代理不通。请检查网络，或更换代理节点后重试。');
    });

    test('reports a server error with its status, without probing', () async {
      final failure = await NetworkFailure.describe(
        dioException(DioExceptionType.badResponse, status: 502),
      );
      expect(failure!.message, contains('HTTP 502'));
    });

    test('returns null for other errors', () async {
      expect(
        await NetworkFailure.describe(const FormatException('bad JSON')),
        isNull,
      );
    });
  });
}
