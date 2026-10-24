import 'dart:convert';

import 'fandom_names.dart';

/// Popular franchises and their other names, from `assets/fandoms.json`,
/// so "Boku no Hero Academia" and "BNHA" land in "My Hero Academia".
/// Empty until [load] is called (the app does it at start).
class FandomList {
  FandomList._();

  static final _byKey = <String, String>{};

  static void load(String json) {
    _byKey.clear();
    final data = jsonDecode(json) as Map<String, Object?>;
    for (final f in data['fandoms'] as List? ?? const []) {
      final name = (f as Map)['name'] as String;
      for (final alias in [name, ...(f['aliases'] as List? ?? const [])]) {
        _byKey[fandomKey('$alias')] = name;
      }
    }
  }

  /// The listed franchise [name] belongs to, or null.
  static String? canonical(String name) => _byKey[fandomKey(name)];

  /// What decides whether two category names are the same franchise.
  static String groupKey(String name) => fandomKey(canonical(name) ?? name);
}
