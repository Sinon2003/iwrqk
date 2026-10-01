import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/controller.dart';
import '../../../../../data/enums/result.dart';
import '../../../../../data/enums/types.dart';
import '../../../../../data/models/media/media.dart';
import '../../../../../data/services/user_service.dart';
import 'repository.dart';

class FavoriteMediaPreviewListController
    extends IwrRefreshController<MediaModel> {
  final FavoriteMediaPreviewListRepository repository =
      FavoriteMediaPreviewListRepository();

  final UserService userService = Get.find();
  late MediaType _sourceType;

  void initConfig(MediaType sourceType) {
    _sourceType = sourceType;
  }

  Future<void> unfavoriteAll() {
    showLoading();
    return Future.wait(data.map((e) => userService.unfavoriteMedia(e.id))).then(
      (value) {
        refreshData(showSplash: true);
      },
    );
  }

  @override
  Future<GroupResult<MediaModel>> getNewData(int currentPage) {
    return repository.getPlaylistMedias(
      type: _sourceType,
      currentPage: currentPage,
    );
  }
}
