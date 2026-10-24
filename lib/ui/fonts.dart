import 'dart:io';

List<String>? _cache;

/// Font families installed on this system, sorted by name; empty where they
/// can't be listed (fontconfig is only asked on Linux).
Future<List<String>> installedFontFamilies() async {
  if (_cache case final cached?) return cached;
  var families = const <String>[];
  if (Platform.isLinux) {
    try {
      final result = await Process.run('fc-list', [':', 'family']);
      if (result.exitCode == 0) {
        families = parseFontFamilies(result.stdout as String);
      }
    } on ProcessException {
      // No fontconfig tools; the user can still type a name.
    }
  }
  return _cache = families;
}

/// Parses `fc-list : family` output. A line lists a family's names in
/// several languages, separated by commas; the first one is used.
List<String> parseFontFamilies(String output) {
  final names = <String>{
    for (final line in output.split('\n'))
      if (line.split(',').first.trim() case final name when name.isNotEmpty)
        name.replaceAll(r'\-', '-'),
  };
  return names.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}
