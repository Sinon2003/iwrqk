import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/data/models/user.dart';
import 'package:iwrqk/app/utils/display_util.dart';
import 'package:iwrqk/i18n/strings.g.dart';

/// A user as returned by `/search?type=users` and `/user/{id}/following`.
Map<String, dynamic> userJson({
  String? name,
  String? username,
  String? status,
}) {
  return {
    'id': '887992e7-8136-4357-b8c9-fc058ec92cf9',
    'name': name,
    'username': username,
    'status': status ?? 'active',
    'role': 'user',
    'followedBy': false,
    'following': false,
    'friend': false,
    'premium': false,
    'creatorProgram': false,
    'locale': null,
    'seenAt': '2026-06-18T09:48:11.000Z',
    'avatar': null,
    'createdAt': '2026-06-15T06:20:28.000Z',
    'updatedAt': '2026-06-18T09:51:30.000Z',
  };
}

void main() {
  group('UserModel.fromJson', () {
    test('parses an active account', () {
      final user = UserModel.fromJson(
        userJson(name: 'Tentacle', username: 'tentacle'),
      );

      expect(user.name, 'Tentacle');
      expect(user.username, 'tentacle');
      expect(user.isDeleted, isFalse);
    });

    test('parses a disabled account with a null name and username', () {
      final user = UserModel.fromJson(userJson(status: 'disabled'));

      expect(user.name, '');
      expect(user.username, '');
      expect(user.isDeleted, isTrue);
    });

    test('a deleted account stays deleted after a toJson round trip', () {
      // Offline history and download records store the uploader this way.
      final user = UserModel.fromJson(
        UserModel.fromJson(userJson(status: 'disabled')).toJson(),
      );

      expect(user.isDeleted, isTrue);
    });
  });

  group('DisplayUtil.getDisplayUserName', () {
    test('shows the name of an active account', () {
      expect(DisplayUtil.getDisplayUserName('Tentacle'), 'Tentacle');
    });

    test('shows a placeholder for a deleted account', () {
      expect(DisplayUtil.getDisplayUserName(''), t.profile.deleted_user);
      expect(t.profile.deleted_user, isNotEmpty);
    });
  });
}
