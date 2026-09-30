import 'package:get/get.dart';

import 'controller.dart';

class AccountSettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountSettingsController>(() => AccountSettingsController());
  }
}
