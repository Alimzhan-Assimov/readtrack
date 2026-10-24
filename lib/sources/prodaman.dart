import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// ПродаМан (prodaman.ru). The reader shows the text in numbered pages; each
/// page becomes a chapter, named after the chapters it contains.
class ProdamanSource extends StorySource {
  const ProdamanSource();

  static const _host = 'prodaman.ru';

  @override
  String get name => 'ПродаМан';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  /// Books: /Author-Name/books/Book-Slug
  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/([\w-]+)/books/([\w-]+)$').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/${match.group(1)}/books/${match.group(2)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1[itemprop="name"], h1'));
    if (title == null) {
      throw SourceException('This is not a ПродаМан book page.');
    }
    final body = doc.body?.text.toLowerCase() ?? '';

    final reader = parseHtml(
      await fetcher.getText(storyUrl.replace(queryParameters: {'nav': 'ok'})),
    );
    final pageCount =
        parseCount(
          RegExp(r'из\s+(\d+)\s+страниц')
              .firstMatch(reader.body?.text ?? '')
              ?.group(1),
        ) ??
        1;
    // The table of contents maps chapter names to page numbers.
    final namesByPage = <int, List<String>>{};
    for (final option in reader.querySelectorAll(
      'select[name="page"] option',
    )) {
      final page = int.tryParse(option.attributes['value'] ?? '');
      final label = textOf(option);
      if (page == null || label == null || label == 'Начало текста') continue;
      namesByPage.putIfAbsent(page, () => []).add(label);
    }
    final cover = doc.querySelector('img.sam-detailed-pic')?.attributes['src'];

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: textOf(doc.querySelector('p.under-title a')),
      summary: textOf(doc.querySelector('[itemprop="description"]')),
      coverUrl: cover == null ? null : storyUrl.resolve(cover),
      isComplete: body.contains('в процессе написания')
          ? false
          : body.contains('завершен') || body.contains('закончен')
          ? true
          : null,
      chapters: [
        for (var page = 1; page <= pageCount; page++)
          ChapterRef(
            number: page,
            title: switch (namesByPage[page]) {
              final names? when names.length == 1 => names.single,
              final names? when names.isNotEmpty =>
                '${names.first} – ${names.last}',
              _ => 'Страница $page',
            },
            url: storyUrl.replace(queryParameters: {'page': '$page'}),
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
    final content = doc.querySelector('.blog-text.reader-box');
    if (content == null) {
      throw SourceException(
        '"${chapter.title}" is not available to read for free on ПродаМан.',
      );
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
