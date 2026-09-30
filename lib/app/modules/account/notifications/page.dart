import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/iwr_refresh/widget.dart';
import '../../../components/network_image.dart';
import '../../../data/models/account/notifications/notification.dart';
import '../../../data/services/user_service.dart';
import '../../../utils/display_util.dart';
import 'controller.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  /// The sentence the site shows for [notification].
  String _describe(NotificationModel notification) {
    final UserService userService = Get.find();
    final user = DisplayUtil.getDisplayUserName(
      notification.commentUser?.name ?? "",
    );
    String item;
    if (notification.profile != null) {
      item = notification.profile!.id == userService.user?.id
          ? t.notification_list.your_profile
          : t.notification_list.their_profile;
    } else {
      item =
          (notification.video ?? notification.image ?? notification.post)
              ?.title ??
          "";
    }

    switch (notification.type) {
      case "newComment":
        return t.notification_list.new_comment(user: user, item: item);
      case "newReply":
        return t.notification_list.new_reply(user: user, item: item);
      case "videoReady":
        return t.notification_list.video_ready(item: item);
      case "warning":
        return t.notification_list.warning;
      case "tagApproved":
        return t.notification_list.tag_approved(item: notification.tag ?? "");
      case "joinedCreatorProgram":
        return t.notification_list.joined_creator_program;
      case "reviewApproved":
        return t.notification_list.review_approved;
      case "reviewRejected":
        return t.notification_list.review_rejected;
      default:
        return t.notification_list.unknown;
    }
  }

  Widget _buildItem(BuildContext context, NotificationModel notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarUrl = notification.commentUser?.avatarUrl;

    return ListTile(
      onTap: () => controller.open(notification),
      tileColor: notification.read
          ? null
          : colorScheme.primaryContainer.withValues(alpha: 0.25),
      leading: avatarUrl != null
          ? ClipOval(
              child: NetworkImg(imageUrl: avatarUrl, width: 40, height: 40),
            )
          : CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.notifications,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
      title: Text(_describe(notification)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.commentBody?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notification.commentBody!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (notification.createdAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DisplayUtil.getDisplayTime(
                  DateTime.parse(notification.createdAt),
                ),
                style: TextStyle(color: colorScheme.outline, fontSize: 12.5),
              ),
            ),
        ],
      ),
      trailing: notification.read
          ? null
          : IconButton(
              tooltip: t.notification_list.mark_read,
              icon: const Icon(Icons.done),
              onPressed: () => controller.markRead(notification),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.notification_list.title),
        actions: [
          IconButton(
            tooltip: t.notification_list.mark_all_read,
            icon: const Icon(Icons.done_all),
            onPressed: controller.markAllRead,
          ),
        ],
      ),
      body: IwrRefresh<NotificationModel>(
        controller: controller,
        requireLogin: true,
        builder: (data, scrollController) => ListView.separated(
          controller: scrollController,
          itemCount: data.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) => _buildItem(context, data[index]),
        ),
      ),
    );
  }
}
