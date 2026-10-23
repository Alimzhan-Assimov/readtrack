import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/adult_tags.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/pairing_tags.dart';

void main() {
  test('recognizes relationships but not genre pairs or AU tags', () {
    for (final tag in [
      'Hatake Kakashi/Shizune',
      'Naruto/ ???',
      'Hyuuga Hinata/Original Male Character(s)',
      'Uchiha Sasuke/Uzumaki Naruto',
    ]) {
      expect(looksLikePairing(tag), isTrue, reason: tag);
    }
    for (final tag in [
      'Hurt/Comfort',
      'Adventure/Romance',
      'Alternate Universe - College/University',
      'Marriage',
      'Fix-it',
    ]) {
      expect(looksLikePairing(tag), isFalse, reason: tag);
    }
  });

  test('adult words from real AO3 tags', () {
    for (final tag in ['Blow Jobs', 'Cock Worship', 'Vaginal Sex']) {
      expect(looksAdult(tag), isTrue, reason: tag);
    }
    expect(looksAdult('Cockatrice'), isFalse);
  });

  WorksCompanion fic(String title) => WorksCompanion.insert(
    type: WorkType.fanfiction,
    format: WorkFormat.online,
    title: title,
  );

  test('relationship tags become pairings on save and on upgrade', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await db.saveWork(
      fic('A'),
      tagNames: ['Marriage', 'Naruto/Hinata'],
    );
    var work = (await db.watchWork(id).first)!;
    expect(work.tags.map((t) => t.name), ['Marriage']);
    expect(work.pairings.map((p) => p.name), ['Naruto/Hinata']);

    // As stored by an older version: relationship directly as a tag.
    final tagId = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'Kakashi/Shizune'));
    await db
        .into(db.workTags)
        .insert(WorkTagsCompanion.insert(workId: id, tagId: tagId));
    await db.moveRelationshipTagsToPairings();

    work = (await db.watchWork(id).first)!;
    expect(work.tags.map((t) => t.name), ['Marriage']);
    expect(work.pairings.map((p) => p.name), [
      'Kakashi/Shizune',
      'Naruto/Hinata',
    ]);
  });
}
