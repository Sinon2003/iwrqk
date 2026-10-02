import 'dart:convert';

/// The tags the app knows, arranged for browsing: by group, and inside a
/// group the most common first.
///
/// A table shipped with the app lists the ids of each group in the order to
/// show them. Its first group repeats the tags used most across the others,
/// so that picking a tag rarely needs more than that one.
class TagGroups {
  const TagGroups(this._groups);

  static const empty = TagGroups({});

  /// Reads a table: one JSON object of tag ids by group.
  factory TagGroups.fromJson(String source) {
    final groups = <String, List<String>>{};
    final decoded = json.decode(source);
    if (decoded is Map) {
      for (final entry in decoded.entries) {
        final ids = entry.value;
        if (entry.key is String && ids is List) {
          groups[entry.key] = [
            for (final id in ids)
              if (id is String) id,
          ];
        }
      }
    }
    return TagGroups(groups);
  }

  final Map<String, List<String>> _groups;

  bool get isEmpty => _groups.isEmpty;

  /// The groups, in the order to offer them.
  List<String> get keys => _groups.keys.toList();

  /// The tags of [group], in the order to show them.
  List<String> of(String group) => _groups[group] ?? const [];
}
