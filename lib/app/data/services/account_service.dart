import 'dart:convert';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../enums/result.dart';
import '../providers/api_provider.dart';
import '../providers/network/auth_client.dart';
import '../providers/storage_provider.dart';

class AccountService extends GetxService {
  AccountService({AuthClient Function()? createAuthClient})
    : _createAuthClient = createAuthClient ?? AuthClient.new;

  final AuthClient Function() _createAuthClient;
  AuthClient? _loginClient;
  int _loginAttempt = 0;
  String? token;
  String? accessToken;

  final RxBool _isLogin = false.obs;

  bool get isLogin => _isLogin.value;

  set isLogin(bool isLogin) {
    _isLogin.value = isLogin;
  }

  void reset() {
    cancelLogin();
    token = null;
    accessToken = null;
    isLogin = false;
  }

  bool _isExpired(String tokenStr) {
    var payload = jsonDecode(
      utf8.decode(base64.decode(base64.normalize(tokenStr.split('.')[1]))),
    );
    var exp = payload["exp"];
    return exp < DateTime.now().millisecondsSinceEpoch / 1000;
  }

  bool isTokenExpired() {
    return token == null ? true : _isExpired(token!);
  }

  bool isAccessTokenExpired() {
    return accessToken == null ? true : _isExpired(accessToken!);
  }

  void notifyTokenExpired() {
    if (token != null && _isExpired(token!)) {
      SmartDialog.showToast(t.account.require_login);
    }
  }

  Future<ApiResult<void>> getAccessToken() async {
    final currentToken = token;
    if (currentToken == null) {
      return ApiResult(
        data: null,
        success: false,
        message: t.account.require_login,
      );
    }
    ApiResult<dynamic> results = await ApiProvider.getAccessToken(
      token: currentToken,
    );

    if (currentToken != token) {
      return ApiResult(
        data: null,
        success: false,
        message: t.account.require_login,
      );
    }
    if (results.success) {
      accessToken = results.data;
    }

    return ApiResult(
      data: null,
      success: results.success,
      message: results.message,
    );
  }

  void logout() {
    reset();
    StorageProvider.userToken.delete();
  }

  Future<ApiResult<void>> login({
    required String account,
    required String password,
  }) async {
    cancelLogin();
    final attempt = _loginAttempt;
    final client = _loginClient = _createAuthClient();
    try {
      final login = await ApiProvider.login(account, password, client: client);
      if (!login.success) {
        return ApiResult(data: null, success: false, message: login.message);
      }
      final access = await ApiProvider.getAccessToken(
        token: login.data,
        client: client,
      );
      if (!access.success) {
        return ApiResult(data: null, success: false, message: access.message);
      }
      if (attempt != _loginAttempt) {
        return ApiResult(
          data: null,
          success: false,
          message: t.error.network.offline,
        );
      }
      // Publish the session only after both requests succeed. A timeout in the
      // token exchange must not leave a half-saved account for the next retry.
      await StorageProvider.userToken.set(login.data!);
      if (attempt != _loginAttempt) {
        return ApiResult(
          data: null,
          success: false,
          message: t.error.network.offline,
        );
      }
      token = login.data;
      accessToken = access.data;
      isLogin = true;
      return ApiResult(data: null, success: true);
    } finally {
      client.close();
      if (identical(_loginClient, client)) _loginClient = null;
    }
  }

  void cancelLogin() {
    _loginAttempt++;
    _loginClient?.close();
    _loginClient = null;
  }

  Future<bool> canLoginFromCache() async {
    token = await StorageProvider.userToken.get();

    if (token != null) {
      if (_isExpired(token!)) {
        return false;
      } else {
        return true;
      }
    }

    return false;
  }

  Future<ApiResult<void>> loginFromCache() async {
    ApiResult<void> results = ApiResult(data: null, success: false);

    token = await StorageProvider.userToken.get();

    if (_isExpired(token!)) {
      results = await getAccessToken();
    } else {
      isLogin = true;
      results = ApiResult(data: null, success: true);
    }

    return results;
  }
}
