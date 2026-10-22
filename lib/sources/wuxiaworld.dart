import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Wuxiaworld. Chapter pages follow a fixed pattern, and teaser (paid)
/// chapters are marked in the page data.
class WuxiaworldSource extends StorySource {
  const WuxiaworldSource();

  static const _host = 'www.wuxiaworld.com';

  @override
  String get name => 'Wuxiaworld';

  @override
  List<String> get hosts => const ['wuxiaworld.com'];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/novel/([^/]+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/novel/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final html = await fetcher.getText(storyUrl);
    final doc = parseHtml(html);
    final title = textOf(doc.querySelector('h1'));
    if (title == null) {
      throw SourceException('This is not a Wuxiaworld novel page.');
    }

    // The chapter list isn't in the page, but the count and the link pattern
    // ("/novel/beyond-the-zenith/bz-chapter-1") are.
    final count =
        parseCount(
          RegExp(r'"chapterCount":\{"value":(\d+)\}')
              .firstMatch(html)
              ?.group(1),
        ) ??
        0;
    final first = RegExp(
      'href="${RegExp.escape(storyUrl.path)}/([^"/]*?-chapter-)1"',
    ).firstMatch(html)?.group(1);
    final author = RegExp(r'"authorName":\{"value":"([^"]+)"')
        .firstMatch(html)
        ?.group(1);
    final cover = metaContent(doc, 'og:image');
    final synopsis = doc
        .querySelectorAll('h4')
        .where((h) => squash(h.text) == 'Synopsis')
        .firstOrNull;

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: author,
      summary: textOf(synopsis?.nextElementSibling),
      coverUrl: cover == null ? null : Uri.parse(cover),
      isComplete: html.contains('>Completed<')
          ? true
          : html.contains('>Ongoing<')
          ? false
          : null,
      chapters: first == null
          ? const []
          : [
              for (var n = 1; n <= count; n++)
                ChapterRef(
                  number: n,
                  title: 'Chapter $n',
                  url: Uri.https(_host, '${storyUrl.path}/$first$n'),
                ),
            ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final html = await fetcher.getText(chapter.url);
    final slug = chapter.url.pathSegments.last;
    if (RegExp('"slug":"${RegExp.escape(slug)}"[^}]*?"isTeaser":true')
        .hasMatch(html)) {
      throw SourceException(
        '"${chapter.title}" is a paid chapter on Wuxiaworld.',
      );
    }
    final doc = parseHtml(html);
    final content = doc.querySelector('.chapter-content');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title:
          textOf(
            doc.querySelector('.chapter-content')?.parent?.querySelector('h4'),
          ) ??
          metaContent(
            doc,
            'og:title',
          )?.replaceFirst(RegExp(r'^.*? - (?=Chapter)'), '') ??
          chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
