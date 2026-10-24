import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/sources/fanfiction_net.dart';

import 'sources/fake_fetcher.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> add(String title, String fandom, List<String> characters) =>
      db.saveWork(
        WorksCompanion.insert(
          type: WorkType.fanfiction,
          format: WorkFormat.online,
          title: title,
        ),
        fandomName: fandom,
        characterNames: characters,
      );

  test('names match in any order and without a franchise note', () {
    expect(characterKey('Fujiwara Chika'), characterKey('Chika Fujiwara'));
    expect(
      characterKey('Fujiwara Chika (Kaguya-sama)'),
      characterKey('fujiwara chika'),
    );
    expect(characterKey('Naruto U.'), 'naruto u');
  });

  test('characters are shared within a franchise and filterable', () async {
    final a = await add('Love Is War', 'Kaguya-sama', ['Fujiwara Chika']);
    final b = await add('Poetry', 'Kaguya-sama', [
      'Chika Fujiwara',
      'Shinomiya Kaguya',
    ]);
    // Same name, other franchise: a different character.
    await add('Moon Princess', 'Naruto', ['Ōtsutsuki Kaguya', 'Kaguya']);
    final chika = (await db.watchWork(a).first)!.characters.single;
    expect((await db.watchWork(b).first)!.characters.map((c) => c.id), [
      chika.id,
      isNot(chika.id),
    ]);
    expect(
      [
        for (final w in await db.watchWorks(characterId: chika.id).first)
          w.work.title,
      ]..sort(),
      ['Love Is War', 'Poetry'],
    );
    expect((await db.usageCounts(UsageKind.character))[chika.id], 2);
    expect(await db.usedCharacters(), hasLength(4));
    expect((await db.watchWorks(search: 'chika').first).length, 2);

    // An alias joins another spelling to the same character.
    await db.addCharacterAlias(chika.id, 'Chika-chan');
    final c = await add('Song', 'Kaguya-sama', ['chika-chan']);
    expect((await db.watchWork(c).first)!.characters.single.id, chika.id);

    // Kept on save without names, and through delete + undo.
    await db.saveWork(
      WorksCompanion(id: Value(a), title: const Value('Love Is War')),
      fandomName: 'Kaguya-sama',
    );
    final deleted = await db.deleteWork(a);
    await db.restoreWork(deleted!);
    expect((await db.watchWork(a).first)!.characters, hasLength(1));
  });

  test('FanFiction.net: characters come from the meta line', () async {
    final story = Uri.parse('https://www.fanfiction.net/s/42/1');
    final info = await const FanFictionNetSource().fetchStory(
      story,
      FakeFetcher({
        '$story': '''
          <div id="pre_story_links"><a href="/anime/">Anime/Manga</a><a href="/anime/Naruto/">Naruto</a></div>
          <div id="profile_top"><b class="xcontrast_txt">Story</b> By: <a href="/u/1/x">x</a>
          <span class="xgray xcontrast_txt">Rated: Fiction T - English - Hurt/Comfort/Adventure - [Naruto U., Hinata H.] Neji H. - Chapters: 1 - Words: 900 - Status: Complete - id: 42</span></div>
          <div id="storytext"><p>Hi.</p></div>''',
      }),
    );
    expect(info.characters, ['Naruto U.', 'Hinata H.', 'Neji H.']);
    expect(info.pairings, ['Naruto U./Hinata H.']);

    final noCharacters = await const FanFictionNetSource().fetchStory(
      story,
      FakeFetcher({
        '$story': '''
          <div id="pre_story_links"><a href="/anime/Naruto/">Naruto</a></div>
          <div id="profile_top"><b class="xcontrast_txt">Story</b> By: <a href="/u/1/x">x</a>
          <span class="xgray xcontrast_txt">Rated: Fiction K - English - Humor - Chapters: 1 - Words: 900 - id: 42</span></div>
          <div id="storytext"><p>Hi.</p></div>''',
      }),
    );
    expect(noCharacters.characters, isEmpty);
  });
}
