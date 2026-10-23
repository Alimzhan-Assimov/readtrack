import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Standard Ebooks. The "single page" edition holds the whole book, with one
/// `<section epub:type="… chapter …">` per chapter.
class StandardEbooksSource extends StorySource {
  const StandardEbooksSource();

  static const _host = 'standardebooks.org';

  /// The last single-page edition, so many chapters fetch it only once.
  static ({Uri url, dom.Document doc})? _lastBook;

  @override
  String get name => 'Standard Ebooks';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.http;

  /// Book links: /ebooks/author/title[/translator], optionally followed by
  /// /text/… or /downloads/….
  @override
  Uri? storyUrl(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length < 3 || segments.first != 'ebooks') return null;
    final book = segments
        .skip(1)
        .takeWhile((s) => s != 'text' && s != 'downloads')
        .toList();
    if (book.length < 2) return null;
    return Uri.https(_host, '/ebooks/${book.join('/')}');
  }

  static Uri _singlePage(Uri storyUrl) =>
      Uri.parse('$storyUrl/text/single-page');

  static Future<dom.Document> _book(Uri url, PageFetcher fetcher) async {
    final cached = _lastBook;
    if (cached != null && cached.url == url) return cached.doc;
    final doc = parseHtml(await fetcher.getText(url));
    _lastBook = (url: url, doc: doc);
    return doc;
  }

  static List<dom.Element> _chapters(dom.Document doc) => [
    for (final section in doc.querySelectorAll('section'))
      if ((section.attributes['epub:type'] ?? '')
          .split(' ')
          .contains('chapter'))
        section,
  ];

  static String _sectionTitle(dom.Element section, int number) {
    final heading = section.querySelector('h2, h3, h4, header');
    return textOf(heading) ?? 'Chapter $number';
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final page = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(page.querySelector('h1'));
    if (title == null) {
      throw SourceException('This is not a Standard Ebooks book page.');
    }
    final book = await _book(_singlePage(storyUrl), fetcher);
    final chapters = _chapters(book);
    final cover = page
        .querySelector('#cover img, img[src*="cover"]')
        ?.attributes['src'];

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.book,
      title: title,
      author: textOf(
        page.querySelector(
          '[property="schema:author"] [property="schema:name"]',
        ),
      ),
      summary: textOf(
        page.querySelector('#description [property="schema:description"]'),
      ),
      coverUrl: cover == null ? null : storyUrl.resolve(cover),
      tags: [
        for (final a in page.querySelectorAll('ul.tags a')) squash(a.text),
      ],
      isComplete: true,
      chapters: [
        for (final (i, section) in chapters.indexed)
          ChapterRef(
            number: i + 1,
            title: _sectionTitle(section, i + 1),
            url: _singlePage(storyUrl).replace(fragment: section.id),
          ),
      ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final book = await _book(chapter.url.removeFragment(), fetcher);
    final section = book.getElementById(chapter.url.fragment);
    if (section == null) {
      throw SourceException('"${chapter.title}" was not found in the book.');
    }
    final copy = section.clone(true);
    copy
        .querySelector('h2, h3, header')
        ?.remove(); // shown as the chapter title
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(copy, base: chapter.url),
    );
  }
}
