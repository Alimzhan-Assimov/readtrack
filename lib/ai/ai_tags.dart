import '../data/database.dart';
import '../data/default_tags.dart';
import '../sources/html_clean.dart';
import 'ai_client.dart';

/// How much of a story is sent for tagging.
enum AiTagMode {
  /// Summary and the first three chapters.
  quick,

  /// Summary and a chapter each from the start, the middle and the end.
  thorough,

  /// Only chapters added since the last analysis.
  newChapters,
}

/// What would be sent: the excerpts, their size, and the last chapter in
/// them (to remember for [AiTagMode.newChapters]).
typedef AiExcerpt = ({String text, int words, int lastChapter});

/// Picks the chapters [mode] sends from those with text, each cut to
/// [wordsPerChapter] words so a request stays affordable.
AiExcerpt pickExcerpt(
  List<Chapter> chapters,
  AiTagMode mode, {
  int analyzedUpTo = 0,
  int wordsPerChapter = 4000,
}) {
  final withText = [
    for (final c in chapters)
      if (c.content != null) c,
  ];
  final picked = switch (mode) {
    AiTagMode.quick => withText.take(3).toList(),
    AiTagMode.thorough => {
      if (withText.isNotEmpty) withText.first,
      if (withText.isNotEmpty) withText[withText.length ~/ 2],
      if (withText.isNotEmpty) withText.last,
    }.toList(),
    AiTagMode.newChapters => [
      for (final c in withText)
        if (c.number > analyzedUpTo) c,
    ].take(5).toList(),
  };
  final buffer = StringBuffer();
  var words = 0;
  for (final c in picked) {
    final all = htmlToPlainText(c.content!).split(RegExp(r'\s+'));
    final part = all.take(wordsPerChapter).join(' ');
    words += all.length < wordsPerChapter ? all.length : wordsPerChapter;
    buffer.writeln('--- ${c.title ?? 'Chapter ${c.number}'} ---\n$part\n');
  }
  return (
    text: '$buffer',
    words: words,
    lastChapter: picked.isEmpty ? analyzedUpTo : picked.last.number,
  );
}

const _system =
    'You tag stories in a personal reading library. From the list of tags '
    'given, choose the ones that clearly fit the story, judging by its '
    'summary and the excerpts. Prefer fewer, certain tags over many vague '
    'ones. Use only names from the list, spelled as given. For each tag, '
    'give one short reason without spoilers past the excerpts. Answer only '
    'with JSON: {"tags": [{"name": "...", "reason": "..."}]}.';

/// Asks the AI which of the [allowed] tags fit [work] and returns them with
/// their reasons, only names from the list.
Future<Map<String, String>> suggestTagsWithAi(
  AiClient client, {
  required Work work,
  required List<String> currentTags,
  required List<String> allowed,
  required AiExcerpt excerpt,
}) async {
  final prompt = StringBuffer()
    ..writeln('Title: ${work.title}')
    ..writeln('Summary: ${work.summary ?? '(none)'}')
    ..writeln('Tags it already has: ${currentTags.join(', ')}')
    ..writeln()
    ..writeln('Tags to choose from: ${allowed.join(', ')}')
    ..writeln()
    ..writeln('Excerpts:')
    ..writeln(excerpt.text);
  final answer = parseJsonObject(
    await client.complete(system: _system, prompt: '$prompt'),
  );
  final byKey = {for (final a in allowed) a.toLowerCase(): a};
  final has = {for (final t in currentTags) t.toLowerCase()};
  return {
    for (final t in answer['tags'] as List? ?? const [])
      if (t case {'name': final String name}
          when byKey.containsKey(name.toLowerCase().trim()) &&
              !has.contains(name.toLowerCase().trim()))
        byKey[name.toLowerCase().trim()]!: switch (t['reason']) {
          final String r when r.trim().isNotEmpty => r.trim(),
          _ => 'Suggested by AI',
        },
  };
}

/// The tags the AI may choose from: the default ones and those used in the
/// library (a fixed list keeps the results consistent).
Future<List<String>> allowedTags(AppDatabase db) async => {
  ...kDefaultTags,
  for (final t in await db.usedTags())
    if (!t.isAdult) t.name,
}.toList()..sort();
