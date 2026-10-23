/// Words that only name a variant of a franchise, not a different one
/// (checked at the end of a name, in lower case).
const _variantSuffixes = [
  'shippuden',
  'shippūden',
  'shippuuden',
  'anime & manga',
  'anime and manga',
  'anime',
  'manga',
  'tv series',
  'series',
  'movies',
  'movie',
  'light novel',
  'novels',
  'ova',
  'аниме и манга',
  'аниме',
  'манга',
  'сериал',
];

/// The franchise part of a category name, so variants share one category:
/// "Naruto (Anime & Manga)", "Naruto: Shippuden", "NARUTO | ナルト" and
/// "Naruto Shippuden" all become "Naruto".
///
/// Only ": " with a space starts a subtitle, so "Re:Zero" stays intact; "/"
/// is kept as well ("Fate/stay night").
String baseFandomName(String name) {
  final original = name.trim().replaceAll(RegExp(r'\s+'), ' ');
  var base = original
      .replaceAll(RegExp(r'\s*[(\[][^)\]]*[)\]]'), '')
      .split(RegExp(r':\s| \| | - | – | — '))
      .first
      .trim();
  var changed = true;
  while (changed) {
    changed = false;
    final lower = base.toLowerCase();
    for (final suffix in _variantSuffixes) {
      if (lower.endsWith(' $suffix') && lower.length > suffix.length + 1) {
        base = base.substring(0, base.length - suffix.length - 1).trim();
        changed = true;
        break;
      }
    }
  }
  return base.isEmpty ? original : base;
}

/// Comparison key: case, "ё" and punctuation don't matter.
String fandomKey(String name) =>
    baseFandomName(name)
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '');
