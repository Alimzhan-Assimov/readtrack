import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/ui/app_settings.dart';

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
}
