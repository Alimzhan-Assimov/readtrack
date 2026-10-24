import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/opds/opds.dart';

import '../sources/fake_fetcher.dart';

String fixture(String name) =>
    File('test/opds/fixtures/$name').readAsStringSync();

void main() {
  test('Gutenberg: the start page lists sections with a search', () {
    final feed = parseOpdsFeed(
      fixture('gut_root.xml'),
      Uri.parse('https://www.gutenberg.org/ebooks.opds/'),
    );
    expect(feed.entries, isNotEmpty);
    expect(feed.entries.every((e) => !e.isBook), isTrue);
    expect(
      feed.entries.first.navigationUrl.toString(),
      startsWith('https://www.gutenberg.org/ebooks/search.opds/'),
    );
    expect(
      feed.searchDescription.toString(),
      'https://www.gutenberg.org/catalog/osd-books.xml',
    );
    expect(feed.entries.first.coverUrl, isNull); // inline icons are skipped
  });

  test('Gutenberg: search results lead to a book with its files', () {
    final results = parseOpdsFeed(
      fixture('gut_search.xml'),
      Uri.parse('https://www.gutenberg.org/ebooks/search.opds/?query=x'),
    );
    final war = results.entries.firstWhere((e) => e.title == 'War and Peace');
    expect(war.author, isNull);
    expect(war.summary, 'graf Leo Tolstoy');
    expect(
      war.navigationUrl.toString(),
      'https://www.gutenberg.org/ebooks/2600.opds',
    );

    final book = parseOpdsFeed(fixture('gut_book.xml'), war.navigationUrl!);
    final entry = book.entries.firstWhere((e) => e.isBook);
    expect(entry.bestFile!.type, 'application/epub+zip');
    expect(entry.bestFile!.url.path, startsWith('/ebooks/2600.epub'));
    expect(entry.pageUrl.toString(), 'https://www.gutenberg.org/ebooks/2600');
    expect(
      entry.coverUrl.toString(),
      'https://www.gutenberg.org/cache/epub/2600/pg2600.cover.medium.jpg',
    );
  });

  test('Standard Ebooks: search and the new releases feed', () {
    final search = parseOpdsFeed(
      fixture('se_search.xml'),
      Uri.parse('https://standardebooks.org/feeds/opds/all?query=tolstoy'),
    );
    expect(search.entries, hasLength(2));
    final first = search.entries.first;
    expect(first.author, contains('Tolstoy'));
    expect(first.bestFile!.url.path, endsWith('.epub'));
    expect(first.bestFile!.url.path, isNot(endsWith('kepub.epub')));
    expect(first.bestFile!.url.path, isNot(contains('_advanced')));

    final news = parseOpdsFeed(
      fixture('se_atom.xml'),
      Uri.parse('https://standardebooks.org/feeds/atom/new-releases'),
    );
    expect(news.entries, hasLength(2));
    expect(news.entries.every((e) => e.bestFile != null), isTrue);
    expect(news.entries.first.pageUrl?.host, 'standardebooks.org');
  });

  test('search addresses come from the catalog or its OpenSearch file', () async {
    expect(
      searchUri(
        'https://a.test/s?q={searchTerms}&p={startPage?}',
        'war peace',
      ).toString(),
      'https://a.test/s?q=war+peace&p=',
    );
    expect(
      parseOpenSearchTemplate(
        '<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">'
        '<Url type="text/html" template="/search/?query={searchTerms}"/>'
        '<Url type="application/atom+xml" template="/search.opds/?query={searchTerms}"/>'
        '</OpenSearchDescription>',
        Uri.parse('https://www.gutenberg.org/catalog/osd-books.xml'),
      ),
      'https://www.gutenberg.org/search.opds/?query={searchTerms}',
    );

    final fetcher = FakeFetcher({
      'https://cal.test/opds':
          '<feed xmlns="http://www.w3.org/2005/Atom"><title>Calibre</title>'
          '<link rel="search" type="application/atom+xml" href="/opds/search/{searchTerms}"/></feed>',
      'https://cal.test/opds/search/dune':
          '<feed xmlns="http://www.w3.org/2005/Atom"><entry><title>Dune</title>'
          '<link rel="http://opds-spec.org/acquisition" type="application/epub+zip" href="/get/epub/1"/></entry></feed>',
    });
    final results = await OpdsClient(fetcher).search(
      OpdsCatalog('Calibre', Uri.parse('https://cal.test/opds')),
      'dune',
    );
    expect(
      results!.entries.single.bestFile!.url.toString(),
      'https://cal.test/get/epub/1',
    );
  });

  test('a page that is not a feed gives a clear error', () {
    expect(
      () => parseOpdsFeed('<html><body/></html>', Uri.parse('https://a.test')),
      throwsA(isA<Exception>()),
    );
  });
}
