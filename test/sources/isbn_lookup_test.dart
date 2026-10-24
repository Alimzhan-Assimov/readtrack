import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/sources/fetcher.dart';
import 'package:readtrack/sources/isbn_lookup.dart';

import 'fake_fetcher.dart';

void main() {
  const isbn = '9783423214124';
  const ol =
      'https://openlibrary.org/api/books?bibkeys=ISBN%3A9783423214124&format=json&jscmd=data';
  const google =
      'https://www.googleapis.com/books/v1/volumes?q=isbn%3A9783423214124';
  String dnb(String isbn) => Uri.https('services.dnb.de', '/sru/dnb', {
    'version': '1.1',
    'operation': 'searchRetrieve',
    'query': 'num=$isbn',
    'recordSchema': 'MARC21-xml',
    'maximumRecords': '1',
  }).toString();
  String marc(String fields) =>
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<searchRetrieveResponse xmlns="http://www.loc.gov/zing/srw/"><version>1.1</version>'
      '<numberOfRecords>1</numberOfRecords><records><record><recordSchema>MARC21-xml</recordSchema>'
      '<recordData><record xmlns="http://www.loc.gov/MARC21/slim" type="Bibliographic">'
      '$fields</record></recordData></record></records></searchRetrieveResponse>';
  const noRecords =
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<searchRetrieveResponse xmlns="http://www.loc.gov/zing/srw/"><version>1.1</version>'
      '<numberOfRecords>0</numberOfRecords><records/></searchRetrieveResponse>';

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

  test('the German National Library is asked first for German ISBNs', () async {
    final fetcher = FakeFetcher({
      dnb(isbn): marc(
        '<datafield tag="100" ind1="1" ind2=" "><subfield code="a">Wisser, Daniel</subfield>'
        '<subfield code="e">Verfasser</subfield></datafield>'
        '<datafield tag="245" ind1="1" ind2="0"><subfield code="a">&#152;Die&#156; Königin der Berge</subfield>'
        '<subfield code="b">Roman</subfield><subfield code="c">Daniel Wisser</subfield></datafield>'
        '<datafield tag="300" ind1=" " ind2=" "><subfield code="a">446 Seiten</subfield>'
        '<subfield code="c">22 cm</subfield></datafield>',
      ),
    });
    final details = (await lookupIsbn(isbn, fetcher))!;
    expect(
      (details.title, details.author, details.pageCount),
      ('Die Königin der Berge', 'Daniel Wisser', 446),
    );
    expect(details.coverUrl!.host, 'portal.dnb.de');
    expect(fetcher.requests, [dnb(isbn)]);
  });

  test('a real subtitle is kept, an edition note is not', () async {
    Future<String?> title(String subtitle) async => (await lookupIsbn(
      isbn,
      FakeFetcher({
        dnb(isbn): marc(
          '<datafield tag="245" ind1="1" ind2="0"><subfield code="a">Der Schwarm</subfield>'
          '<subfield code="b">$subtitle</subfield></datafield>',
        ),
      }),
    ))?.title;
    expect(
      await title('Ein Roman über das Meer'),
      'Der Schwarm: Ein Roman über das Meer',
    );
    expect(
      await title('Limitierte Box. - Ungekürzte Lesung und Hörspiel'),
      'Der Schwarm',
    );
  });

  test('nothing found is null; an error only if no catalog answered', () async {
    expect(
      await lookupIsbn(
        isbn,
        FakeFetcher({
          ol: '{}',
          dnb(isbn): noRecords,
          google: '{"totalItems": 0}',
        }),
      ),
      isNull,
    );
    // Google Books over its quota doesn't hide that the others had nothing.
    expect(
      await lookupIsbn(isbn, FakeFetcher({ol: '{}', dnb(isbn): noRecords})),
      isNull,
    );
    expect(
      () => lookupIsbn(isbn, FakeFetcher({})),
      throwsA(isA<SourceException>()),
    );
  });
}
