import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../enums/result.dart';
import '../enums/types.dart';
import '../models/account/conversations/conversation.dart';
import '../models/account/notifications/counts.dart';
import '../models/account/notifications/notification.dart';
import '../models/account/notifications/settings.dart';
import '../models/playlist/light_playlist.dart';
import '../models/profile.dart';
import '../models/tag.dart';
import '../models/user.dart';
import '../providers/api_provider.dart';
import '../../utils/display_util.dart';
import 'account_service.dart';

class UserService extends GetxService {
  final AccountService accountService = Get.find();

  /// Reactive, so avatars and names shown with Obx follow profile edits.
  final Rxn<UserModel> _user = Rxn<UserModel>();
  UserModel? get user => _user.value;
  set user(UserModel? value) => _user.value = value;

  ProfileModel? profile;
  bool hideSensitive = false;

  NotificationsSettings? notificationsSettings;

  List<TagModel> blockedTags = <TagModel>[];

  /// Unread messages, notifications and friend requests; reactive so the
  /// drawer badges follow it.
  final Rxn<NotificationsCountsModel> _notificationsCounts = Rxn();
  NotificationsCountsModel? get notificationsCounts =>
      _notificationsCounts.value;
  set notificationsCounts(NotificationsCountsModel? value) =>
      _notificationsCounts.value = value;

