import '../data/enums.dart';
import 'fetcher.dart';
import 'source.dart';

/// Целлюлоза (zelluloza.ru) draws its text onto a canvas as copy protection,
/// so ReadTrack only imports the book details for tracking.
class ZellulozaSource extends StorySource {
  const ZellulozaSource();

  static const _host = 'zelluloza.ru';

  @override
  String get name => 'Целлюлоза';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  bool get canRead => false;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/books/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/books/${match.group(1)}/');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    // "Константин Муравьев. Неучтенный 3. Угроза клану"
    final heading = metaContent(doc, 'og:title');
    if (heading == null) {
      throw SourceException('This is not a Целлюлоза book page.');
    }
    final dot = heading.indexOf('. ');
    final stats = {
      for (final item in doc.querySelectorAll('.bookinfo-top__stats-item'))
        textOf(item.querySelector('.bookinfo-top__stats-label')) ?? '':
            textOf(item.querySelector('.bookinfo-top__stats-value')) ?? '',
    };
    final status = (stats['Статус произведения'] ?? '').toLowerCase();
    final cover = metaContent(doc, 'og:image');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.book,
      title: dot < 0 ? heading : heading.substring(dot + 2),
      author: dot < 0 ? null : heading.substring(0, dot),
      summary: metaContent(doc, 'description'),
      coverUrl: cover == null ? null : Uri.parse(cover),
      chapterCount: parseCount(stats['Количество глав']),
      isComplete: status.contains('процессе')
          ? false
          : status.contains('заверш')
          ? true
          : null,
      chapters: const [],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) => throw SourceException(
    'Целлюлоза protects its text, so it can only be read on the site.',
  );
}
