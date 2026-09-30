import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/account/conversations/message.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/user_service.dart';

/// Messages of one conversation, oldest first. Pages go back in time with the
/// `before` cursor, as on the site.
class ConversationDetailController extends GetxController with StateMixin {
  final UserService userService = Get.find();
  final TextEditingController inputController = TextEditingController();

  late final String conversationId;
  late final String title;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool _hasMore = false.obs;
  final RxBool _loadingOlder = false.obs;
  final RxBool _sending = false.obs;

  bool get hasMore => _hasMore.value;
  bool get loadingOlder => _loadingOlder.value;
  bool get sending => _sending.value;

  @override
  void onInit() {
    super.onInit();
    conversationId = Get.parameters["id"]!;
    title = (Get.arguments as Map?)?["title"] ?? "";
    loadLatest();
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  List<MessageModel> _sorted(Iterable<MessageModel> list) =>
      list.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> loadLatest() async {
    if (messages.isEmpty) change(null, status: RxStatus.loading());
    final result = await ApiProvider.getMessages(
      conversationId,
      DateTime.now().toUtc().toIso8601String(),
    );
    if (!result.success) {
      change(null, status: RxStatus.error(result.message));
      return;
    }
    messages.value = _sorted(result.data!.results);
    _hasMore.value = messages.length < result.data!.count;
    change(null, status: RxStatus.success());
  }

  Future<void> loadOlder() async {
    if (loadingOlder || messages.isEmpty) return;
    _loadingOlder.value = true;
    final result = await ApiProvider.getMessages(
      conversationId,
      messages.first.createdAt,
    );
    _loadingOlder.value = false;
    if (!result.success) return;
    final known = messages.map((m) => m.id).toSet();
    final older = result.data!.results.where((m) => !known.contains(m.id));
    messages.insertAll(0, _sorted(older));
    _hasMore.value = older.isNotEmpty && messages.length < result.data!.count;
  }

  Future<void> send() async {
    final text = inputController.text.trim();
    if (text.isEmpty || sending) return;
    _sending.value = true;
    final sent = await userService.sendMessage(
      conversationId: conversationId,
      content: text,
    );
    _sending.value = false;
    if (sent) {
      inputController.clear();
      await loadLatest();
    }
  }

  Future<void> delete(MessageModel message) async {
    if (await userService.deleteMessage(message.id)) {
      messages.removeWhere((m) => m.id == message.id);
    }
  }
}
