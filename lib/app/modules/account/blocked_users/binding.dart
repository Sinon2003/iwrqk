import 'package:get/get.dart';

import 'controller.dart';

class BlockedUsersBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockedUsersController>(() => BlockedUsersController());
  }
}
