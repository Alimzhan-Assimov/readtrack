import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Ficbook (Книга Фанфиков), the largest Russian fanfiction archive.
class FicbookSource extends StorySource {
  const FicbookSource();

  static const _host = 'ficbook.net';

  @override
  String get name => 'Ficbook';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  /// Story ids are numbers on old links and UUIDs on new ones.
  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/readfic/([0-9a-f-]+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/readfic/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1[itemprop="name"], h1.heading'));
    if (title == null) {
      throw SourceException('This is not a Ficbook story page.');
    }

    // Details are blocks like <div class="mb-10"><strong>Фэндом:</strong>…</div>.
    dom.Element? block(String label) => doc
        .querySelectorAll('div.mb-10')
        .where(
          (d) => textOf(d.querySelector('strong'))?.startsWith(label) ?? false,
        )
        .firstOrNull;
    final size = textOf(block('Размер')) ?? '';
    final status =
        doc.querySelector('[class*="ds-label-status-"]')?.className ?? '';
    final description = doc.querySelector('[itemprop="description"]');
    final fandoms = block('Фэндом')?.querySelectorAll('a') ?? const [];

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: fandoms.isEmpty ? WorkType.webnovel : WorkType.fanfiction,
      title: title,
      author: textOf(doc.querySelector('a[itemprop="author"]')),
      summary: description == null
          ? null
          : _paragraphs(description, storyUrl, plain: true),
      fandom: fandoms.isEmpty ? null : textOf(fandoms.first),
      tags: [
        for (final a
            in block('Метки')?.querySelectorAll('a.tag') ??
                const <dom.Element>[])
          squash(a.text),
      ],
      // Ficbook marks adult tags itself.
      adultTags: {
        for (final a
            in block('Метки')?.querySelectorAll('a.tag-adult') ??
                const <dom.Element>[])
          squash(a.text),
      },
      // Pairing links contain "/" ("Какаши Хатаке/Наруто Узумаки"); the
      // others in that block are single characters.
      pairings: [
        for (final a
            in block('Пэйринг')?.querySelectorAll('a.pairing-link') ??
                const <dom.Element>[])
          if (squash(a.text).contains('/')) squash(a.text),
      ],
      // "написано 1 124 страницы, 553 964 слова, 74 части"
      pageCount: parseCount(
        RegExp(r'([\d\s]+)\s+страниц').firstMatch(size)?.group(1),
      ),
      wordCount: parseCount(
        RegExp(r'([\d\s]+)\s+слов').firstMatch(size)?.group(1),
      ),
      isComplete: status.contains('finished')
          ? true
          : status.contains('in-progress') || status.contains('frozen')
          ? false
          : null,
      chapters: _chapters(doc, storyUrl, title),
    );
  }

  List<ChapterRef> _chapters(dom.Document doc, Uri storyUrl, String title) {
    final links = doc.querySelectorAll('ul.list-of-fanfic-parts a.part-link');
    // Single-part stories have the text right on the story page.
    if (links.isEmpty) {
      return [ChapterRef(number: 1, title: title, url: storyUrl)];
    }
    return [
      for (final (i, a) in links.indexed)
        ChapterRef(
          number: i + 1,
          title: textOf(a.querySelector('.part-title')) ?? 'Часть ${i + 1}',
          url: storyUrl.resolve(a.attributes['href']!.split('#').first),
        ),
    ];
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('#content');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: textOf(doc.querySelector('#part_content h2')) ?? chapter.title,
      html: _paragraphs(content, chapter.url),
    );
  }

  /// Ficbook keeps line breaks as plain newlines (CSS `pre-line`), so each
  /// line becomes its own paragraph before cleaning.
  static String _paragraphs(
    dom.Element element,
    Uri base, {
    bool plain = false,
  }) {
    final lines = element.innerHtml
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);
    final html = cleanHtml(
      parseHtml('<div>${lines.map((l) => '<p>$l</p>').join()}</div>').body!,
      base: base,
    );
    return plain ? htmlToPlainText(html) : html;
  }
}
