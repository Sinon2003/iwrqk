import 'dart:convert';

/// The names of the site's tags in one language, by tag id.
///
/// The site only has ids such as `school_swimsuit`. A table shipped with the
/// app gives each a name, so that tags can be read and looked up in that
/// language. A tag the table does not have keeps its id.
class TagNames {
  const TagNames(this._names);

  static const empty = TagNames({});

  /// Reads a table: one JSON object of names by tag id.
  factory TagNames.fromJson(String source) {
    final names = <String, String>{};
    final decoded = json.decode(source);
    if (decoded is Map) {
      for (final entry in decoded.entries) {
        final name = entry.value;
        if (entry.key is String && name is String && name.isNotEmpty) {
          names[entry.key] = name;
        }
      }
    }
    return TagNames(names);
  }

  final Map<String, String> _names;

  bool get isEmpty => _names.isEmpty;
  int get length => _names.length;

  String? of(String id) => _names[id];

  /// The ids of the tags whose name or id contains [keyword], the closest
  /// matches first. Ids are matched the way they are written, so "cat ears"
  /// finds `cat_ears`.
  List<String> search(String keyword, {int limit = 30}) {
    final inName = keyword.trim().toLowerCase();
    if (inName.isEmpty) return const [];
    final inId = inName.replaceAll(RegExp(r'\s+'), '_');

    final matches = <(int, int, String)>[];
    for (final entry in _names.entries) {
      final id = entry.key;
      final name = entry.value.toLowerCase();
      final int rank;
      if (name == inName || id == inId) {
        rank = 0;
      } else if (name.startsWith(inName)) {
        rank = 1;
      } else if (id.startsWith(inId)) {
        rank = 2;
      } else if (name.contains(inName)) {
        rank = 3;
      } else if (id.contains(inId)) {
        rank = 4;
      } else {
        continue;
      }
      matches.add((rank, name.length, id));
    }
    matches.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      if (a.$2 != b.$2) return a.$2.compareTo(b.$2);
      return a.$3.compareTo(b.$3);
    });
    return [for (final match in matches.take(limit)) match.$3];
  }

  /// Suggestions for a tag being typed: what [site] completes the keyword
  /// to, then the tags found here by name. The site only knows ids, so it is
  /// not asked about a keyword that cannot be part of one.
  Future<List<String>> complete(
    String keyword,
    Future<List<String>> Function(String keyword) site,
  ) async {
    final named = search(keyword);
    if (keyword.codeUnits.any((unit) => unit > 0x7f)) return named;
    try {
      return {...await site(keyword), ...named}.toList();
    } catch (_) {
      return named;
    }
  }
}
