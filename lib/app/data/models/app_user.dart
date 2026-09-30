import 'account/notifications/settings.dart';
import 'profile.dart';
import 'tag.dart';
import 'user.dart';

class AppUserModel {
  UserModel user;
  List<TagModel> tagBlacklist;
  ProfileModel profile;
  NotificationsSettings notifications;

  /// Hides videos and images with a tag the site considers sensitive. Only
  /// the signed-in user's own record carries it.
  bool hideSensitive;

  AppUserModel({
    required this.user,
    required this.tagBlacklist,
    required this.profile,
    required this.notifications,
    this.hideSensitive = false,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      user: UserModel.fromJson(json['user']),
      tagBlacklist: List<TagModel>.from(
        json['tagBlacklist'].map((x) => TagModel.fromJson(x)),
      ),
      profile: ProfileModel.fromJson(json['profile']),
      notifications: NotificationsSettings.fromJson(json['notifications']),
      hideSensitive: json['user']['hideSensitive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "user": {...user.toJson(), "hideSensitive": hideSensitive},
    "tagBlacklist": List<dynamic>.from(tagBlacklist.map((x) => x.toJson())),
    "profile": profile.toJson(),
    "notifications": notifications.toJson(),
  };
}
