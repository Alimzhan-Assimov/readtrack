import 'dart:typed_data';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../data/enums.dart';
import 'browser_fetcher.dart';
import 'fetcher.dart';

/// One chapter as listed on the site.
class ChapterRef {
  const ChapterRef({
    required this.number,
    required this.title,
    required this.url,
    this.locked = false,
  });

  /// 1-based position in the story.
  final int number;
  final String title;
  final Uri url;

  /// Paywalled or otherwise unavailable for reading.
  final bool locked;
}

/// Everything a site tells us about a story.
class StoryInfo {
  const StoryInfo({
    required this.url,
    required this.siteName,
    required this.type,
    required this.title,
    required this.chapters,
    this.author,
    this.summary,
    this.coverUrl,
    this.fandom,
    this.tags = const [],
    this.pairings = const [],
    this.adultTags = const {},
    this.wordCount,
    this.pageCount,
    this.characterCount,
    this.series,
    this.crossovers = const [],
    this.characters = const [],
    this.isComplete,
    this.updatedOn,
    this._chapterCount,
  });

  final Uri url;
  final String siteName;
  final WorkType type;
  final String title;
  final String? author;
  final String? summary;
  final Uri? coverUrl;
  final String? fandom;
  final List<String> tags;

  /// Relationships such as "Naruto/Hinata".
  final List<String> pairings;

  /// Tags the site itself marks as adult content.
  final Set<String> adultTags;
  final List<ChapterRef> chapters;
  final int? wordCount;
  final int? pageCount;

  /// Size in characters, for sites that give neither words nor pages.
  final int? characterCount;

  /// Characters the site lists for the story.
  final List<String> characters;

  /// Further fandoms of a crossover, besides [fandom].
  final List<String> crossovers;

  /// The series the story is part of, and its position there.
  final ({String name, double? index})? series;
  final bool? isComplete;

  /// When the story was last updated, if the site says.
  final DateTime? updatedOn;
  final int? _chapterCount;

  /// Number of chapters; sites that only list a count (and no chapters)
  /// report it here.
  int get chapterCount =>
      chapters.isEmpty ? (_chapterCount ?? 0) : chapters.length;
}

class ChapterContent {
  const ChapterContent({required this.html, this.title});

  final String? title;

  /// Cleaned HTML, see `cleanHtml` in html_clean.dart.
  final String html;
}

enum FetchMode {
  /// Plain HTTP requests.
  http,

  /// A real browser window, for sites behind Cloudflare.
  browser,

  /// Plain HTTP, falling back to the browser when the site refuses it.
  httpThenBrowser,
}

/// A story found on a list page (bookmarks, favorites, a reading list).
typedef ListedStory = ({Uri url, String title});

/// A website ReadTrack can import stories from.
abstract class StorySource {
  const StorySource();

  String get name;

  /// Host names without "www.".
  List<String> get hosts;

  FetchMode get fetchMode;

  PageFetcher createFetcher() => switch (fetchMode) {
    FetchMode.http => HttpFetcher(),
    FetchMode.browser => BrowserFetcher(windowTitle: 'ReadTrack · $name'),
    FetchMode.httpThenBrowser => FallbackFetcher(
      HttpFetcher(),
      () => BrowserFetcher(windowTitle: 'ReadTrack · $name'),
    ),
  };

  /// False for catalog sites that only describe a story but don't host it.
  bool get canRead => true;

  bool matches(Uri uri) => hosts.contains(_bareHost(uri));

