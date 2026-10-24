import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// WebNovel. Behind Cloudflare, so it is read through the browser. Chapter
/// text is taken from the rendered page, exactly as a reader sees it; paid
/// chapters are marked as locked and never unlocked.
class WebnovelSource extends StorySource {
  const WebnovelSource();

  static const _host = 'www.webnovel.com';

  @override
  String get name => 'WebNovel';

  @override
  List<String> get hosts => const ['webnovel.com'];

  @override
  FetchMode get fetchMode => FetchMode.browser;

  /// Book links look like /book/some-title_12345 or /book/12345, optionally
  /// followed by a chapter.
  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/book/(?:[^/]*_)?(\d{6,})').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/book/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1'));
    if (title == null) {
      throw SourceException('This is not a WebNovel book page.');
    }

    final genre = doc.querySelector('a.det-hd-tag');
    final isFanfic =
        genre?.attributes['href']?.contains('/stories/fanfic') ?? false;
    final author = RegExp(r'Author:\s*([^\n]+?)\s*(?:more|Translator|Editor|$)')
        .firstMatch(textOf(doc.querySelector('address')) ?? '')
        ?.group(1);
    final cover = metaContent(doc, 'og:image');
    final synopsis = doc.querySelector('.j_synopsis');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: isFanfic ? WorkType.fanfiction : WorkType.webnovel,
      title: title,
      author: author,
      summary: synopsis == null
          ? null
          : htmlToPlainText(cleanHtml(synopsis, base: storyUrl)),
      coverUrl: cover == null ? null : storyUrl.resolve(cover),
      fandom: isFanfic ? genre?.attributes['title'] : null,
      tags: [
        for (final a in doc.querySelectorAll('.m-tags a'))
          squash(a.text).replaceFirst(RegExp(r'^#\s*'), ''),
      ],
      // The book page doesn't show the status reliably, so it stays unknown.
      chapters: await _chapters(storyUrl, fetcher),
    );
  }

  Future<List<ChapterRef>> _chapters(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(
      await fetcher.getText(Uri.parse('$storyUrl/catalog')),
    );
    final items = doc.querySelectorAll('.content-list li[data-cid]');
    return [
      for (final (i, li) in items.indexed)
        if (li.querySelector('a') case final a?)
          ChapterRef(
            number: i + 1,
            title: a.attributes['title'] ?? squash(a.text),
            url: storyUrl.resolve(a.attributes['href']!),
            // Paid chapters show a lock icon (<use xlink:href="#i-lock">).
            locked: li.innerHtml.contains('#i-lock'),
          ),
    ];
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    if (chapter.locked) {
      throw SourceException(
        '"${chapter.title}" is a paid chapter on WebNovel.',
      );
    }
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('.cha-content');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    if (content.classes.contains('_lock')) {
      throw SourceException(
        '"${chapter.title}" is a paid chapter on WebNovel.',
      );
    }
    // Paragraph comment counters are part of each paragraph's markup.
    for (final counter in content.querySelectorAll(
      '.para-comment, .para-comment_num',
    )) {
      counter.remove();
    }
    final paragraphs = content.querySelectorAll(
      '.cha-paragraph p, .cha-words p',
    );
    final html = paragraphs.isEmpty
        ? cleanHtml(content, base: chapter.url)
        : cleanHtml(
            parseHtml(paragraphs.map((p) => p.outerHtml).join()).body!,
            base: chapter.url,
          );
    return ChapterContent(
      title: textOf(doc.querySelector('.cha-tit h1')) ?? chapter.title,
      // Chapters start with a "..." teaser paragraph.
      html: html.replaceFirst(RegExp(r'^<p>\s*(?:\.\.\.|…)\s*</p>'), ''),
    );
  }
}
