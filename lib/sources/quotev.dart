import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Quotev. Pages come back empty to plain HTTP clients, so it uses the
/// browser.
class QuotevSource extends StorySource {
  const QuotevSource();

  static const _host = 'www.quotev.com';

  @override
  String get name => 'Quotev';

  @override
  List<String> get hosts => const ['quotev.com'];

  @override
  FetchMode get fetchMode => FetchMode.browser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/story/(\d+)(/[^/]+)?').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/story/${match.group(1)}${match.group(2) ?? ''}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1'));
    if (title == null) {
      throw SourceException('This is not a Quotev story page.');
    }
    final links = doc.querySelectorAll('#rselectList a');
    final cover = metaContent(doc, 'og:image');
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.fanfiction,
      title: title,
      author: textOf(doc.querySelector('.quizAuthorList a[rel="author"]')),
      summary: metaContent(doc, 'og:description'),
      coverUrl: cover == null ? null : Uri.parse(cover),
      chapters: [
        for (final (i, a) in links.indexed)
          ChapterRef(
            number: i + 1,
            title: squash(a.text),
            url: Uri.parse(a.attributes['href']!),
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
    final content = doc.querySelector('#rescontent');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
