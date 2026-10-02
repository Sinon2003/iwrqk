import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../data/enums/types.dart';
import '../../../data/models/user.dart';
import '../../../data/services/user_service.dart';
import '../../../utils/display_util.dart';
import '../../dialogs/confirm_destructive.dart';

class FriendButtonController extends GetxController {
  late String _userId;
  late String _userName;
  final UserService userService = Get.find();
  final Rx<FriendRelationType> _relation = FriendRelationType.unknown.obs;

  FriendRelationType get relation => _relation.value;

  final RxBool _isProcessing = false.obs;

  bool get isProcessing => _isProcessing.value;

  @override
  void onInit() {
    _isProcessing.value = true;
    super.onInit();
  }

  void init(UserModel user) {
    _userId = user.id;
    _userName = DisplayUtil.getDisplayUserName(user.name);
    getFriendRelation().then((value) => _isProcessing.value = false);
  }

  Future<bool> getFriendRelation() async {
    bool success = false;
    if (!userService.accountService.isLogin) {
      _isProcessing.value = false;
      return success;
    }

    await userService.getFriendRelation(_userId).then((value) {
      if (value.success) {
        _relation.value = value.data!;
        success = true;
      }
    });

    return success;
  }

  Future<void> sendFriendRequest(BuildContext context) async {
    bool success = true;
    _isProcessing.value = true;

    if (_relation.value == FriendRelationType.unknown) {
      await getFriendRelation().then((value) {
        success = value;
      });
    }

    if (!success) {
      _isProcessing.value = false;
      return;
    }

    await userService.sendFriendRequest(_userId).then((value) {
      if (value) {
        _relation.value = FriendRelationType.pending;
      }
    });

    _isProcessing.value = false;
  }

  /// Ending a friendship takes a new request to undo, so it asks first.
  Future<void> unfriend(BuildContext context) async {
    if (!await confirmDestructive(
      t.friend.unfriend_confirm(name: _userName),
      action: t.friend.unfriend,
    )) {
      return;
    }
    _isProcessing.value = true;

    await userService.unfriend(_userId).then((value) {
      if (value) {
        _relation.value = FriendRelationType.none;
      }
    });

    _isProcessing.value = false;
  }
}
