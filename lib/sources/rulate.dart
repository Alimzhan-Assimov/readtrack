import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Rulate (tl.rulate.ru), translated web novels. Paid chapters are locked.
class RulateSource extends StorySource {
  const RulateSource();

  static const _host = 'tl.rulate.ru';

  @override
  String get name => 'Rulate';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/book/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/book/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1 [itemprop="name"], h1'));
    if (title == null) throw SourceException('This is not a Rulate book page.');
    // "Выпуск: продолжается" / "завершён"
    final release = doc
        .querySelectorAll('p')
        .where(
          (p) =>
              textOf(p.querySelector('strong'))?.startsWith('Выпуск') ?? false,
        )
        .map((p) => textOf(p.querySelector('em'))?.toLowerCase())
        .firstOrNull;
    final rows = doc.querySelectorAll('tr.chapter_row');
    final cover = metaContent(doc, 'og:image');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      summary:
          metaContent(doc, 'ranobe:description') ??
          metaContent(doc, 'og:description'),
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: {
        for (final a in doc.querySelectorAll(
          'a[href*="genres%5B0%5D"], a[href*="tags%5B0%5D"]',
        ))
          ?textOf(a),
      }.toList(),
      isComplete: release == null
          ? null
          : release.contains('заверш')
          ? true
          : release.contains('продолжа')
          ? false
          : null,
      chapters: [
        for (final (i, row) in rows.indexed)
          if (row.querySelector('td.t a') case final a?)
            ChapterRef(
              number: i + 1,
              title: squash(a.text),
              url: storyUrl.resolve(a.attributes['href']!),
              // Paid chapters have a price checkbox for buying them.
              locked: row.querySelector('input[data-price]') != null,
            ),
      ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    if (chapter.locked) {
      throw SourceException('"${chapter.title}" is a paid chapter on Rulate.');
    }
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('.content-text');
    if (content == null) {
      throw SourceException(
        '"${chapter.title}" is not available to read for free on Rulate.',
      );
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
