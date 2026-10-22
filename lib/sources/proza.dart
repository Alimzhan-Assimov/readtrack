import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Proza.ru. Each work is a single page (Windows-1251) and a single chapter.
class ProzaSource extends StorySource {
  const ProzaSource();

  static const _host = 'proza.ru';

  @override
  String get name => 'Proza.ru';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.http;

  /// Works: /2026/10/22/2136
  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/(\d{4}/\d{2}/\d{2}/\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1'));
    if (title == null) {
      throw SourceException('This is not a Proza.ru work page.');
    }
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: textOf(doc.querySelector('.titleauthor a')),
      chapters: [ChapterRef(number: 1, title: title, url: storyUrl)],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('div.text');
    if (content == null) {
      throw SourceException('"${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
