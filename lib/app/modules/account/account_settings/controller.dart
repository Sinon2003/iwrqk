import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../const/iwara.dart';
import '../../../data/models/account/notifications/settings.dart';
import '../../../data/services/user_service.dart';

/// Account and profile settings, matching the site's account pages.
class AccountSettingsController extends GetxController with StateMixin {
  final UserService _userService = Get.find();

  final RxString _name = "".obs;
  final RxString _avatarUrl = IwaraConst.defaultAvatarUrl.obs;
  final RxString _headerUrl = IwaraConst.defaultBannerUrl.obs;
  final RxBool _hasHeader = false.obs;
  final RxString _description = "".obs;
  final RxBool _hideSensitive = false.obs;
  final Rxn<NotificationsSettings> _notifications = Rxn();

  String get name => _name.value;
  String get avatarUrl => _avatarUrl.value;
  String get headerUrl => _headerUrl.value;
  bool get hasHeader => _hasHeader.value;
  String get description => _description.value;
  bool get hideSensitive => _hideSensitive.value;
  NotificationsSettings? get notifications => _notifications.value;
  bool get canBlockUsers => _userService.canBlockUsers;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    change(null, status: RxStatus.loading());
    if (await _userService.getUser()) {
      _syncFromService();
      change(null, status: RxStatus.success());
    } else {
      change(null, status: RxStatus.error());
    }
  }

  void _syncFromService() {
    final user = _userService.user!;
    _name.value = user.name;
    _avatarUrl.value = user.avatarUrl;
    _headerUrl.value =
        _userService.profile?.bannerUrl ?? IwaraConst.defaultBannerUrl;
    _hasHeader.value = _userService.profile?.header != null;
    _description.value = _userService.profile?.body ?? "";
    _hideSensitive.value = _userService.hideSensitive;
    _notifications.value = _userService.notificationsSettings;
  }

  /// Runs [update] behind a loading dialog and shows [success] when it worked.
  Future<void> _run(Future<bool> Function() update, String success) async {
    SmartDialog.showLoading(msg: t.notifications.loading);
    final ok = await update();
    SmartDialog.dismiss(status: SmartStatus.loading);
    if (ok) {
      _syncFromService();
      SmartDialog.showToast(success);
    }
  }

  Future<String?> _pickImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    return file?.path;
  }

  Future<void> changeAvatar() async {
    final path = await _pickImage();
    if (path == null) return;
    await _run(
      () => _userService.updateAvatar(path),
      t.account_settings.avatar_updated,
    );
  }

  Future<void> changeHeader() async {
    final path = await _pickImage();
    if (path == null) return;
    await _run(
      () => _userService.updateHeader(path),
      t.account_settings.header_updated,
    );
  }

  Future<void> removeHeader() async {
    await _run(_userService.removeHeader, t.account_settings.header_removed);
  }

  Future<void> changeName(String value) async {
    final newName = value.trim();
    if (newName.isEmpty || newName == name) return;
    await _run(
      () => _userService.updateName(newName),
      t.account_settings.name_updated,
    );
  }

  Future<void> changeDescription(String value) async {
    if (value == description) return;
    await _run(
      () => _userService.updateDescription(value),
      t.account_settings.description_updated,
    );
  }

  Future<void> setHideSensitive(bool value) async {
    await _run(
      () => _userService.updateHideSensitive(value),
      t.account_settings.saved,
    );
  }

  Future<void> setNotification({
    bool? comment,
    bool? reply,
    bool? mention,
  }) async {
    final current = notifications;
    if (current == null) return;
    await _run(
      () => _userService.updateNotificationsSettings(
        NotificationsSettings(
          comment: comment ?? current.comment,
          reply: reply ?? current.reply,
          mention: mention ?? current.mention,
        ),
      ),
      t.account_settings.saved,
    );
  }
}
