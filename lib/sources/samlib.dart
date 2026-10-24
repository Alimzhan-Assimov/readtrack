import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Samlib (Журнал «Самиздат»). Each work is a single page, encoded in
/// KOI8-R; it becomes a single chapter.
class SamlibSource extends StorySource {
  const SamlibSource();

  static const _host = 'samlib.ru';

  @override
  String get name => 'Samlib';

  @override
  List<String> get hosts => const [_host, 'zhurnal.lib.ru', 'budclub.ru'];

  @override
  FetchMode get fetchMode => FetchMode.http;

  /// Works: /a/author_name/work.shtml (author indexes are not works).
  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/\w/[\w-]+/([\w-]+)\.shtml$').firstMatch(uri.path);
    if (match == null || match.group(1)!.startsWith('index')) return null;
    return Uri.http(_host, uri.path);
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final heading = doc.querySelector('h2');
    final author = textOf(heading?.querySelector('small'));
    heading?.querySelector('small')?.remove();
    final title = textOf(heading);
    if (title == null) throw SourceException('This is not a Samlib work page.');
    final annotation = doc
        .querySelectorAll('li')
        .where((li) => li.text.contains('Аннотация:'))
        .firstOrNull
        ?.querySelector('i');

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: author,
      summary: textOf(annotation),
      chapters: [ChapterRef(number: 1, title: title, url: storyUrl)],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final html = await fetcher.getText(chapter.url);
    // The text sits between "<!-- Собственно произведение -->" and the
    // rating form at the bottom of the page.
    final marker = html.indexOf('Собственно произведение');
    final start = marker < 0 ? -1 : html.indexOf('-->', marker);
    if (start < 0) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    var end = html.lastIndexOf('<form');
    if (end <= start) end = html.length;
    final text = parseHtml('<div>${html.substring(start + 3, end)}</div>')
        .body!;
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(text, base: chapter.url),
    );
  }
}
