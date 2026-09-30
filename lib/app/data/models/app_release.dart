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

  /// The changelog part of [notes], without Markdown heading marks.
  String get changelog {
    final start = notes.indexOf('## Changelog');
    final text = start == -1 ? notes : notes.substring(start);
    return text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '').trim();
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
