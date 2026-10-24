import 'dart:convert';

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

/// Looks [isbn] up in Open Library, then Google Books; null if neither
/// knows it. Both are free and need no key.
Future<BookDetails?> lookupIsbn(String isbn, PageFetcher fetcher) async {
  SourceException? failure;
  for (final lookup in [_openLibrary, _googleBooks]) {
    try {
      final details = await lookup(isbn, fetcher);
      if (details != null) return details;
    } on SourceException catch (e) {
      failure ??= e;
    } on FormatException {
      // An unexpected answer; try the next catalog.
    }
  }
  if (failure != null) throw failure;
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

String? _names(Object? people) {
  final names = [
    for (final p in people as List? ?? const [])
      if ((p as Map)['name'] case final String name) name,
  ];
  return names.isEmpty ? null : names.join(', ');
}
