import 'package:get/get.dart';

import 'controller.dart';

class ConversationsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationsController>(() => ConversationsController());
  }
}
