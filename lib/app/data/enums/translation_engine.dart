/// Key-free translation sources. Persisted by [name], so keep names stable.
enum TranslationEngine {
  google(maxChunkLength: 5000),
  // Rejects requests somewhere between 5000 and 6000 characters.
  volcengine(maxChunkLength: 4500),
  tencent(maxChunkLength: 5000),
  yandex(maxChunkLength: 5000);

  const TranslationEngine({required this.maxChunkLength});

  /// Longest text sent in one request; longer text is split at line breaks.
  final int maxChunkLength;

  static TranslationEngine? fromName(String? name) {
    for (final engine in values) {
      if (engine.name == name) return engine;
    }
    return null;
  }
}
