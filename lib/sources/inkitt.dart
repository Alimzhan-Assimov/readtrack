import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Inkitt.
class InkittSource extends StorySource {
  const InkittSource();

  static const _host = 'www.inkitt.com';

  @override
  String get name => 'Inkitt';

  @override
  List<String> get hosts => const ['inkitt.com'];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/stories/(?:[^/]+/)?(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/stories/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1.story-title, h1'));
    if (title == null) {
      throw SourceException('This is not an Inkitt story page.');
    }
    final seen = <String>{};
    final links = [
      for (final a in doc.querySelectorAll('a.chapter-link'))
        if (seen.add(a.attributes['href'] ?? '')) a,
    ];
    final cover = metaContent(doc, 'og:image');
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author:
          textOf(
            doc.querySelector(
              '.author-block a.author-link:not([data-cta="Profile Picture"])',
            ),
          ) ??
          doc.querySelector('.author-block img')?.attributes['alt'],
      summary: textOf(doc.querySelector('p.story-summary')),
      coverUrl: cover == null ? null : Uri.parse(cover),
      isComplete: doc.querySelector('.story-status-complete') != null
          ? true
          : doc.querySelector('[class*="story-status-"]') != null
          ? false
          : null,
      chapters: [
        for (final (i, a) in links.indexed)
          ChapterRef(
            number: i + 1,
            title:
                textOf(a.querySelectorAll('span').lastOrNull) ??
                'Chapter ${i + 1}',
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
    final content = doc.querySelector('#chapterText');
    if (content == null) {
      throw SourceException(
        '"${chapter.title}" is only available in the Inkitt app.',
      );
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
