import 'package:get/get.dart';

import '../../../components/iwr_refresh/controller.dart';
import '../../../data/enums/result.dart';
import '../../../data/models/user.dart';
import '../../../data/services/user_service.dart';

class BlockedUsersController extends IwrRefreshController<UserModel> {
  final UserService _userService = Get.find();

  @override
  Future<GroupResult<UserModel>> getNewData(int currentPage) async {
    final result = await _userService.getBlockedUsers(currentPage);
    if (!result.success) throw Exception(result.message);
    return result.data!;
  }

  Future<void> unblock(UserModel user) async {
    if (!await _userService.setUserBlocked(user.id, false)) return;
    data.remove(user);
    change(
      data.isEmpty ? {"state": "empty"} : null,
      status: RxStatus.success(),
    );
  }
}
