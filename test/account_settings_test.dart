import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/data/models/account/notifications/settings.dart';
import 'package:iwrqk/app/data/models/profile.dart';
import 'package:iwrqk/app/data/models/user.dart';
import 'package:iwrqk/app/data/services/user_service.dart';
import 'package:iwrqk/app/modules/account/account_settings/controller.dart';
import 'package:iwrqk/i18n/strings.g.dart';

/// Stands in for the site: it keeps a description without the blanks around
/// it, and can be out of reach.
class _Users extends GetxService implements UserService {
  String stored = 'before';
  bool reachable = true;

  @override
  UserModel? user = UserModel(
    id: 'id',
    name: 'Alice',
    username: 'alice',
    status: 'active',
    role: 'user',
    followedBy: false,
    following: false,
    friend: false,
    premium: false,
    createdAt: '',
    updatedAt: '',
  );

  @override
  ProfileModel? profile;

  @override
  bool hideSensitive = false;

  @override
  NotificationsSettings? notificationsSettings;

  @override
  Future<bool> getUser() async {
    profile = ProfileModel(
      body: stored,
      user: user,
      createdAt: '',
      updatedAt: '',
    );
    return true;
  }

  @override
  Future<bool> updateDescription(String body) async {
    if (!reachable) return false;
    stored = body.trim();
    return getUser();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Users users;
  late AccountSettingsController page;

  Future<void> pumpPage(WidgetTester tester) async {
    Get.reset();
    users = Get.put<UserService>(_Users()) as _Users;
    await tester.pumpWidget(
      MaterialApp(builder: FlutterSmartDialog.init(), home: const Scaffold()),
    );
    page = Get.put(AccountSettingsController());
    await tester.pump();
    expect(page.description, 'before');
  }

  testWidgets('a saved description shows as the site keeps it, and says so', (
    tester,
  ) async {
    await pumpPage(tester);
    await page.changeDescription('  after  ');
    await tester.pump();
    expect(page.description, 'after');
    expect(find.text(t.account_settings.saved), findsOneWidget);
    // Lets the toast run out.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('a description that did not save goes back, with no "saved"', (
    tester,
  ) async {
    await pumpPage(tester);
    users.reachable = false;
    await page.changeDescription('after');
    await tester.pump();
    expect(page.description, 'before');
    expect(find.text(t.account_settings.saved), findsNothing);
  });
}
