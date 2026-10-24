import 'dart:async';
import 'dart:convert';

import 'package:xml/xml.dart';

import 'fetcher.dart';

/// What a book catalog knows about an ISBN.
class BookDetails {
  const BookDetails({
    required this.isbn,
    required this.title,
    this.author,
    this.summary,
    this.pageCount,
    this.coverUrl,
    this.tags = const [],
  });

  final String isbn;
  final String title;
  final String? author;
  final String? summary;
  final int? pageCount;
  final Uri? coverUrl;
  final List<String> tags;
}

typedef _Catalog = Future<BookDetails?> Function(
  String isbn,
  PageFetcher fetcher,
);

/// Looks [isbn] up in Open Library, the German National Library (first for
/// German ISBNs, which Open Library rarely has) and Google Books; null if
/// none knows it. All are free and need no key. Throws only if no catalog
/// answered at all; Google Books without a key is usually over its daily
/// quota, so it gets little time.
Future<BookDetails?> lookupIsbn(String isbn, PageFetcher fetcher) async {
  final german = isbn.startsWith('9783') || isbn.length == 10 && isbn[0] == '3';
  final catalogs = <(_Catalog, Duration)>[
    if (german) (_dnb, const Duration(seconds: 15)),
    (_openLibrary, const Duration(seconds: 15)),
    if (!german) (_dnb, const Duration(seconds: 15)),
    (_googleBooks, const Duration(seconds: 6)),
  ];
  SourceException? failure;
  var answered = false;
  for (final (lookup, limit) in catalogs) {
    try {
      final details = await lookup(isbn, fetcher).timeout(limit);
      if (details != null) return details;
      answered = true;
    } on SourceException catch (e) {
      failure ??= e;
    } on TimeoutException {
      // Too slow (or retrying a quota error); try the next catalog.
    } on FormatException {
      answered = true; // An unexpected answer; try the next catalog.
    }
  }
  if (!answered) {
    throw failure ?? SourceException('No book catalog answered in time.');
  }
  return null;
}

Future<BookDetails?> _openLibrary(String isbn, PageFetcher fetcher) async {
  final json = jsonDecode(
    await fetcher.getText(
      Uri.https('openlibrary.org', '/api/books', {
        'bibkeys': 'ISBN:$isbn',
        'format': 'json',
        'jscmd': 'data',
      }),
    ),
  ) as Map;
  final book = json['ISBN:$isbn'] as Map?;
  final title = book?['title'] as String?;
  if (book == null || title == null) return null;
  final subtitle = book['subtitle'] as String?;
  final cover =
      (book['cover'] as Map?)?['large'] ?? (book['cover'] as Map?)?['medium'];
  final excerpt = ((book['excerpts'] as List?)?.firstOrNull as Map?)?['text'];
  return BookDetails(
    isbn: isbn,
    title: subtitle == null ? title : '$title: $subtitle',
    author: _names(book['authors']),
    summary: excerpt is String ? excerpt : null,
    pageCount: (book['number_of_pages'] as num?)?.toInt(),
    coverUrl: cover is String ? Uri.parse(cover) : null,
    tags: [
      for (final s in (book['subjects'] as List? ?? const []).take(8))
        if ((s as Map)['name'] case final String name) name,
    ],
  );
}

Future<BookDetails?> _googleBooks(String isbn, PageFetcher fetcher) async {
  final json = jsonDecode(
    await fetcher.getText(
      Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': 'isbn:$isbn'}),
    ),
  ) as Map;
  final info =
      ((json['items'] as List?)?.firstOrNull as Map?)?['volumeInfo'] as Map?;
  final title = info?['title'] as String?;
  if (info == null || title == null) return null;
  final subtitle = info['subtitle'] as String?;
  final thumbnail = (info['imageLinks'] as Map?)?['thumbnail'] as String?;
  return BookDetails(
    isbn: isbn,
    title: subtitle == null ? title : '$title: $subtitle',
    author: (info['authors'] as List?)?.join(', '),
    summary: info['description'] as String?,
    pageCount: (info['pageCount'] as num?)?.toInt(),
    coverUrl: thumbnail == null
        ? null
        : Uri.parse(thumbnail.replaceFirst('http://', 'https://')),
    tags: [for (final c in info['categories'] as List? ?? const []) '$c'],
  );
}

/// The German National Library's catalog (SRU, MARC 21): German-language
/// books and translations.
Future<BookDetails?> _dnb(String isbn, PageFetcher fetcher) async {
  final xml = XmlDocument.parse(
    await fetcher.getText(
      Uri.https('services.dnb.de', '/sru/dnb', {
        'version': '1.1',
        'operation': 'searchRetrieve',
        'query': 'num=$isbn',
        'recordSchema': 'MARC21-xml',
        'maximumRecords': '1',
      }),
    ),
  );
  final record = xml
      .findAllElements('record', namespaceUri: '*')
      .where((e) => e.getAttribute('type') == 'Bibliographic')
      .firstOrNull;
  if (record == null) return null;
  List<String> field(String tag, String code) => [
    for (final f in record.findAllElements('datafield', namespaceUri: '*'))
      if (f.getAttribute('tag') == tag)
        for (final s in f.findElements('subfield', namespaceUri: '*'))
          if (s.getAttribute('code') == code)
            // Without the non-sorting marks around "Der" in "Der Schwarm".
            s.innerText.replaceAll(RegExp('[\u0098\u009c¬]'), '').trim(),
  ];
  final title = field('245', 'a').firstOrNull;
  if (title == null || title.isEmpty) return null;
  // A short subtitle; "Roman" or a long edition note is left out.
  final subtitle = field('245', 'b').firstOrNull;
  final keepSubtitle =
      subtitle != null &&
      subtitle.contains(' ') &&
      subtitle.length <= 80 &&
      !subtitle.contains(' - ');
  // "Wisser, Daniel" → "Daniel Wisser".
  final authors = [
    for (final name in field('100', 'a'))
      switch (name.split(', ')) {
        [final last, final first] => '$first $last',
        _ => name,
      },
  ];
  final pages = RegExp(r'(\d+)\s*(?:Seiten|S\.|pages|p\.)')
      .firstMatch(field('300', 'a').firstOrNull ?? '');
  return BookDetails(
    isbn: isbn,
    title: keepSubtitle ? '$title: $subtitle' : title,
    author: authors.isEmpty
        ? field('245', 'c').firstOrNull
        : authors.join(', '),
    summary: field('520', 'a').firstOrNull,
    pageCount: pages == null ? null : int.parse(pages[1]!),
    coverUrl: Uri.https('portal.dnb.de', '/opac/mvb/cover', {'isbn': isbn}),
    tags: field('650', 'a').take(8).toList(),
  );
}

String? _names(Object? people) {
  final names = [
    for (final p in people as List? ?? const [])
      if ((p as Map)['name'] case final String name) name,
  ];
  return names.isEmpty ? null : names.join(', ');
}
