import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../../components/iwr_markdown.dart';
import '../../../../components/network_image.dart';
import '../../../../components/translated_content.dart';
import '../../../../components/translation_mixin.dart';
import '../../../../data/models/forum/post.dart';
import '../../../../data/services/user_service.dart';
import '../../../../utils/display_util.dart';
import 'edit_post_bottom_sheet/widget.dart';

class Post extends StatefulWidget {
  final PostModel post;
  final int index;
  final bool showDivider;
  final String starterUserName;
  final bool isMyComment;

  /// The thread the post belongs to; its first post stands for the thread.
  final String? threadId;
  final void Function(Map)? onUpdated;

  const Post({
    super.key,
    required this.post,
    required this.index,
    this.showDivider = true,
    required this.starterUserName,
    this.isMyComment = false,
    this.threadId,
    this.onUpdated,
  });

  @override
  State<StatefulWidget> createState() => _PostState();
}

class _PostState extends State<Post>
    with AutomaticKeepAliveClientMixin, TranslationMixin {
  bool get _isThreadStart => widget.index == 0 && widget.threadId != null;

  Future<bool> _confirm(String message) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        content: Text(message),
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
    return confirmed == true;
  }

  /// Deletes the post; for the first post the whole thread goes too, as on
  /// the site, and the thread page closes.
  Future<void> _delete() async {
    final confirmed = await _confirm(
      _isThreadStart
          ? t.thread.delete_thread_confirm
          : t.message.are_you_sure_to_do_that,
    );
    if (!confirmed) return;
    final UserService userService = Get.find();
    if (!await userService.deletePost(id: widget.post.id)) return;
    if (_isThreadStart) {
      if (await userService.deleteThread(widget.threadId!)) {
        SmartDialog.showToast(t.thread.thread_deleted);
        Get.back();
      }
      return;
    }
    widget.onUpdated?.call({"state": "delete"});
  }

  Future<void> _editThreadTitle() async {
    final textController = TextEditingController();
    final title = await Get.dialog<String>(
      AlertDialog(
        title: Text(t.thread.edit_title),
        content: TextField(controller: textController, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(t.notifications.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: textController.text.trim()),
            child: Text(t.notifications.confirm),
          ),
        ],
      ),
    );
    textController.dispose();
    if (title == null || title.isEmpty) return;
    final UserService userService = Get.find();
    if (await userService.updateThreadTitle(widget.threadId!, title)) {
      SmartDialog.showToast(t.thread.title_updated);
      widget.onUpdated?.call({"state": "title", "title": title});
    }
  }

  Widget _buildStarterBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "OP",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUserWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.post.user.isDeleted) return;
        Get.toNamed("/profile?userName=${widget.post.user.username}");
      },
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: NetworkImg(
                    imageUrl: widget.post.user.avatarUrl,
                    width: 40,
                    height: 40,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      DisplayUtil.getDisplayUserName(widget.post.user.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                if (!widget.post.user.isDeleted &&
                    widget.starterUserName == widget.post.user.username)
                  _buildStarterBadge(context),
              ],
            ),
          ),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            position: PopupMenuPosition.under,
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.outline,
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: "translate",
                  enabled: !translating,
                  onTap: () => toggleTranslation(widget.post.body),
                  child: Text(translationActionLabel),
                ),
                if (canChooseTranslationEngine)
                  PopupMenuItem<String>(
                    value: "translate_with",
                    enabled: !translating,
                    onTap: () => chooseEngineAndTranslate(widget.post.body),
                    child: Text(t.translation.choose_engine),
                  ),
                if (widget.isMyComment) ...[
                  PopupMenuItem<String>(
                    value: "edit",
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: EditPostBottomSheet(
                            isEdit: true,
                            editId: widget.post.id,
                            editInitialContent: widget.post.body,
                            onChanged: (String content) => widget.onUpdated
                                ?.call({"state": "edit", "content": content}),
                          ),
                        ),
                      );
                    },
                    child: Text(t.comment.edit_comment),
                  ),
                  if (_isThreadStart)
                    PopupMenuItem<String>(
                      value: "edit_title",
                      onTap: _editThreadTitle,
                      child: Text(t.thread.edit_title),
                    ),
                  PopupMenuItem<String>(
                    value: "delete",
                    onTap: _delete,
                    child: Text(t.comment.delete_comment),
                  ),
                ],
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    String text = DisplayUtil.getDisplayTime(
      DateTime.parse(widget.post.createAt),
    );
    if (widget.post.createAt != widget.post.updateAt) {
      text +=
          "\n${t.media.updated_at(time: DisplayUtil.getDisplayTime(DateTime.parse(widget.post.updateAt)))}";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "#${widget.index} ",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTranslationInPlace)
            TranslatedContent(
              translatedContent: translatedContent!,
              engine: translationEngine!,
              onCollapse: hideTranslation,
              inPlace: true,
            )
          else
            IwrMarkdown(selectable: true, data: widget.post.body),
          if (showTranslationBelow)
            TranslatedContent(
              translatedContent: translatedContent!,
              engine: translationEngine!,
              onCollapse: hideTranslation,
            ),
          _buildBottomWidget(context),
          if (widget.showDivider) const SizedBox(height: 12),
          if (widget.showDivider) const Divider(height: 0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildUserWidget(context), _buildContent(context)],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
