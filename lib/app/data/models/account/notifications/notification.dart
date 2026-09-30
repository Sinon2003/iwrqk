import '../../user.dart';

/// Something the target of a notification links to: a video, image, post or
/// profile. Only the fields the list shows are kept.
class NotificationTarget {
  final String id;
  final String? title;
  final String? username;

  const NotificationTarget({required this.id, this.title, this.username});

  static NotificationTarget? fromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['id'] == null) return null;
    return NotificationTarget(
      id: json['id'],
      title: json['title'],
      username: json['username'],
    );
  }
}

class NotificationModel {
  final String id;

  /// newComment, newReply, videoReady, warning, tagApproved,
  /// joinedCreatorProgram, reviewApproved or reviewRejected, as on the site.
  final String type;
  bool read;
  final String createdAt;
  final UserModel? commentUser;
  final String? commentBody;
  final NotificationTarget? video;
  final NotificationTarget? image;
  final NotificationTarget? profile;
  final NotificationTarget? post;
  final String? tag;

  NotificationModel({
    required this.id,
    required this.type,
    required this.read,
    required this.createdAt,
    this.commentUser,
    this.commentBody,
    this.video,
    this.image,
    this.profile,
    this.post,
    this.tag,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final comment = json['comment'];
    return NotificationModel(
      id: json['id'],
      type: json['type'] ?? '',
      read: json['read'] ?? true,
      createdAt: json['createdAt'] ?? '',
      commentUser: comment is Map<String, dynamic> && comment['user'] != null
          ? UserModel.fromJson(comment['user'])
          : null,
      commentBody: comment is Map<String, dynamic> ? comment['body'] : null,
      video: NotificationTarget.fromJson(json['video']),
      image: NotificationTarget.fromJson(json['image']),
      profile: NotificationTarget.fromJson(json['profile']),
      post: NotificationTarget.fromJson(json['post']),
      tag: json['tag'] is Map ? json['tag']['id'] : null,
    );
  }
}
