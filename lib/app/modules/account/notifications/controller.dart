import 'package:get/get.dart';

import '../../../components/iwr_refresh/controller.dart';
import '../../../data/enums/result.dart';
import '../../../data/enums/types.dart';
import '../../../data/models/account/notifications/notification.dart';
import '../../../data/services/user_service.dart';

class NotificationsController extends IwrRefreshController<NotificationModel> {
  final UserService _userService = Get.find();

  bool get hasUnread => data.any((notification) => !notification.read);

  @override
  Future<GroupResult<NotificationModel>> getNewData(int currentPage) async {
    final result = await _userService.getNotifications(currentPage);
    if (!result.success) throw Exception(result.message);
    return result.data!;
  }

  Future<void> markRead(NotificationModel notification) async {
    if (notification.read) return;
    if (await _userService.markNotificationRead(notification.id)) {
      notification.read = true;
      change(null, status: RxStatus.success());
    }
  }

  Future<void> markAllRead() async {
    if (await _userService.markNotificationRead("all")) {
      for (final notification in data) {
        notification.read = true;
      }
      change(null, status: RxStatus.success());
    }
  }

  /// Opens what the notification is about, the way the site links it.
  void open(NotificationModel notification) {
    markRead(notification);
    if (notification.video != null) {
      Get.toNamed(
        "/mediaDetail?id=${notification.video!.id}",
        arguments: {"mediaType": MediaType.video},
      );
    } else if (notification.image != null) {
      Get.toNamed(
        "/mediaDetail?id=${notification.image!.id}",
        arguments: {"mediaType": MediaType.image},
      );
    } else if (notification.profile?.username != null) {
      Get.toNamed("/profile?userName=${notification.profile!.username}");
    }
  }
}
