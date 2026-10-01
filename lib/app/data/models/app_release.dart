/// A release of this app on GitHub.
class AppRelease {
  AppRelease({
    required this.version,
    required this.notes,
    required this.pageUrl,
    required this.assets,
  });

  /// The tag without its leading "v", such as "2.4.0".
  final String version;
  final String notes;
  final String pageUrl;
  final List<AppReleaseAsset> assets;

  /// The changelog part of [notes] as plain text.
  ///
  /// Release notes lead with download links and the Chinese changelog, and
  /// fold the English one in a `<details>` block (see tool/release.dart).
  /// Older releases only have an English changelog.
  String changelog({required bool chinese}) {
    final fold = notes.indexOf('<details>');
    final leading = fold == -1 ? notes : notes.substring(0, fold);
    final folded = fold == -1 ? '' : notes.substring(fold);

    String? from(String text, String heading) {
      final start = text.indexOf(heading);
      return start == -1 ? null : text.substring(start);
    }

    final text =
        (chinese ? from(leading, '## 更新内容') : from(folded, '## Changelog')) ??
        from(leading, '## 更新内容') ??
        from(notes, '## Changelog') ??
        notes;
    return text
        .replaceAll(RegExp(r'</?details>|<summary>.*?</summary>'), '')
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .trim();
  }

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    return AppRelease(
      version: (json['tag_name'] as String).replaceFirst('v', ''),
      notes: json['body'] ?? '',
      pageUrl: json['html_url'] ?? '',
      assets: [
        for (final asset in json['assets'] as List? ?? [])
          AppReleaseAsset.fromJson(asset),
      ],
    );
  }
}

class AppReleaseAsset {
  AppReleaseAsset({required this.name, required this.size, required this.url});

  final String name;
  final int size;
  final String url;

  factory AppReleaseAsset.fromJson(Map<String, dynamic> json) {
    return AppReleaseAsset(
      name: json['name'],
      size: json['size'],
      url: json['browser_download_url'],
    );
  }
}
