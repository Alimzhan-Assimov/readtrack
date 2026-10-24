import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../data/enums.dart';
import '../sources/charsets.dart';
import '../sources/html_clean.dart';
import '../sources/source.dart' show parseHtml, squash, textOf;
import 'exporters.dart';

/// Images inside an imported book are addressed under this made-up host
/// while cleaning the HTML, then saved locally when the book is stored.
const kBookHost = 'book.local';

/// A book read from a local file.
class ImportedBook {
  ImportedBook({
    required this.title,
    required this.format,
    required this.chapters,
    this.author,
    this.summary,
    this.tags = const [],
    this.cover,
    this.images = const {},
    this.sourceUrl,
    this.isbn,
    this.isFanfiction = false,
    this.type,
    this.rightToLeft = false,
    this.fandom,
  });

  /// The category the file names, e.g. in a ReadTrack EPUB.
  final String? fandom;

  /// What the file says it is, e.g. manga for a CBZ; null for a book.
  final WorkType? type;

  /// Pages are read right to left (manga).
  final bool rightToLeft;

  /// Where the book came from, e.g. a ReadTrack export of a web story.
  final String? sourceUrl;
  final String? isbn;

  /// The file says it is fan fiction (FB2 genre "fanfiction").
  final bool isFanfiction;

  /// The same book with [url] as its source link, e.g. the catalog page it
  /// was downloaded from.
  ImportedBook withSource(String url) => ImportedBook(
    title: title,
    format: format,
    chapters: chapters,
    author: author,
    summary: summary,
    tags: tags,
    cover: cover,
    images: images,
    sourceUrl: url,
    isbn: isbn,
    isFanfiction: isFanfiction,
    type: type,
    rightToLeft: rightToLeft,
    fandom: fandom,
  );

  final String title;
  final String? author;
  final String? summary;
  final List<String> tags;
  final ExportFormat format;
  final Uint8List? cover;
  final List<({String title, String html})> chapters;

  /// Image bytes by the `https://book.local/…` address used in [chapters].
  final Map<String, Uint8List> images;
}

class ImportException implements Exception {
  ImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

const kImportExtensions = ['epub', 'fb2', 'zip', 'cbz', 'txt', 'html', 'htm'];

/// Reads an EPUB, FB2 (also zipped), TXT or HTML file.
Future<ImportedBook> readBookFile(String path) async {
  final bytes = await File(path).readAsBytes();
  final name = p.basenameWithoutExtension(path);
  final extension = p.extension(path).toLowerCase();
  return switch (extension) {
    '.epub' => readEpub(bytes),
    '.fb2' => readFb2(bytes),
    '.zip' => _readZippedFb2(bytes),
    '.cbz' => readCbz(bytes, title: name),
    '.txt' => readTxt(bytes, title: name),
    '.html' || '.htm' => readHtmlBook(
      decodeBody(bytes),
      title: name,
      loadImage: (relative) {
        final file = File(p.join(p.dirname(path), relative));
        return file.existsSync() ? file.readAsBytesSync() : null;
      },
    ),
    _ => throw ImportException(
      'Files of type "$extension" can\'t be imported.',
    ),
  };
}

ImportedBook _readZippedFb2(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final fb2 = archive.files
      .where((f) => f.name.toLowerCase().endsWith('.fb2'))
      .firstOrNull;
  if (fb2 == null) throw ImportException('This ZIP file contains no FB2 book.');
  return readFb2(fb2.content);
}

String _bookUrl(String path) => Uri.https(kBookHost, '/$path').toString();

/// Collects the images referenced by cleaned chapters.
Map<String, Uint8List> _referencedImages(
  Iterable<String> chapters,
  Uint8List? Function(String path) load,
) {
  final images = <String, Uint8List>{};
  for (final html in chapters) {
    for (final m in RegExp(
      '<img src="(https://$kBookHost/[^"]+)"',
    ).allMatches(html)) {
      final url = m.group(1)!.replaceAll('&amp;', '&');
      if (images.containsKey(url)) continue;
      final bytes = load(Uri.decodeComponent(Uri.parse(url).path.substring(1)));
      if (bytes != null) images[url] = bytes;
    }
  }
  return images;
}

// --- CBZ --------------------------------------------------------------------

const _imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};

