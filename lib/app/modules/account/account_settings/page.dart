import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../components/load_fail.dart';
import '../../../components/network_image.dart';
import '../../../routes/pages.dart';
import '../../settings/page.dart';
import 'controller.dart';

class AccountSettingsPage extends GetView<AccountSettingsController> {
  const AccountSettingsPage({super.key});

  static const String _accountPageUrl = "https://www.iwara.tv/account";

  /// The profile header with the avatar over its corner; tapping either one
  /// replaces it.
  Widget _buildProfilePreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AspectRatio(
        aspectRatio: 3,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkImg(
                      imageUrl: controller.headerUrl,
                      fit: BoxFit.cover,
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: controller.changeHeader),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: controller.changeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: NetworkImg(
                      imageUrl: controller.avatarUrl,
                      width: 64,
                      height: 64,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editText(
    BuildContext context, {
    required String title,
    required String initialValue,
    required void Function(String) onSave,
    bool multiline = false,
  }) async {
    final textController = TextEditingController(text: initialValue);
    final value = await Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: Get.width * 0.8,
          child: TextField(
            controller: textController,
            autofocus: true,
            minLines: multiline ? 5 : 1,
            maxLines: multiline ? 12 : 1,
            keyboardType: multiline
                ? TextInputType.multiline
                : TextInputType.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              t.notifications.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: textController.text),
            child: Text(t.notifications.confirm),
          ),
        ],
      ),
    );
    textController.dispose();
    if (value != null) onSave(value);
  }

  List<Widget> _buildProfileSection(BuildContext context) {
    return [
      SettingTitle(title: t.account_settings.profile),
      _buildProfilePreview(context),
      ListTile(
        leading: const Icon(Icons.account_circle),
        title: Text(t.account_settings.avatar),
        subtitle: Text(t.account_settings.tap_to_change),
        onTap: controller.changeAvatar,
      ),
      ListTile(
        leading: const Icon(Icons.wallpaper),
        title: Text(t.account_settings.header),
        subtitle: Text(t.account_settings.tap_to_change),
        onTap: controller.changeHeader,
      ),
      ListTile(
        leading: const Icon(Icons.badge),
        title: Text(t.profile.nickname),
        subtitle: Text(controller.name),
        onTap: () => _editText(
          context,
          title: t.profile.nickname,
          initialValue: controller.name,
          onSave: controller.changeName,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.notes),
        title: Text(t.profile.description),
        subtitle: Text(
          controller.description.isEmpty
              ? t.account_settings.not_set
              : controller.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => _editText(
          context,
          title: t.profile.description,
          initialValue: controller.description,
          onSave: controller.changeDescription,
          multiline: true,
        ),
      ),
    ];
  }

  List<Widget> _buildContentSection() {
    return [
      SettingTitle(title: t.account_settings.content),
      SwitchListTile(
        secondary: const Icon(Icons.visibility_off),
        title: Text(t.account_settings.hide_sensitive),
        subtitle: Text(t.account_settings.hide_sensitive_desc),
        value: controller.hideSensitive,
        onChanged: controller.setHideSensitive,
      ),
      ListTile(
        leading: const Icon(Icons.block),
        title: Text(t.user.blocked_tags),
        onTap: () => Get.toNamed(AppRoutes.blockedTags),
      ),
      if (controller.canBlockUsers)
        ListTile(
          leading: const Icon(Icons.person_off),
          title: Text(t.account_settings.blocked_users),
          onTap: () => Get.toNamed(AppRoutes.blockedUsers),
        ),
    ];
  }

  List<Widget> _buildNotificationSection() {
    final settings = controller.notifications;
    if (settings == null) return [];
    return [
      SettingTitle(title: t.account_settings.notifications),
      SwitchListTile(
        title: Text(t.account_settings.notify_comment),
        value: settings.comment,
        onChanged: (value) => controller.setNotification(comment: value),
      ),
      SwitchListTile(
        title: Text(t.account_settings.notify_reply),
        value: settings.reply,
        onChanged: (value) => controller.setNotification(reply: value),
      ),
      SwitchListTile(
        title: Text(t.account_settings.notify_mention),
        value: settings.mention,
        onChanged: (value) => controller.setNotification(mention: value),
      ),
    ];
  }

  List<Widget> _buildSecuritySection() {
    return [
      SettingTitle(title: t.account_settings.security),
      ListTile(
        leading: const Icon(Icons.open_in_new),
        title: Text(t.account_settings.manage_on_web),
        subtitle: Text(t.account_settings.manage_on_web_desc),
        onTap: () => launchUrlString(
          _accountPageUrl,
          mode: LaunchMode.externalApplication,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.account_settings.title)),
      body: controller.obx(
        (state) => Obx(
          () => ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            children: [
              ..._buildProfileSection(context),
              ..._buildContentSection(),
              ..._buildNotificationSection(),
              ..._buildSecuritySection(),
            ],
          ),
        ),
        onLoading: const Center(child: CircularProgressIndicator()),
        onError: (error) => Center(
          child: LoadFail(
            errorMessage: error ?? t.error.retry,
            onRefresh: controller.loadData,
          ),
        ),
      ),
    );
  }
}
