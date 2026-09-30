import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../utils/log_util.dart';
import '../enums/result.dart';
import '../enums/translation_engine.dart';

/// Translates user content with key-free web translation endpoints.
///
/// The target language follows the app locale. Long text is split at line
/// breaks into chunks each engine accepts, translated in order and joined
/// with line breaks again.
class TranslateProvider {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "user-agent":
            "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.5672.76 Mobile Safari/537.36",
      },
    ),
  );

  static final String _sessionId = _randomHex(32);

  static Future<ApiResult<String>> translate({
    required String text,
    required TranslationEngine engine,
  }) async {
    if (text.trim().isEmpty) {
      return ApiResult(data: text, success: true);
    }

    String? message;
    String? data;
    try {
      final target = targetLanguage(engine, LocaleSettings.currentLocale);
      final results = <String>[];
      for (final chunk in splitIntoChunks(text, engine.maxChunkLength)) {
        results.add(await _translateChunk(engine, chunk, target));
      }
      data = results.join("\n");
    } catch (e, stackTrace) {
      LogUtil.error("Translate with ${engine.name} failed", e, stackTrace);
      message = e.toString();
    }
    return ApiResult(data: data, message: message, success: message == null);
  }

  /// Splits [text] at line breaks into chunks of at most [maxLength]
  /// characters. A single line longer than that is cut into pieces.
  @visibleForTesting
  static List<String> splitIntoChunks(String text, int maxLength) {
    final chunks = <String>[];
    String? current;
    for (var line in text.replaceAll("\r\n", "\n").split("\n")) {
      while (line.length > maxLength) {
        if (current != null) {
          chunks.add(current);
          current = null;
        }
        chunks.add(line.substring(0, maxLength));
        line = line.substring(maxLength);
      }
      if (current == null) {
        current = line;
      } else if (current.length + 1 + line.length <= maxLength) {
        current = "$current\n$line";
      } else {
        chunks.add(current);
        current = line;
      }
    }
    if (current != null) chunks.add(current);
    return chunks;
  }

  @visibleForTesting
  static String targetLanguage(TranslationEngine engine, AppLocale locale) {
    switch (engine) {
      case TranslationEngine.google:
        return switch (locale) {
          AppLocale.en => "en",
          AppLocale.ja => "ja",
          AppLocale.zhCn => "zh-CN",
          AppLocale.zhTw => "zh-TW",
        };
      case TranslationEngine.volcengine:
        return switch (locale) {
          AppLocale.en => "en",
          AppLocale.ja => "ja",
          AppLocale.zhCn => "zh",
          AppLocale.zhTw => "zh-Hant",
        };
      case TranslationEngine.tencent:
        return switch (locale) {
          AppLocale.en => "en",
          AppLocale.ja => "ja",
          AppLocale.zhCn => "zh",
          AppLocale.zhTw => "zh-TW",
        };
      case TranslationEngine.yandex:
        // Yandex has no Traditional Chinese target.
        return switch (locale) {
          AppLocale.en => "en",
          AppLocale.ja => "ja",
          AppLocale.zhCn || AppLocale.zhTw => "zh",
        };
    }
  }

  static Future<String> _translateChunk(
    TranslationEngine engine,
    String text,
    String target,
  ) async {
    switch (engine) {
      case TranslationEngine.google:
        final response = await _dio.post(
          "https://translate.googleapis.com/translate_a/t",
          queryParameters: {
            "client": "gtx",
            "sl": "auto",
            "tl": target,
            "dt": "t",
          },
          // POST: long text in the query string is rejected with HTTP 400.
          data: {"q": text},
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        return parseGoogle(response.data);
      case TranslationEngine.volcengine:
        final response = await _dio.post(
          "https://translate.volcengine.com/crx/translate/v1/",
          data: {
            "source_language": "detect",
            "target_language": target,
            "text": text,
          },
        );
        return parseVolcengine(response.data);
      case TranslationEngine.tencent:
        final response = await _dio.post(
          "https://transmart.qq.com/api/imt",
          data: {
            "header": {
              "fn": "auto_translation",
              "client_key":
                  "browser-chrome-120.0.0-Android-$_sessionId-${DateTime.now().millisecondsSinceEpoch}",
            },
            "type": "plain",
            "model_category": "normal",
            "source": {"lang": "auto", "text_list": text.split("\n")},
            "target": {"lang": target},
          },
        );
        return parseTencent(response.data);
      case TranslationEngine.yandex:
        final response = await _dio.post(
          "https://translate.yandex.net/api/v1/tr.json/translate",
          queryParameters: {"id": "$_sessionId-0-0", "srv": "android"},
          data: {"lang": target, "text": text},
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        return parseYandex(response.data);
    }
  }

  /// `[["translated", "detected language"]]`, or `["translated"]` when the
  /// source language is fixed.
  @visibleForTesting
  static String parseGoogle(dynamic data) {
    final first = (data as List).first;
    return (first is List ? first.first : first) as String;
  }

  @visibleForTesting
  static String parseVolcengine(dynamic data) {
    final status = data["base_resp"]?["status_code"];
    if (status != null && status != 0) {
      throw Exception(
        "Volcengine error $status: ${data["base_resp"]["status_message"]}",
      );
    }
    return data["translation"] as String;
  }

  @visibleForTesting
  static String parseTencent(dynamic data) {
    final retCode = data["header"]?["ret_code"];
    if (retCode != "succ") {
      throw Exception("TranSmart error: $retCode");
    }
    return (data["auto_translation"] as List).join("\n");
  }

  @visibleForTesting
  static String parseYandex(dynamic data) {
    if (data["code"] != 200) {
      throw Exception("Yandex error: ${data["code"]}");
    }
    return (data["text"] as List).join();
  }

  static String _randomHex(int length) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }
}