/// A comic book archive: the images in natural order ("2" before "10"),
/// one chapter per folder (or one chapter for loose pages). ComicInfo.xml
/// fills in title, writer, summary, genres and the reading direction.
ImportedBook readCbz(List<int> bytes, {required String title}) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object {
    throw ImportException('This CBZ file is damaged or not a ZIP archive.');
  }
  final pages = [
    for (final f in archive.files)
      if (f.isFile &&
          _imageExtensions.contains(p.extension(f.name).toLowerCase()) &&
          !p.basename(f.name).startsWith('.') &&
          !f.name.startsWith('__MACOSX'))
        f,
  ]..sort((a, b) => naturalCompare(a.name, b.name));
  if (pages.isEmpty) throw ImportException('This CBZ file has no images.');

  final byFolder = <String, List<ArchiveFile>>{};
  for (final f in pages) {
    byFolder.putIfAbsent(p.posix.dirname(f.name), () => []).add(f);
  }
  final images = <String, Uint8List>{};
  final chapters = <({String title, String html})>[];
  for (final MapEntry(key: folder, value: files) in byFolder.entries) {
    final html = StringBuffer();
    for (final f in files) {
      final url = Uri.https(kBookHost, '/${Uri.encodeFull(f.name)}').toString();
      images[url] = f.readBytes()!;
      html.write('<p><img src="$url" alt=""></p>');
    }
    chapters.add((
      title: folder == '.' ? title : p.posix.basename(folder),
      html: '$html',
    ));
  }

  XmlElement? info;
  final infoFile = archive.findFile('ComicInfo.xml');
  if (infoFile != null) {
    try {
      info = XmlDocument.parse(
        utf8.decode(infoFile.readBytes()!, allowMalformed: true),
      ).rootElement;
    } on XmlException {
      // Pages without details.
    }
  }
  String? field(String name) {
    final v = info?.findElements(name).firstOrNull?.innerText.trim();
    return v == null || v.isEmpty ? null : v;
  }

  final manga = field('Manga');
  return ImportedBook(
    title: field('Title') ?? field('Series') ?? title,
    author: field('Writer'),
    summary: field('Summary'),
    tags: [
      for (final g in (field('Genre') ?? '').split(','))
        if (g.trim().isNotEmpty) g.trim(),
    ],
    format: ExportFormat.cbz,
    cover: pages.first.readBytes(),
    chapters: chapters,
    images: images,
    type: manga != null && manga.startsWith('Yes')
        ? WorkType.manga
        : WorkType.comic,
    rightToLeft: manga == 'YesAndRightToLeft',
  );
}

/// Compares names with numbers by their value: "page2" before "page10".
int naturalCompare(String a, String b) {
  final parts = RegExp(r'(\d+)|(\D+)');
  final x = parts.allMatches(a.toLowerCase()).toList();
  final y = parts.allMatches(b.toLowerCase()).toList();
  for (var i = 0; i < x.length && i < y.length; i++) {
    final (s, t) = (x[i].group(0)!, y[i].group(0)!);
    final (m, n) = (int.tryParse(s), int.tryParse(t));
    final c = m != null && n != null ? m.compareTo(n) : s.compareTo(t);
    if (c != 0) return c;
  }
  return x.length.compareTo(y.length);
}

// --- EPUB -------------------------------------------------------------------

