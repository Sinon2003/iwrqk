import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/iwr_refresh/widget.dart';
import '../../../components/network_image.dart';
import '../../../const/iwara.dart';
import '../../../data/models/account/conversations/conversation.dart';
import '../../../utils/display_util.dart';
import 'controller.dart';

class ConversationsPage extends GetView<ConversationsController> {
  const ConversationsPage({super.key});

  Widget _buildItem(BuildContext context, ConversationModel conversation) {
    final myId = controller.userService.user?.id;
    final others = conversation.participants.where((u) => u.id != myId);
    final other = others.isEmpty ? null : others.first;
    final last = conversation.lastMessage;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () async {
        await Get.toNamed(
          "/conversationDetail?id=${conversation.id}",
          arguments: {"title": conversation.title},
        );
        controller.refreshData();
        controller.userService.getNotificationsCounts();
      },
      leading: ClipOval(
        child: NetworkImg(
          imageUrl: other?.avatarUrl ?? IwaraConst.defaultAvatarUrl,
          width: 44,
          height: 44,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.title.isEmpty
                  ? DisplayUtil.getDisplayUserName(other?.name ?? "")
                  : conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: conversation.unread ? FontWeight.bold : null,
              ),
            ),
          ),
          Text(
            DisplayUtil.getDisplayTime(DateTime.parse(conversation.updatedAt)),
            style: TextStyle(fontSize: 12, color: colorScheme.outline),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              "${DisplayUtil.getDisplayUserName(last.user.name)}: ${last.body}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.unread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.messages.title)),
      body: IwrRefresh<ConversationModel>(
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
