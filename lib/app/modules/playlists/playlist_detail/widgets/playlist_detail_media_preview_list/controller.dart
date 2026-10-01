import 'package:get/get.dart';

import '../../../../../components/iwr_refresh/controller.dart';
import '../../../../../data/enums/result.dart';
import '../../../../../data/models/media/media.dart';
import '../../../../../data/services/user_service.dart';
import 'repository.dart';

class PlaylistDetailMediaPreviewListController
    extends IwrRefreshController<MediaModel> {
  final PlaylistDetailMediaPreviewListRepository repository =
      PlaylistDetailMediaPreviewListRepository();
  final UserService _userService = Get.find();
  late String _playlistId;

  void initConfig(String playlistId) {
    _playlistId = playlistId;
  }

  Future<void> removeAllFromPlaylist() async {
    Future.wait(
      data.map((e) => _userService.removeFromPlaylist(e.id, [_playlistId])),
    ).then((value) {
      refreshData(showSplash: true);
    });
  }

  @override
  Future<GroupResult<MediaModel>> getNewData(int currentPage) {
    return repository.getPlaylistMedia(
      currentPage: currentPage,
      playlistId: _playlistId,
    );
  }
}
