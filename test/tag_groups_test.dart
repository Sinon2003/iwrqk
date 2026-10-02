import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/components/tag_catalog.dart';
import 'package:iwrqk/app/data/services/tag_name_service.dart';
import 'package:iwrqk/app/utils/tag_groups.dart';

void main() {
  group('TagGroups', () {
    test('reads the groups and their tags in the order they are written', () {
      final groups = TagGroups.fromJson(
        '{"common": ["dance", "anal"], "acts": ["anal", "blowjob"]}',
      );
      expect(groups.keys, ['common', 'acts']);
      expect(groups.of('common'), ['dance', 'anal']);
      expect(groups.of('acts'), ['anal', 'blowjob']);
      expect(groups.of('body'), isEmpty);
    });

    test('leaves out what is not a group of tags', () {
      final groups = TagGroups.fromJson(
        '{"acts": ["anal", 1, null], "count": 2, "note": "x"}',
      );
      expect(groups.keys, ['acts']);
      expect(groups.of('acts'), ['anal']);
      expect(TagGroups.fromJson('[]').isEmpty, isTrue);
      expect(TagGroups.empty.keys, isEmpty);
    });
  });

  group('the groups shipped with the app', () {
    // Kept by their id in the name tables on purpose, and not put on show.
    const notOnShow = {'cunny', 'lolidom', 'sholicon', 'js', 'poke_kid'};

    final source = File(TagNameService.groupsAsset).readAsStringSync();
    final groups = TagGroups.fromJson(source);
    final named = {
      for (final asset in TagNameService.assets.values)
        ...(json.decode(File(asset).readAsStringSync()) as Map<String, dynamic>)
            .keys,
    };

    test('start with the common tags and have a name each', () {
      expect(groups.keys.first, 'common');
      expect(groups.keys.length, greaterThan(1));
      for (final key in groups.keys) {
        expect(groups.of(key), isNotEmpty, reason: key);
        expect(tagGroupName(key), isNot(key), reason: 'no word for $key');
      }
    });

    test('put every tag that has a name in exactly one group', () {
      final placed = <String>[
        for (final key in groups.keys.skip(1)) ...groups.of(key),
      ];
      expect(placed.toSet().length, placed.length, reason: 'a tag twice');
      expect(placed.toSet().difference(named), isEmpty, reason: 'no name');
      expect(named.difference(placed.toSet()), notOnShow);
    });

    test('repeat among the common ones only tags that have a group', () {
      final common = groups.of('common');
      final placed = {for (final key in groups.keys.skip(1)) ...groups.of(key)};
      expect(common.toSet().length, common.length);
      expect(common.toSet().difference(placed), isEmpty);
    });
  });

  group('TagCatalogView', () {
    const groups = TagGroups({
      'common': ['dance', 'anal'],
      'acts': ['anal', 'blowjob'],
    });
    const names = {'dance': '舞蹈', 'anal': '肛交', 'blowjob': '口交'};

    Future<RxList<String>> pump(WidgetTester tester) async {
      final picked = <String>[].obs;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                TagCatalogView(
                  groups: groups,
                  label: (id) => names[id] ?? id,
                  withIds: true,
                  isPicked: picked.contains,
                  onToggle: (id) {
                    if (!picked.remove(id)) picked.add(id);
                  },
                ),
              ],
            ),
          ),
        ),
      );
      return picked;
    }

    testWidgets('opens on the first group, each tag by name and id', (
      tester,
    ) async {
      await pump(tester);
      expect(find.widgetWithText(ChoiceChip, 'Common'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Sex acts'), findsOneWidget);
      expect(find.text('舞蹈'), findsOneWidget);
      expect(find.text('dance'), findsOneWidget);
      expect(find.text('肛交'), findsOneWidget);
      expect(find.text('口交'), findsNothing);
    });

    testWidgets('shows the tags of the group that is tapped', (tester) async {
      await pump(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sex acts'));
      await tester.pump();
      expect(find.text('口交'), findsOneWidget);
      expect(find.text('肛交'), findsOneWidget);
      expect(find.text('舞蹈'), findsNothing);
    });

    testWidgets('picks a tag on a tap and drops it on the next', (
      tester,
    ) async {
      final picked = await pump(tester);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.text('肛交'));
      await tester.pump();
      expect(picked, ['anal']);
      expect(find.byIcon(Icons.check), findsOneWidget);

      // The same tag is marked in the other group it is listed in.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sex acts'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('肛交'));
      await tester.pump();
      expect(picked, isEmpty);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('is nothing while there are no groups', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                TagCatalogView(
                  groups: TagGroups.empty,
                  label: (id) => id,
                  withIds: false,
                  isPicked: (id) => false,
                  onToggle: (id) {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(ChoiceChip), findsNothing);
    });
  });
}
