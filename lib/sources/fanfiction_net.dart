import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// FanFiction.Net and its sister site FictionPress (original fiction), which
/// share the same markup. Behind Cloudflare, so read through the browser.
class FanFictionNetSource extends StorySource {
  const FanFictionNetSource()
    : name = 'FanFiction.Net',
      _host = 'www.fanfiction.net',
      _type = WorkType.fanfiction;

  const FanFictionNetSource.fictionPress()
    : name = 'FictionPress',
      _host = 'www.fictionpress.com',
      _type = WorkType.webnovel;

  @override
  final String name;
  final String _host;
  final WorkType _type;

  /// FanFiction.Net's genre list. "Hurt/Comfort" contains the separator that
  /// joins genres, so genres are matched instead of split.
  static const _genres = [
    'Hurt/Comfort',
    'Adventure',
    'Angst',
    'Crime',
    'Drama',
    'Family',
    'Fantasy',
    'Friendship',
    'General',
    'Horror',
    'Humor',
    'Mystery',
    'Parody',
    'Poetry',
    'Romance',
    'Sci-Fi',
    'Spiritual',
    'Supernatural',
    'Suspense',
    'Tragedy',
    'Western',
  ];

  @override
  List<String> get hosts => [_host.substring(4)];

  @override
  FetchMode get fetchMode => FetchMode.browser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/s/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/s/${match.group(1)}/1');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final profile = doc.querySelector('#profile_top');
    final title = textOf(profile?.querySelector('b.xcontrast_txt'));
    if (profile == null || title == null) {
      throw SourceException('This is not a $name story page.');
    }
    final meta = textOf(profile.querySelector('span.xgray')) ?? '';
    final segments = meta.split(' - ').map((s) => s.trim()).toList();
    String? field(String label) => segments
        .where((s) => s.startsWith('$label:'))
        .map((s) => s.substring(label.length + 1).trim())
        .firstOrNull;
    final genres = {
      for (final segment in segments.take(4))
        for (final genre in _genres)
          if (segment.split('/').contains(genre) ||
              (genre.contains('/') && segment.contains(genre)))
            genre,
    }.toList();
    final image = profile.querySelector('img.cimage')?.attributes['src'];
    final storyId = RegExp(r'^/s/(\d+)').firstMatch(storyUrl.path)!.group(1);

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: _type,
      title: title,
      author: textOf(profile.querySelector('a[href^="/u/"]')),
      summary: textOf(profile.querySelector('div.xcontrast_txt')),
      coverUrl: image == null || image.contains('/static/')
          ? null
          // "/image/123/75/" is a thumbnail; 180 is the largest size.
          : storyUrl.resolve(image.replaceFirst(RegExp(r'/75/$'), '/180/')),
      // FictionPress shows a genre category here instead of a fandom.
      fandom: _type == WorkType.fanfiction
          ? textOf(doc.querySelectorAll('#pre_story_links a').lastOrNull)
          : null,
      tags: genres,
      wordCount: parseCount(field('Words')),
      isComplete: field('Status') == 'Complete',
      chapters: _chapters(doc, storyId!, title),
    );
  }

  List<ChapterRef> _chapters(
    dom.Document doc,
    String storyId,
    String storyTitle,
  ) {
    final options =
        doc.querySelector('select#chap_select')?.querySelectorAll('option') ??
        const <dom.Element>[];
    if (options.isEmpty) {
      return [
        ChapterRef(
          number: 1,
          title: storyTitle,
          url: Uri.https(_host, '/s/$storyId/1'),
        ),
      ];
    }
    return [
      for (final option in options)
        if (int.tryParse(option.attributes['value'] ?? '') case final number?)
          ChapterRef(
            number: number,
            // "12. Title" -> "Title"
            title: squash(option.text).replaceFirst(RegExp(r'^\d+\.\s*'), ''),
            url: Uri.https(_host, '/s/$storyId/$number'),
          ),
    ];
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('#storytext');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
