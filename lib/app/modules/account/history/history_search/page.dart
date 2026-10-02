import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import '../../../../data/models/offline/history_media.dart';
import '../../../../data/providers/storage_provider.dart';
import '../controller.dart';
import '../widgets/history_media_preview.dart';

/// Looks through this device's history by title or uploader while the words
/// are typed. The records are on the device, so nothing is requested.
class HistorySearchPage extends StatefulWidget {
  const HistorySearchPage({super.key});

  @override
  State<HistorySearchPage> createState() => _HistorySearchPageState();
}

class _HistorySearchPageState extends State<HistorySearchPage> {
  final HistoryController _historyController = Get.find();
  final TextEditingController _textController = TextEditingController();

  late List<HistoryMediaModel> _records = StorageProvider.historyList.get();
  String _keyword = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _search(String text) => setState(() => _keyword = text.trim());

  Future<void> _open(HistoryMediaModel item) async {
    await Get.toNamed(
      "/mediaDetail?id=${item.id}",
      arguments: {"mediaType": item.type},
    );
    // Watching it again moved it to the front of the history.
    if (mounted) setState(() => _records = StorageProvider.historyList.get());
  }

  /// What the page says while there is nothing to list.
  Widget _buildNotice(BuildContext context, IconData icon, String text) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 42),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_keyword.isEmpty) {
      return _buildNotice(
        context,
        Icons.search,
        t.records.search_local_history_hint,
      );
    }

    final found = [
      for (final record in _records)
        if (record.contains(_keyword)) record,
    ];
    if (found.isEmpty) {
      return _buildNotice(
        context,
        Icons.search_off,
        t.records.search_no_result(keyword: _keyword),
      );
    }

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: found.length,
      itemBuilder: (context, index) => HistoryMediaPreview(
        historyController: _historyController,
        media: found[index],
        onTap: () => _open(found[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          controller: _textController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: t.records.search_local_history,
          ),
          onChanged: _search,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
        actions: [
          if (_keyword.isNotEmpty)
            IconButton(
              onPressed: () {
                _textController.clear();
                _search('');
              },
              icon: const Icon(Icons.clear),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context),
    );
  }
}
