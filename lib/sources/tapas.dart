import 'dart:convert';

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Tapas novels. Episodes come from a JSON list; paid ones are locked.
class TapasSource extends StorySource {
  const TapasSource();

  static const _host = 'tapas.io';

  /// The episode list allows at most 20 per page.
  static const _pageSize = 20;
  static const _maxPages = 200;

  @override
  String get name => 'Tapas';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/series/([^/]+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/series/${match.group(1)}/info');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final html = await fetcher.getText(storyUrl);
    final doc = parseHtml(html);
    final title =
        metaContent(doc, 'og:title')?.replaceFirst(RegExp(r'^Read\s+'), '') ??
        textOf(doc.querySelector('.title'));
    final id = RegExp(r'subscribers\?series_id=(\d+)')
        .firstMatch(html)
        ?.group(1);
    if (title == null || id == null) {
      throw SourceException('This is not a Tapas series page.');
    }

    final chapters = <ChapterRef>[];
    for (var page = 1; page <= _maxPages; page++) {
      final json = jsonDecode(
        await fetcher.getText(
          Uri.https(_host, '/series/$id/episodes', {
            'page': '$page',
            'sort': 'OLDEST',
            'max_limit': '$_pageSize',
          }),
          headers: const {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json',
          },
        ),
      ) as Map<String, Object?>;
      final data = json['data'] as Map<String, Object?>?;
      for (final e
          in (data?['episodes'] as List? ?? const [])
              .cast<Map<String, Object?>>()) {
        chapters.add(
          ChapterRef(
            number: chapters.length + 1,
            title: e['title'] as String? ?? 'Episode ${chapters.length + 1}',
            url: Uri.https(_host, '/episode/${e['id']}'),
            locked: e['free'] != true && e['unlocked'] != true,
          ),
        );
      }
      if ((data?['pagination'] as Map?)?['has_next'] != true) break;
    }

    final cover = metaContent(doc, 'og:image');
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title.replaceFirst(RegExp(r'\s*\|\s*Tapas.*$'), ''),
      author: textOf(doc.querySelector('.creator__item, a.creator')),
      summary: textOf(doc.querySelector('.description__body')),
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: {
        for (final a in doc.querySelectorAll('a.genre-btn')) squash(a.text),
      }.toList(),
      chapters: chapters,
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    if (chapter.locked) {
      throw SourceException('"${chapter.title}" is a paid episode on Tapas.');
    }
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector(
      'article.js-episode-article, .viewer__body',
    );
    if (content == null) {
      throw SourceException('Episode "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
