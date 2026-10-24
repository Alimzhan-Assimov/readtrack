import 'dart:convert';

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Litnet. Book details come from the page's embedded state; chapter text
/// comes page by page from the reader, which needs its CSRF token. Paid
/// chapters are refused by the site and reported as unavailable.
class LitnetSource extends StorySource {
  const LitnetSource();

  static const _host = 'litnet.com';

  /// Safety limit for pages per chapter.
  static const _maxPages = 100;

  @override
  String get name => 'Litnet';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.http;

  /// Book links: /ru/book/some-title-b614747. Reader: /ru/reader/some-title-b614747.
  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/(?:\w\w/)?(?:book|reader)/([\w-]+-b\d+)')
        .firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/ru/book/${match.group(1)}');
  }

  static String _slug(Uri url) => url.pathSegments.last;

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final html = await fetcher.getText(storyUrl);
    final doc = parseHtml(html);
    final slug = _slug(storyUrl);
    final book = _findBook(html, slug);
    final title = book?['title'] as String? ?? textOf(doc.querySelector('h1'));
    if (title == null) throw SourceException('This is not a Litnet book page.');

    final reader = parseHtml(
      await fetcher.getText(Uri.https(_host, '/ru/reader/$slug')),
    );
    final options = reader.querySelectorAll('select.js-chapter-change option');
    final cover = book?['image'] as String? ?? metaContent(doc, 'og:image');
    final annotation = book?['annotation'] as String?;

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: ((book?['author'] as Map?)?['name'] as String?)?.trim(),
      summary: annotation == null
          ? null
          : htmlToPlainText(
              cleanHtml(
                parseHtml('<div>$annotation</div>').body!,
                base: storyUrl,
              ),
            ),
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: {
        for (final a in doc.querySelectorAll(
          'a[href^="/ru/top/"], a[href^="/ru/tag/"]',
        ))
          if (textOf(a) case final t?) t.replaceFirst(RegExp(r'^#\s*'), ''),
      }.toList(),
      pageCount: (book?['pages'] as num?)?.toInt(),
      isComplete: book?['is_finished'] as bool?,
      chapters: [
        for (final (i, o) in options.indexed)
          ChapterRef(
            number: i + 1,
            title: squash(o.text),
            url: Uri.https(_host, '/ru/reader/$slug', {
              'c': o.attributes['value'],
            }),
          ),
      ],
    );
  }

  /// The book object in the embedded Angular state (`<script id="ng-state">`).
  static Map<String, Object?>? _findBook(String html, String slug) {
    final state = RegExp(
      r'<script id="ng-state" type="application/json">(.*?)</script>',
      dotAll: true,
    ).firstMatch(html)?.group(1);
    if (state == null) return null;
    Map<String, Object?>? search(Object? node) {
      if (node is Map) {
        if (node['alias'] == slug && node['title'] is String) {
          return node.cast<String, Object?>();
        }
        for (final value in node.values) {
          if (search(value) case final found?) return found;
        }
      } else if (node is List) {
        for (final value in node) {
          if (search(value) case final found?) return found;
        }
      }
      return null;
    }

    try {
      return search(jsonDecode(state));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final chapterId = chapter.url.queryParameters['c'];
    if (chapterId == null) {
      throw SourceException('Unknown Litnet chapter link: ${chapter.url}');
    }
    // The reader page sets the session cookie and carries the CSRF token.
    final reader = parseHtml(await fetcher.getText(chapter.url));
    final token = reader
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
    if (token == null) throw SourceException('Litnet did not open its reader.');

    final pages = StringBuffer();
    for (var page = 1; page <= _maxPages; page++) {
      final json = jsonDecode(
        await fetcher.postForm(
          Uri.https(_host, '/reader/get-page'),
          {'chapterId': chapterId, 'page': '$page', '_csrf': token},
          headers: {
            'X-CSRF-Token': token,
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      ) as Map<String, Object?>;
      if (json['status'] != 1) {
        throw SourceException(
          '"${chapter.title}" is not available to read for free on Litnet.',
        );
      }
      pages.write(json['data'] as String? ?? '');
      if (json['isLastPage'] == true ||
          page >= ((json['totalPages'] as num?) ?? 1)) {
        break;
      }
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(parseHtml('<div>$pages</div>').body!, base: chapter.url),
    );
  }
}
