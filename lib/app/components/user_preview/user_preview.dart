import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user.dart';
import '../../utils/display_util.dart';
import '../buttons/follow_button/widget.dart';
import '../buttons/friend_button/widget.dart';
import '../network_image.dart';

class UserPreview extends StatelessWidget {
  final UserModel user;
  final bool showFollowButton;
  final bool showFriendButton;
  final Widget? customButton;

  const UserPreview({
    super.key,
    required this.user,
    this.showFollowButton = false,
    this.showFriendButton = false,
    this.customButton,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: user.isDeleted
          ? null
          : () {
              Get.toNamed("/profile?userName=${user.username}");
            },
      child: ListTile(
        leading: ClipOval(
          child: NetworkImg(imageUrl: user.avatarUrl, width: 50, height: 50),
        ),
        title: Text(
          DisplayUtil.getDisplayUserName(user.name),
          style: TextStyle(
            fontSize: 17.5,
            color: user.isDeleted
                ? Theme.of(context).colorScheme.outline
                : null,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        // Kept empty for deleted accounts, so every row has the same height.
        subtitle: Text(
          user.isDeleted ? '' : '@${user.username}',
          style: TextStyle(
            fontSize: 12.5,
            color: Theme.of(context).colorScheme.outline,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFollowButton && !user.isDeleted) FollowButton(user: user),
            if (showFriendButton && !user.isDeleted) FriendButton(user: user),
            ?customButton,
          ],
        ),
      ),
    );
  }
}
