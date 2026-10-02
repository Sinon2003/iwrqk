import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathUtil {
  static late Directory tempDir;

  static Directory? appDocDir;

  static Directory? appSupportDir;

  /// The app's folder on shared storage, which other apps can see.
  static Directory? externalStorageDir;

  static Directory? systemDownloadDir;

  static Future<void> init() async {
    await Future.wait([
      getTemporaryDirectory().then((value) => tempDir = value),
      getApplicationDocumentsDirectory().then((value) => appDocDir = value),
      getApplicationSupportDirectory().then((value) => appSupportDir = value),
      getExternalStorageDirectory()
          .then((value) => externalStorageDir = value)
          .catchError((error) => null),
      getDownloadsDirectory()
          .then((value) => systemDownloadDir = value)
          .catchError((error) => null),
    ]);
  }

  static Directory getVisibleDir() {
    return externalStorageDir ??
        appDocDir ??
        appSupportDir ??
        systemDownloadDir!;
  }

  /// Turns [name], such as a video title, into a usable file or folder name.
  ///
  /// Characters that file systems reject become their full-width forms, so
  /// titles stay readable; a colon would also make the downloader take the
  /// folder for a URI. The name is cut to [maxBytes] bytes of UTF-8, as
  /// names may take 255.
  static String safeFileName(String name, {int maxBytes = 200}) {
    const fullWidth = {
      '/': '／',
      '\\': '＼',
      ':': '：',
      '*': '＊',
      '?': '？',
      '"': '＂',
      '<': '＜',
      '>': '＞',
      '|': '｜',
    };
    final replaced = name
        .replaceAllMapped(
          RegExp(r'[/\\:*?"<>|]'),
          (match) => fullWidth[match[0]]!,
        )
        .replaceAll(RegExp(r'[\x00-\x1f]'), '')
        .trim();

    final kept = StringBuffer();
    var bytes = 0;
    for (final rune in replaced.runes) {
      bytes += utf8.encode(String.fromCharCode(rune)).length;
      if (bytes > maxBytes) break;
      kept.writeCharCode(rune);
    }
    final safe = kept.toString().trim();
    return safe.isEmpty || safe == '.' || safe == '..' ? '_' : safe;
  }
}
