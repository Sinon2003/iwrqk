import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iwrqk/app/components/buttons/friend_button/widget.dart';
import 'package:iwrqk/app/data/enums/result.dart';
import 'package:iwrqk/app/data/enums/types.dart';
import 'package:iwrqk/app/data/models/user.dart';
import 'package:iwrqk/app/data/services/account_service.dart';
import 'package:iwrqk/app/data/services/user_service.dart';
import 'package:iwrqk/i18n/strings.g.dart';

class _Account extends GetxService implements AccountService {
  @override
  bool get isLogin => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A friend already, and counting how often the friendship is ended.
class _Users extends GetxService implements UserService {
  int unfriended = 0;

  @override
  final AccountService accountService = _Account();

  @override
  Future<ApiResult<FriendRelationType>> getFriendRelation(String userId) async {
    return ApiResult(data: FriendRelationType.friended, success: true);
  }

  @override
  Future<bool> unfriend(String userId) async {
    unfriended++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Users users;

  setUp(() {
    Get.reset();
    users = Get.put<UserService>(_Users()) as _Users;
  });

  Future<void> pumpButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: FriendButton(
            user: UserModel(
              id: 'id',
              name: 'Alice',
              username: 'alice',
              status: 'active',
              role: 'user',
              followedBy: false,
              following: false,
              friend: true,
              premium: false,
              createdAt: '',
              updatedAt: '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.friend.unfriend));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping "unfriend" asks first and names the friend', (
    tester,
  ) async {
    await pumpButton(tester);
    expect(find.text(t.friend.unfriend_confirm(name: 'Alice')), findsOneWidget);
    expect(users.unfriended, 0);
  });

  testWidgets('cancelling keeps the friend', (tester) async {
    await pumpButton(tester);
    await tester.tap(find.text(t.notifications.cancel));
    await tester.pumpAndSettle();
    expect(users.unfriended, 0);
    expect(find.text(t.friend.unfriend), findsOneWidget);
  });

  testWidgets('confirming ends the friendship once', (tester) async {
    await pumpButton(tester);
    // The dialog's button carries the same label as the one under it.
    await tester.tap(find.text(t.friend.unfriend).last);
    await tester.pumpAndSettle();
    expect(users.unfriended, 1);
    expect(find.text(t.friend.add_friend), findsOneWidget);
  });
}
