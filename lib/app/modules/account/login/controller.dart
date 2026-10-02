import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../components/dialogs/loading_dialog/widget.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/services/account_service.dart';
import '../../../routes/pages.dart';
import '../../../utils/display_util.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? account;
  String? password;
  bool _submitting = false;

  final RxBool _passwordVisibility = false.obs;

  bool get passwordVisibility => _passwordVisibility.value;

  final AccountService _accountService = Get.find();

  @override
  void onInit() {
    super.onInit();
    StorageProvider.savedUserAccountPassword.get().then((value) {
      if (!isClosed && value != null) {
        accountController.text = value["account"];
        passwordController.text = value["password"];
      }
    });
  }

  void togglePasswordVisibility() {
    _passwordVisibility.value = !_passwordVisibility.value;
  }

  Future<void> login(BuildContext context) async {
    if (_submitting || isClosed) return;
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    final submittedAccount = account!;
    final submittedPassword = password!;
    _submitting = true;

    try {
      await Get.dialog(
        LoadingDialog(
          task: () async {
            await _accountService
                .login(account: submittedAccount, password: submittedPassword)
                .then((value) {
                  if (!value.success) {
                    throw DisplayUtil.getErrorMessage(value.message!);
                  }
                });
          },
          onCancel: _accountService.cancelLogin,
          onSuccess: () {
            Get.offNamedUntil(AppRoutes.splash, (route) => false);
            StorageProvider.savedUserAccountPassword.set({
              "account": submittedAccount,
              "password": submittedPassword,
            });
          },
          successMessage: t.message.account.login_success,
        ),
        barrierDismissible: false,
      );
    } finally {
      _submitting = false;
    }
  }

  @override
  void onClose() {
    _accountService.cancelLogin();
    accountController.dispose();
    passwordController.dispose();
    super.onClose();
    if (!_accountService.isLogin) {
      cancel();
    }
  }

  void cancel() {
    _accountService.logout();
  }
}
