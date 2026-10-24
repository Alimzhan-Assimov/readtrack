import '../data/database.dart';

/// Finds which of a franchise's [known] characters appear in [text], by
/// points: each mention of a full name (two or more words, or a name in
/// another script) counts 3, each mention of a single part of a name that
/// no other character shares counts 1 ("Chika" yes, "Uchiha" no). Returns
/// character ids with how sure the guess is (0–0.95), only above
/// [minPoints]. Names that aren't known (original characters) are never
/// made up.
Map<int, double> detectCharacters(
  String text,
  List<({Character character, List<String> names})> known, {
  int minPoints = 6,
}) {
  final lower = text.toLowerCase();
  int count(String name) {
    final n = name.toLowerCase().trim();
    if (n.length < 3) return 0;
    // Whole words only, in any script.
    return RegExp(
      '(?<![\\p{L}\\p{N}])${RegExp.escape(n)}(?![\\p{L}\\p{N}])',
      unicode: true,
    ).allMatches(lower).length;
  }

  // Parts of names, and how many characters have each.
  Iterable<String> parts(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'\([^)]*\)'), ' ')
      .split(RegExp(r'[\s.,\-]+'))
      .where((p) => p.length >= 3);
  final owners = <String, int>{};
  for (final k in known) {
    for (final part in {for (final n in k.names) ...parts(n)}) {
      owners[part] = (owners[part] ?? 0) + 1;
    }
  }

  final found = <int, double>{};
  for (final k in known) {
    var points = 0;
    final full = {
      for (final n in k.names)
        if (n.trim().contains(' ') || !RegExp(r'^[\x00-\x7F]+$').hasMatch(n))
          n.trim(),
    };
    for (final n in full) {
      points += 3 * count(n);
    }
    for (final part in {for (final n in k.names) ...parts(n)}) {
      if (owners[part] == 1 && !full.any((f) => f.toLowerCase() == part)) {
        // Mentions inside the full names were counted already.
        points +=
            count(part) -
            full
                .where((f) => f.toLowerCase().contains(part))
                .fold(0, (sum, f) => sum + count(f));
      }
    }
    if (points >= minPoints) {
      found[k.character.id] = (points / (points + 20)).clamp(0, 0.95);
    }
  }
  return found;
}
