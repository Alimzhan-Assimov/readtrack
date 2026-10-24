import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/character_detection.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Character c(int id, String name) => Character(id: id, name: name);

  test('full names count more; shared family names count nothing', () {
    final known = [
      (
        character: c(1, 'Uchiha Sasuke'),
        names: ['Uchiha Sasuke', 'Sasuke Uchiha'],
      ),
      (character: c(2, 'Uchiha Itachi'), names: ['Uchiha Itachi']),
      (character: c(3, 'Haruno Sakura'), names: ['Haruno Sakura', 'サクラ']),
      (character: c(4, 'Hatake Kakashi'), names: ['Hatake Kakashi']),
    ];
    const text = '''
      Sasuke Uchiha looked at the Uchiha crest. Sasuke sighed. "Sasuke!"
      Sakura called. Sakura and Sasuke walked on. Sakura laughed. Sakura
      smiled, and Sakura waved. The Uchiha clan was gone. サクラ.
      Kakashi was late.''';
    final found = detectCharacters(text, known);
    // Sasuke: full name 3 + "Sasuke" 3 more times = 6.
    expect(found.keys, containsAll([1, 3]));
    // Itachi only through the shared "Uchiha": nothing.
    expect(found.containsKey(2), isFalse);
    // One mention isn't enough.
    expect(found.containsKey(4), isFalse);
    expect(found.values.every((v) => v > 0 && v <= 0.95), isTrue);
    // Words inside other words don't count.
    expect(detectCharacters('Sasukeeee Sasukes', known), isEmpty);
  });

  test('suggestions are shown apart, confirmed or dismissed', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'Fic',
      ),
      fandomName: 'Naruto',
      characterNames: ['Uzumaki Naruto'],
    );
    final fandomId = (await db.watchWork(id).first)!.fandom!.id;
    final hinata = (await db.characterIdFor('Hyuuga Hinata', fandomId))!;
    await db.addCharacterAlias(hinata, 'Hinata Hyuga');
    await db.saveChapterList(id, [
      (number: 1, title: '1', url: 'https://a.test/1', locked: false),
    ]);
    await db.saveChapterText(
      id,
      1,
      html: '<p>Hinata Hyuga blushed. Hinata Hyuga smiled at Naruto.</p>',
      wordCount: 9,
    );
    final known = await db.charactersOf(fandomId);
    expect(known.firstWhere((k) => k.character.id == hinata).names, [
      'Hyuuga Hinata',
      'Hinata Hyuga',
    ]);
    final found = detectCharacters(await db.textOf(id), known);
    expect(found.keys, [hinata]);
    await db.suggestCharacters(id, found);
    var w = (await db.watchWork(id).first)!;
    expect(w.suggestedCharacters, {hinata});
    expect(w.confirmedCharacters.map((c) => c.name), ['Uzumaki Naruto']);

    // Saving the form (confirmed names only) keeps the suggestion.
    await db.saveWork(
      WorksCompanion(id: Value(id), title: const Value('Fic')),
      fandomName: 'Naruto',
      characterNames: ['Uzumaki Naruto'],
    );
    expect((await db.watchWork(id).first)!.suggestedCharacters, {hinata});

    await db.confirmCharacter(id, hinata);
    w = (await db.watchWork(id).first)!;
    expect(w.suggestedCharacters, isEmpty);
    expect(w.confirmedCharacters, hasLength(2));
    await db.removeCharacter(id, hinata);
    expect((await db.watchWork(id).first)!.characters, hasLength(1));
  });
}
