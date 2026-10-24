import 'dart:convert';

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// LitMarket. Its reader loads the freely readable text as Draft.js-style
/// blocks; chapters start at blocks of type "chapter".
class LitMarketSource extends StorySource {
  const LitMarketSource();

  static const _host = 'litmarket.ru';

  @override
  String get name => 'LitMarket';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.http;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/(?:books|reader)/([a-z0-9-]+)$')
        .firstMatch(uri.path);
    final slug = match?.group(1);
    if (slug == null ||
        const {'genres', 'ebooks', 'audiobooks'}.contains(slug)) {
      return null;
    }
    return Uri.https(_host, '/books/$slug');
  }

  /// Opens the reader (for its session and CSRF token) and loads the reader
  /// data and the blocks.
  static Future<
    ({Map<String, Object?> book, List<Map<String, Object?>> blocks})
  >
  _load(String slug, PageFetcher fetcher) async {
    final reader = parseHtml(
      await fetcher.getText(Uri.https(_host, '/reader/$slug')),
    );
    final token = reader
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
    if (token == null) {
      throw SourceException('LitMarket did not open its reader.');
    }
    final headers = {
      'X-CSRF-TOKEN': token,
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json',
    };
    final data = jsonDecode(
      await fetcher.getText(
        Uri.https(_host, '/reader/data/$slug'),
        headers: headers,
      ),
    ) as Map<String, Object?>;
    final book = (data['book'] as Map?)?.cast<String, Object?>() ?? const {};
    final blocks = jsonDecode(
      await fetcher.getText(
        Uri.https(_host, '/reader/blocks/${book['ebookId']}'),
        headers: headers,
      ),
    ) as List;
    return (book: book, blocks: blocks.cast<Map<String, Object?>>());
  }

  static String _blockType(Map<String, Object?> block) =>
      (block['chunk'] as Map?)?['type'] as String? ?? '';

  static String _blockText(Map<String, Object?> block) => [
    for (final mod in ((block['chunk'] as Map?)?['mods'] as List? ?? const []))
      if (mod is Map && mod['type'] == 'INLINE') mod['text'] as String? ?? '',
  ].join();

  /// Splits blocks into chapters at "chapter" headings.
  static List<List<Map<String, Object?>>> _split(
    List<Map<String, Object?>> blocks,
  ) {
    final chapters = <List<Map<String, Object?>>>[];
    for (final block in blocks) {
      if (_blockType(block) == 'chapter' || chapters.isEmpty) chapters.add([]);
      chapters.last.add(block);
    }
    return chapters;
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final slug = storyUrl.pathSegments.last;
    final page = parseHtml(await fetcher.getText(storyUrl));
    final (:book, :blocks) = await _load(slug, fetcher);
    final title =
        book['bookName'] as String? ?? textOf(page.querySelector('h1'));
    if (title == null) {
      throw SourceException('This is not a LitMarket book page.');
    }
    final status = (book['ebookStatus'] as String? ?? '').toLowerCase();
    final cover =
        book['bookCoverSrc'] as String? ?? metaContent(page, 'og:image');
    final chapters = _split(blocks);

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: book['authorNickname'] as String?,
      summary: book['annotation'] as String?,
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: {
        for (final a in page.querySelectorAll('a[href*="/books/genres/"]'))
          ?textOf(a),
      }.toList(),
      isComplete: status.contains('заверш')
          ? true
          : status.contains('работе') || status.contains('процессе')
          ? false
          : null,
      chapters: [
        for (final (i, c) in chapters.indexed)
          ChapterRef(
            number: i + 1,
            title: _blockType(c.first) == 'chapter'
                ? squash(_blockText(c.first))
                : title,
            url: Uri.https(_host, '/reader/$slug', {'chapter': '${i + 1}'}),
          ),
      ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final slug = chapter.url.pathSegments.last;
    final index =
        int.tryParse(chapter.url.queryParameters['chapter'] ?? '') ?? 1;
    final chapters = _split((await _load(slug, fetcher)).blocks);
    if (index < 1 || index > chapters.length) {
      throw SourceException(
        '"${chapter.title}" is not available to read for free on LitMarket.',
      );
    }
    final html = StringBuffer();
    for (final block in chapters[index - 1]) {
      final text = const HtmlEscape(HtmlEscapeMode.element)
          .convert(_blockText(block));
      switch (_blockType(block)) {
        case 'chapter':
          break; // shown as the chapter title
        case 'header-one' || 'header-two' || 'header-three':
          html.write('<h3>$text</h3>');
        case 'blockquote':
          html.write('<blockquote><p>$text</p></blockquote>');
        case 'atomic':
          break; // images and the "to be continued" marker
        default:
          html.write('<p>$text</p>');
      }
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(parseHtml('<div>$html</div>').body!, base: chapter.url),
    );
  }
}
