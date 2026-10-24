import 'dart:convert';

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Honeyfeed. Behind Cloudflare, so it uses the browser.
class HoneyfeedSource extends StorySource {
  const HoneyfeedSource();

  static const _host = 'www.honeyfeed.fm';

  @override
  String get name => 'Honeyfeed';

  @override
  List<String> get hosts => const ['honeyfeed.fm'];

  @override
  FetchMode get fetchMode => FetchMode.browser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/novels/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/novels/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final html = await fetcher.getText(storyUrl);
    final doc = parseHtml(html);
    final title = metaContent(
      doc,
      'og:title',
    )?.replaceFirst(RegExp(r'\s*\|\s*Honeyfeed$'), '');
    if (title == null) {
      throw SourceException('This is not a Honeyfeed novel page.');
    }
    // The JSON-LD block lists the genres as keywords.
    final keywords = RegExp(r'"keywords":\[([^\]]*)\]')
        .firstMatch(html)
        ?.group(1);
    final links = doc.querySelectorAll('ul.list-chapter a[href^="/chapters/"]');
    final cover = metaContent(doc, 'og:image');
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      // The first author link wraps the avatar; the next one has the name.
      author: doc
          .querySelectorAll('a[data-gtm-click="link-novelUser-novelsShow"]')
          .map(textOf)
          .nonNulls
          .firstOrNull,
      summary: metaContent(doc, 'og:description'),
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: keywords == null
          ? const []
          : (jsonDecode('[$keywords]') as List).cast<String>(),
      isComplete: html.contains('>Completed<')
          ? true
          : html.contains('>Ongoing<')
          ? false
          : null,
      chapters: [
        for (final (i, a) in links.indexed)
          ChapterRef(
            number: i + 1,
            title: textOf(a.querySelector('.text-bold')) ?? 'Chapter ${i + 1}',
            url: storyUrl.resolve(a.attributes['href']!),
          ),
      ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('.wrap-body');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: textOf(doc.querySelector('h1')) ?? chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
