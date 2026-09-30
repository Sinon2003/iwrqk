import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/utils/path_util.dart';

void main() {
  group('safeFileName', () {
    test('replaces characters file systems reject with full-width ones', () {
      expect(PathUtil.safeFileName('MasoFactory: Elegg'), 'MasoFactory： Elegg');
      expect(PathUtil.safeFileName(r'a/b\c*d?e"f<g>h|i'), 'a／b＼c＊d？e＂f＜g＞h｜i');
    });

    test('keeps ordinary titles as they are', () {
      const title = '【MMD R-18】GORANSHIN DANCE2【刑部姫巴御前紫式部】';
      expect(PathUtil.safeFileName(title), title);
    });

    test('drops control characters and surrounding spaces', () {
      expect(PathUtil.safeFileName('  line\none\t '), 'lineone');
    });

    test('cuts long names without splitting a character', () {
      final safe = PathUtil.safeFileName('あ' * 100, maxBytes: 200);
      expect(utf8.encode(safe).length, lessThanOrEqualTo(200));
      expect(safe, 'あ' * 66);
    });

    test('never returns an empty or special name', () {
      expect(PathUtil.safeFileName('   '), '_');
      expect(PathUtil.safeFileName('..'), '_');
    });
  });
}