ImportedBook readEpub(List<int> bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Exception {
    throw ImportException('This EPUB file is damaged.');
  }
  Uint8List? file(String path) {
    final entry = archive.findFile(path);
    return entry == null ? null : Uint8List.fromList(entry.content);
  }

  XmlDocument xml(String path) {
    final data = file(path);
    if (data == null) throw ImportException('The EPUB is missing "$path".');
    return XmlDocument.parse(utf8.decode(data, allowMalformed: true));
  }

  final container = xml('META-INF/container.xml');
  final opfPath = container
      .findAllElements('rootfile')
      .firstOrNull
      ?.getAttribute('full-path');
  if (opfPath == null) throw ImportException('The EPUB has no package file.');
  final opf = xml(opfPath);
  final base = p.posix.dirname(opfPath);
  String resolve(String href) => p.posix.normalize(
    p.posix.join(
      base == '.' ? '' : base,
      Uri.decodeComponent(href.split('#').first),
    ),
  );

  String? meta(String name) {
    final value = opf
        .findAllElements(name, namespaceUri: '*')
        .firstOrNull
        ?.innerText
        .trim();
    return value == null || value.isEmpty ? null : value;
  }

  final manifest = {
    for (final item in opf.findAllElements('item', namespaceUri: '*'))
      item.getAttribute('id') ?? '': item,
  };

  // The table of contents in reading order (EPUB 3 nav, else EPUB 2 NCX).
  // Entries may point into a file ("text.xhtml#chapter-11").
  final toc = <({String path, String? fragment, String title})>[];
  void addEntry(String fromFile, String href, String title) {
    final parts = href.split('#');
    final path = p.posix.normalize(
      p.posix.join(p.posix.dirname(fromFile), Uri.decodeComponent(parts.first)),
    );
    final fragment = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
    if (title.isNotEmpty) {
      toc.add((path: path, fragment: fragment, title: title));
    }
  }

  final navItem = manifest.values
      .where(
        (i) => (i.getAttribute('properties') ?? '').split(' ').contains('nav'),
      )
      .firstOrNull;
  final ncxItem = manifest.values
      .where((i) => i.getAttribute('media-type') == 'application/x-dtbncx+xml')
      .firstOrNull;
  final navPath = navItem == null
      ? null
      : resolve(navItem.getAttribute('href')!);
  final nav = navPath == null ? null : file(navPath);
  if (navPath != null && nav != null) {
    final navDoc = parseHtml(utf8.decode(nav, allowMalformed: true));
    final tocNav =
        navDoc
            .querySelectorAll('nav')
            .where((n) => n.attributes['epub:type'] == 'toc')
            .firstOrNull ??
        navDoc.querySelector('nav');
    for (final a in tocNav?.querySelectorAll('a[href]') ?? const []) {
      addEntry(navPath, a.attributes['href']!, squash(a.text));
    }
  } else if (ncxItem != null) {
    final ncxPath = resolve(ncxItem.getAttribute('href')!);
    for (final point in xml(
      ncxPath,
    ).findAllElements('navPoint', namespaceUri: '*')) {
      final src = point
          .findElements('content', namespaceUri: '*')
          .firstOrNull
          ?.getAttribute('src');
      final label = point
          .findElements('navLabel', namespaceUri: '*')
          .firstOrNull
          ?.innerText;
      if (src != null && label != null) addEntry(ncxPath, src, squash(label));
    }
  }
  final tocFiles = {for (final e in toc) e.path};

  final chapters = <({String title, String html})>[];
  void addChapter(String title, String html, String path) {
    final doc = parseHtml('<div>$html</div>').body!;
    // The heading is shown as the chapter title already.
    final heading = doc.querySelector('h1, h2, h3');
    if (heading != null && textOf(heading) == title) heading.remove();
    final cleaned = cleanHtml(doc, base: Uri.parse(_bookUrl(path)));
    final text = htmlToPlainText(cleaned).trim();
    if (text.isEmpty && !cleaned.contains('<img')) return;
    // Cover and title pages: short pages before the first chapter of the
    // table of contents.
    if (toc.isNotEmpty &&
        chapters.isEmpty &&
        !tocFiles.contains(path) &&
        countWords(text) < 300) {
      return;
    }
    chapters.add((title: title, html: cleaned));
  }

  for (final ref in opf.findAllElements('itemref', namespaceUri: '*')) {
    final item = manifest[ref.getAttribute('idref')];
    final href = item?.getAttribute('href');
    if (item == null || href == null) continue;
    if (!(item.getAttribute('media-type') ?? '').contains('html')) continue;
    if ((item.getAttribute('properties') ?? '').contains('nav')) continue;
    final path = resolve(href);
    final data = file(path);
    if (data == null) continue;
    final body = parseHtml(utf8.decode(data, allowMalformed: true)).body;
    if (body == null) continue;
    final source = body.innerHtml;
    final fallbackTitle = textOf(body.querySelector('h1, h2, h3'));

    // Split the file where table-of-contents entries point into it.
    final cuts = <({int at, String title})>[];
    for (final entry in toc.where(
      (e) => e.path == path && e.fragment != null,
    )) {
      final id = RegExp('id=["\']${RegExp.escape(entry.fragment!)}["\']')
          .firstMatch(source);
      if (id == null) continue;
      final at = source.lastIndexOf('<', id.start);
      if (at >= 0 && !cuts.any((c) => c.at == at)) {
        cuts.add((at: at, title: entry.title));
      }
    }
    cuts.sort((a, b) => a.at.compareTo(b.at));
    final wholeFileTitle = toc
        .where((e) => e.path == path && e.fragment == null)
        .firstOrNull
        ?.title;

    if (cuts.isEmpty) {
      addChapter(
        wholeFileTitle ?? fallbackTitle ?? 'Chapter ${chapters.length + 1}',
        source,
        path,
      );
      continue;
    }
    if (cuts.first.at > 0) {
      addChapter(
        wholeFileTitle ?? fallbackTitle ?? 'Chapter ${chapters.length + 1}',
        source.substring(0, cuts.first.at),
        path,
      );
    }
    for (var i = 0; i < cuts.length; i++) {
      final end = i + 1 < cuts.length ? cuts[i + 1].at : source.length;
      addChapter(cuts[i].title, source.substring(cuts[i].at, end), path);
    }
  }
  if (chapters.isEmpty) {
    throw ImportException('This EPUB contains no readable chapters.');
  }

  // Cover: EPUB 3 "cover-image" property or the EPUB 2 <meta name="cover">.
  final coverId = opf
      .findAllElements('meta', namespaceUri: '*')
      .where((m) => m.getAttribute('name') == 'cover')
      .firstOrNull
      ?.getAttribute('content');
  final coverItem =
      manifest.values
          .where(
            (i) => (i.getAttribute('properties') ?? '')
                .split(' ')
                .contains('cover-image'),
          )
          .firstOrNull ??
      manifest[coverId];

  final description = meta('description');
  final creators = [
    for (final c in opf.findAllElements('creator', namespaceUri: '*'))
      if (squash(c.innerText) case final name when name.isNotEmpty) name,
  ];
  final identifiers = [
    for (final e in [
      ...opf.findAllElements('identifier', namespaceUri: '*'),
      ...opf.findAllElements('source', namespaceUri: '*'),
    ])
      e.innerText.trim(),
  ];
  final fandom = opf
      .findAllElements('meta', namespaceUri: '*')
      .where((m) => m.getAttribute('name') == 'readtrack:fandom')
      .map((m) => m.getAttribute('content')?.trim() ?? '')
      .where((f) => f.isNotEmpty)
      .firstOrNull;
  return ImportedBook(
    title: meta('title') ?? 'Untitled',
    fandom: fandom,
    sourceUrl: identifiers.where(_isWebLink).firstOrNull,
    isbn: identifiers.map(isbnOf).nonNulls.firstOrNull,
    author: creators.isEmpty ? null : creators.join(', '),
    // Descriptions are often HTML.
    summary: description == null
        ? null
        : squash(parseHtml(description).body?.text ?? description),
    tags: [
      for (final s in opf.findAllElements('subject', namespaceUri: '*'))
        squash(s.innerText),
    ],
    format: ExportFormat.epub,
    cover: coverItem == null
        ? null
        : file(resolve(coverItem.getAttribute('href')!)),
    chapters: chapters,
    images: _referencedImages(chapters.map((c) => c.html), file),
  );
}

