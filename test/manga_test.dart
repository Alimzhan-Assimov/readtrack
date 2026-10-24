import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/book_importer.dart';
import 'package:readtrack/library/exporters.dart';
import 'package:readtrack/library/file_import.dart';
import 'package:readtrack/library/storage.dart';
import 'package:readtrack/reader/manga_pages.dart';

/// A tiny PNG whose last byte tells the pages apart.
Uint8List png(int n) => Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, n, //
]);

List<int> cbz(Map<String, List<int>> files) {
  final archive = Archive();
  for (final MapEntry(:key, :value) in files.entries) {
    archive.addFile(ArchiveFile(key, value.length, value));
  }
  return ZipEncoder().encode(archive);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('names with numbers sort by value', () {
    final names = ['p10.png', 'p2.png', 'p1.png', 'Cover.png'];
    expect(names..sort(naturalCompare), [
      'Cover.png',
      'p1.png',
      'p2.png',
      'p10.png',
    ]);
  });

  test('a CBZ gives one chapter per folder, pages in order', () {
    final book = readCbz(
      cbz({
        'Vol 1/Ch 10/page2.png': png(3),
        'Vol 1/Ch 2/page10.png': png(2),
        'Vol 1/Ch 2/page9.png': png(1),
        'Vol 1/Ch 10/page1.png': png(4),
        '__MACOSX/Vol 1/._page1.png': png(9),
        'ComicInfo.xml':
            '<ComicInfo><Title>Frieren</Title><Writer>Yamada</Writer>'
                    '<Genre>Fantasy, Adventure</Genre><Manga>YesAndRightToLeft</Manga></ComicInfo>'
                .codeUnits,
      }),
      title: 'file',
    );
    expect(book.title, 'Frieren');
    expect(book.author, 'Yamada');
    expect(book.tags, ['Fantasy', 'Adventure']);
    expect((book.type, book.rightToLeft), (WorkType.manga, true));
    expect(book.chapters.map((c) => c.title), ['Ch 2', 'Ch 10']);
    final first = imageOnlyPages(book.chapters.first.html)!;
    expect([for (final s in first) book.images[s]!.last], [1, 2]);
    expect(book.cover!.last, 1);
  });

  test('loose pages are one chapter; no ComicInfo means a comic', () {
    final book = readCbz(cbz({'b.png': png(2), 'a.png': png(1)}), title: 'X');
    expect(book.chapters.single.title, 'X');
    expect((book.type, book.rightToLeft), (WorkType.comic, false));
  });

  test('an imported CBZ exports back to the same pages', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final temp = Directory.systemTemp.createTempSync('readtrack_cbz');
    final storage = LibraryStorage(
      dataDir: Directory('${temp.path}/b'),
      exportDir: Directory('${temp.path}/e'),
    );
    final file = File('${temp.path}/in.cbz')
      ..writeAsBytesSync(
        cbz({'1/01.png': png(1), '1/02.png': png(2), '2/01.png': png(3)}),
      );
    final id = await BookImporter(db, storage).importFile(file.path);
    final details = (await db.watchWork(id).first)!;
    expect(details.work.type, WorkType.comic);
    final exported = buildCbz(
      ExportBook(
        work: details.work,
        chapters: await db.chaptersOf(id),
        from: 1,
        to: 2,
        storage: storage,
      ),
    );
    final again = readCbz(exported, title: 'again');
    expect(again.chapters, hasLength(2));
    expect(
      [
        for (final c in again.chapters)
          for (final s in imageOnlyPages(c.html)!) again.images[s]!.last,
      ],
      [1, 2, 3],
    );
    expect(ExportFormat.forType(WorkType.manga), contains(ExportFormat.cbz));
    expect(
      ExportFormat.forType(WorkType.book),
      isNot(contains(ExportFormat.cbz)),
    );
  });

  test('only chapters without text count as image chapters', () {
    expect(imageOnlyPages('<p><img src="a.png" alt=""></p>\n<p> </p>'), [
      'a.png',
    ]);
    expect(imageOnlyPages('<p>Map:</p><p><img src="a.png"></p>'), isNull);
    expect(imageOnlyPages('<p>Text</p>'), isNull);
  });

  testWidgets('pages turn by direction and ask for more at the end', (
    tester,
  ) async {
    final shown = <int>[];
    var pastEnd = 0;
    final key = GlobalKey<MangaPagesState>();
    Future<void> pump({required bool rtl, bool double = false}) =>
        tester.pumpWidget(
          MaterialApp(
            home: MangaPages(
              key: key,
              pages: [for (var i = 0; i < 5; i++) MemoryImage(png(i))],
              rightToLeft: rtl,
              doublePage: double,
              onPageChanged: (page, _) => shown.add(page),
              onPastEnd: () => pastEnd++,
              onBeforeStart: () {},
            ),
          ),
        );
    await pump(rtl: true);
    // Right to left: the left edge turns forward.
    key.currentState!.turn(left: true);
    await tester.pumpAndSettle();
    key.currentState!.turn(left: false);
    await tester.pumpAndSettle();
    expect(shown, [1, 0]);

    // Two pages: the cover alone, then pairs; past the last spread asks
    // for the next chapter.
    shown.clear();
    await pump(rtl: false, double: true);
    for (var i = 0; i < 3; i++) {
      key.currentState!.next();
      await tester.pumpAndSettle();
    }
    expect(shown, [1, 3]);
    expect(pastEnd, 1);
  });
}
