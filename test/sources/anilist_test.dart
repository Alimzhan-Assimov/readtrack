import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/anilist_apply.dart';
import 'package:readtrack/sources/anilist.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final fixture = File('test/sources/fixtures/anilist_kaguya.json')
      .readAsStringSync();

  AniListClient client(String body, {int status = 200}) => AniListClient(
    client: MockClient((request) async {
      final sent = jsonDecode(request.body) as Map;
      expect(sent['variables'], {'q': 'Kaguya-sama', 't': 'MANGA'});
      return http.Response.bytes(utf8.encode(body), status);
    }),
  );

  test('search results carry titles, characters and relations', () async {
    final m = (await client(
      fixture,
    ).search('Kaguya-sama', type: 'MANGA')).single;
    expect(m.id, 86635);
    expect(m.title, 'Kaguya-sama: Love is War');
    expect(
      m.titles,
      contains('Kaguya-sama wa Kokurasetai: Tensaitachi no Renai Zunousen'),
    );
    expect((m.format, m.year, m.isAdult), ('MANGA', 2015, false));
    expect(m.genres, isNotEmpty);
    expect(m.tags, contains('School'));
    expect(m.characters.map((c) => c.name), contains('Chika Fujiwara'));
    expect(m.relations.map((r) => r.type), contains('SPIN_OFF'));
    expect(m.description, isNot(contains('<')));
  });

  test('errors and rate limits become clear messages', () async {
    expect(
      () => client(
        '{"errors":[{"message":"Too Many Requests."}],"data":null}',
        status: 429,
      ).search('Kaguya-sama', type: 'MANGA'),
      throwsA(predicate((e) => '$e'.contains('slow down'))),
    );
  });

  test('applying fills empty fields, characters and links', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = (await client(
      fixture,
    ).search('Kaguya-sama', type: 'MANGA')).single;
    final spinOff = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.manga,
        format: WorkFormat.physical,
        title: 'Doujin Edition',
        anilistId: const Value(102490),
      ),
    );
    final id = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.manga,
        format: WorkFormat.physical,
        title: 'Kaguya-sama Vol. 1',
        summary: const Value('My own summary'),
      ),
      fandomName: 'Kaguya-sama',
      tagNames: ['Comedy', 'Owned'],
      characterNames: ['Fujiwara Chika'],
    );
    final item = (await db.watchWork(id).first)!;
    final result = await applyAniList(db, item, media);
    final w = (await db.watchWork(id).first)!;
    expect(w.work.summary, 'My own summary');
    expect(w.work.anilistId, 86635);
    expect(w.work.coverUrl, startsWith('https://'));
    expect(w.tags.map((t) => t.name), containsAll(['Owned', 'School']));
    // "Chika Fujiwara" is the same character as "Fujiwara Chika".
    expect(w.characters.map((c) => c.name), contains('Fujiwara Chika'));
    expect(w.characters, hasLength(4));
    expect(result.characters, 3);
    final chika = w.characters.firstWhere((c) => c.name == 'Fujiwara Chika');
    expect(chika.anilistId, isNotNull);
    expect(result.relations, 1);
    expect((await db.watchRelations(spinOff).first).single.work.id, id);
    // The romaji title now leads to the same category.
    final other = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'A fic',
      ),
      fandomName: 'Kaguya-sama wa Kokurasetai: Tensaitachi no Renai Zunousen',
    );
    expect((await db.watchWork(other).first)!.fandom!.id, w.fandom!.id);

    // A second lookup doesn't link twice.
    expect((await applyAniList(db, w, media)).relations, 0);
  });
}