// --- FB2 --------------------------------------------------------------------

ImportedBook readFb2(List<int> bytes) {
  // The XML declaration names the encoding; Russian books often use
  // Windows-1251.
  final head = latin1.decode(bytes.take(200).toList(), allowInvalid: true);
  final encoding = RegExp(r'''encoding=["']([\w-]+)["']''')
      .firstMatch(head)
      ?.group(1);
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(decodeCharset(bytes, encoding));
  } on XmlException catch (e) {
    throw ImportException('This FB2 file is damaged: ${e.message}');
  }
  final info = doc.findAllElements('title-info', namespaceUri: '*').firstOrNull;
  String? text(XmlElement? parent, String name) {
    final value = parent
        ?.findElements(name, namespaceUri: '*')
        .firstOrNull
        ?.innerText
        .trim();
    return value == null || value.isEmpty ? null : squash(value);
  }

  String? authorName(XmlElement a) {
    final full = [
      text(a, 'first-name'),
      text(a, 'middle-name'),
      text(a, 'last-name'),
    ].nonNulls.join(' ');
    return full.isEmpty ? text(a, 'nickname') : full;
  }

  final authors = [
    for (final a
        in info?.findElements('author', namespaceUri: '*') ??
            const <XmlElement>[])
      ?authorName(a),
  ];

  final binaries = <String, Uint8List>{
    for (final b in doc.findAllElements('binary', namespaceUri: '*'))
      ?b.getAttribute('id'): base64Decode(
        b.innerText.replaceAll(RegExp(r'\s+'), ''),
      ),
  };
  String? href(XmlElement image) =>
      (image.getAttribute('l:href') ??
              image.getAttribute('xlink:href') ??
              image.attributes
                  .where((a) => a.localName == 'href')
                  .firstOrNull
                  ?.value)
          ?.replaceFirst('#', '');

  final coverImage = info
      ?.findElements('coverpage', namespaceUri: '*')
      .firstOrNull
      ?.findElements('image', namespaceUri: '*')
      .firstOrNull;

  final body = doc
      .findAllElements('body', namespaceUri: '*')
      .where((b) => b.getAttribute('name') != 'notes')
      .firstOrNull;
  if (body == null) throw ImportException('This FB2 file has no text.');

  final chapters = <({String title, String html})>[];
  void addChapter(String title, Iterable<XmlNode> nodes) {
    final html = cleanHtml(
      parseHtml('<div>${nodes.map(_fb2Html).join()}</div>').body!,
      base: Uri.https(kBookHost, '/'),
    );
    if (htmlToPlainText(html).trim().isNotEmpty || html.contains('<img')) {
      chapters.add((title: title, html: html));
    }
  }

  // A section with its own text is a chapter; sections that only group
  // others (parts, volumes) are walked through.
  void walk(XmlElement section, String? parentTitle) {
    final title = section
        .findElements('title', namespaceUri: '*')
        .firstOrNull
        ?.innerText
        .trim();
    final name = title == null || title.isEmpty ? null : squash(title);
    final content = section.children.where(
      (n) =>
          n is XmlElement && n.localName != 'section' && n.localName != 'title',
    );
    final subsections = section
        .findElements('section', namespaceUri: '*')
        .toList();
    if (content.any(
      (n) =>
          n is XmlElement && n.innerText.trim().isNotEmpty ||
          n is XmlElement && n.localName == 'image',
    )) {
      addChapter(
        name ?? parentTitle ?? 'Chapter ${chapters.length + 1}',
        content,
      );
    }
    for (final sub in subsections) {
      walk(sub, name ?? parentTitle);
    }
  }

  final sections = body.findElements('section', namespaceUri: '*').toList();
  if (sections.isEmpty) {
    addChapter(text(info, 'book-title') ?? 'Text', body.children);
  } else {
    for (final section in sections) {
      walk(section, null);
    }
  }
  if (chapters.isEmpty) {
    throw ImportException('This FB2 file has no readable text.');
  }

  final annotation = info
      ?.findElements('annotation', namespaceUri: '*')
      .firstOrNull;
  final keywords = text(info, 'keywords');
  final documentInfo = doc
      .findAllElements('document-info', namespaceUri: '*')
      .firstOrNull;
  final publishInfo = doc
      .findAllElements('publish-info', namespaceUri: '*')
      .firstOrNull;
  final sourceUrl = text(documentInfo, 'src-url');
  return ImportedBook(
    title: text(info, 'book-title') ?? 'Untitled',
    sourceUrl: sourceUrl != null && _isWebLink(sourceUrl) ? sourceUrl : null,
    isbn: isbnOf(text(publishInfo, 'isbn') ?? ''),
    isFanfiction:
        info
            ?.findElements('genre', namespaceUri: '*')
            .any((g) => g.innerText.trim().toLowerCase() == 'fanfiction') ??
        false,
    author: authors.isEmpty ? null : authors.join(', '),
    summary: annotation == null ? null : _annotation(annotation),
    tags: keywords == null
        ? const []
        : [
            for (final k in keywords.split(','))
              if (k.trim().isNotEmpty) k.trim(),
          ],
    format: ExportFormat.fb2,
    cover: coverImage == null ? null : binaries[href(coverImage)],
    chapters: chapters,
    images: {
      for (final MapEntry(key: id, value: data) in binaries.entries)
        Uri.https(kBookHost, '/binary/$id').toString(): data,
    },
  );
}

