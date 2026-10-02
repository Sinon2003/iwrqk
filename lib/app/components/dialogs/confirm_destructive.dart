import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';

/// Asks before something that cannot be taken back, and tells whether the
/// user went ahead. [action] labels the button that does it; without one it
/// reads "Delete".
Future<bool> confirmDestructive(String message, {String? action}) async {
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
            child: Text(action ?? t.records.delete),
          ),
        ],
      ),
    ),
  );
  return confirmed == true;
}
