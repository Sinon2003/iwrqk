import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

import 'controller.dart';

class LoadingDialog extends StatefulWidget {
  final FutureOr<void> Function() task;
  final Function()? onSuccess;
  final Function()? onFail;
  final VoidCallback? onCancel;
  final String? successMessage;
  final String? errorMessage;

  const LoadingDialog({
    super.key,
    required this.task,
    this.successMessage,
    this.errorMessage,
    this.onSuccess,
    this.onFail,
    this.onCancel,
  });

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  final controller = LoadingDialogController();
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    controller.init(widget.task);
  }

  @override
  void dispose() {
    _cancelPending();
    controller.onDelete();
    super.dispose();
  }

  void _cancelPending() {
    if (_cancelled || !controller.status.isLoading) return;
    _cancelled = true;
    controller.onDelete();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _cancelPending();
      },
      child: controller.obx(
        (_) => AlertDialog(
          title: Text(t.notifications.success),
          content: Text(widget.successMessage ?? t.notifications.success),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                widget.onSuccess?.call();
              },
              child: Text(t.notifications.ok),
            ),
          ],
        ),
        onLoading: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(top: 5, bottom: 15),
                    child: const CircularProgressIndicator(),
                  ),
                  Text(
                    t.notifications.loading,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        onError: (error) => AlertDialog(
          title: Text(t.notifications.error),
          content: Text(widget.errorMessage ?? error ?? t.notifications.error),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                widget.onFail?.call();
              },
              child: Text(t.notifications.ok),
            ),
          ],
        ),
      ),
    );
  }
}
