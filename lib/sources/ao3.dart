import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Archive of Our Own. Plain HTTP is sometimes refused, so it falls back to
/// the browser.
class Ao3Source extends StorySource {
  const Ao3Source();

  static const _host = 'archiveofourown.org';

  @override
  String get name => 'AO3';

  @override
  List<String> get hosts => const [_host, 'ao3.org'];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/works/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/works/${match.group(1)}');
  }

  /// "Part 2 of the <a>Name</a> series" (the first series, if several).
  static ({String name, double? index})? _series(dom.Document doc) {
    // In two steps: package:html's "dd.series span.position" stops at the
    // inner span.series and finds nothing.
    final position = doc
        .querySelector('dd.series')
        ?.querySelector('span.position');
    final name = textOf(position?.querySelector('a'));
    if (position == null || name == null) return null;
    final part = RegExp(r'Part (\d+)').firstMatch(position.text)?.group(1);
    return (name: name, index: part == null ? null : double.parse(part));
  }

  /// Bookmarks, collections, series and works listings use the same blurbs.
  @override
  List<String> get listLinkSelectors => const [
    'li.blurb h4.heading a[href*="/works/"]',
  ];

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(
      await fetcher.getText(
        storyUrl.replace(queryParameters: {'view_adult': 'true'}),
      ),
    );
    final title = textOf(doc.querySelector('h2.title'));
    if (title == null) {
      throw SourceException(
        doc.querySelector('#signin, .flash.error') != null
            ? 'This AO3 work is only visible to logged-in users.'
            : 'This is not an AO3 work page.',
      );
    }
    List<String> tags(String cls) => [
      for (final a in doc.querySelectorAll('dd.$cls.tags a.tag'))
        squash(a.text),
    ];
    final authors = [
      for (final a in doc.querySelectorAll('h3.byline a[rel="author"]'))
        squash(a.text),
    ];
    final chapterStats = textOf(doc.querySelector('dd.chapters'))?.split('/');
    final summary = doc.querySelector('.summary blockquote.userstuff');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.fanfiction,
      title: title,
      author: authors.isEmpty
          ? textOf(doc.querySelector('h3.byline'))
          : authors.join(', '),
      summary: summary == null
          ? null
          : htmlToPlainText(cleanHtml(summary, base: storyUrl)),
      fandom: tags('fandom').firstOrNull,
      series: _series(doc),
      // "Uchiha Sasuke/Uzumaki Naruto" etc. are relationships, not tags.
      pairings: tags('relationship'),
      tags: tags('freeform'),
      wordCount: parseCount(textOf(doc.querySelector('dd.words'))),
      isComplete: chapterStats == null || chapterStats.length != 2
          ? null
          : chapterStats[0].trim() == chapterStats[1].trim(),
      // "Updated"/"Completed" date, or the publishing date for one-shots.
      updatedOn: DateTime.tryParse(
        textOf(doc.querySelector('dd.status')) ??
            textOf(doc.querySelector('dd.published')) ??
            '',
      ),
      chapters: await _chapters(storyUrl, fetcher),
    );
  }

  Future<List<ChapterRef>> _chapters(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(
      await fetcher.getText(Uri.parse('$storyUrl/navigate')),
    );
    final links = doc.querySelectorAll('ol.chapter.index li a');
    return [
      for (final (i, a) in links.indexed)
        ChapterRef(
          number: i + 1,
          // "1. Title" -> "Title"
          title: squash(a.text).replaceFirst(RegExp(r'^\d+\.\s*'), ''),
          url: storyUrl.resolve(a.attributes['href']!),
        ),
    ];
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final url = chapter.url.replace(queryParameters: {'view_adult': 'true'});
    final doc = parseHtml(await fetcher.getText(url));
    final content =
        doc.querySelector('#chapters .userstuff[role="article"]') ??
        doc.querySelector('#chapters > .userstuff, #chapters .userstuff');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    content.querySelector('h3.landmark')?.remove();
    return ChapterContent(
      title: textOf(doc.querySelector('.chapter .title')),
      html: cleanHtml(content, base: url),
    );
  }
}
