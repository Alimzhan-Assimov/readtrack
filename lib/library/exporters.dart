import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../data/database.dart';
import 'storage.dart';
import 'txt_export.dart';

/// File formats a download can be saved in.
enum ExportFormat {
  txt('TXT', 'txt'),
  epub('EPUB', 'epub'),
  fb2('FB2', 'fb2'),
  html('HTML', 'html'),

  /// Comic book archive: only the images, for manga and comics.
  cbz('CBZ', 'cbz');

  const ExportFormat(this.label, this.extension);
  final String label;
  final String extension;

  static ExportFormat fromName(String name) =>
      values.firstWhere((f) => f.name == name, orElse: () => txt);

  /// The formats that suit a work of [type]: CBZ only for manga and comics.
  static List<ExportFormat> forType(WorkType type) => [
    for (final f in values)
      if (f != cbz || type == WorkType.manga || type == WorkType.comic) f,
  ];
}

/// Everything an exporter needs about the book.
class ExportBook {
  ExportBook({
    required this.work,
    required this.chapters,
    required this.from,
    required this.to,
    required this.storage,
    this.tags = const [],
    this.withImages = true,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  /// False leaves every chapter image out of the file.
  final bool withImages;

  final Work work;
  final List<Chapter> chapters;
  final int from;
  final int to;
  final LibraryStorage storage;
  final List<String> tags;
  final DateTime date;

  List<Chapter> get inRange => [
    for (final c in chapters)
      if (c.number >= from && c.number <= to)
        withImages || c.content == null
            ? c
            : c.copyWith(content: Value(withoutImages(c.content!))),
  ];

  String get rangeLabel => from == to ? 'Chapter $from' : 'Chapters $from–$to';

  /// "ru" when the title or summary is mostly Cyrillic, otherwise "en".
  String get language {
    final sample = '${work.title} ${work.summary ?? ''}';
    final cyrillic = RegExp(r'[А-Яа-яЁё]').allMatches(sample).length;
    final latin = RegExp(r'[A-Za-z]').allMatches(sample).length;
    return cyrillic > latin ? 'ru' : 'en';
  }

  String chapterTitle(Chapter c) => c.title ?? 'Chapter ${c.number}';

  /// The chapter text, or a note when it is missing.
  String chapterHtml(Chapter c) =>
      c.content ??
      (c.isLocked
          ? '<p>[This chapter is locked on the site.]</p>'
          : '<p>[This chapter could not be downloaded.]</p>');

  /// Bytes of a downloaded image referenced from chapter HTML, or null for
  /// online images (they are left out of offline files).
  Uint8List? imageBytes(String src) {
    if (src.startsWith('http')) return null;
    final file = storage.resolve(work.id, src);
    return file.existsSync() ? file.readAsBytesSync() : null;
  }

  Uint8List? coverBytes() {
    final path = work.coverPath;
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file.readAsBytesSync() : null;
  }
}

Future<void> writeExport(
  ExportFormat format,
  ExportBook book,
  File file,
) async {
  await file.parent.create(recursive: true);
  switch (format) {
    case ExportFormat.txt:
      await file.writeAsString(
        buildTxt(
          work: book.work,
          chapters: book.chapters,
          from: book.from,
          to: book.to,
          now: book.date,
        ),
      );
    case ExportFormat.html:
      await file.writeAsString(buildHtml(book));
    case ExportFormat.epub:
      await file.writeAsBytes(buildEpub(book));
    case ExportFormat.fb2:
      await file.writeAsString(buildFb2(book));
    case ExportFormat.cbz:
      await file.writeAsBytes(buildCbz(book));
  }
}

/// The downloaded images of the chapters in order, as a CBZ: one folder per
/// chapter, pages numbered so readers sort them right. Text is left out.
List<int> buildCbz(ExportBook book) {
  final archive = Archive();
  final chapters = book.inRange;
  final width = '${chapters.length}'.length;
  for (final (i, c) in chapters.indexed) {
    final folder =
        '${'${i + 1}'.padLeft(width, '0')} ${book.chapterTitle(c).replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}';
    var page = 0;
    for (final m in RegExp(
      r'<img[^>]+src="([^"]+)"',
    ).allMatches(c.content ?? '')) {
      final bytes = book.imageBytes(m.group(1)!);
      if (bytes == null) continue;
      final name = '${'${++page}'.padLeft(3, '0')}.${_extensionOf(bytes)}';
      archive.addFile(ArchiveFile('$folder/$name', bytes.length, bytes));
    }
  }
  return ZipEncoder().encode(archive);
}

String _extensionOf(Uint8List bytes) => switch (_mime(bytes)) {
  'image/png' => 'png',
  'image/gif' => 'gif',
  'image/webp' => 'webp',
  _ => 'jpg',
};

String _xml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _mime(Uint8List bytes) {
  if (bytes.length > 3 && bytes[0] == 0x89 && bytes[1] == 0x50) {
    return 'image/png';
  }
  if (bytes.length > 3 && bytes[0] == 0x47 && bytes[1] == 0x49) {
    return 'image/gif';
  }
  if (bytes.length > 12 && bytes[8] == 0x57 && bytes[9] == 0x45) {
    return 'image/webp';
  }
  return 'image/jpeg';
}

String _imageExtension(String mime) => switch (mime) {
  'image/png' => 'png',
  'image/gif' => 'gif',
  'image/webp' => 'webp',
  _ => 'jpg',
};

/// Cleaned chapter HTML as well-formed XHTML; images are passed to
/// [image], which returns the new `src` or null to drop the image.
String _toXhtml(String html, String? Function(String src, String? alt) image) {
  final root = html_parser.parseFragment(html);
  final out = StringBuffer();
  void walk(dom.Node node) {
    for (final child in node.nodes) {
      if (child is dom.Text) {
        out.write(_xml(child.text));
      } else if (child is dom.Element) {
        final tag = child.localName!;
        switch (tag) {
          case 'br' || 'hr':
            out.write('<$tag/>');
          case 'img':
            final alt = child.attributes['alt'];
            final src = image(child.attributes['src'] ?? '', alt);
            if (src != null) {
              out.write('<img src="${_xml(src)}" alt="${_xml(alt ?? '')}"/>');
            } else if (alt != null) {
              out.write('<p>[${_xml(alt)}]</p>');
            }
          default:
            out.write('<$tag>');
            walk(child);
            out.write('</$tag>');
        }
      }
    }
  }

  walk(root);
  return out.toString();
}

/// A single self-contained HTML page; downloaded images are embedded.
String buildHtml(ExportBook book) {
  final w = book.work;
  final out = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="${book.language}"><head><meta charset="utf-8">')
    ..writeln(
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
    )
    ..writeln('<title>${_xml(w.title)}</title>')
    ..writeln(
      '<style>body{max-width:42em;margin:2em auto;padding:0 1em;font-family:Georgia,serif;'
      'line-height:1.6}img{max-width:100%}nav li{margin:.2em 0}h2{margin-top:2.5em}</style>',
    )
    ..writeln('</head><body>')
    ..writeln('<h1>${_xml(w.title)}</h1>');
  if (w.author != null) out.writeln('<p><em>${_xml(w.author!)}</em></p>');
  final cover = book.coverBytes();
  if (cover != null) {
    out.writeln(
      '<p><img src="data:${_mime(cover)};base64,${base64Encode(cover)}" alt="Cover"></p>',
    );
  }
  if (w.summary != null) {
    out.writeln('<p>${_xml(w.summary!).replaceAll('\n', '<br>')}</p>');
  }
  out.writeln(
    '<p><small>${book.rangeLabel}${w.sourceUrl == null ? '' : ' · ${_xml(w.sourceUrl!)}'}</small></p>',
  );
  out.writeln('<nav><ol>');
  for (final c in book.inRange) {
    out.writeln(
      '<li><a href="#ch${c.number}">${_xml(book.chapterTitle(c))}</a></li>',
    );
  }
  out.writeln('</ol></nav>');
  for (final c in book.inRange) {
    out
      ..writeln(
        '<section id="ch${c.number}"><h2>${_xml(book.chapterTitle(c))}</h2>',
      )
      ..writeln(
        _toXhtml(book.chapterHtml(c), (src, alt) {
          final bytes = book.imageBytes(src);
          return bytes == null
              ? null
              : 'data:${_mime(bytes)};base64,${base64Encode(bytes)}';
        }),
      )
      ..writeln('</section>');
  }
  out.writeln('</body></html>');
  return out.toString();
}

/// An EPUB 3 book (with an EPUB 2 table of contents for older readers).
List<int> buildEpub(ExportBook book) {
  final w = book.work;
  final archive = Archive();
  void add(String name, List<int> bytes, {bool compress = true}) {
    final file = ArchiveFile.bytes(name, bytes);
    if (!compress) file.compression = CompressionType.none;
    archive.addFile(file);
  }

  void addText(String name, String text) => add(name, utf8.encode(text));

  // The mimetype must come first and stay uncompressed.
  add('mimetype', ascii.encode('application/epub+zip'), compress: false);
  addText(
    'META-INF/container.xml',
    '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
        '<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>'
        '</rootfiles></container>',
  );

  final manifest = StringBuffer();
  final spine = StringBuffer();
  final images = <String, String>{}; // src -> file name in the book
  var imageCount = 0;

  final cover = book.coverBytes();
  String? coverName;
  if (cover != null) {
    final mime = _mime(cover);
    coverName = 'images/cover.${_imageExtension(mime)}';
    add('OEBPS/$coverName', cover);
    manifest.writeln(
      '<item id="cover-image" href="$coverName" media-type="$mime" properties="cover-image"/>',
    );
  }

  String page(String title, String body) =>
      '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE html>\n'
      '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" '
      'lang="${book.language}" xml:lang="${book.language}">'
      '<head><meta charset="utf-8"/><title>${_xml(title)}</title>'
      '<link rel="stylesheet" href="style.css" type="text/css"/></head><body>$body</body></html>';

  addText(
    'OEBPS/style.css',
    'body{line-height:1.5}img{max-width:100%}h1,h2{text-align:center}',
  );
  manifest.writeln('<item id="css" href="style.css" media-type="text/css"/>');

  final titleBody = StringBuffer('<h1>${_xml(w.title)}</h1>');
  if (w.author != null) {
    titleBody.write(
      '<p style="text-align:center"><em>${_xml(w.author!)}</em></p>',
    );
  }
  if (coverName != null) {
    titleBody.write('<p><img src="$coverName" alt="Cover"/></p>');
  }
  if (w.summary != null) {
    for (final line in w.summary!.split(RegExp(r'\n+'))) {
      titleBody.write('<p>${_xml(line)}</p>');
    }
  }
  titleBody.write('<p><small>${_xml(book.rangeLabel)}</small></p>');
  addText('OEBPS/title.xhtml', page(w.title, titleBody.toString()));
  manifest.writeln(
    '<item id="title" href="title.xhtml" media-type="application/xhtml+xml"/>',
  );
  spine.writeln('<itemref idref="title"/>');

  final nav = StringBuffer();
  final ncx = StringBuffer();
  for (final (i, c) in book.inRange.indexed) {
    final name = 'chapter-${c.number}.xhtml';
    final title = book.chapterTitle(c);
    final body = _toXhtml(book.chapterHtml(c), (src, alt) {
      final known = images[src];
      if (known != null) return known;
      final bytes = book.imageBytes(src);
      if (bytes == null) return null;
      final mime = _mime(bytes);
      final imageName = 'images/image-${++imageCount}.${_imageExtension(mime)}';
      add('OEBPS/$imageName', bytes);
      manifest.writeln(
        '<item id="img$imageCount" href="$imageName" media-type="$mime"/>',
      );
      return images[src] = imageName;
    });
    addText('OEBPS/$name', page(title, '<h2>${_xml(title)}</h2>$body'));
    manifest.writeln(
      '<item id="ch${c.number}" href="$name" media-type="application/xhtml+xml"/>',
    );
    spine.writeln('<itemref idref="ch${c.number}"/>');
    nav.writeln('<li><a href="$name">${_xml(title)}</a></li>');
    ncx.writeln(
      '<navPoint id="np${i + 1}" playOrder="${i + 1}"><navLabel><text>${_xml(title)}</text></navLabel>'
      '<content src="$name"/></navPoint>',
    );
  }

  addText(
    'OEBPS/nav.xhtml',
    page(
      'Contents',
      '<nav epub:type="toc"><h1>Contents</h1><ol>$nav</ol></nav>',
    ),
  );
  manifest.writeln(
    '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
  );
  final identifier = w.sourceUrl ?? 'readtrack:work:${w.id}';
  addText(
    'OEBPS/toc.ncx',
    '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">'
        '<head><meta name="dtb:uid" content="${_xml(identifier)}"/></head>'
        '<docTitle><text>${_xml(w.title)}</text></docTitle><navMap>$ncx</navMap></ncx>',
  );
  manifest.writeln(
    '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>',
  );

  final modified = '${book.date.toUtc().toIso8601String().substring(0, 19)}Z';
  addText(
    'OEBPS/content.opf',
    '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid">'
        '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
        '<dc:identifier id="bookid">${_xml(identifier)}</dc:identifier>'
        '<dc:title>${_xml(w.title)}</dc:title>'
        '${w.author == null ? '' : '<dc:creator>${_xml(w.author!)}</dc:creator>'}'
        '<dc:language>${book.language}</dc:language>'
        '${w.summary == null ? '' : '<dc:description>${_xml(w.summary!)}</dc:description>'}'
        '${[for (final t in book.tags) '<dc:subject>${_xml(t)}</dc:subject>'].join()}'
        '<meta property="dcterms:modified">$modified</meta>'
        '${coverName == null ? '' : '<meta name="cover" content="cover-image"/>'}'
        '</metadata><manifest>$manifest</manifest><spine toc="ncx">$spine</spine></package>',
  );
  return ZipEncoder().encode(archive);
}

/// A FictionBook 2 file; downloaded images are embedded as binaries.
String buildFb2(ExportBook book) {
  final w = book.work;
  final binaries = StringBuffer();
  final images = <String, String>{}; // src -> binary id
  var imageCount = 0;

  String? imageId(String src) {
    final known = images[src];
    if (known != null) return known;
    final bytes = book.imageBytes(src);
    if (bytes == null) return null;
    final mime = _mime(bytes);
    final id = 'img${++imageCount}.${_imageExtension(mime)}';
    binaries.writeln(
      '<binary id="$id" content-type="$mime">${base64Encode(bytes)}</binary>',
    );
    return images[src] = id;
  }

  // FB2 paragraphs hold only inline markup, so line breaks split them.
  String inline(dom.Node node) {
    final out = StringBuffer();
    for (final child in node.nodes) {
      if (child is dom.Text) {
        out.write(_xml(child.text));
      } else if (child is dom.Element) {
        final inner = inline(child);
        out.write(switch (child.localName) {
          'em' => '<emphasis>$inner</emphasis>',
          'strong' => '<strong>$inner</strong>',
          's' => '<strikethrough>$inner</strikethrough>',
          'sup' => '<sup>$inner</sup>',
          'sub' => '<sub>$inner</sub>',
          'br' => '</p><p>',
          'img' => '',
          _ => inner,
        });
      }
    }
    return out.toString();
  }

  String blocks(String html) {
    final out = StringBuffer();
    void walk(dom.Node node) {
      for (final child in node.nodes) {
        if (child is dom.Text) {
          if (child.text.trim().isNotEmpty) {
            out.write('<p>${_xml(child.text.trim())}</p>');
          }
          continue;
        }
        if (child is! dom.Element) continue;
        switch (child.localName) {
          case 'p':
            for (final img in child.querySelectorAll('img')) {
              if (imageId(img.attributes['src'] ?? '') case final id?) {
                out.write('<image l:href="#$id"/>');
              }
            }
            final text = inline(child).replaceAll('<p></p>', '');
            if (text.trim().isNotEmpty) out.write('<p>$text</p>');
          case 'h2' || 'h3':
            out.write('<subtitle>${inline(child)}</subtitle>');
          case 'hr':
            out.write('<empty-line/>');
          case 'img':
            if (imageId(child.attributes['src'] ?? '') case final id?) {
              out.write('<image l:href="#$id"/>');
            } else if (child.attributes['alt'] case final alt?) {
              out.write('<p>[${_xml(alt)}]</p>');
            }
          case 'blockquote':
            out.write('<cite>');
            walk(child);
            out.write('</cite>');
          case 'ul' || 'ol':
            var n = 0;
            for (final li in child.children.where((e) => e.localName == 'li')) {
              n++;
              final marker = child.localName == 'ol' ? '$n.' : '•';
              out.write('<p>$marker ${inline(li)}</p>');
            }
          default:
            walk(child);
        }
      }
    }

    walk(html_parser.parseFragment(html));
    final text = out.toString();
    return text.isEmpty ? '<empty-line/>' : text;
  }

  final author = (w.author ?? 'Unknown').trim();
  final names = author.split(RegExp(r'\s+'));
  final authorXml = names.length >= 2
      ? '<first-name>${_xml(names.first)}</first-name><last-name>${_xml(names.skip(1).join(' '))}</last-name>'
      : '<nickname>${_xml(author)}</nickname>';
  final cover = book.coverBytes();
  String? coverId;
  if (cover != null) {
    final mime = _mime(cover);
    coverId = 'cover.${_imageExtension(mime)}';
    binaries.writeln(
      '<binary id="$coverId" content-type="$mime">${base64Encode(cover)}</binary>',
    );
  }

  final body = StringBuffer();
  for (final c in book.inRange) {
    body.writeln(
      '<section><title><p>${_xml(book.chapterTitle(c))}</p></title>${blocks(book.chapterHtml(c))}</section>',
    );
  }
  final date = book.date.toIso8601String().substring(0, 10);
  return '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<FictionBook xmlns="http://www.gribuser.ru/xml/fictionbook/2.0" '
      'xmlns:l="http://www.w3.org/1999/xlink">'
      '<description><title-info>'
      '<genre>${w.type == WorkType.fanfiction ? 'fanfiction' : 'prose_contemporary'}</genre>'
      '<author>$authorXml</author>'
      '<book-title>${_xml(w.title)}</book-title>'
      '${w.summary == null ? '' : '<annotation>${[for (final line in w.summary!.split(RegExp(r'\n+'))) '<p>${_xml(line)}</p>'].join()}</annotation>'}'
      '${book.tags.isEmpty ? '' : '<keywords>${_xml(book.tags.join(', '))}</keywords>'}'
      '<lang>${book.language}</lang>'
      '${coverId == null ? '' : '<coverpage><image l:href="#$coverId"/></coverpage>'}'
      '</title-info><document-info><author><nickname>ReadTrack</nickname></author>'
      '<program-used>ReadTrack</program-used><date value="$date">$date</date>'
      '${w.sourceUrl == null ? '' : '<src-url>${_xml(w.sourceUrl!)}</src-url>'}'
      '<id>${_xml(w.sourceUrl ?? 'readtrack-${w.id}')}</id><version>1.0</version></document-info>'
      '</description><body><title><p>${_xml(w.title)}</p></title>$body</body>$binaries</FictionBook>\n';
}

/// [html] with its images (and the figures or links that only held them)
/// removed.
String withoutImages(String html) => html
    .replaceAll(RegExp(r'<img\b[^>]*>', caseSensitive: false), '')
    .replaceAll(
      RegExp(
        r'<(figure|a)\b[^>]*>\s*(<figcaption>.*?</figcaption>\s*)?</\1>',
        caseSensitive: false,
        dotAll: true,
      ),
      '',
    );
