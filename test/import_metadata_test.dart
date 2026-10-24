import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/fandom_list.dart';
import 'package:readtrack/data/pairing_tags.dart';
import 'package:readtrack/library/story_sync.dart';
import 'package:readtrack/sources/sources.dart';

StoryInfo info({
  String title = 'Наруто с чит-кодами Том 1',
  WorkType type = WorkType.webnovel,
  List<String> tags = const ['Попаданцы', 'Фанфик', 'мир наруто'],
  String? fandom,
  List<String> characters = const [],
  ({String name, double? index})? series,
}) => StoryInfo(
  url: Uri.parse('https://author.today/work/466508'),
  siteName: 'Author.Today',
  type: type,
  title: title,
  summary: 'Узумаки Наруто получает систему.',
  fandom: fandom,
  tags: tags,
  characters: characters,
  series: series,
  chapters: const [],
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUpAll(
    () => FandomList.load(File('assets/fandoms.json').readAsStringSync()),
  );
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a "Фанфик" tag makes a story fan fiction', () {
    expect(storyType(info()), WorkType.fanfiction);
    expect(storyType(info(tags: ['Попаданцы'])), WorkType.webnovel);
    expect(
      storyType(info(tags: ['fanfiction'], type: WorkType.book)),
      WorkType.fanfiction,
    );
  });

  test('the franchise is guessed from tags, then the title', () async {
    expect(await db.guessFandom(title: 'X', tags: ['мир наруто']), 'Naruto');
    expect(
      await db.guessFandom(title: 'X', tags: ['Naruto (Anime)']),
      'Naruto',
    );
    expect(await db.guessFandom(title: 'Жизнь внутри Наруто'), 'Naruto');
    expect(
      await db.guessFandom(title: 'Ичиго: Из сёнена', tags: ['блич']),
      'Bleach',
    );
    // The library's own categories count too.
    await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'a',
      ),
      fandomName: 'Arifureta',
    );
    expect(await db.guessFandom(title: 'Arifureta: Another Path'), 'Arifureta');
    // Short names don't match inside titles; unknown stays unknown.
    expect(await db.guessFandom(title: 'HP Lovecraft and the Sea'), isNull);
    expect(
      await db.guessFandom(title: 'Глобальная Миссия', tags: ['боевик']),
      isNull,
    );
  });

  test(
    'a list import of an Author.Today fan fiction gets type and franchise',
    () async {
      final id = await addStory(db, info());
      final w = (await db.watchWork(id).first)!;
      expect((w.work.type, w.fandom?.name), (WorkType.fanfiction, 'Naruto'));
    },
  );

  test('updating from the site fills in what an old entry lacks', () async {
    final id = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.book,
        format: WorkFormat.online,
        title: 'My title',
        summary: const Value('My summary'),
        sourceUrl: const Value('https://author.today/work/466508'),
      ),
      tagNames: ['Own tag'],
    );
    final item = (await db.watchWork(id).first)!;
    await refreshFromSite(
      db,
      item,
      info(
        characters: ['Узумаки Наруто'],
        series: (name: 'Наруто с чит-кодами', index: 1),
      ),
    );
    final w = (await db.watchWork(id).first)!;
    expect((w.work.title, w.work.summary), ('My title', 'My summary'));
    expect((w.work.type, w.fandom?.name), (WorkType.fanfiction, 'Naruto'));
    expect(w.series?.name, 'Наруто с чит-кодами');
    expect(w.work.seriesIndex, 1);
    expect(w.characters.map((c) => c.name), ['Узумаки Наруто']);
    expect(w.tags.map((t) => t.name), containsAll(['Own tag', 'Isekai']));

    final failed = await refreshAllFromSites(
      db,
      load: (_, _) async => info(),
      pause: Duration.zero,
    );
    expect(failed, isEmpty);
  });

  test('translated tags are merged into one at start', () async {
    final a = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.book,
        format: WorkFormat.online,
        title: 'a',
      ),
      tagNames: ['Action'],
    );
    final b = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.book,
        format: WorkFormat.online,
        title: 'b',
      ),
    );
    // Stored as they came in before the synonyms were known.
    for (final (work, name) in [(b, 'экшн'), (b, 'Aktion'), (a, 'Comedy')]) {
      final tag = await db
          .into(db.tags)
          .insert(TagsCompanion.insert(name: name));
      await db
          .into(db.workTags)
          .insert(WorkTagsCompanion.insert(workId: work, tagId: tag));
    }
    await db.mergeSynonymTags();
    expect((await db.allTags()).map((t) => t.name).toSet(), {
      'Action',
      'Humor',
    });
    expect((await db.watchWork(b).first)!.tags.single.name, 'Action');
    final action = (await db.allTags()).firstWhere((t) => t.name == 'Action');
    expect((await db.usageCounts(UsageKind.tag))[action.id], 2);
  });

  test('original characters in pairings are written one way', () async {
    expect(
      normalizePairing('Hyuuga Hinata/Original Male Character(s)'),
      'Hyuuga Hinata/Original Male Character',
    );
    expect(
      normalizePairing('Uzumaki Karin/Original Male Characters'),
      'Uzumaki Karin/Original Male Character',
    );
    expect(normalizePairing('OC/Haku'), 'Original Character/Haku');
    expect(
      normalizePairing('Naruto & OFC'),
      'Naruto & Original Female Character',
    );
    expect(normalizePairing('Sasuke/Naruto'), 'Sasuke/Naruto');

    final a = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'a',
      ),
      pairingNames: ['Yamanaka Ino/OMC'],
    );
    final b = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'b',
      ),
    );
    final old = await db
        .into(db.pairings)
        .insert(
          PairingsCompanion.insert(
            name: 'Yamanaka Ino/Original Male Character(s)',
          ),
        );
    await db
        .into(db.workPairings)
        .insert(WorkPairingsCompanion.insert(workId: b, pairingId: old));
    await db.mergeEquivalentPairings();
    for (final id in [a, b]) {
      expect(
        (await db.watchWork(id).first)!.pairings.single.name,
        'Yamanaka Ino/Original Male Character',
      );
    }
    expect(await db.usedPairings(), hasLength(1));
  });
}