  /// The canonical story URL for any link into the story (e.g. a chapter),
  /// or null if [uri] doesn't point to a story.
  Uri? storyUrl(Uri uri);

  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher);

  Future<ChapterContent> fetchChapter(ChapterRef chapter, PageFetcher fetcher);

  /// The newest chapters, oldest first, from a light feed the site offers
  /// (e.g. RSS), with their release time if known; null if there is none.
  /// Lets the check for new chapters skip loading the whole story.
  Future<List<({ChapterRef chapter, DateTime? date})>?> recentChapters(
    Uri storyUrl,
    PageFetcher fetcher,
  ) async => null;

  /// What identifies a chapter across [recentChapters] and the story's
  /// chapter list; the link by default.
  String chapterKey(Uri chapterUrl) => '$chapterUrl';

  /// Selectors for the story links on this site's list pages, tried in
  /// order; the first that finds any wins. Empty takes every story link,
  /// which may include sidebars.
  List<String> get listLinkSelectors => const [];

  /// The stories on a list page such as bookmarks, favorites or a
  /// collection, following "next" links for up to [maxPages] pages.
  Future<List<ListedStory>> fetchList(
    Uri url,
    PageFetcher fetcher, {
    int maxPages = 50,
  }) async {
    final found = <String, ListedStory>{};
    Uri? page = url;
    final seen = <String>{};
    for (var n = 0; page != null && n < maxPages; n++) {
      if (!seen.add('$page')) break;
      final doc = parseHtml(await fetcher.getText(page));
      var links = const <dom.Element>[];
      for (final selector in [...listLinkSelectors, 'a[href]']) {
        links = doc.querySelectorAll(selector);
        if (links.isNotEmpty) break;
      }
      for (final a in links) {
        final href = a.attributes['href'];
        final target = href == null ? null : page.resolve(href);
        if (target == null || !matches(target)) continue;
        final story = storyUrl(target);
        final title = squash(a.text);
        if (story == null || title.isEmpty) continue;
        found.putIfAbsent('$story', () => (url: story, title: title));
      }
      final next = doc
          .querySelector('a[rel="next"], li.next a, a.next, .pagination a.next')
          ?.attributes['href'];
      page = next == null ? null : page.resolve(next);
    }
    return found.values.toList();
  }

  static String _bareHost(Uri uri) {
    final host = uri.host.toLowerCase();
    for (final prefix in const ['www.', 'm.']) {
      if (host.startsWith(prefix)) return host.substring(prefix.length);
    }
    return host;
  }
}

/// Opens the right kind of [PageFetcher] for a source. Close it when done.
PageFetcher openFetcher(StorySource source) => source.createFetcher();

/// Uses [primary] until it fails once, then switches to the fallback for the
/// rest of the session.
class FallbackFetcher implements PageFetcher {
  FallbackFetcher(this._primary, this._createFallback);

  final PageFetcher _primary;
  final PageFetcher Function() _createFallback;
  PageFetcher? _fallback;

  Future<T> _run<T>(Future<T> Function(PageFetcher f) call) async {
    final fallback = _fallback;
    if (fallback != null) return call(fallback);
    try {
      return await call(_primary);
    } on SourceException {
      return call(_fallback = _createFallback());
    }
  }

  @override
  Future<String> getText(Uri uri, {Map<String, String> headers = const {}}) =>
      _run((f) => f.getText(uri, headers: headers));

  @override
  Future<({String body, Map<String, String> headers})> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  }) => _run((f) => f.getWithHeaders(uri, headers: headers));

  @override
  Future<String> postForm(
    Uri uri,
    Map<String, String> fields, {
    Map<String, String> headers = const {},
  }) => _run((f) => f.postForm(uri, fields, headers: headers));

  @override
  Future<Uint8List> getBytes(Uri uri) => _run((f) => f.getBytes(uri));

  @override
  Future<void> close() async {
    await _primary.close();
    await _fallback?.close();
  }
}

dom.Document parseHtml(String html) => html_parser.parse(html);

/// Collapses whitespace like a browser does when rendering text.
String squash(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// "45,300" / "45 300" / "45.300" -> 45300
int? parseCount(String? text) {
  if (text == null) return null;
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? null : int.tryParse(digits);
}

String? textOf(dom.Element? element) {
  if (element == null) return null;
  final text = squash(element.text);
  return text.isEmpty ? null : text;
}

/// Content of `<meta property="..." content="...">`.
String? metaContent(dom.Document doc, String property) {
  final value = doc
      .querySelector('meta[property="$property"], meta[name="$property"]')
      ?.attributes['content']
      ?.trim();
  return value == null || value.isEmpty ? null : value;
}
