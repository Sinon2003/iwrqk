import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iwrqk/app/data/providers/api_provider.dart';
import 'package:iwrqk/app/data/providers/network/auth_client.dart';
import 'package:iwrqk/app/data/providers/storage_provider.dart';
import 'package:iwrqk/app/data/services/account_service.dart';
import 'package:iwrqk/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    StorageProvider.userToken = SecStorageObject(
      const FlutterSecureStorage(),
      'userToken',
    );
  });

  http.Response success(http.Request request) => http.Response(
    request.url.path == '/user/login'
        ? '{"token":"new-refresh"}'
        : '{"accessToken":"new-access"}',
    200,
  );

  test(
    'timeout then retry uses a fresh client and ignores the late response',
    () async {
      var clients = 0;
      var requests = 0;
      final oldResponse = Completer<http.Response>();
      final account = AccountService(
        createAuthClient: () {
          final attempt = ++clients;
          return AuthClient(
            timeout: const Duration(milliseconds: 80),
            client: MockClient((request) {
              requests++;
              return attempt == 1
                  ? oldResponse.future
                  : Future.value(success(request));
            }),
          );
        },
      );
      final first = await account.login(account: 'test', password: 'password');
      expect(first.success, isFalse);
      expect(first.message, t.error.network.offline);
      expect(account.isLogin, isFalse);
      expect(await StorageProvider.userToken.get(), isNull);
      expect(
        (await account.login(account: 'test', password: 'password')).success,
        isTrue,
      );
      oldResponse.complete(http.Response('{"token":"old-refresh"}', 200));
      await Future<void>.delayed(Duration.zero);
      expect(clients, 2);
      expect(requests, 3);
      expect(account.token, 'new-refresh');
      expect(account.accessToken, 'new-access');
      expect(await StorageProvider.userToken.get(), 'new-refresh');
    },
  );

  test('failure during token exchange leaves no partial login', () async {
    var attempts = 0;
    final paths = <String>[];
    final account = AccountService(
      createAuthClient: () {
        final attempt = ++attempts;
        return AuthClient(
          client: MockClient((request) async {
            paths.add(request.url.path);
            if (attempt == 1 && request.url.path == '/user/token') {
              throw const SocketException('route unavailable');
            }
            return success(request);
          }),
        );
      },
    );
    expect(
      (await account.login(account: 'test', password: 'password')).success,
      isFalse,
    );
    expect(account.token, isNull);
    expect(account.accessToken, isNull);
    expect(await StorageProvider.userToken.get(), isNull);
    expect(
      (await account.login(account: 'test', password: 'password')).success,
      isTrue,
    );
    expect(paths, ['/user/login', '/user/token', '/user/login', '/user/token']);
  });

  test('closing a login prevents it from authenticating later', () async {
    final pending = Completer<http.Response>();
    final account = AccountService(
      createAuthClient: () =>
          AuthClient(client: MockClient((_) => pending.future)),
    );
    final result = account.login(account: 'test', password: 'password');
    account.cancelLogin();
    expect((await result).success, isFalse);
    pending.complete(http.Response('{"token":"old"}', 200));
    await Future<void>.delayed(Duration.zero);
    expect(account.isLogin, isFalse);
    expect(await StorageProvider.userToken.get(), isNull);
  });

  for (final body in ['{}', '{"token":null}', '<html>challenge</html>']) {
    test(
      'an invalid authentication response is not a successful login: $body',
      () async {
        final client = AuthClient(
          client: MockClient((_) async => http.Response(body, 200)),
        );
        try {
          final result = await ApiProvider.login(
            'test',
            'password',
            client: client,
          );
          expect(result.success, isFalse);
          expect(result.message, t.error.network.invalid_response);
        } finally {
          client.close();
        }
      },
    );
  }

  test(
    'invalid credentials retain the account error rather than a network error',
    () async {
      final client = AuthClient(
        client: MockClient(
          (_) async => http.Response('{"message":"errors.invalidLogin"}', 401),
        ),
      );
      try {
        final result = await ApiProvider.login('test', 'wrong', client: client);
        expect(result.success, isFalse);
        expect(result.message, 'errors.invalidLogin');
      } finally {
        client.close();
      }
    },
  );
}