bool _isWebLink(String text) =>
    RegExp(r'^https?://\S+$', caseSensitive: false).hasMatch(text);

/// The ISBN-10 or ISBN-13 in [text] ("urn:isbn:978-…", "ISBN 0-306-…"),
/// digits only, or null.
String? isbnOf(String text) {
  final match = RegExp(
    r'(?:isbn[:\s]*)?((?:97[89][-\s]?)?\d[-\s\d]{7,15}[\dXx])',
    caseSensitive: false,
  ).firstMatch(text.trim());
  if (match == null) return null;
  final digits = match.group(1)!.replaceAll(RegExp(r'[-\s]'), '');
  if (digits.length != 10 && digits.length != 13) return null;
  if (digits.length == 13 && !RegExp(r'^\d+$').hasMatch(digits)) return null;
  final ok = digits.length == 13
      ? [for (var i = 0; i < 13; i++) int.parse(digits[i]) * (i.isEven ? 1 : 3)]
                    .reduce((a, b) => a + b) %
                10 ==
            0
      : [
                  for (var i = 0; i < 10; i++)
                    (digits[i].toUpperCase() == 'X'
                            ? 10
                            : int.parse(digits[i])) *
                        (10 - i),
                ].reduce((a, b) => a + b) %
                11 ==
            0;
  return ok ? digits.toUpperCase() : null;
}

