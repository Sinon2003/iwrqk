import 'package:get/get.dart';

import '../../../components/iwr_refresh/controller.dart';
import '../../../data/enums/result.dart';
import '../../../data/models/account/conversations/conversation.dart';
import '../../../data/services/user_service.dart';

class ConversationsController extends IwrRefreshController<ConversationModel> {
  final UserService userService = Get.find();

  @override
  Future<GroupResult<ConversationModel>> getNewData(int currentPage) async {
    final result = await userService.getConversations(currentPage);
    if (!result.success) throw Exception(result.message);
    return result.data!;
  }
}
