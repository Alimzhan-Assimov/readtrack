import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/book_importer.dart';
import 'package:readtrack/library/exporters.dart';
import 'package:readtrack/library/file_import.dart';
import 'package:readtrack/library/storage.dart';
import 'package:readtrack/sources/charsets.dart';

void main() {
  late Directory temp;
  late LibraryStorage storage;
  late ExportBook exported;
  const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3, 4];

  setUp(() {
    temp = Directory.systemTemp.createTempSync('readtrack_import');
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/books'),
      exportDir: Directory('${temp.path}/exports'),
    );
    storage.resolve(1, 'images/map.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png);
    final cover = File('${temp.path}/cover.png')..writeAsBytesSync(png);
    Chapter chapter(int n, String html) => Chapter(
      id: n,
      workId: 1,
      number: n,
      title: 'Chapter $n',
      content: html,
      isLocked: false,
    );
    exported = ExportBook(
      work: Work(
        id: 1,
        type: WorkType.book,
        format: WorkFormat.digital,
        title: 'Война и мир',
        author: 'Лев Толстой',
        summary: 'Роман.',
        coverPath: cover.path,
        status: ReadingStatus.planned,
        isComplete: true,
        addedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        newChapters: 0,
        wordsEstimated: false,
        pagesEstimated: false,
        ownsPhysicalCopy: false,
      ),
      chapters: [
        chapter(
          1,
          '<p>— Eh bien, mon prince. <em>Gênes</em>.</p><img src="images/map.png" alt="Map">',
        ),
        chapter(2, '<p>Второй.</p>'),
      ],
      from: 1,
      to: 2,
      storage: storage,
      tags: ['Роман'],
    );
  });

  tearDown(() => temp.deleteSync(recursive: true));

  void expectBook(ImportedBook book) {
    expect(book.title, 'Война и мир');
    expect(book.author, 'Лев Толстой');
    expect(book.summary, 'Роман.');
    expect(book.chapters.map((c) => c.title), ['Chapter 1', 'Chapter 2']);
    expect(book.chapters.first.html, contains('<em>Gênes</em>'));
    expect(book.cover, png);
    final image = RegExp(r'<img src="([^"]+)"')
        .firstMatch(book.chapters.first.html)!
        .group(1)!;
    expect(book.images[image], png);
  }

  test('reads back an EPUB written by ReadTrack', () {
    final book = readEpub(buildEpub(exported));
    expectBook(book);
    expect(book.format, ExportFormat.epub);
    expect(book.tags, ['Роман']);
    // The title page has no chapter heading but is kept as text.
    expect(book.chapters, hasLength(2));
  });

  test('reads back an FB2 written by ReadTrack, also in Windows-1251', () {
    final fb2 = buildFb2(exported);
    expectBook(readFb2(utf8.encode(fb2)));

    // Encode as Windows-1251, as many Russian FB2 files are; the encoder is
    // the decoder's table turned around.
    final encode = {
      for (var b = 0x80; b < 0x100; b++) decodeCharset([b], 'windows-1251'): b,
    };
    const xml =
        '<?xml version="1.0" encoding="windows-1251"?><FictionBook xmlns="http://www.gribuser.ru/xml/fictionbook/2.0">'
        '<description><title-info><book-title>Война и мир</book-title></title-info></description>'
        '<body><section><title><p>Глава</p></title><p>мир</p></section></body></FictionBook>';
    final bytes = [
      for (final ch in xml.split('')) encode[ch] ?? ch.codeUnitAt(0),
    ];
    final book = readFb2(bytes);
    expect(book.title, 'Война и мир');
    expect(book.chapters.single.title, 'Глава');
  });

  test('the source link and fan fiction type come back from exports', () {
    final fic = ExportBook(
      work: exported.work.copyWith(
        type: WorkType.fanfiction,
        sourceUrl: const Value('https://archiveofourown.org/works/1'),
      ),
      chapters: exported.chapters,
      from: 1,
      to: 2,
      storage: storage,
      fandom: 'Naruto & Boruto',
    );
    final epub = readEpub(buildEpub(fic));
    expect(epub.sourceUrl, 'https://archiveofourown.org/works/1');
    expect(epub.fandom, 'Naruto & Boruto');
    expect(readEpub(buildEpub(exported)).fandom, isNull);
    final fb2 = readFb2(utf8.encode(buildFb2(fic)));
    expect(
      (fb2.sourceUrl, fb2.isFanfiction),
      ('https://archiveofourown.org/works/1', true),
    );
    expect(readFb2(utf8.encode(buildFb2(exported))).isFanfiction, isFalse);
  });

  test('ISBNs are found and checked', () {
    expect(isbnOf('urn:isbn:978-3-16-148410-0'), '9783161484100');
    expect(isbnOf('ISBN 0-306-40615-2'), '0306406152');
    expect(isbnOf('080442957X'), '080442957X');
    expect(isbnOf('978-3-16-148410-1'), isNull); // wrong check digit
    expect(isbnOf('readtrack:work:12'), isNull);
    expect(isbnOf('https://example.com/123456789'), isNull);
  });

  test('form values replace the file\'s when importing', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final book = readEpub(buildEpub(exported));
    final id = await BookImporter(db, storage).store(
      book,
      work: BookImporter.metadataOf(book).copyWith(
        type: const Value(WorkType.fanfiction),
        title: const Value('War and Peace'),
        status: const Value(ReadingStatus.reading),
        chapterCount: const Value(null),
      ),
      fandomName: 'Russian Classics',
      tagNames: ['Historical'],
    );
    final w = (await db.watchWork(id).first)!;
    expect(
      (w.work.title, w.work.type, w.work.status, w.work.format),
      (
        'War and Peace',
        WorkType.fanfiction,
        ReadingStatus.reading,
        WorkFormat.digital,
      ),
    );
    expect(w.fandom?.name, 'Russian Classics');
    expect(w.tags.map((t) => t.name), ['Historical']);
    // Counts the form left empty come from the file.
    expect(w.work.chapterCount, 2);
    expect(w.work.wordCount, greaterThan(0));
    expect(await db.chaptersOf(id), hasLength(2));
  });

  test('splits a text file at chapter headings', () {
    const text =
        'My Story\n\nForeword line.\n\nChapter 1: Start\n\nFirst para.\n\nSecond para.\n\nГлава 2\nСтрока один.\nСтрока два.\n';
    final book = readTxt(utf8.encode(text), title: 'my-story');
    expect(book.chapters.map((c) => c.title), [
      'my-story',
      'Chapter 1: Start',
      'Глава 2',
    ]);
    expect(book.chapters[1].html, '<p>First para.</p><p>Second para.</p>');
    expect(book.chapters[2].html, '<p>Строка один.</p><p>Строка два.</p>');
  });

  test('splits an HTML file at second-level headings', () {
    final book = readHtmlBook(
      '<html><head><title>Book</title></head><body><h1>Book</h1><p>Intro.</p>'
      '<h2>One</h2><p>A.</p><img src="pic.png"><h2>Two</h2><p>B.</p></body></html>',
      title: 'file',
      loadImage: (path) => path == 'pic.png' ? Uint8List.fromList(png) : null,
    );
    expect(book.title, 'Book');
    expect(book.chapters.map((c) => c.title), ['Book', 'One', 'Two']);
    expect(book.images.values.single, png);
  });

  test(
    'importing stores chapters, images, cover, a copy and a download',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final file = File('${temp.path}/war-and-peace.epub')
        ..writeAsBytesSync(buildEpub(exported));

      final id = await BookImporter(db, storage).importFile(file.path);

      final work = (await db.watchWork(id).first)!;
      expect(
        (work.work.title, work.work.format, work.work.chapterCount),
        ('Война и мир', WorkFormat.digital, 2),
      );
      expect(File(work.work.coverPath!).readAsBytesSync(), png);
      final chapters = await db.chaptersOf(id);
      expect(chapters.map((c) => c.url), [null, null]);
      final image = RegExp(r'<img src="(images/[^"]+)"')
          .firstMatch(chapters.first.content!)!
          .group(1)!;
      expect(storage.resolve(id, image).readAsBytesSync(), png);

      final download = (await db.downloadsOf(id)).single;
      expect(
        (download.fromChapter, download.toChapter, download.format),
        (1, 2, 'epub'),
      );
      expect(download.filePath, endsWith('exports/war-and-peace.epub'));
      expect(File(download.filePath!).existsSync(), isTrue);
    },
  );

  test('unsupported or broken files give a clear error', () async {
    final bad = File('${temp.path}/x.epub')..writeAsStringSync('not a zip');
    expect(() => readBookFile(bad.path), throwsA(isA<ImportException>()));
    final other = File('${temp.path}/x.docx')..writeAsStringSync('');
    expect(() => readBookFile(other.path), throwsA(isA<ImportException>()));
  });
}
