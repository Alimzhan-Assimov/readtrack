/// Genre words that are joined with "/" without being a pairing
/// ("Hurt/Comfort", "Adventure/Romance").
const _genreWords = {
  'adventure',
  'angst',
  'comfort',
  'crime',
  'drama',
  'family',
  'fantasy',
  'friendship',
  'general',
  'horror',
  'humor',
  'hurt',
  'mystery',
  'parody',
  'poetry',
  'romance',
  'sci-fi',
  'spiritual',
  'supernatural',
  'suspense',
  'tragedy',
  'western',
  'fluff',
  'smut',
  'action',
  'comedy',
};

/// Whether a tag names a relationship, like AO3's "Uchiha Sasuke/Uzumaki
/// Naruto" or "Naruto/ ???", so it belongs to pairings instead of tags.
bool looksLikePairing(String tag) {
  final text = tag.trim();
  // AO3 descriptions such as "Alternate Universe - College/University".
  if (!text.contains('/') || text.contains(' - ') || text.contains(' – ')) {
    return false;
  }
  final parts = [for (final p in text.split('/')) p.trim()];
  if (parts.length < 2 || parts.any((p) => p.isEmpty)) return false;
  if (parts.every((p) => _genreWords.contains(p.toLowerCase()))) return false;
  // Names are short; longer parts are descriptions.
  return parts.every(
    (p) =>
        p == '???' ||
        (RegExp(r'\p{L}', unicode: true).hasMatch(p) &&
            p.split(' ').length <= 5),
  );
}
