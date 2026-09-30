import 'package:get/get.dart';

import '../../../data/enums/types.dart';
import 'controller.dart';

class SiteHistoryBinding implements Bindings {
  @override
  void dependencies() {
    for (final type in [MediaType.video, MediaType.image]) {
      Get.lazyPut(() => SiteHistoryListController(type), tag: type.name);
    }
  }
}
