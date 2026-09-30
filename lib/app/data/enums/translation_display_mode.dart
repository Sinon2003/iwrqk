/// Where a translation of user content is shown. Persisted by [name], so keep
/// names stable.
enum TranslationDisplayMode {
  /// Below the original text.
  below,

  /// In place of the original text, which can be shown again.
  replace;

  static TranslationDisplayMode? fromName(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}
