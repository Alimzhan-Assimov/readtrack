import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/backup.dart';
import 'package:readtrack/library/shelves.dart';

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('readtrack_backup'));
  tearDown(() => temp.deleteSync(recursive: true));

  test('a backup restores database and books on the next start', () async {
    final support = Directory(p.join(temp.path, 'support'))..createSync();
    final books = Directory(p.join(support.path, 'books'));
    File(p.join(books.path, '1', 'cover.jpg'))
      ..createSync(recursive: true)
      ..writeAsStringSync('cover');
    final backup = LibraryBackup(supportDir: support, booksDir: books);

    final db = AppDatabase(NativeDatabase.memory());
    await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.book,
        format: WorkFormat.digital,
        title: 'Backed up',
      ),
    );
    final zip = await backup.create(
      db,
      Directory(p.join(temp.path, 'Backups')),
      now: DateTime(2026, 10, 23, 12, 30),
    );
    await db.close();
    expect(p.basename(zip.path), 'ReadTrack backup 2026-10-23 12-30.zip');

    // The library changes after the backup …
    final current = File(p.join(support.path, 'readtrack.sqlite'))
      ..writeAsStringSync('newer');
    File(p.join(books.path, '2', 'cover.jpg'))
      ..createSync(recursive: true)
      ..writeAsStringSync('newer');

    // … and the backup is restored.
    expect(await backup.stageRestore(zip), DateTime(2026, 10, 23, 12, 30));
    expect(current.readAsStringSync(), 'newer', reason: 'not swapped yet');
    expect(await backup.applyPendingRestore(), books.path);
    expect(await backup.applyPendingRestore(), isNull, reason: 'only once');

    expect(File('${current.path}.before-restore').readAsStringSync(), 'newer');
    expect(
      File(p.join(books.path, '1', 'cover.jpg')).readAsStringSync(),
      'cover',
    );
    expect(File(p.join(books.path, '2', 'cover.jpg')).existsSync(), isFalse);

    final restored = AppDatabase(NativeDatabase(current));
    addTearDown(restored.close);
    final works = await restored.watchWorks().first;
    expect(works.single.work.title, 'Backed up');
  });

  test('other zip files are rejected and leave nothing behind', () async {
    final support = Directory(p.join(temp.path, 'support'))..createSync();
    final backup = LibraryBackup(
      supportDir: support,
      booksDir: Directory(p.join(support.path, 'books')),
    );
    final notZip = File(p.join(temp.path, 'x.zip'))..writeAsStringSync('no');
    await expectLater(backup.stageRestore(notZip), throwsA(anything));
    expect(await backup.applyPendingRestore(), isNull);
  });

  test('shelves keep their filters as JSON', () {
    const shelf = Shelf(
      'Long finished',
      LibraryFilter(
        type: WorkType.fanfiction,
        tagId: 3,
        minWords: 100000,
        complete: true,
        sort: WorkSort.title,
      ),
    );
    final back = Shelf.fromJson(shelf.toJson());
    expect(back.name, 'Long finished');
    expect(
      (back.filter.type, back.filter.tagId, back.filter.fandomId),
      (WorkType.fanfiction, 3, null),
    );
    expect(
      (back.filter.minWords, back.filter.complete, back.filter.sort),
      (100000, true, WorkSort.title),
    );
    expect(Shelf.fromJson({'name': 'x'}).filter.sort, WorkSort.updated);
  });
}
