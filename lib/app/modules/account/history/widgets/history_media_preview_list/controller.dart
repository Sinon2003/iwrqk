import '../../../../../components/iwr_refresh/controller.dart';
import '../../../../../data/enums/result.dart';
import '../../../../../data/models/offline/history_media.dart';
import 'repository.dart';

class HistoryMediaPreviewListController
    extends IwrRefreshController<HistoryMediaModel> {
  final HistoryMediaPreviewListRepository repository =
      HistoryMediaPreviewListRepository();

  @override
  Future<GroupResult<HistoryMediaModel>> getNewData(int currentPage) async =>
      repository.getHistoryMedias(currentPage);
}
