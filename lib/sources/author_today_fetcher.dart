import 'dart:convert';
import 'dart:typed_data';

import 'browser_fetcher.dart';
import 'fetcher.dart';

/// Opens the site's own reader only when its API asks for age confirmation
/// or sign-in. The user completes that step; no consent cookie is fabricated.
class AuthorTodayFetcher implements PageFetcher {
  AuthorTodayFetcher({
    PageFetcher? http,
    PageFetcher Function()? openBrowser,
    this.confirmationTimeout = const Duration(minutes: 3),
    this.pollInterval = const Duration(seconds: 2),
  }) : _http = http ?? HttpFetcher(),
       _openBrowser =
           openBrowser ??
           (() => BrowserFetcher(
             windowTitle: 'ReadTrack · Author.Today · Confirm age or sign in',
           ));

  final PageFetcher _http;
  final PageFetcher Function() _openBrowser;
  final Duration confirmationTimeout;
  final Duration pollInterval;
  PageFetcher? _browser;
  bool _closed = false;

  static bool _needsConfirmation(String body) {
    try {
      final json = jsonDecode(body);
      return json is Map &&
          json['isSuccessful'] == false &&
          json['messages'] is List &&
          (json['messages'] as List).any(
            (message) => message == 'Unadulted' || message == 'Unauthorized',
          );
    } on FormatException {
      return false;
    }
  }

  @override
  Future<({String body, Map<String, String> headers})> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final chapterApi = RegExp(r'^/reader/(\d+)/chapter$').firstMatch(uri.path);
    if (uri.scheme != 'https' ||
        uri.host != 'author.today' ||
        chapterApi == null ||
        int.tryParse(uri.queryParameters['id'] ?? '') == null) {
      return _http.getWithHeaders(uri, headers: headers);
    }
    if (_closed) throw SourceAccessException('The reading session was closed.');
    try {
      var response = await (_browser ?? _http).getWithHeaders(
        uri,
        headers: headers,
      );
      if (!_needsConfirmation(response.body)) return response;
      final browser = _browser ??= _openBrowser();
      final reader = Uri.https(
        'author.today',
        '/reader/${chapterApi.group(1)}/${uri.queryParameters['id']}',
      );
      // Navigation shows the actual age/sign-in form. Do not click it here.
      await browser.getText(reader);
      final deadline = DateTime.now().add(confirmationTimeout);
      while (!_closed) {
        response = await browser.getWithHeaders(uri, headers: headers);
        if (!_needsConfirmation(response.body)) return response;
        if (DateTime.now().isAfter(deadline)) {
          throw SourceAccessException(
            'Author.Today is still waiting for age confirmation or sign-in. '
            'Complete it in the ReadTrack browser window, then retry.',
          );
        }
        await Future<void>.delayed(pollInterval);
      }
      throw SourceAccessException('The reading session was closed.');
    } on SourceAccessException {
      rethrow;
    } on Exception catch (error) {
      final browser = _browser;
      _browser = null;
      await browser?.close();
      throw SourceAccessException(
        'Author.Today confirmation was not completed. Keep the ReadTrack '
        'browser window open until the chapter loads, then retry. $error',
      );
    }
  }

  // Covers/images can live on a different host. Fetch them over HTTP so an
  // image never navigates the confirmation window away from the reader.
  @override
  Future<Uint8List> getBytes(Uri uri) => _http.getBytes(uri);

  @override
  Future<String> getText(Uri uri, {Map<String, String> headers = const {}}) =>
      _http.getText(uri, headers: headers);

  @override
  Future<String> postForm(
    Uri uri,
    Map<String, String> fields, {
    Map<String, String> headers = const {},
  }) => _http.postForm(uri, fields, headers: headers);

  @override
  Future<void> close() async {
    _closed = true;
    await _http.close();
    await _browser?.close();
  }
}
