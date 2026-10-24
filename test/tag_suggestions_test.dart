import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/keyword_tags.dart';
import 'package:readtrack/library/story_sync.dart';
import 'package:readtrack/sources/sources.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('keywords in a summary point to tags, in several languages', () {
    expect(
      keywordTags(
        'Naruto is reborn and sent back in time. A slow-burn romance.',
      ),
      {
        'Time Travel': 'back in time',
        'Reincarnation': 'reborn',
        'Slow Burn': 'slow-burn',
        'Romance': 'romance',
      },
    );
    expect(keywordTags('Попаданец в мир магии строит государство').keys, [
      'Isekai',
      'Kingdom Building',
      'Fantasy',
    ]);
    // Only at the start of a word: "Shaharem" isn't a harem.
    expect(keywordTags('Shaharem, the city'), isEmpty);
  });

  test('suggestions are added, accepted or dismissed for good', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await addStory(
      db,
      StoryInfo(
        url: Uri.parse('https://example.test/s/1'),
        siteName: 'Test',
        type: WorkType.fanfiction,
        title: 'Second Chance',
        summary: 'He was reborn with all his memories. Harem.',
        tags: const ['Harem'],
        chapters: const [],
      ),
    );
    var open = await db.watchTagSuggestions(id).first;
    // "Harem" is already a tag; the rest are suggestions with a reason.
    expect([for (final s in open) s.tag.name], ['Fix-it', 'Reincarnation']);
    expect(open.last.suggestion.reason, 'The summary mentions “reborn”');

    await db.acceptTagSuggestion(id, open.last.tag.id);
    await db.dismissTagSuggestion(id, open.first.tag.id);
    final w = (await db.watchWork(id).first)!;
    expect(w.tags.map((t) => t.name).toSet(), {'Harem', 'Reincarnation'});
    expect(await db.watchTagSuggestions(id).first, isEmpty);

    // Asking again doesn't bring back the dismissed or accepted ones.
    expect(await suggestKeywordTags(db, id, 'reborn, second chance'), 0);
  });
}
