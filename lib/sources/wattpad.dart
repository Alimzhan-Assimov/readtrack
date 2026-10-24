import 'dart:convert';

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Wattpad, through its public JSON API (the web pages are built in the
/// browser).
class WattpadSource extends StorySource {
  const WattpadSource();

  static const _host = 'www.wattpad.com';

  /// Part text is paged; stop after this many pages per part.
  static const _maxPages = 50;

  @override
  String get name => 'Wattpad';

  @override
  List<String> get hosts => const ['wattpad.com'];

  @override
  FetchMode get fetchMode => FetchMode.http;

  /// Story links: /story/123-title. Part links: /456-title (resolved to the
  /// story when the details are loaded).
  @override
  Uri? storyUrl(Uri uri) {
    final story = RegExp(r'^/story/(\d+)').firstMatch(uri.path);
    if (story != null) return Uri.https(_host, '/story/${story.group(1)}');
    final part = RegExp(r'^/(\d+)(?:-|$)').firstMatch(uri.path);
    if (part != null) return Uri.https(_host, '/${part.group(1)}');
    return null;
  }

  /// Reading lists (/list/123-name) come from the API.
  @override
  Future<List<ListedStory>> fetchList(
    Uri url,
    PageFetcher fetcher, {
    int maxPages = 50,
  }) async {
    final id = RegExp(r'^/list/(\d+)').firstMatch(url.path)?.group(1);
    if (id == null) return super.fetchList(url, fetcher, maxPages: maxPages);
    final stories = <ListedStory>[];
    Uri? page = Uri.https(_host, '/api/v3/lists/$id/stories', {
      'limit': '100',
      'fields': 'stories(id,title),nextUrl',
    });
    for (var n = 0; page != null && n < maxPages; n++) {
      final json = jsonDecode(await fetcher.getText(page)) as Map;
      for (final s in (json['stories'] as List? ?? const [])) {
        stories.add((
          url: Uri.https(_host, '/story/${(s as Map)['id']}'),
          title: '${s['title']}',
        ));
      }
      final next = json['nextUrl'] as String?;
      page = next == null ? null : Uri.parse(next);
    }
    return stories;
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    var id = RegExp(r'^/story/(\d+)').firstMatch(storyUrl.path)?.group(1);
    if (id == null) {
      // A part link: ask the API which story it belongs to.
      final partId = RegExp(r'^/(\d+)').firstMatch(storyUrl.path)!.group(1);
      final part = jsonDecode(
        await fetcher.getText(
          Uri.https(_host, '/api/v3/story_parts/$partId', {
            'fields': 'groupId',
          }),
        ),
      ) as Map<String, Object?>;
      id = '${part['groupId']}';
    }
    final json = jsonDecode(
      await fetcher.getText(
        Uri.https(_host, '/api/v3/stories/$id', {
          'fields':
              'id,title,user(name),description,cover,completed,tags,mainCategory,'
              'parts(id,title,wordCount,url,draft,deleted)',
        }),
      ),
    ) as Map<String, Object?>;
    final title = json['title'] as String?;
    if (title == null) {
      throw SourceException('This Wattpad story could not be found.');
    }

    final parts = [
      for (final p
          in (json['parts'] as List? ?? const []).cast<Map<String, Object?>>())
        if (p['draft'] != true && p['deleted'] != true) p,
    ];
    final words = parts.fold<int>(
      0,
      (sum, p) => sum + ((p['wordCount'] as num?)?.toInt() ?? 0),
    );
    final tags = (json['tags'] as List? ?? const []).cast<String>();
    final cover = json['cover'] as String?;
    return StoryInfo(
      url: Uri.https(_host, '/story/$id'),
      siteName: name,
      type: tags.any((t) => t.toLowerCase().contains('fanfic'))
          ? WorkType.fanfiction
          : WorkType.webnovel,
      title: title,
      author: (json['user'] as Map?)?['name'] as String?,
      summary: json['description'] as String?,
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: tags,
      wordCount: words == 0 ? null : words,
      isComplete: json['completed'] as bool?,
      chapters: [
        for (final (i, p) in parts.indexed)
          ChapterRef(
            number: i + 1,
            title: p['title'] as String? ?? 'Part ${i + 1}',
            url: Uri.parse(p['url'] as String? ?? 'https://$_host/${p['id']}'),
          ),
      ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final partId = RegExp(r'^/(\d+)').firstMatch(chapter.url.path)?.group(1);
    if (partId == null) {
      throw SourceException('Unknown Wattpad part link: ${chapter.url}');
    }
    final pages = StringBuffer();
    for (var page = 1; page <= _maxPages; page++) {
      final html = await fetcher.getText(
        Uri.https(_host, '/apiv2/', {
          'm': 'storytext',
          'id': partId,
          'page': '$page',
        }),
      );
      if (html.trim().isEmpty) break;
      pages.write(html);
    }
    if (pages.isEmpty) {
      throw SourceException(
        '"${chapter.title}" is not available without logging in to Wattpad.',
      );
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(parseHtml('<div>$pages</div>').body!, base: chapter.url),
    );
  }
}
