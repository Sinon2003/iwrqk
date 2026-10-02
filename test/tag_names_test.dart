import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/data/services/tag_name_service.dart';
import 'package:iwrqk/app/utils/tag_names.dart';

void main() {
  const names = TagNames({
    'black_cat': '黑猫',
    'cat_ears': '猫耳',
    'cat_lingerie': '猫咪内衣',
    'catgirl': '猫娘',
    'hatsune_miku': '初音未来',
    'school_swimsuit': '死库水',
  });

  group('TagNames', () {
    test('names the tags it has', () {
      expect(names.of('school_swimsuit'), '死库水');
      expect(names.of('swimsuit'), isNull);
      expect(TagNames.empty.of('school_swimsuit'), isNull);
    });

    test('reads a table and leaves out what is not a name', () {
      final read = TagNames.fromJson(
        '{"cat_ears": "猫耳", "empty": "", "number": 1, "none": null}',
      );
      expect(read.length, 1);
      expect(read.of('cat_ears'), '猫耳');
      expect(TagNames.fromJson('[]').isEmpty, isTrue);
    });

    test('finds tags by a part of the name, the closest first', () {
      expect(names.search('猫'), [
        'cat_ears',
        'catgirl',
        'cat_lingerie',
        'black_cat',
      ]);
      expect(names.search('猫耳'), ['cat_ears']);
      expect(names.search('库水'), ['school_swimsuit']);
      expect(names.search('犬'), isEmpty);
    });

    test('finds tags by a part of the id, written with spaces or not', () {
      expect(names.search('cat'), [
        'cat_ears',
        'catgirl',
        'cat_lingerie',
        'black_cat',
      ]);
      expect(names.search('Cat Ears'), ['cat_ears']);
      expect(names.search(' miku '), ['hatsune_miku']);
    });

    test('finds nothing for nothing, and no more than asked', () {
      expect(names.search(''), isEmpty);
      expect(names.search('   '), isEmpty);
      expect(names.search('猫', limit: 2), ['cat_ears', 'catgirl']);
    });
  });

  group('TagNames.complete', () {
    test('puts what the site completes first, then the tags by name', () async {
      final asked = <String>[];
      final found = await names.complete('cat', (keyword) async {
        asked.add(keyword);
        return ['catgirl', 'catboy'];
      });
      expect(asked, ['cat']);
      expect(found, [
        'catgirl',
        'catboy',
        'cat_ears',
        'cat_lingerie',
        'black_cat',
      ]);
    });

    test('does not ask the site about a name it cannot know', () async {
      var asked = false;
      final found = await names.complete('猫娘', (keyword) async {
        asked = true;
        return ['never'];
      });
      expect(asked, isFalse);
      expect(found, ['catgirl']);
    });

    test('keeps the tags by name when the site fails', () async {
      final found = await names.complete(
        'miku',
        (keyword) async => throw StateError('offline'),
      );
      expect(found, ['hatsune_miku']);
    });

    test('is the site alone without a table', () async {
      expect(
        await TagNames.empty.complete('cat', (keyword) async => ['catgirl']),
        ['catgirl'],
      );
      expect(
        await TagNames.empty.complete('猫', (keyword) async => ['never']),
        isEmpty,
      );
    });
  });

  group('the tables shipped with the app', () {
    Map<String, dynamic> read(String asset) =>
        json.decode(File(asset).readAsStringSync()) as Map<String, dynamic>;

    for (final asset in TagNameService.assets.values) {
      test('$asset is a table of names by tag id, in the order of the ids', () {
        final table = read(asset);
        final ids = table.keys.toList();

        expect(ids, isNotEmpty);
        expect(ids, [...ids]..sort(), reason: 'ids out of order');
        for (final entry in table.entries) {
          expect(
            entry.key,
            matches(RegExp(r'^[a-z0-9_().-]+$')),
            reason: 'not a tag id',
          );
          final name = entry.value;
          expect(name, isA<String>(), reason: entry.key);
          expect(name, isNotEmpty, reason: entry.key);
          expect(name, (name as String).trim(), reason: entry.key);
          expect(name.contains('\n'), isFalse, reason: entry.key);
        }
        expect(
          TagNames.fromJson(File(asset).readAsStringSync()).length,
          ids.length,
        );
      });
    }

    test('name the same tags in every language', () {
      final tables = [
        for (final asset in TagNameService.assets.values) read(asset),
      ];
      for (final table in tables.skip(1)) {
        expect(table.keys.toSet(), tables.first.keys.toSet());
      }
    });
  });
}
