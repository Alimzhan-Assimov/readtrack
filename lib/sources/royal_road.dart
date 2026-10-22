import 'dart:convert';

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
  List<ChapterRef> _chapters(String html, Uri base) {
    final json = RegExp(
      r'window\.chapters\s*=\s*(\[.*?\]);',
      dotAll: true,
    ).firstMatch(html)?.group(1);
    if (json == null) return const [];
    final list = (jsonDecode(json) as List).cast<Map<String, Object?>>();
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
