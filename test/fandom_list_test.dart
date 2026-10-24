import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/fandom_list.dart';
import 'package:readtrack/data/fandom_names.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final json = File('assets/fandoms.json').readAsStringSync();

  setUpAll(() => FandomList.load(json));
  tearDownAll(() => FandomList.load('{"fandoms": []}'));

  test('the list is valid and no alias names two franchises', () {
    final data = jsonDecode(json) as Map;
    final owner = <String, String>{};
    for (final f in data['fandoms'] as List) {
      for (final alias in [f['name'], ...f['aliases'] as List]) {
        final key = fandomKey('$alias');
        expect(owner[key] ?? f['name'], f['name'], reason: '$alias');
        owner[key] = f['name'] as String;
      }
    }
    expect(owner.length, greaterThan(100));
  });

  test('other names land in the listed franchise', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    Future<String?> categoryOf(String name) async {
      final id = await db.saveWork(
        WorksCompanion.insert(
          type: WorkType.fanfiction,
          format: WorkFormat.online,
          title: name,
        ),
        fandomName: name,
      );
      return (await db.watchWork(id).first)!.fandom?.name;
    }

    expect(await categoryOf('Boku no Hero Academia'), 'My Hero Academia');
    expect(await categoryOf('僕のヒーローアカデミア'), 'My Hero Academia');
    expect(await categoryOf('BNHA'), 'My Hero Academia');
    expect(await categoryOf('Моя геройская академия'), 'My Hero Academia');
    expect(await categoryOf('Shingeki no Kyojin (Anime)'), 'Attack on Titan');
    expect(await categoryOf('Harry Potter - J. K. Rowling'), 'Harry Potter');
    expect(await categoryOf('Гарри Поттер'), 'Harry Potter');
    expect((await db.usedFandoms()).map((f) => f.name), [
      'Attack on Titan',
      'Harry Potter',
      'My Hero Academia',
    ]);
  });

  test('merging remembers the name for later imports', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    Future<int> add(String fandom) => db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: fandom,
      ),
      fandomName: fandom,
      crossoverNames: const [],
      characterNames: ['Kirito'],
    );
    await add('Sword Art Online');
    final b = await add('SAO Alicization Lycoris Abridged');
    final all = {for (final f in await db.usedFandoms()) f.name: f.id};
    await db.mergeFandom(
      all['SAO Alicization Lycoris Abridged']!,
      all['Sword Art Online']!,
    );
    expect((await db.watchWork(b).first)!.fandom!.name, 'Sword Art Online');
    final c = await add('SAO Alicization Lycoris Abridged');
    expect((await db.watchWork(c).first)!.fandom!.name, 'Sword Art Online');
    expect(await db.usedFandoms(), hasLength(1));
  });
}
