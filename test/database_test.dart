import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/ui/app_settings.dart';
import 'package:readtrack/ui/fonts.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  WorksCompanion fic(String title) => WorksCompanion.insert(
    type: WorkType.fanfiction,
    format: WorkFormat.online,
    title: title,
  );

  test('categories and tags are merged case-insensitively', () async {
    final id = await db.saveWork(
      fic('First'),
      fandomName: 'Naruto',
      tagNames: ['Harem', 'Action'],
    );
    await db.saveWork(
      fic('Second'),
      fandomName: 'naruto',
      tagNames: ['action'],
    );

    final all = await db.watchWorks().first;
    expect(all, hasLength(2));
    final first = all.firstWhere((w) => w.work.id == id);
    expect(first.fandom?.name, 'Naruto');
    expect(first.tags.map((t) => t.name), ['Action', 'Harem']);
    expect(await db.usedFandoms(), hasLength(1));

    final action = first.tags.first;
    expect(await db.watchWorks(tagId: action.id).first, hasLength(2));
    expect(await db.watchWorks(search: 'naru').first, hasLength(2));
    expect(await db.watchWorks(type: WorkType.book).first, isEmpty);
  });

  test('non-ASCII tags match regardless of case', () async {
    // SQLite's lower() leaves "Ф" alone; this used to fail with a UNIQUE
    // constraint error when saving a second Russian story.
    await db.saveWork(
      fic('First'),
      tagNames: ['Фанфик'],
      pairingNames: ['Ли/Ма'],
    );
    final id = await db.saveWork(
      fic('Second'),
      tagNames: ['Фанфик', 'фанфик', 'ФАНФИК'],
      pairingNames: ['ли/ма'],
    );
    final work = await db.watchWork(id).first;
    expect(work!.tags.map((t) => t.name), ['Фанфик']);
    expect(work.pairings.map((p) => p.name), ['Ли/Ма']);
    expect(await db.usedTags(), hasLength(1));
  });

  test('editing replaces tags, deleting can be undone', () async {
    final id = await db.saveWork(fic('Fic'), tagNames: ['Fluff', 'Drama']);
    await db.saveWork(
      fic('Renamed fic').copyWith(id: Value(id)),
      tagNames: ['Fluff'],
    );

    final work = await db.watchWork(id).first;
    expect(work?.work.title, 'Renamed fic');
    expect(work?.tags.map((t) => t.name), ['Fluff']);

    final deleted = await db.deleteWork(id);
    expect(await db.watchWork(id).first, isNull);
    expect(await db.usedTags(), isEmpty);

    await db.restoreWork(deleted!);
    final restored = await db.watchWork(id).first;
    expect(restored?.work.title, 'Renamed fic');
    expect(restored?.tags.map((t) => t.name), ['Fluff']);
  });

  test('length and completion filters', () async {
    await db.saveWork(
      fic(
        'Short done',
      ).copyWith(wordCount: const Value(5000), isComplete: const Value(true)),
    );
    await db.saveWork(
      fic('Long ongoing').copyWith(
        wordCount: const Value(120000),
        isComplete: const Value(false),
      ),
    );
    await db.saveWork(fic('Unknown'));
    Future<List<String>> titles({int? minWords, bool? complete}) async => [
      for (final w
          in await db
              .watchWorks(
                minWords: minWords,
                complete: complete,
                sort: WorkSort.title,
              )
              .first)
        w.work.title,
    ];
    expect(await titles(minWords: 50000), ['Long ongoing']);
    expect(await titles(complete: true), ['Short done']);
    expect(await titles(complete: false), ['Long ongoing', 'Unknown']);
  });

  test('cover paths move to another books folder', () async {
    final id = await db.saveWork(
      fic('Covered').copyWith(coverPath: const Value('/old/books/1/cover.jpg')),
    );
    await db.saveWork(
      fic('Other').copyWith(coverPath: const Value('/x/c.jpg')),
    );
    await db.moveCoverPaths('/old/books', '/new/books');
    final works = await db.watchWorks(sort: WorkSort.title).first;
    expect(works.map((w) => w.work.coverPath), [
      '/new/books/1/cover.jpg',
      '/x/c.jpg',
    ]);
    expect(works.first.work.id, id);
  });

  test('trash hides works; old ones are deleted for good', () async {
    final old = await db.saveWork(fic('Old'), tagNames: ['Gone']);
    final recent = await db.saveWork(fic('Recent'));
    await db.saveWork(fic('Kept'));
    await db.moveToTrash(old, now: DateTime(2026));
    await db.moveToTrash(recent, now: DateTime(2026, 10));

    final visible = await db.watchWorks().first;
    expect(visible.map((w) => w.work.title), ['Kept']);
    expect(await db.usedTags(), isEmpty, reason: 'only used by trashed works');
    expect((await db.watchTrash().first).map((w) => w.title), [
      'Recent',
      'Old',
    ]);

    final removed = await db.emptyTrash(before: DateTime(2026, 6));
    expect(removed.keys, [old]);
    expect(await db.workById(old), isNull);

    await db.restoreFromTrash(recent);
    expect(await db.watchWorks().first, hasLength(2));
    expect(await db.watchTrash().first, isEmpty);
  });

  test('missing word and page counts are estimated', () async {
    // Four chapters, two of them read: words are scaled up to all four.
    final id = await db.saveWork(
      fic('Long').copyWith(chapterCount: const Value(4)),
    );
    await db.saveChapterList(id, [
      for (var n = 1; n <= 4; n++)
        (number: n, title: 'C$n', url: 'https://x/$n', locked: false),
    ]);
    await db.saveChapterText(id, 1, html: '<p>a</p>', wordCount: 1000);
    await db.saveChapterText(id, 2, html: '<p>b</p>', wordCount: 1500);
    var w = (await db.workById(id))!;
    expect((w.wordCount, w.wordsEstimated), (5000, true));
    expect((w.pageCount, w.pagesEstimated), (20, true));

    // Reading more refines the estimate.
    await db.saveChapterText(id, 3, html: '<p>c</p>', wordCount: 500);
    w = (await db.workById(id))!;
    expect(w.wordCount, 4000);

    // Numbers from the site or the user are never replaced.
    final given = await db.saveWork(
      fic('Given').copyWith(wordCount: const Value(12345)),
    );
    await db.fillMissingCounts(given);
    w = (await db.workById(given))!;
    expect((w.wordCount, w.wordsEstimated), (12345, false));
    expect((w.pageCount, w.pagesEstimated), (49, true));

    // Only pages known (Royal Road): words follow from them.
    final pages = await db.saveWork(
      fic('Pages').copyWith(pageCount: const Value(100)),
    );
    await db.fillMissingCounts(pages);
    w = (await db.workById(pages))!;
    expect((w.wordCount, w.wordsEstimated), (27500, true));
    expect((w.pageCount, w.pagesEstimated), (100, false));
    await db.fillMissingCounts(pages);
    expect((await db.workById(pages))!.wordCount, 27500, reason: 'stable');

    // Nothing known: nothing made up.
    final empty = await db.saveWork(fic('Empty'));
    await db.fillMissingCounts(empty);
    w = (await db.workById(empty))!;
    expect((w.wordCount, w.pageCount), (null, null));
  });

  test('sorting by title ignores case', () async {
    for (final title in ['beta', 'Gamma', 'Alpha']) {
      await db.saveWork(fic(title));
    }
    final sorted = await db.watchWorks(sort: WorkSort.title).first;
    expect(sorted.map((w) => w.work.title), ['Alpha', 'beta', 'Gamma']);
  });

  test('sorting by status puts current reads first; status filter', () async {
    Future<void> add(String title, ReadingStatus status) =>
        db.saveWork(fic(title).copyWith(status: Value(status)));
    await add('Done', ReadingStatus.finished);
    await add('Now', ReadingStatus.reading);
    await add('Dropped', ReadingStatus.dropped);
    await add('Later', ReadingStatus.planned);

    final sorted = await db.watchWorks(sort: WorkSort.status).first;
    expect(sorted.map((w) => w.work.title), [
      'Now',
      'Later',
      'Done',
      'Dropped',
    ]);
    final reading = await db.watchWorks(status: ReadingStatus.reading).first;
    expect(reading.map((w) => w.work.title), ['Now']);
  });

  test(
    'pairings are saved, filterable and restored; adult tags flagged',
    () async {
      final id = await db.saveWork(
        fic('Fic'),
        tagNames: ['Romance', 'Anal Sex', 'Kink X'],
        pairingNames: ['Naruto/Hinata', 'naruto/hinata', 'Sasuke/Sakura'],
        adultTags: {'Kink X'},
      );
      await db.saveWork(fic('Other'), pairingNames: ['Sasuke/Sakura']);

      final work = (await db.watchWork(id).first)!;
      expect(work.pairings.map((p) => p.name), [
        'Naruto/Hinata',
        'Sasuke/Sakura',
      ]);
      expect(
        {for (final t in work.tags) t.name: t.isAdult},
        {'Anal Sex': true, 'Kink X': true, 'Romance': false},
      );

      final naruHina = work.pairings.first;
      expect(await db.watchWorks(pairingId: naruHina.id).first, hasLength(1));
      expect(await db.usedPairings(), hasLength(2));

      final deleted = await db.deleteWork(id);
      await db.restoreWork(deleted!);
      expect((await db.watchWork(id).first)!.pairings, hasLength(2));
    },
  );

  test('settings are stored', () async {
    expect(await db.setting('x'), isNull);
    await db.setSetting('x', 'true');
    await db.setSetting('x', 'false');
    expect(await db.setting('x'), 'false');
  });

  test('annotations come back when deleting is undone', () async {
    final id = await db.saveWork(fic('Fic'));
    await db.addAnnotation(
      AnnotationsCompanion.insert(
        workId: id,
        chapterNumber: 2,
        kind: AnnotationKind.quote,
        quote: const Value('A line'),
      ),
    );
    final deleted = await db.deleteWork(id);
    expect(deleted!.annotations, hasLength(1));
    await db.restoreWork(deleted);
    expect((await db.watchAnnotations(id).first).single.quote, 'A line');
  });

  test('reader settings are stored and loaded', () async {
    final settings = AppSettings(db);
    await settings.setReader(
      const ReaderPrefs(
        fontSize: 22,
        font: ReaderFont.mono,
        lineHeight: 1.9,
        theme: ReaderTheme.sepia,
        justify: true,
      ),
    );
    final again = AppSettings(db);
    await again.load();
    final r = again.reader;
    expect(
      (r.fontSize, r.font, r.lineHeight, r.theme, r.justify),
      (22.0, ReaderFont.mono, 1.9, ReaderTheme.sepia, true),
    );
  });

  test('custom reader colors, font and width are stored and loaded', () async {
    final settings = AppSettings(db);
    await settings.setReader(
      const ReaderPrefs(
        theme: ReaderTheme.custom,
        background: Color(0xFF102030),
        textColor: Color(0xFFAABBCC),
        fontFamily: 'Noto Serif',
        textWidth: double.infinity,
      ),
    );
    final again = AppSettings(db);
    await again.load();
    final r = again.reader;
    expect(
      (r.pageColor, r.inkColor, r.family, r.textWidth),
      (
        const Color(0xFF102030),
        const Color(0xFFAABBCC),
        'Noto Serif',
        double.infinity,
      ),
    );

    await again.setReader(r.copyWith(clearFontFamily: true, textWidth: 960));
    await settings.load();
    expect(
      (settings.reader.family, settings.reader.textWidth),
      (ReaderFont.serif.family, 960.0),
    );
  });

  test('hex colors parse and print', () {
    expect(parseHexColor('#1a2B3c'), const Color(0xFF1A2B3C));
    expect(parseHexColor(' 801A2B3C '), const Color(0x801A2B3C));
    expect(parseHexColor('#12345'), isNull);
    expect(parseHexColor('red'), isNull);
    expect(hexOfColor(const Color(0xFF1A2B3C)), '#1A2B3C');
    expect(hexOfColor(const Color(0x801A2B3C)), '#801A2B3C');
  });

  test('font families are read from fc-list output', () {
    expect(
      parseFontFamilies(
        'DejaVu Sans,DejaVu Sans Condensed\n'
        'Noto Serif\n'
        'DejaVu Sans\n'
        'Fira Code,Fira Code Light\n'
        'Source Code Pro\\-Bold\n\n',
      ),
      ['DejaVu Sans', 'Fira Code', 'Noto Serif', 'Source Code Pro-Bold'],
    );
  });
}
