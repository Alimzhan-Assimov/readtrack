import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';

/// Schema of version 1, as created by the first release.
const _v1Schema = [
  'CREATE TABLE "fandoms" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL UNIQUE)',
  'CREATE TABLE "tags" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL UNIQUE)',
  'CREATE TABLE "works" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "type" TEXT NOT NULL, "format" TEXT NOT NULL, "title" TEXT NOT NULL, "author" TEXT NULL, "summary" TEXT NULL, "isbn" TEXT NULL, "source_url" TEXT NULL, "cover_url" TEXT NULL, "fandom_id" INTEGER NULL REFERENCES fandoms (id) ON DELETE SET NULL, "status" TEXT NOT NULL DEFAULT \'planned\', "is_complete" INTEGER NOT NULL DEFAULT 0 CHECK ("is_complete" IN (0, 1)), "chapter_count" INTEGER NULL, "current_chapter" INTEGER NULL, "word_count" INTEGER NULL, "page_count" INTEGER NULL, "rating" INTEGER NULL, "notes" TEXT NULL, "added_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))',
  'CREATE TABLE "work_tags" ("work_id" INTEGER NOT NULL REFERENCES works (id) ON DELETE CASCADE, "tag_id" INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE, PRIMARY KEY ("work_id", "tag_id"))',
  'CREATE TABLE "chapters" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "work_id" INTEGER NOT NULL REFERENCES works (id) ON DELETE CASCADE, "number" INTEGER NOT NULL, "title" TEXT NULL, "url" TEXT NULL, "content" TEXT NULL, "word_count" INTEGER NULL, "downloaded_at" INTEGER NULL, UNIQUE ("work_id", "number"))',
];

void main() {
  test(
    'upgrading from version 1 keeps entries and adds the new columns',
    () async {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            for (final statement in _v1Schema) {
              raw.execute(statement);
            }
            raw.execute(
              "INSERT INTO works (type, format, title) VALUES ('fanfiction', 'online', 'The new dawn')",
            );
            raw.execute(
              "INSERT INTO tags (name) VALUES ('Анальный секс'), ('Romance')",
            );
            raw.execute('PRAGMA user_version = 1');
          },
        ),
      );
      addTearDown(db.close);

      final flags = {for (final t in await db.allTags()) t.name: t.isAdult};
      expect(flags, {'Romance': false, 'Анальный секс': true});

      final works = await db.watchWorks().first;
      expect(works.single.work.title, 'The new dawn');
      expect(works.single.work.coverPath, isNull);

      final id = works.single.work.id;
      await db.saveChapterList(id, [
        (number: 1, title: 'One', url: 'https://x/1', locked: true),
      ]);
      expect((await db.chaptersOf(id)).single.isLocked, isTrue);
      await db.addDownload(
        DownloadsCompanion.insert(workId: id, fromChapter: 1, toChapter: 1),
      );
      expect(await db.downloadsOf(id), hasLength(1));
      await db.updateWork(id, const WorksCompanion(readOffset: Value(0.5)));
      expect((await db.watchWork(id).first)!.work.readOffset, 0.5);
    },
  );

  test('a column that already exists does not stop the upgrade', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final statement in _v1Schema) {
            raw.execute(statement);
          }
          // As left behind by a development build.
          raw.execute('ALTER TABLE works ADD COLUMN deleted_at INTEGER NULL');
          raw.execute(
            "INSERT INTO works (type, format, title) VALUES ('book', 'digital', 'Kept')",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(db.close);
    final works = await db.watchWorks().first;
    expect(works.single.work.title, 'Kept');
  });
}
