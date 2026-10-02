import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/components/dialogs/loading_dialog/widget.dart';
import 'package:iwrqk/i18n/strings.g.dart';

void main() {
  tearDown(Get.reset);

  Future<void> setup(WidgetTester tester, Future<void> Function() task) async {
    Get.reset();
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: TextButton(
            onPressed: () => Get.dialog(
              LoadingDialog(task: task),
              barrierDismissible: false,
            ),
            child: const Text('login'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'a layout rebuild does not repeat the request or retain an old error',
    (tester) async {
      var requests = 0;
      final pending = Completer<void>();
      await setup(tester, () {
        requests++;
        return pending.future;
      });
      expect(requests, 1);
      tester.view.physicalSize = const Size(900, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pump();
      tester.element(find.byType(LoadingDialog)).markNeedsBuild();
      await tester.pump();
      expect(requests, 1);
      pending.completeError('offline');
      await tester.pump();
      expect(find.text('offline'), findsOneWidget);
    },
  );

  testWidgets(
    'retry starts a fresh request and shows loading until it finishes',
    (tester) async {
      var requests = 0;
      final second = Completer<void>();
      await setup(tester, () async {
        requests++;
        if (requests == 1) throw 'offline';
        await second.future;
      });
      expect(find.text('offline'), findsOneWidget);
      await tester.tap(find.text(t.notifications.ok));
      await tester.pumpAndSettle();
      await tester.tap(find.text('login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(requests, 2);
      expect(find.text('offline'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      second.complete();
      await tester.pumpAndSettle();
      expect(find.text(t.notifications.success), findsWidgets);
    },
  );

  testWidgets(
    'closing a pending dialog cancels its attempt and ignores completion',
    (tester) async {
      Get.reset();
      final pending = Completer<void>();
      var cancelled = 0;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () => Get.dialog(
                LoadingDialog(
                  task: () => pending.future,
                  onCancel: () => cancelled++,
                ),
              ),
              child: const Text('login'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      Get.back();
      await tester.pumpAndSettle();
      expect(cancelled, 1);
      pending.completeError('late failure');
      await tester.pumpAndSettle();
      expect(find.text('late failure'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
