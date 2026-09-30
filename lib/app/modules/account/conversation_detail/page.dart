import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/load_fail.dart';
import '../../../components/network_image.dart';
import '../../../data/models/account/conversations/message.dart';
import '../../../utils/display_util.dart';
import 'controller.dart';

class ConversationDetailPage extends GetView<ConversationDetailController> {
  const ConversationDetailPage({super.key});

  Future<void> _confirmDelete(MessageModel message) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(t.messages.delete_message),
        content: Text(t.messages.delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(t.notifications.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(t.notifications.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.delete(message);
  }

  Widget _buildMessage(BuildContext context, MessageModel message) {
    final colorScheme = Theme.of(context).colorScheme;
    final mine = message.user.id == controller.userService.user?.id;

    final bubble = GestureDetector(
      onLongPress: mine ? () => _confirmDelete(message) : null,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(message.body),
            const SizedBox(height: 4),
            Text(
              DisplayUtil.getDisplayTime(DateTime.parse(message.createdAt)),
              style: TextStyle(fontSize: 11, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            ClipOval(
              child: NetworkImg(
                imageUrl: message.user.avatarUrl,
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 8),
          ],
          bubble,
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller.inputController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: t.messages.message_hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            Obx(
              () => IconButton(
                tooltip: t.messages.send,
                onPressed: controller.sending ? null : controller.send,
                icon: controller.sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.title.isEmpty ? t.messages.title : controller.title,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: controller.obx(
              (state) => Obx(() {
                final messages = controller.messages;
                // Newest at the bottom: the reversed list keeps it in view.
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length + (controller.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return Center(
                        child: controller.loadingOlder
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(),
                              )
                            : TextButton(
                                onPressed: controller.loadOlder,
                                child: Text(t.messages.load_older),
                              ),
                      );
                    }
                    return _buildMessage(
                      context,
                      messages[messages.length - 1 - index],
                    );
                  },
                );
              }),
              onLoading: const Center(child: CircularProgressIndicator()),
              onError: (error) => Center(
                child: LoadFail(
                  errorMessage: error ?? t.error.retry,
                  onRefresh: controller.loadLatest,
                ),
              ),
            ),
          ),
          _buildInput(context),
        ],
      ),
    );
  }
}
