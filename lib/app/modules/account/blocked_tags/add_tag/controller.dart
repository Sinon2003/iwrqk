import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../data/services/tag_name_service.dart';
import 'repository.dart';

class AddTagController extends GetxController {
  final AddTagRepository repository = AddTagRepository();
  final TagNameService _tagNames = Get.find();

  final GlobalKey tagsBoxKey = GlobalKey();

  final TextEditingController tagEditingController = TextEditingController();
  final GlobalKey tagEditingControllerKey = GlobalKey();
  final FocusNode tagFocusNode = FocusNode();

  final RxList<String> _selectedTags = <String>[].obs;
  List<String> get selectedTags => _selectedTags.toList();

  Future<List<String>> autoCompleteTags(String keyword) {
    return _tagNames.complete(
      keyword,
      (keyword) async => [
        for (final tag in await repository.autoCompleteTags(keyword)) tag.id,
      ],
    );
  }

  void addTag(String tag) {
    if (_selectedTags.contains(tag)) {
      return;
    }
    _selectedTags.add(tag);
    tagEditingController.clear();
  }

  void removeTag(String tag) {
    _selectedTags.remove(tag);
  }

  bool isSelected(String tag) => _selectedTags.contains(tag);

  /// Picks or drops a tag from the catalogue; what is being typed stays.
  void toggleTag(String tag) {
    if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
  }
}