String? _annotation(XmlElement annotation) {
  final paragraphs = [
    for (final para in annotation.findAllElements('p', namespaceUri: '*'))
      if (squash(para.innerText) case final t when t.isNotEmpty) t,
  ];
  final text = paragraphs.isEmpty
      ? squash(annotation.innerText)
      : paragraphs.join('\n');
  return text.isEmpty ? null : text;
}

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

/// FB2 markup as the HTML subset the cleaner understands.
String _fb2Html(XmlNode node) {
  if (node is XmlText) return _escape(node.value);
  if (node is! XmlElement) return '';
  final inner = node.children.map(_fb2Html).join();
  return switch (node.localName) {
    'p' || 'v' || 'text-author' => '<p>$inner</p>',
    'emphasis' => '<em>$inner</em>',
    'strong' => '<strong>$inner</strong>',
    'strikethrough' => '<s>$inner</s>',
    'sup' => '<sup>$inner</sup>',
    'sub' => '<sub>$inner</sub>',
    'subtitle' => '<h3>$inner</h3>',
    'title' => '<h3>$inner</h3>',
    'epigraph' || 'cite' => '<blockquote>$inner</blockquote>',
    'poem' || 'stanza' => '<div>$inner</div>',
    'empty-line' => '<br><br>',
    'image' => switch ((node.getAttribute('l:href') ??
            node.attributes
                .where((a) => a.localName == 'href')
                .firstOrNull
                ?.value)
        ?.replaceFirst('#', '')) {
      final id? =>
        '<img src="https://$kBookHost/binary/${Uri.encodeComponent(id)}">',
      null => '',
    },
    // Footnote links: keep the marker text.
    'a' => '<sup>$inner</sup>',
    'tr' =>
      '<p>${node.children.whereType<XmlElement>().map((c) => c.innerText.trim()).join(' | ')}</p>',
    _ => inner,
  };
}

// --- TXT --------------------------------------------------------------------

