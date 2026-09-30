import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/data/enums/translation_display_mode.dart';
import 'package:iwrqk/app/data/enums/translation_engine.dart';
import 'package:iwrqk/app/data/providers/translate_provider.dart';
import 'package:iwrqk/i18n/strings.g.dart';

void main() {
  group('splitIntoChunks', () {
    test('keeps short text as one chunk and normalizes CRLF', () {
      expect(TranslateProvider.splitIntoChunks('a\r\n\r\nb', 100), ['a\n\nb']);
    });

    test('packs lines up to the limit and preserves them when rejoined', () {
      final lines = List.generate(10, (i) => 'line $i ${'x' * 20}');
      final text = lines.join('\n');
      final chunks = TranslateProvider.splitIntoChunks(text, 80);

      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(80));
      }
      expect(chunks.join('\n'), text);
    });

    test('keeps empty lines between paragraphs', () {
      final chunks = TranslateProvider.splitIntoChunks('a\n\n\nb', 3);
      expect(chunks, ['a\n\n', 'b']);
      expect(chunks.join('\n'), 'a\n\n\nb');
    });

    test('cuts a single line longer than the limit', () {
      final chunks = TranslateProvider.splitIntoChunks(
        'short\n${'y' * 25}',
        10,
      );
      expect(chunks, ['short', 'y' * 10, 'y' * 10, 'y' * 5]);
    });
  });

  group('targetLanguage', () {
    test('maps app locales per engine', () {
      expect(
        TranslateProvider.targetLanguage(
          TranslationEngine.google,
          AppLocale.zhTw,
        ),
        'zh-TW',
      );
      expect(
        TranslateProvider.targetLanguage(
          TranslationEngine.volcengine,
          AppLocale.zhTw,
        ),
        'zh-Hant',
      );
      expect(
        TranslateProvider.targetLanguage(
          TranslationEngine.tencent,
          AppLocale.zhCn,
        ),
        'zh',
      );
      expect(
        TranslateProvider.targetLanguage(
          TranslationEngine.yandex,
          AppLocale.zhTw,
        ),
        'zh',
      );
      for (final engine in TranslationEngine.values) {
        expect(TranslateProvider.targetLanguage(engine, AppLocale.ja), 'ja');
        expect(TranslateProvider.targetLanguage(engine, AppLocale.en), 'en');
      }
    });
  });

  group('response parsing', () {
    test('Google: nested and flat responses', () {
      expect(
        TranslateProvider.parseGoogle([
          ['你好\n\n世界', 'ja'],
        ]),
        '你好\n\n世界',
      );
      expect(TranslateProvider.parseGoogle(['你好']), '你好');
    });

    test('Volcengine: success and error status', () {
      expect(
        TranslateProvider.parseVolcengine({
          'translation': '你好',
          'base_resp': {'status_code': 0, 'status_message': ''},
        }),
        '你好',
      );
      expect(
        () => TranslateProvider.parseVolcengine({
          'base_resp': {'status_code': 1, 'status_message': 'too long'},
        }),
        throwsException,
      );
    });

    test('TranSmart: joins lines and rejects failures', () {
      expect(
        TranslateProvider.parseTencent({
          'header': {'ret_code': 'succ'},
          'auto_translation': ['第一段', '', '第二段'],
        }),
        '第一段\n\n第二段',
      );
      expect(
        () => TranslateProvider.parseTencent({
          'header': {'ret_code': 'error'},
        }),
        throwsException,
      );
    });

    test('Yandex: success and error code', () {
      expect(
        TranslateProvider.parseYandex({
          'code': 200,
          'text': ['你好\n\n世界'],
        }),
        '你好\n\n世界',
      );
      expect(
        () => TranslateProvider.parseYandex({'code': 403}),
        throwsException,
      );
    });
  });

  test('fromName resolves stored names', () {
    expect(
      TranslationEngine.fromName('volcengine'),
      TranslationEngine.volcengine,
    );
    expect(TranslationEngine.fromName('unknown'), isNull);
    expect(TranslationEngine.fromName(null), isNull);
  });

  test('display mode fromName resolves stored names', () {
    expect(
      TranslationDisplayMode.fromName('replace'),
      TranslationDisplayMode.replace,
    );
    expect(TranslationDisplayMode.fromName('unknown'), isNull);
    expect(TranslationDisplayMode.fromName(null), isNull);
  });
}
