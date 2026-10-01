import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

/// Asks before deleting something that cannot be brought back, and tells
/// whether the user went ahead.
Future<bool> confirmDelete(String message) async {
  final confirmed = await Get.dialog<bool>(
    Builder(
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(t.notifications.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.records.delete),
          ),
        ],
      ),
    ),
  );
  return confirmed == true;
}
