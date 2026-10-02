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
  final RxString _description = "".obs;
  final RxBool _hideSensitive = false.obs;
  final Rxn<NotificationsSettings> _notifications = Rxn();

  String get name => _name.value;
  String get avatarUrl => _avatarUrl.value;
  String get headerUrl => _headerUrl.value;
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
    _description.value = _userService.profile?.body ?? "";
    _hideSensitive.value = _userService.hideSensitive;
    _notifications.value = _userService.notificationsSettings;
  }

  /// Shows the change at once, like the app's own settings, and saves it in
  /// the background. When saving fails, the service says why. Either way the
  /// page ends up showing what was last read from the site.
  ///
  /// A switch shows by itself that it took; text does not, so [confirm] says
  /// so once the change has been read back.
  Future<void> _save(
    void Function() show,
    Future<bool> Function() save, {
    bool confirm = false,
  }) async {
    show();
    final saved = await save();
    _syncFromService();
    if (saved && confirm) SmartDialog.showToast(t.account_settings.saved);
  }

  /// Uploads take a while, so they keep a loading dialog.
  Future<void> _upload(Future<bool> Function() upload) async {
    SmartDialog.showLoading(msg: t.notifications.loading);
    final ok = await upload();
    SmartDialog.dismiss(status: SmartStatus.loading);
    if (ok) _syncFromService();
  }

  Future<String?> _pickImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    return file?.path;
  }

  Future<void> changeAvatar() async {
    final path = await _pickImage();
    if (path == null) return;
    await _upload(() => _userService.updateAvatar(path));
  }

  Future<void> changeHeader() async {
    final path = await _pickImage();
    if (path == null) return;
    await _upload(() => _userService.updateHeader(path));
  }

  Future<void> changeName(String value) async {
    final newName = value.trim();
    if (newName.isEmpty || newName == name) return;
    await _save(
      () => _name.value = newName,
      () => _userService.updateName(newName),
      confirm: true,
    );
  }

  Future<void> changeDescription(String value) async {
    if (value == description) return;
    await _save(
      () => _description.value = value,
      () => _userService.updateDescription(value),
      confirm: true,
    );
  }

  Future<void> setHideSensitive(bool value) async {
    await _save(
      () => _hideSensitive.value = value,
      () => _userService.updateHideSensitive(value),
    );
  }

  Future<void> setNotification({
    bool? comment,
    bool? reply,
    bool? mention,
  }) async {
    final current = notifications;
    if (current == null) return;
    final settings = NotificationsSettings(
      comment: comment ?? current.comment,
      reply: reply ?? current.reply,
      mention: mention ?? current.mention,
    );
    await _save(
      () => _notifications.value = settings,
      () => _userService.updateNotificationsSettings(settings),
    );
  }
}