/// Lines that start a chapter in plain-text books.
final _chapterHeading = RegExp(
  r'^\s*(chapter|part|book|prologue|epilogue|interlude|глава|часть|книга|пролог|эпилог)(?![\p{L}\p{N}]).{0,80}$',
  caseSensitive: false,
  unicode: true,
);

ImportedBook readTxt(List<int> bytes, {required String title}) {
  // Plain text has no declared encoding: UTF-8 unless it isn't valid.
  String text;
  try {
    text = utf8.decode(bytes);
  } on FormatException {
    text = decodeCharset(bytes, 'windows-1251');
  }
  text = text.replaceAll('\r\n', '\n').replaceFirst('﻿', '');
  final lines = text.split('\n');
  final starts = [
    for (final (i, line) in lines.indexed)
      if (line.trim().length < 100 && _chapterHeading.hasMatch(line)) i,
  ];

  String paragraphs(Iterable<String> part) {
    final block = part.join('\n').trim();
    // Blank lines separate paragraphs; without any, each line is one.
    final pieces = block.contains(RegExp(r'\n\s*\n'))
        ? block.split(RegExp(r'\n\s*\n'))
        : block.split('\n');
    return [
      for (final piece in pieces)
        if (piece.trim().isNotEmpty)
          '<p>${_escape(piece.trim()).replaceAll('\n', '<br>')}</p>',
    ].join();
  }

  final chapters = <({String title, String html})>[];
  if (starts.length >= 2) {
    final front = paragraphs(lines.take(starts.first));
    if (front.isNotEmpty) chapters.add((title: title, html: front));
    for (var i = 0; i < starts.length; i++) {
      final end = i + 1 < starts.length ? starts[i + 1] : lines.length;
      chapters.add((
        title: squash(lines[starts[i]]),
        html: paragraphs(lines.sublist(starts[i] + 1, end)),
      ));
    }
  } else {
    chapters.add((title: title, html: paragraphs(lines)));
  }
  if (chapters.every((c) => c.html.isEmpty)) {
    throw ImportException('This text file is empty.');
  }
  return ImportedBook(
    title: title,
    format: ExportFormat.txt,
    chapters: chapters,
  );
}

// --- HTML -------------------------------------------------------------------

ImportedBook readHtmlBook(
  String html, {
  required String title,
  required Uint8List? Function(String relativePath) loadImage,
}) {
  final doc = parseHtml(html);
  final body = doc.body;
  if (body == null) throw ImportException('This HTML file has no content.');
  final name =
      textOf(doc.querySelector('title')) ??
      textOf(doc.querySelector('h1')) ??
      title;
  doc.querySelector('h1')?.remove();
  // Split at second-level headings, like most single-page books.
  final headings = body.querySelectorAll('h2');
  final chapters = <({String title, String html})>[];
  final base = Uri.https(kBookHost, '/');
  if (headings.length < 2) {
    chapters.add((title: name, html: cleanHtml(body, base: base)));
  } else {
    final source = body.innerHtml;
    final positions = [
      for (final m in RegExp(
        r'<h2[^>]*>(.*?)</h2>',
        dotAll: true,
      ).allMatches(source))
        m,
    ];
    final front = source.substring(0, positions.first.start);
    final frontHtml = cleanHtml(
      parseHtml('<div>$front</div>').body!,
      base: base,
    );
    if (htmlToPlainText(frontHtml).trim().isNotEmpty) {
      chapters.add((title: name, html: frontHtml));
    }
    for (var i = 0; i < positions.length; i++) {
      final end = i + 1 < positions.length
          ? positions[i + 1].start
          : source.length;
      final chunk = source.substring(positions[i].end, end);
      chapters.add((
        title: squash(
          parseHtml(positions[i].group(1)!).body?.text ?? 'Chapter ${i + 1}',
        ),
        html: cleanHtml(parseHtml('<div>$chunk</div>').body!, base: base),
      ));
    }
  }
  return ImportedBook(
    title: name,
    format: ExportFormat.html,
    chapters: chapters,
    images: _referencedImages(chapters.map((c) => c.html), loadImage),
  );
}
