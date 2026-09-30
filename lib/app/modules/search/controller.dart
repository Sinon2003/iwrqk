import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/enums/types.dart';
import '../../data/models/offline/search_history.dart';
import '../../data/providers/storage_provider.dart';
import '../../routes/pages.dart';

class SearchController extends GetxController {
  final int maxExpandedClipsCount = 15;
  final RxBool _clipsExpanded = false.obs;
  TextEditingController searchEditingController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  final RxBool _showSearchSuffix = false.obs;

  final RxList<SearchHistoryModel> _searchHistoryList =
      <SearchHistoryModel>[].obs;

  final RxBool _editingHistory = false.obs;

  bool get clipsExpanded => _clipsExpanded.value;
  bool get editingHistory => _editingHistory.value;
  bool get showSearchSuffix => _showSearchSuffix.value;

  set showSearchSuffix(bool value) {
    _showSearchSuffix.value = value;
  }

  List<SearchHistoryModel> get searchHistoryList => _searchHistoryList;

  @override
  void onInit() {
    super.onInit();
    _refreshSearchHistoryList();
  }

  void _refreshSearchHistoryList() {
    List<SearchHistoryModel> list = StorageProvider.searchHistoryList.get();
    if (list.length <= maxExpandedClipsCount) {
      _clipsExpanded.value = true;
    } else if (_searchHistoryList.length <= maxExpandedClipsCount) {
      // Collapse only when the list grows past the limit, so deleting an item
      // from an expanded list keeps it expanded.
      _clipsExpanded.value = false;
    }
    _searchHistoryList.value = list;
    if (list.isEmpty) {
      _editingHistory.value = false;
    }
  }

  Future<void> addSearchHistoryItem(String text) async {
    SearchHistoryModel newItem = SearchHistoryModel(
      keyword: text,
      source: SearchSource.offical,
    );
    StorageProvider.searchHistoryList.add(newItem);
    _refreshSearchHistoryList();
  }

  /// Deletes by keyword (unique in the list): on a quick repeated tap an index
  /// could already point at the next item.
  Future<void> deleteSearchHistoryItem(String keyword) async {
    await StorageProvider.searchHistoryList.deleteWhere(
      (item) => item.keyword == keyword,
    );
    _refreshSearchHistoryList();
  }

  Future<void> clearSearchHistoryList() async {
    await StorageProvider.searchHistoryList.clean();
    _refreshSearchHistoryList();
  }

  /// Shows a delete button on every history item. The keyboard is hidden so
  /// it does not cover the items.
  void startEditingHistory() {
    searchFocusNode.unfocus();
    _editingHistory.value = true;
  }

  void stopEditingHistory() {
    _editingHistory.value = false;
  }

  void onSearchTextChanged(String text) {
    _showSearchSuffix.value = text.isNotEmpty;
  }

  void clearSearchText() {
    searchEditingController.clear();
    _showSearchSuffix.value = false;
  }

  void toggleClipsExpanded() {
    _clipsExpanded.value = !_clipsExpanded.value;
  }

  void submit() {
    String keyword = searchEditingController.text;
    if (keyword.isEmpty) return;
    stopEditingHistory();
    Get.toNamed(AppRoutes.searchResult, arguments: keyword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addSearchHistoryItem(keyword);
    });
  }
}
