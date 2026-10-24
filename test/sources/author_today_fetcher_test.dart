import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/sources/author_today.dart';
import 'package:readtrack/sources/author_today_fetcher.dart';
import 'package:readtrack/sources/fetcher.dart';
import 'package:readtrack/sources/source.dart';

import 'fake_fetcher.dart';

typedef Response = ({String body, Map<String, String> headers});

class SessionFetcher extends FakeFetcher {
  SessionFetcher(this.responses, {Map<String, String> pages = const {}})
    : super(pages);

  final List<Response> responses;
  bool closed = false;
  bool failRequests = false;
  final sentHeaders = <Map<String, String>>[];

  @override
  Future<Response> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    requests.add('$uri');
    sentHeaders.add(headers);
    if (failRequests) throw SourceException('The browser window was closed.');
    return responses.length == 1 ? responses.single : responses.removeAt(0);
  }

  @override
  Future<void> close() async => closed = true;
}

Response gate([String message = 'Unadulted']) => (
  body: jsonEncode({
    'isSuccessful': false,
    'messages': [message],
    'data': null,
  }),
  headers: {},
);

Response chapter({String userId = ''}) {
  const html = '<p>Chapter text.</p>';
  // Matches the site's published reader algorithm, including signed-in id.
  final key = 'cba@_@$userId';
  final encrypted = String.fromCharCodes([
    for (var i = 0; i < html.length; i++)
      html.codeUnitAt(i) ^ key.codeUnitAt(i % key.length),
  ]);
  return (
    body: jsonEncode({
      'isSuccessful': true,
      'data': {'text': encrypted},
    }),
    headers: {'reader-secret': 'abc', 'readtrack-user-id': userId},
  );
}

void main() {
  final api = Uri.parse(
    'https://author.today/reader/564935/chapter?id=5359854',
  );
  const reader = 'https://author.today/reader/564935/5359854';
  const headers = {'X-Requested-With': 'XMLHttpRequest'};

  test('public chapters stay on HTTP without a confirmation window', () async {
    final http = SessionFetcher([chapter()]);
    final fetcher = AuthorTodayFetcher(
      http: http,
      openBrowser: () => throw StateError('No browser should open'),
    );
    addTearDown(fetcher.close);
    expect((await fetcher.getWithHeaders(api)).body, chapter().body);
  });

  test(
    'waits for user confirmation, then reuses session and headers',
    () async {
      final http = SessionFetcher([gate()]);
      final browser = SessionFetcher(
        [gate(), chapter(userId: '42')],
        pages: {reader: 'Site age confirmation form'},
      );
      var opened = 0;
      final fetcher = AuthorTodayFetcher(
        http: http,
        openBrowser: () {
          opened++;
          return browser;
        },
        pollInterval: Duration.zero,
      );
      final source = const AuthorTodaySource();
      for (var number = 1; number <= 2; number++) {
        final content = await source.fetchChapter(
          ChapterRef(number: number, title: 'Chapter', url: Uri.parse(reader)),
          fetcher,
        );
        expect(content.html, '<p>Chapter text.</p>');
      }
      expect(opened, 1);
      expect(http.requests, ['$api']);
      expect(browser.requests.where((url) => url == reader), hasLength(1));
      expect(
        browser.sentHeaders.every(
          (sent) => sent['X-Requested-With'] == 'XMLHttpRequest',
        ),
        isTrue,
      );
      await fetcher.close();
      expect(http.closed, isTrue);
      expect(browser.closed, isTrue);
    },
  );

  test('unconfirmed age times out without returning chapter content', () async {
    final browser = SessionFetcher([gate()], pages: {reader: 'Age form'});
    final fetcher = AuthorTodayFetcher(
      http: SessionFetcher([gate()]),
      openBrowser: () => browser,
      confirmationTimeout: Duration.zero,
      pollInterval: Duration.zero,
    );
    addTearDown(fetcher.close);
    await expectLater(
      fetcher.getWithHeaders(api, headers: headers),
      throwsA(isA<SourceAccessException>()),
    );
    expect(browser.requests, [reader, '$api']);
  });

  test(
    'a closed confirmation window is reported and retry can reopen it',
    () async {
      final closed = SessionFetcher([gate()], pages: {reader: 'Age form'})
        ..failRequests = true;
      final confirmed = SessionFetcher([chapter()], pages: {reader: 'Reader'});
      var opened = 0;
      final fetcher = AuthorTodayFetcher(
        http: SessionFetcher([gate()]),
        openBrowser: () => opened++ == 0 ? closed : confirmed,
        pollInterval: Duration.zero,
      );
      addTearDown(fetcher.close);
      await expectLater(
        fetcher.getWithHeaders(api),
        throwsA(isA<SourceAccessException>()),
      );
      expect(closed.closed, isTrue);
      expect((await fetcher.getWithHeaders(api)).body, chapter().body);
      expect(opened, 2);
    },
  );

  test('sign-in uses the same interactive flow', () async {
    final browser = SessionFetcher(
      [chapter(userId: '42')],
      pages: {reader: 'Sign in'},
    );
    final fetcher = AuthorTodayFetcher(
      http: SessionFetcher([gate('Unauthorized')]),
      openBrowser: () => browser,
    );
    addTearDown(fetcher.close);
    expect(
      (await fetcher.getWithHeaders(api)).headers['readtrack-user-id'],
      '42',
    );
  });

  test('paid chapters do not start age confirmation', () async {
    final denied = gate('Unpurchased');
    final fetcher = AuthorTodayFetcher(
      http: SessionFetcher([denied]),
      openBrowser: () =>
          throw StateError('Do not open a browser for a paywall'),
    );
    addTearDown(fetcher.close);
    expect((await fetcher.getWithHeaders(api)).body, denied.body);
  });

  test('images use HTTP without navigating the reading session', () async {
    final uri = Uri.parse('https://cm.author.today/map.png');
    final http = FakeFetcher(
      {},
      bytes: {
        '$uri': [1, 2, 3],
      },
    );
    final fetcher = AuthorTodayFetcher(
      http: http,
      openBrowser: () => throw StateError('An image must not open a browser'),
    );
    addTearDown(fetcher.close);
    expect(await fetcher.getBytes(uri), [1, 2, 3]);
  });
}
