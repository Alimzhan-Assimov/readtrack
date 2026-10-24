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

/// Names for original characters that mean the same, by the words they're
/// made of (lowercase, without a plural).
const _originalCharacters = {
  'oc': 'Original Character',
  'original character': 'Original Character',
  'omc': 'Original Male Character',
  'original male character': 'Original Male Character',
  'male oc': 'Original Male Character',
  'ofc': 'Original Female Character',
  'original female character': 'Original Female Character',
  'female oc': 'Original Female Character',
  'onbc': 'Original Non-Binary Character',
  'original non-binary character': 'Original Non-Binary Character',
};

/// [pairing] with each original character written one way ("OC" and
/// "Original Character(s)" become "Original Character"); the partners, their
/// order, genders and the "/" or "&" between them are kept.
String normalizePairing(String pairing) => pairing
    .trim()
    .split(RegExp(r'(?=\s*[/&]\s*)|(?<=[/&])'))
    .map((part) {
      final t = part.trim();
      if (t == '/' || t == '&') return t;
      final key = t
          .toLowerCase()
          .replaceAll(RegExp(r'\(s\)$'), '')
          .replaceAll(RegExp(r'(?<=character)s$'), '')
          .replaceAll(RegExp(r'(?<=oc)s$'), '')
          .trim();
      return _originalCharacters[key] ?? t;
    })
    .join()
    .replaceAllMapped(
      RegExp(r'\s*([/&])\s*'),
      (m) => m[1] == '&' ? ' & ' : '/',
    );
