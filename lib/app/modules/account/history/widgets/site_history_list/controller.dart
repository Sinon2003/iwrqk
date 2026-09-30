import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/controller.dart';
import '../../../../../data/enums/result.dart';
import '../../../../../data/enums/types.dart';
import '../../../../../data/models/media/media.dart';
import '../../../../../data/services/user_service.dart';

/// One tab of the watch history the site keeps for the account.
class SiteHistoryListController extends IwrRefreshController<MediaModel> {
  SiteHistoryListController(this.type);

  final MediaType type;
  final UserService _userService = Get.find();

  @override
  Future<GroupResult<MediaModel>> getNewData(int currentPage) async {
    final result = await _userService.getSiteHistory(type, currentPage);
    if (!result.success) throw Exception(result.message);
    return result.data!;
  }
}
