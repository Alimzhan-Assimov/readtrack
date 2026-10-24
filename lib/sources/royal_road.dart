import 'dart:convert';

import 'package:xml/xml.dart';

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

class RoyalRoadSource extends StorySource {
  const RoyalRoadSource();

  @override
  String get name => 'Royal Road';

  @override
  List<String> get hosts => const ['royalroad.com'];

  @override
  // Royal Road's bot protection sometimes refuses plain HTTP clients.
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/fiction/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https('www.royalroad.com', '/fiction/${match.group(1)}');
  }

  /// Favorites, follows and search results.
  @override
  List<String> get listLinkSelectors => const [
    '.fiction-list-item .fiction-title a',
  ];

  /// Each story has an RSS feed of its latest chapters, which (unlike the
  /// story page) is rarely behind Cloudflare.
  @override
  Future<List<({ChapterRef chapter, DateTime? date})>?> recentChapters(
    Uri storyUrl,
    PageFetcher fetcher,
  ) async {
    final id = RegExp(r'^/fiction/(\d+)').firstMatch(storyUrl.path)?.group(1);
    if (id == null) return null;
    final XmlDocument rss;
    try {
      rss = XmlDocument.parse(
        await fetcher.getText(
          Uri.https('www.royalroad.com', '/fiction/syndication/$id'),
        ),
      );
    } on XmlException {
      return null;
    }
    final story = rss
        .findAllElements('channel')
        .firstOrNull
        ?.getElement('title')
        ?.innerText
        .trim();
    final items = [
      for (final item in rss.findAllElements('item'))
        if (item.getElement('link')?.innerText.trim() case final link?)
          (
            title: item.getElement('title')?.innerText.trim() ?? '',
            url: Uri.parse(link),
            date: _rssDate(item.getElement('pubDate')?.innerText.trim()),
          ),
    ];
    // The feed lists the newest first.
    return [
      for (final (i, item) in items.reversed.indexed)
        (
          chapter: ChapterRef(
            number: i + 1,
            // "Story - Chapter 3" -> "Chapter 3"
            title: story != null && item.title.startsWith('$story - ')
                ? item.title.substring(story.length + 3)
                : item.title,
            url: item.url,
          ),
          date: item.date,
        ),
    ];
  }

  @override
  String chapterKey(Uri chapterUrl) =>
      RegExp(r'/chapter/(\d+)').firstMatch(chapterUrl.path)?.group(1) ??
      '$chapterUrl';

  /// RFC 822 dates as in RSS: "Sat, 24 Oct 2026 08:00:00 GMT".
  static DateTime? _rssDate(String? text) {
    final m = RegExp(r'(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2})')
        .firstMatch(text ?? '');
    if (m == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months.indexOf(m.group(2)!) + 1;
    if (month == 0) return null;
    return DateTime.utc(
      int.parse(m.group(3)!),
      month,
      int.parse(m.group(1)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
      int.parse(m.group(6)!),
    );
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final html = await fetcher.getText(storyUrl);
    final doc = parseHtml(html);
    final title = textOf(doc.querySelector('.fic-header h1, h1'));
    if (title == null) {
      throw SourceException('This is not a Royal Road story page.');
    }

    final labels = doc
        .querySelectorAll('.fiction-info span.label')
        .map((e) => squash(e.text).toUpperCase())
        .toSet();
    final description = doc.querySelector('.description');
    final cover = metaContent(doc, 'og:image');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: labels.contains('FAN FICTION')
          ? WorkType.fanfiction
          : WorkType.webnovel,
      title: title,
      author:
          metaContent(doc, 'books:author') ??
          textOf(doc.querySelector('.fic-header h4 a')),
      summary: description == null
          ? null
          : htmlToPlainText(cleanHtml(description, base: storyUrl)),
      coverUrl: cover == null || cover.contains('nocover')
          ? null
          : Uri.parse(cover),
      tags: [
        for (final a in doc.querySelectorAll('a.fiction-tag')) squash(a.text),
      ],
      chapters: _chapters(html, storyUrl),
      updatedOn: _lastChapterDate(html),
      // From the JSON-LD block: "numberOfPages":2932
      pageCount: parseCount(
        RegExp(r'"numberOfPages"\s*:\s*(\d+)').firstMatch(html)?.group(1),
      ),
      isComplete: labels.contains('COMPLETED')
          ? true
          : labels.intersection(const {
              'ONGOING',
              'HIATUS',
              'STUB',
              'DROPPED',
            }).isNotEmpty
          ? false
          : null,
    );
  }

  /// The chapter list is embedded as `window.chapters = [...]`.
  static List<Map<String, Object?>> _chapterJson(String html) {
    final json = RegExp(
      r'window\.chapters\s*=\s*(\[.*?\]);',
      dotAll: true,
    ).firstMatch(html)?.group(1);
    if (json == null) return const [];
    return (jsonDecode(json) as List).cast<Map<String, Object?>>();
  }

  DateTime? _lastChapterDate(String html) =>
      [for (final c in _chapterJson(html)) ?DateTime.tryParse('${c['date']}')]
          .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

  List<ChapterRef> _chapters(String html, Uri base) {
    final list = _chapterJson(html);
    if (list.isEmpty) return const [];
    var number = 0;
    return [
      for (final c in list)
        if (c['visible'] != 0)
          ChapterRef(
            number: ++number,
            title: squash(c['title'] as String? ?? 'Chapter $number'),
            url: base.resolve(c['url'] as String),
            locked: c['isUnlocked'] == false,
          ),
    ];
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final html = await fetcher.getText(chapter.url);
    final doc = parseHtml(html);
    final content = doc.querySelector('.chapter-inner.chapter-content');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    // Royal Road hides anti-piracy sentences in paragraphs whose class is set
    // to display: none in an inline stylesheet.
    for (final style in doc.querySelectorAll('style')) {
      for (final m in RegExp(
        r'\.([\w-]+)\s*\{[^}]*display:\s*none',
      ).allMatches(style.text)) {
        for (final hidden in content.querySelectorAll('.${m.group(1)}')) {
          hidden.remove();
        }
      }
    }
    return ChapterContent(
      title: textOf(doc.querySelector('.fic-header h1, h1.font-white')),
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
