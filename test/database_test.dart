import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesetracker/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  WorksCompanion fic(String title) => WorksCompanion.insert(
    type: WorkType.fanfiction,
    format: WorkFormat.online,
    title: title,
  );

  test('Kategorie und Tags werden ohne Rücksicht auf Groß-/Kleinschreibung zusammengeführt', () async {
    final id = await db.saveWork(
      fic('Erste'),
      fandomName: 'Naruto',
      tagNames: ['Harem', 'Action'],
    );
    await db.saveWork(
      fic('Zweite'),
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

  test(
    'Bearbeiten ersetzt Tags, Löschen lässt sich rückgängig machen',
    () async {
      final id = await db.saveWork(fic('Fic'), tagNames: ['Fluff', 'Drama']);
      await db.saveWork(
        fic('Fic umbenannt').copyWith(id: Value(id)),
        tagNames: ['Fluff'],
      );

      final work = await db.watchWork(id).first;
      expect(work?.work.title, 'Fic umbenannt');
      expect(work?.tags.map((t) => t.name), ['Fluff']);

      final deleted = await db.deleteWork(id);
      expect(await db.watchWork(id).first, isNull);
      expect(await db.usedTags(), isEmpty);

      await db.restoreWork(deleted!);
      final restored = await db.watchWork(id).first;
      expect(restored?.work.title, 'Fic umbenannt');
      expect(restored?.tags.map((t) => t.name), ['Fluff']);
    },
  );

  test('Sortierung nach Titel ignoriert Groß-/Kleinschreibung', () async {
    for (final title in ['beta', 'Gamma', 'Alpha']) {
      await db.saveWork(fic(title));
    }
    final sorted = await db.watchWorks(sort: WorkSort.title).first;
    expect(sorted.map((w) => w.work.title), ['Alpha', 'beta', 'Gamma']);
  });
}
