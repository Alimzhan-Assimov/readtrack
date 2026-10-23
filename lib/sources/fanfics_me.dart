import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Fanfics.me, a Russian fanfiction archive.
class FanficsMeSource extends StorySource {
  const FanficsMeSource();

  static const _host = 'fanfics.me';

  @override
  String get name => 'Fanfics.me';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  /// Story links: /fic123. Reader links: /read.php?id=123&chapter=0.
  @override
  Uri? storyUrl(Uri uri) {
    final id =
        RegExp(r'^/fic(\d+)').firstMatch(uri.path)?.group(1) ??
        (uri.path == '/read.php' ? uri.queryParameters['id'] : null);
    return id == null ? null : Uri.https(_host, '/fic$id');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final heading = doc.querySelector('h1');
    heading?.querySelector('span')?.remove(); // "(джен)" and similar labels
    final title = textOf(heading);
    if (title == null) {
      throw SourceException('This is not a Fanfics.me story page.');
    }

    // Details are rows: <div class="tr"><div class="title">Фандом:</div><div class="content">…
    dom.Element? field(String label) => doc
        .querySelectorAll('div.tr')
        .where(
          (r) => textOf(r.querySelector('.title'))?.startsWith(label) ?? false,
        )
        .firstOrNull
        ?.querySelector('.content');
    final size = textOf(doc.querySelector('#FicSize')) ?? '';
    final status = textOf(field('Статус'))?.toLowerCase() ?? '';
    final id = RegExp(r'^/fic(\d+)').firstMatch(storyUrl.path)!.group(1);
    final cover = metaContent(doc, 'og:image');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.fanfiction,
      title: title,
      author: textOf(
        field('Автор')?.querySelector('a') ??
            doc.querySelector('a[href^="/user"]'),
      ),
      summary: textOf(doc.querySelector('#summary_$id')),
      coverUrl: cover == null ? null : Uri.parse(cover),
      fandom: textOf(field('Фандом')?.querySelector('a')),
      tags: [
        ...?textOf(field('Жанр'))?.split(',').map((g) => g.trim()),
        for (final a
            in field('События')?.querySelectorAll('a') ?? const <dom.Element>[])
          squash(a.text),
      ],
      wordCount: parseCount(
        RegExp(r'([\d\s]+)\s+слов').firstMatch(size)?.group(1),
      ),
      pageCount: parseCount(
        RegExp(r'([\d\s]+)\s+страниц').firstMatch(size)?.group(1),
      ),
      isComplete: status.contains('закончен')
          ? true
          : status.contains('процессе') || status.contains('заморожен')
          ? false
          : null,
      chapters: [
        // Only links into the reader; the list also holds other links.
        for (final (i, a)
            in doc
                .querySelectorAll('ul.FicContents a[href*="read.php"]')
                .indexed)
          ChapterRef(
            number: i + 1,
            title: squash(a.text),
            url: storyUrl.resolve(a.attributes['href']!.split('#').first),
          ),
      ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final index = chapter.url.queryParameters['chapter'] ?? '0';
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('#c$index');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    // Paragraph anchors (<a name="c0p1">) carry no text.
    for (final anchor in content.querySelectorAll('a[name]')) {
      anchor.remove();
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
