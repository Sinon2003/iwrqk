import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../data/enums/result.dart';
import '../../data/enums/types.dart';
import '../../data/models/media/media.dart';
import '../../data/models/profile.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/config_service.dart';
import '../../data/services/user_service.dart';

class ProfileController extends GetxController
    with GetTickerProviderStateMixin, StateMixin {
  final UserService userService = Get.find();
  final ConfigService configService = Get.find();

  late String userName;
  late ProfileModel profile;
  late int followingNum;
  late int followersNum;

  late GroupResult<MediaModel> popularVideos;
  late GroupResult<MediaModel> popularImages;

  ProfileModel? profileModel;

  String? fetchWorksPreviewMessage;
  final RxBool _isFetchingWorksPreview = false.obs;
  bool get isFetchingWorksPreview => _isFetchingWorksPreview.value;

  /// Whether you have blocked this user; only loaded when you can block.
  bool blocked = false;

  @override
  void onInit() {
    super.onInit();

    userName = Get.parameters['userName']!;

    loadData();
  }

  Future<void> loadData() async {
    change(null, status: RxStatus.loading());

    String? message;
    bool success = true;

    await ApiProvider.getProfile(userName).then((value) {
      success = value.success;
      if (!success) {
        message = value.message;
      } else {
        profileModel = value.data;
      }
    });

    if (!success) {
      change(null, status: RxStatus.error(message!));
      return;
    }

    await ApiProvider.getUsersCount(
      path: "/user/${profileModel!.user!.id}/following",
    ).then((value) {
      success = value.success;
      if (!success) {
        message = value.message;
      } else {
        followingNum = value.data!;
      }
    });

    if (!success) {
      change(null, status: RxStatus.error(message!));
      return;
    }

    await ApiProvider.getUsersCount(
      path: "/user/${profileModel!.user!.id}/followers",
    ).then((value) {
      success = value.success;
      if (!success) {
        message = value.message;
      } else {
        followersNum = value.data!;
      }
    });

    if (!success) {
      change(null, status: RxStatus.error(message!));
      return;
    } else {
      profile = profileModel!;
      change(null, status: RxStatus.success());

      fetchWorksPreview();
      _fetchBlocked();
    }
  }

  Future<void> _fetchBlocked() async {
    final userId = profile.user!.id;
    if (!userService.canBlockUsers || userId == userService.user?.id) return;
    blocked = await userService.isUserBlocked(userId) ?? blocked;
  }

  Future<void> toggleBlocked() async {
    if (await userService.setUserBlocked(profile.user!.id, !blocked)) {
      blocked = !blocked;
      SmartDialog.showToast(
        blocked ? t.profile.user_blocked : t.profile.user_unblocked,
      );
    }
  }

  Future<void> fetchWorksPreview() async {
    fetchWorksPreviewMessage = null;
    _isFetchingWorksPreview.value = true;
    bool success = true;
    await ApiProvider.getMedia(
      path: "/videos",
      queryParameters: {"user": profileModel!.user!.id, "limit": 8},
      type: MediaType.video,
    ).then((value) {
      success = value.success;
      if (!success) {
        fetchWorksPreviewMessage = value.message;
      } else {
        popularVideos = value.data!;
      }
    });

    if (!success) {
      _isFetchingWorksPreview.value = false;
      return;
    }

    await ApiProvider.getMedia(
      path: "/images",
      queryParameters: {"user": profileModel!.user!.id, "limit": 8},
      type: MediaType.image,
    ).then((value) {
      success = value.success;
      if (!success) {
        fetchWorksPreviewMessage = value.message;
      } else {
        popularImages = value.data!;
      }
    });

    _isFetchingWorksPreview.value = false;
  }
}