  Future<bool> init() async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return Future.value(flag);
    }
    return getUser().then((value) {
      if (!value) {
        return Future.value(false);
      }
      return Future.value(true);
    });
  }

  Future<bool> getUser() {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return Future.value(flag);
    }
    return ApiProvider.getAppUser().then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        user = value.data!.user;
        profile = value.data!.profile;
        hideSensitive = value.data!.hideSensitive;
        blockedTags = value.data!.tagBlacklist;
        notificationsSettings = value.data!.notifications;
        flag = true;
      }
      return flag;
    });
  }

  Future<bool> getNotificationsCounts() {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return Future.value(flag);
    }
    return ApiProvider.getNotificationsCounts().then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        notificationsCounts = value.data;
        flag = true;
      }
      return flag;
    });
  }

  Future<ApiResult<GroupResult<ConversationModel>>> getConversations(
    int pageNum,
  ) {
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      return Future.value(
        ApiResult(data: null, message: t.account.require_login, success: false),
      );
    }
    return ApiProvider.getConversations(user!.id, pageNum);
  }

  Future<bool> followUser(String userId) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.followUser(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> unfollowUser(String userId) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.unfollowUser(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  /// The site lets premium members and staff block users.
  bool get canBlockUsers {
    final user = this.user;
    return user != null &&
        (user.premium ||
            const {
              "janitor",
              "moderator",
              "officer",
              "admin",
            }.contains(user.role));
  }

  Future<bool> setUserBlocked(String userId, bool blocked) async {
    final result = await ApiProvider.setUserBlocked(
      userId: userId,
      blocked: blocked,
    );
    if (!result.success) SmartDialog.showToast(result.message!);
    return result.success;
  }

  /// Null when the status could not be loaded.
  Future<bool?> isUserBlocked(String userId) async {
    final result = await ApiProvider.getUserBlocked(userId: userId);
    return result.success ? result.data : null;
  }

  Future<ApiResult<GroupResult<UserModel>>> getBlockedUsers(int pageNum) {
    return ApiProvider.getBlockedUsers(pageNum: pageNum);
  }

  Future<ApiResult<FriendRelationType>> getFriendRelation(String userId) async {
    bool flag = false;
    FriendRelationType? relation;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return ApiResult(data: null, success: flag);
    }
    await ApiProvider.getFriendRelation(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
        relation = value.data;
      }
    });
    return ApiResult(data: relation, success: flag);
  }

  Future<bool> sendFriendRequest(String userId) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.sendFriendRequest(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> acceptFriendRequest(String userId) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.acceptFriendRequest(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> rejectFriendRequest(String userId) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.rejectFriendRequest(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> unfriend(String userId) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.unfriend(userId: userId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> favoriteMedia(String id) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.favoriteMedia(id: id).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> unfavoriteMedia(String id) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.unfavoriteMedia(id: id).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<ApiResult<List<LightPlaylistModel>>> getLightPlaylists(
    String videoId,
  ) async {
    bool flag = false;
    List<LightPlaylistModel>? result;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return ApiResult(data: null, success: flag);
    }
    await ApiProvider.getLightPlaylists(videoId: videoId).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
        result = value.data;
      }
    });
    return ApiResult(data: result, success: flag);
  }

  Future<bool> createPlaylist(String title) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.createPlaylist(title: title).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> editPlaylistTitle(String playlistId, String title) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.editPlaylistTitle(
      playlistId: playlistId,
      title: title,
    ).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> addToPlaylist(String videoId, List<String> playlistIds) async {
    bool flag = true;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    for (String playlistId in playlistIds) {
      await ApiProvider.addToPlaylist(
        videoId: videoId,
        playlistId: playlistId,
      ).then((value) {
        if (!value.success) {
          SmartDialog.showToast(value.message!);
          flag = false;
        } else {
          flag &= true;
        }
      });
    }
    return flag;
  }

  Future<bool> removeFromPlaylist(
    String videoId,
    List<String> playlistIds,
  ) async {
    bool flag = true;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    for (String playlistId in playlistIds) {
      await ApiProvider.removeFromPlaylist(
        videoId: videoId,
        playlistId: playlistId,
      ).then((value) {
        if (!value.success) {
          SmartDialog.showToast(value.message!);
          flag = false;
        } else {
          flag &= true;
        }
      });
    }
    return flag;
  }

  Future<bool> sendComment({
    required CommentsSourceType sourceType,
    required String sourceId,
    required String content,
    String? parentId,
  }) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.sendComment(
      sourceType: sourceType,
      sourceId: sourceId,
      content: content,
      parentId: parentId,
    ).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> editComment({
    required String id,
    required String content,
  }) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.editComment(id: id, content: content).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> deleteComment({required String id}) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }
    await ApiProvider.deleteComment(id: id).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }

    await ApiProvider.sendMessage(
      conversationId: conversationId,
      content: content,
    ).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> createThread({
    required String channelName,
    required String title,
    required String content,
  }) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }

    await ApiProvider.createThread(
      channelName: channelName,
      title: title,
      content: content,
    ).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> sendPost({
    required String threadId,
    required String content,
  }) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }

    await ApiProvider.sendPost(threadId: threadId, content: content).then((
      value,
    ) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<bool> editPost({required String id, required String content}) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }

    await ApiProvider.editPost(id: id, content: content).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });

    return flag;
  }

  Future<bool> deletePost({required String id}) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }

    await ApiProvider.deletePost(id: id).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });

    return flag;
  }

  Future<bool> deleteThread(String threadId) async {
    final result = await ApiProvider.deleteThread(id: threadId);
    if (!result.success) {
      SmartDialog.showToast(DisplayUtil.getErrorMessage(result.message!));
    }
    return result.success;
  }

  Future<bool> updateThreadTitle(String threadId, String title) async {
    final result = await ApiProvider.updateThreadTitle(
      id: threadId,
      title: title,
    );
    if (!result.success) {
      SmartDialog.showToast(DisplayUtil.getErrorMessage(result.message!));
    }
    return result.success;
  }

  Future<bool> saveBlockedTags(List<String> blockedTags) async {
    bool flag = false;
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      flag = false;
      return flag;
    }

    await ApiProvider.updateAppUser(
      userId: user!.id,
      tagBlacklist: blockedTags,
    ).then((value) {
      if (!value.success) {
        SmartDialog.showToast(value.message!);
        flag = false;
      } else {
        flag = true;
      }
    });
    return flag;
  }

  Future<ApiResult<GroupResult<NotificationModel>>> getNotifications(
    int pageNum,
  ) {
    if (!accountService.isLogin || user == null) {
      return Future.value(
        ApiResult(data: null, message: t.account.require_login, success: false),
      );
    }
    return ApiProvider.getNotifications(userId: user!.id, pageNum: pageNum);
  }

  /// Marks a notification, or all of them with "all", as read and refreshes
  /// the unread counts.
  Future<bool> markNotificationRead(String id) async {
    final result = await ApiProvider.markNotificationRead(id);
    if (!result.success) {
      SmartDialog.showToast(DisplayUtil.getErrorMessage(result.message!));
      return false;
    }
    getNotificationsCounts();
    return true;
  }

  /// Starts a conversation with [userId] and returns its id.
  Future<String?> createConversation({
    required String userId,
    required String title,
    required String body,
  }) async {
    if (!accountService.isLogin) {
      SmartDialog.showToast(t.account.require_login);
      return null;
    }
    final result = await ApiProvider.createConversation(
      userId: userId,
      title: title,
      body: body,
    );
    if (!result.success) {
      SmartDialog.showToast(
        DisplayUtil.getErrorMessage(result.message ?? t.notifications.error),
      );
      return null;
    }
    return result.data;
  }

  Future<bool> deleteMessage(String messageId) async {
    final result = await ApiProvider.deleteMessage(messageId);
    if (!result.success) {
      SmartDialog.showToast(DisplayUtil.getErrorMessage(result.message!));
    }
    return result.success;
  }

  /// Applies an account or profile change, then reloads the user so every
  /// page shows the new values.
  Future<bool> _updateAccount(Future<ApiResult<void>> Function() update) async {
    if (!accountService.isLogin || user == null) {
      SmartDialog.showToast(t.account.require_login);
      return false;
    }
    final result = await update();
    if (!result.success) {
      SmartDialog.showToast(DisplayUtil.getErrorMessage(result.message!));
      return false;
    }
    await getUser();
    return true;
  }

  Future<bool> updateName(String name) {
    return _updateAccount(
      () => ApiProvider.updateAppUser(userId: user!.id, name: name),
    );
  }

  Future<bool> updateDescription(String body) {
    return _updateAccount(
      () => ApiProvider.updateProfile(userName: user!.username, body: body),
    );
  }

  Future<bool> updateHideSensitive(bool value) {
    return _updateAccount(
      () => ApiProvider.updateAppUser(userId: user!.id, hideSensitive: value),
    );
  }

  Future<bool> updateNotificationsSettings(NotificationsSettings settings) {
    return _updateAccount(
      () => ApiProvider.updateAppUser(
        userId: user!.id,
        notifications: settings.toJson(),
      ),
    );
  }

  /// Uploads the image at [filePath] and makes it the avatar.
  Future<bool> updateAvatar(String filePath) {
    return _updateAccount(() async {
      final upload = await ApiProvider.uploadImage(filePath);
      if (!upload.success) return upload;
      return ApiProvider.updateAppUser(userId: user!.id, avatar: upload.data);
    });
  }

  /// Uploads the image at [filePath] and makes it the profile header.
  Future<bool> updateHeader(String filePath) {
    return _updateAccount(() async {
      final upload = await ApiProvider.uploadImage(filePath);
      if (!upload.success) return upload;
      return ApiProvider.updateProfile(
        userName: user!.username,
        header: upload.data,
      );
    });
  }

  Future<bool> removeHeader() async {
    final removed = await _updateAccount(
      () => ApiProvider.updateProfile(
        userName: user!.username,
        removeHeader: true,
      ),
    );
    // The site deletes the header file in the background, so the reloaded
    // profile can still have it for a while.
    if (removed) profile?.header = null;
    return removed;
  }
}
