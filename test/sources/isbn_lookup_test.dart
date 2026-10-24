import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/sources/isbn_lookup.dart';

import 'fake_fetcher.dart';

void main() {
  const isbn = '9783423214124';
  const ol =
      'https://openlibrary.org/api/books?bibkeys=ISBN%3A9783423214124&format=json&jscmd=data';
  const google =
      'https://www.googleapis.com/books/v1/volumes?q=isbn%3A9783423214124';

  test('Open Library gives title, author, pages, cover and subjects', () async {
    final details = (await lookupIsbn(
      isbn,
      FakeFetcher({
        ol:
            '{"ISBN:$isbn": {"title": "Der kleine Hobbit", "authors": [{"name": "J.R.R. Tolkien"}],'
            '"number_of_pages": 354, "cover": {"medium": "https://covers.openlibrary.org/b/id/1-M.jpg", "large": "https://covers.openlibrary.org/b/id/1-L.jpg"},'
            '"subjects": [{"name": "Fantasy"}, {"name": "Dragons"}]}}',
      }),
    ))!;
    expect(
      (details.title, details.author, details.pageCount, '${details.coverUrl}'),
      (
        'Der kleine Hobbit',
        'J.R.R. Tolkien',
        354,
        'https://covers.openlibrary.org/b/id/1-L.jpg',
      ),
    );
    expect(details.tags, ['Fantasy', 'Dragons']);
  });

  test('Google Books fills in when Open Library has nothing', () async {
    final details = (await lookupIsbn(
      isbn,
      FakeFetcher({
        ol: '{}',
        google:
            '{"items": [{"volumeInfo": {"title": "Хоббит", "subtitle": "Туда и обратно",'
            '"authors": ["Дж. Р. Р. Толкин"], "pageCount": 320, "description": "Сказка.",'
            '"imageLinks": {"thumbnail": "http://books.google.com/x.jpg"}, "categories": ["Fiction"]}}]}',
      }),
    ))!;
    expect(details.title, 'Хоббит: Туда и обратно');
    expect(details.summary, 'Сказка.');
    expect(details.coverUrl!.scheme, 'https');
  });

  test(
    'nothing found is null; a failure without an answer is an error',
    () async {
      expect(
        await lookupIsbn(
          isbn,
          FakeFetcher({ol: '{}', google: '{"totalItems": 0}'}),
        ),
        isNull,
      );
      // Open Library unreachable, Google Books knows nothing: report the error.
      expect(
        () => lookupIsbn(isbn, FakeFetcher({google: '{"totalItems": 0}'})),
        throwsA(isA<Exception>()),
      );
    },
  );
}
