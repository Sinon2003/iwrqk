import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:iwrqk/i18n/strings.g.dart';

abstract class ClipboardUtil {
  /// Copies [text] and confirms it with a toast.
  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    SmartDialog.showToast(t.message.copied);
  }
}
