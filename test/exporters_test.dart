import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/exporters.dart';
import 'package:readtrack/library/storage.dart';
import 'package:xml/xml.dart';

void main() {
  late Directory temp;
  late LibraryStorage storage;
  late ExportBook book;
  const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0];

  setUp(() {
    temp = Directory.systemTemp.createTempSync('readtrack_export');
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/books'),
      exportDir: Directory('${temp.path}/exports'),
    );
    final image = storage.resolve(1, 'images/map.png')
      ..createSync(recursive: true);
    image.writeAsBytesSync(png);
    final cover = File('${temp.path}/cover.png')..writeAsBytesSync(png);

    final work = Work(
      id: 1,
      type: WorkType.fanfiction,
      format: WorkFormat.online,
      title: 'Kingdom & Leaves',
      author: 'Some Author',
      summary: 'A <story> about Konoha.',
      sourceUrl: 'https://example.com/s/1',
      coverPath: cover.path,
      status: ReadingStatus.reading,
      isComplete: false,
      addedAt: DateTime(2026),
      updatedAt: DateTime(2026),
      newChapters: 0,
      wordsEstimated: false,
      pagesEstimated: false,
      ownsPhysicalCopy: false,
    );
    Chapter chapter(int n, String? html, {bool locked = false}) => Chapter(
      id: n,
      workId: 1,
      number: n,
      title: 'Chapter $n',
      content: html,
      isLocked: locked,
    );
    book = ExportBook(
      work: work,
      chapters: [
        chapter(
          1,
          '<p>Hello <em>Naruto</em> &amp; friends.<br>Second line.</p><hr><img src="images/map.png" alt="Map">',
        ),
        chapter(
          2,
          '<h3>Part</h3><blockquote><p>Quote</p></blockquote><ul><li>One</li></ul><img src="https://x.test/online.png" alt="Online">',
        ),
        chapter(3, null, locked: true),
      ],
      from: 1,
      to: 3,
      storage: storage,
      tags: ['Action', 'Marriage'],
      date: DateTime.utc(2026, 10, 23),
    );
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('EPUB is a valid package with chapters, cover and images', () {
    final archive = ZipDecoder().decodeBytes(buildEpub(book));
    final first = archive.files.first;
    expect(first.name, 'mimetype');
    expect(first.compression, CompressionType.none);
    expect(utf8.decode(first.content), 'application/epub+zip');

    String text(String name) => utf8.decode(archive.findFile(name)!.content);
    // Every XML/XHTML file must be well-formed for e-book readers.
    for (final f in archive.files) {
      if (RegExp(r'\.(xhtml|opf|ncx|xml)$').hasMatch(f.name)) {
        expect(
          () => XmlDocument.parse(utf8.decode(f.content)),
          returnsNormally,
          reason: f.name,
        );
      }
    }
    final opf = XmlDocument.parse(text('OEBPS/content.opf'));
    expect(
      opf.findAllElements('dc:title').single.innerText,
      'Kingdom & Leaves',
    );
    expect(opf.findAllElements('dc:subject').map((e) => e.innerText), [
      'Action',
      'Marriage',
    ]);
    expect(opf.findAllElements('itemref').length, 4); // title page + 3 chapters
    expect(archive.findFile('OEBPS/images/cover.png'), isNotNull);
    expect(archive.findFile('OEBPS/images/image-1.png'), isNotNull);

    final ch1 = text('OEBPS/chapter-1.xhtml');
    expect(ch1, contains('<em>Naruto</em> &amp; friends.<br/>Second line.'));
    expect(ch1, contains('<img src="images/image-1.png" alt="Map"/>'));
    // Online images can't be embedded; their description is kept instead.
    expect(text('OEBPS/chapter-2.xhtml'), contains('<p>[Online]</p>'));
    expect(text('OEBPS/chapter-3.xhtml'), contains('locked on the site'));
  });

  test('FB2 is well-formed with sections, markup and embedded images', () {
    final doc = XmlDocument.parse(buildFb2(book));
    expect(
      doc.findAllElements('book-title').single.innerText,
      'Kingdom & Leaves',
    );
    expect(doc.findAllElements('first-name').single.innerText, 'Some');
    expect(doc.findAllElements('section').length, 3);
    expect(doc.findAllElements('emphasis').single.innerText, 'Naruto');
    expect(doc.findAllElements('cite'), hasLength(1));
    expect(doc.findAllElements('subtitle').single.innerText, 'Part');
    final binaries = doc
        .findAllElements('binary')
        .map((b) => b.getAttribute('id'))
        .toList();
    expect(binaries, unorderedEquals(['img1.png', 'cover.png']));
    final image = doc
        .findAllElements('binary')
        .firstWhere((b) => b.getAttribute('id') == 'img1.png');
    expect(base64Decode(image.innerText), png);
    // A line break splits the paragraph.
    final paragraphs = doc
        .findAllElements('section')
        .first
        .findElements('p')
        .map((p) => p.innerText);
    expect(
      paragraphs,
      containsAll(['Hello Naruto & friends.', 'Second line.']),
    );
  });

  test('HTML is one page with a contents list and embedded images', () {
    final html = buildHtml(book);
    expect(html, contains('<title>Kingdom &amp; Leaves</title>'));
    expect(html, contains('<a href="#ch2">Chapter 2</a>'));
    expect(
      html,
      contains('src="data:image/png;base64,${base64Encode(png)}" alt="Map"'),
    );
    expect(html, contains('A &lt;story&gt; about Konoha.'));
  });

  test('writeExport writes each format to its file', () async {
    for (final format in ExportFormat.values) {
      final file = storage.exportFile(book.work.title, 1, 3, format.extension);
      await writeExport(format, book, file);
      expect(file.existsSync(), isTrue, reason: format.name);
      expect(file.path, endsWith('.${format.extension}'));
    }
  });

  test('formats round-trip through their stored name', () {
    for (final f in ExportFormat.values) {
      expect(ExportFormat.fromName(f.name), f);
    }
    expect(ExportFormat.fromName('unknown'), ExportFormat.txt);
  });
}
