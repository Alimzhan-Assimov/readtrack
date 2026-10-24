import 'dart:convert';
import 'dart:typed_data';

import 'package:readtrack/sources/fetcher.dart';

/// Serves canned responses by URL, so parsers can be tested offline.
class FakeFetcher implements PageFetcher {
  FakeFetcher(this.pages, {this.headers = const {}, this.bytes = const {}});

  final Map<String, String> pages;
  final Map<String, Map<String, String>> headers;
  final Map<String, List<int>> bytes;
  final requests = <String>[];
  final posts = <String, Map<String, String>>{};

  String _page(Uri uri) {
    requests.add(uri.toString());
    final page = pages[uri.toString()];
    if (page == null) throw SourceException('No fake page for $uri');
    return page;
  }

  @override
  Future<String> getText(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async => _page(uri);

  @override
  Future<({String body, Map<String, String> headers})> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async => (
    body: _page(uri),
    headers: this.headers[uri.toString()] ?? const <String, String>{},
  );

  @override
  Future<String> postForm(
    Uri uri,
    Map<String, String> fields, {
    Map<String, String> headers = const {},
  }) async {
    posts[uri.toString()] = fields;
    return _page(uri);
  }

  @override
  Future<Uint8List> getBytes(Uri uri) async {
    requests.add(uri.toString());
    final data = bytes[uri.toString()];
    if (data == null) throw SourceException('No fake bytes for $uri');
    return Uint8List.fromList(data);
  }

  @override
  Future<void> close() async {}
}

String jsonString(Object value) => jsonEncode(value);
