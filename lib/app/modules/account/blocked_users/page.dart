import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/iwr_refresh/widget.dart';
import '../../../components/user_preview/user_preview.dart';
import '../../../data/models/user.dart';
import 'controller.dart';

class BlockedUsersPage extends GetView<BlockedUsersController> {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.account_settings.blocked_users)),
      body: IwrRefresh<UserModel>(
        controller: controller,
        requireLogin: true,
        builder: (data, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final user = data[index];
            return UserPreview(
              user: user,
              customButton: TextButton(
                onPressed: () => controller.unblock(user),
                child: Text(t.profile.unblock),
              ),
            );
          },
        ),
      ),
    );
  }
}
