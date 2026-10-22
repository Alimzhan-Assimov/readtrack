import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Forums running XenForo with threadmarks: SpaceBattles, Sufficient
/// Velocity and Questionable Questing. A story is a thread; each threadmark
/// (marked post) is a chapter.
class XenForoSource extends StorySource {
  const XenForoSource(this.name, this._host);

  static const spaceBattles = XenForoSource(
    'SpaceBattles',
    'forums.spacebattles.com',
  );
  static const sufficientVelocity = XenForoSource(
    'Sufficient Velocity',
    'forums.sufficientvelocity.com',
  );
  static const questionableQuesting = XenForoSource(
    'Questionable Questing',
    'forum.questionablequesting.com',
  );

  @override
  final String name;
  final String _host;

  /// Safety limit for the paginated threadmark list (25 per page).
  static const _maxPages = 200;

  @override
  List<String> get hosts => [_host];

  // Thread pages are often behind Cloudflare, forum pages sometimes aren't.
  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/threads/([^/]*\.)?(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(
      _host,
      '/threads/${match.group(1) ?? ''}${match.group(2)}/',
    );
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1.p-title-value'));
    if (title == null) throw SourceException('This is not a $name thread.');

    final chapters = <ChapterRef>[];
    var words = 0;
    for (var page = 1; page <= _maxPages; page++) {
      final list = parseHtml(
        await fetcher.getText(
          storyUrl.resolve('threadmarks?per_page=25&page=$page'),
        ),
      );
      final rows = list.querySelectorAll(
        '.structItem--threadmark .structItem-title a',
      );
      for (final a in rows) {
        final post = RegExp(r'post-(\d+)')
            .firstMatch(a.attributes['href'] ?? '')
            ?.group(1);
        if (post == null) continue;
        chapters.add(
          ChapterRef(
            number: chapters.length + 1,
            title: squash(a.text),
            url: Uri.https(_host, '/posts/$post/'),
          ),
        );
      }
      for (final dd in list.querySelectorAll(
        '.structItem--threadmark .pairs dd',
      )) {
        words += _parseShortCount(dd.text);
      }
      if (rows.isEmpty || list.querySelector('a.pageNav-jump--next') == null) {
        break;
      }
    }

    final firstPost = doc.querySelector('article.message');
    final image = metaContent(doc, 'og:image');
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.fanfiction,
      title: title,
      author: firstPost?.attributes['data-author'],
      summary:
          metaContent(doc, 'og:description') ?? metaContent(doc, 'description'),
      coverUrl: image != null && image.contains('threadmark-index-icons')
          ? Uri.parse(image)
          : null,
      tags: [for (final t in doc.querySelectorAll('a.tagItem')) squash(t.text)],
      wordCount: words == 0 ? null : words,
      chapters: chapters,
    );
  }

  /// "6.9k" -> 6900, "1.2m" -> 1200000, "812" -> 812
  static int _parseShortCount(String text) {
    final match = RegExp(
      r'([\d.,]+)\s*([km]?)',
      caseSensitive: false,
    ).firstMatch(text.trim());
    if (match == null) return 0;
    final value = double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
    final factor = switch (match.group(2)!.toLowerCase()) {
      'k' => 1000,
      'm' => 1000000,
      _ => 1,
    };
    return (value * factor).round();
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final post = RegExp(r'/posts/(\d+)').firstMatch(chapter.url.path)?.group(1);
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final article =
        doc.querySelector('[data-content="post-$post"]') ??
        doc.querySelector('#js-post-$post');
    final body = article?.querySelector('.bbWrapper');
    if (body == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    // Spoiler buttons and "click to expand" links are UI, not text.
    for (final ui in body.querySelectorAll(
      '.bbCodeSpoiler-button, .bbCodeBlock-expandLink, .bbCodeBlock-title, script',
    )) {
      ui.remove();
    }
    _useFullImages(body);
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(body, base: chapter.url),
    );
  }

  /// Lazy-loaded images keep the real address in data-url.
  static void _useFullImages(dom.Element body) {
    for (final img in body.querySelectorAll('img')) {
      final full = img.attributes['data-url'];
      if (full != null && full.isNotEmpty) img.attributes['src'] = full;
    }
  }
}
