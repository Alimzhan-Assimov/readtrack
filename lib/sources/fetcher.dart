import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Thrown when a page or chapter cannot be loaded or understood.
class SourceException implements Exception {
  SourceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Loads pages for a [StorySource]. Sites behind Cloudflare need a real
/// browser ([BrowserFetcher]); all others use plain HTTP ([HttpFetcher]).
abstract class PageFetcher {
  Future<String> getText(Uri uri, {Map<String, String> headers = const {}});

  /// Like [getText], but also returns the response headers.
  Future<({String body, Map<String, String> headers})> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  });

  Future<String> postForm(Uri uri, Map<String, String> fields);

  Future<Uint8List> getBytes(Uri uri);

  /// Releases resources such as an open browser window.
  Future<void> close();
}

/// Spaces out requests to the same host so downloads don't hammer a site.
class RateLimiter {
  RateLimiter(this.minInterval);

  final Duration minInterval;
  final _next = <String, DateTime>{};

  Future<void> wait(String host) async {
    final now = DateTime.now();
    final next = _next[host] ?? now;
    final start = next.isAfter(now) ? next : now;
    _next[host] = start.add(minInterval);
    final delay = start.difference(now);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }
}

class HttpFetcher implements PageFetcher {
  HttpFetcher({
    http.Client? client,
    Duration minInterval = const Duration(milliseconds: 800),
  }) : _client = client ?? http.Client(),
       _limiter = RateLimiter(minInterval);

  static const userAgent =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/141.0 Safari/537.36';

  final http.Client _client;
  final RateLimiter _limiter;

  Future<http.Response> _send(
    Future<http.Response> Function() request,
    Uri uri,
  ) async {
    // Retry briefly on rate limiting and transient server errors.
    for (var attempt = 0; ; attempt++) {
      await _limiter.wait(uri.host);
      final http.Response response;
      try {
        response = await request().timeout(const Duration(seconds: 45));
      } on TimeoutException {
        if (attempt < 2) continue;
        throw SourceException('${uri.host} did not respond in time.');
      } on Exception catch (e) {
        throw SourceException('Could not reach ${uri.host}: $e');
      }
      final code = response.statusCode;
      if (code == 429 || code >= 500) {
        if (attempt < 3) {
          await Future<void>.delayed(Duration(seconds: 2 << attempt));
          continue;
        }
      }
      if (code >= 400) {
        throw SourceException('${uri.host} answered with error $code.');
      }
      return response;
    }
  }

  Map<String, String> _headers(Map<String, String> extra) => {
    'User-Agent': userAgent,
    'Accept-Language': 'en-US,en;q=0.9',
    ...extra,
  };

  @override
  Future<String> getText(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async => (await getWithHeaders(uri, headers: headers)).body;

  @override
  Future<({String body, Map<String, String> headers})> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _send(
      () => _client.get(uri, headers: _headers(headers)),
      uri,
    );
    return (
      body: utf8.decode(response.bodyBytes, allowMalformed: true),
      headers: response.headers,
    );
  }

  @override
  Future<String> postForm(Uri uri, Map<String, String> fields) async {
    final response = await _send(
      () => _client.post(uri, headers: _headers(const {}), body: fields),
      uri,
    );
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  @override
  Future<Uint8List> getBytes(Uri uri) async => (await _send(
    () => _client.get(uri, headers: _headers(const {})),
    uri,
  )).bodyBytes;

  @override
  Future<void> close() async => _client.close();
}
