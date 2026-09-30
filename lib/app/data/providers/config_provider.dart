import 'package:dio/dio.dart';

import '../../const/config.dart';
import '../enums/result.dart';
import '../models/app_release.dart';

class ConfigProvider {
  static late Dio _dio;

  static void init() {
    _dio = Dio();

    _dio.options.headers = {
      "user-agent":
          "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.5672.76 Mobile Safari/537.36",
    };
  }

  /// The newest release, which may be a prerelease.
  static Future<ApiResult<AppRelease>> getLatestRelease() async {
    String? message;
    AppRelease? release;
    try {
      final response = await _dio.get(ConfigConst.checkUpdateUrl);
      release = AppRelease.fromJson(response.data[0]);
    } catch (e) {
      message = e.toString();
    }
    return ApiResult(data: release, message: message, success: message == null);
  }

  /// Downloads [url] to [path], reporting the bytes received and the total.
  static Future<void> download(
    String url,
    String path, {
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) {
    return _dio.download(
      url,
      path,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}
