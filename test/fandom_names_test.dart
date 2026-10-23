import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/fandom_names.dart';

void main() {
  test('variants of a franchise share one base name', () {
    for (final name in [
      'Naruto',
      'Naruto (Anime & Manga)',
      'Naruto: Shippuden',
      'Naruto Shippuden',
      'NARUTO | ナルト',
      'Naruto / Наруто / Аниме и манга, 1999-2017'.split(' / ').first,
      'naruto (anime)',
    ]) {
      expect(fandomKey(name), 'naruto', reason: name);
    }
    expect(baseFandomName('Naruto (Anime & Manga)'), 'Naruto');
    expect(baseFandomName('Harry Potter - J. K. Rowling'), 'Harry Potter');
    expect(baseFandomName('Гарри Поттер (аниме)'), 'Гарри Поттер');
  });

  test('different franchises stay apart', () {
    expect(
      fandomKey('Boruto: Naruto Next Generations'),
      isNot(fandomKey('Naruto')),
    );
    expect(baseFandomName('Re:Zero'), 'Re:Zero');
    expect(baseFandomName('Fate/stay night'), 'Fate/stay night');
    expect(baseFandomName('Anime'), 'Anime'); // never reduced to nothing
  });

  WorksCompanion fic(String title) => WorksCompanion.insert(
    type: WorkType.fanfiction,
    format: WorkFormat.online,
    title: title,
  );

  test('saving reuses the category of the same franchise', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.saveWork(fic('A'), fandomName: 'Naruto (Anime & Manga)');
    await db.saveWork(fic('B'), fandomName: 'Naruto: Shippuden');
    await db.saveWork(fic('C'), fandomName: 'Boruto: Naruto Next Generations');

    final names = [for (final f in await db.usedFandoms()) f.name];
    expect(names, ['Boruto', 'Naruto']);
  });

  test('existing duplicate categories are merged on start', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // Insert duplicates directly, as an older version would have.
    final a = await db
        .into(db.fandoms)
        .insert(FandomsCompanion.insert(name: 'Naruto (Anime & Manga)'));
    final b = await db
        .into(db.fandoms)
        .insert(FandomsCompanion.insert(name: 'naruto'));
    final first = await db
        .into(db.works)
        .insert(fic('A').copyWith(fandomId: Value(a)));
    final second = await db
        .into(db.works)
        .insert(fic('B').copyWith(fandomId: Value(b)));

    await db.mergeSimilarFandoms();

    final fandoms = await db.select(db.fandoms).get();
    expect(fandoms.map((f) => (f.id, f.name)), [(a, 'Naruto')]);
    for (final id in [first, second]) {
      expect((await db.watchWork(id).first)?.fandom?.name, 'Naruto');
    }
  });
}
