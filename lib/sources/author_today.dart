import 'dart:convert';

import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'author_today_fetcher.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// author.today, a Russian e-book platform. Only chapters that are free to
/// read are available; paid ones come back as an error.
class AuthorTodaySource extends StorySource {
  const AuthorTodaySource();

  static const _host = 'author.today';

  @override
  String get name => 'Author.Today';

  @override
  List<String> get hosts => const [_host];

  @override
  FetchMode get fetchMode => FetchMode.httpThenBrowser;

  @override
  PageFetcher createFetcher() => AuthorTodayFetcher();

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/(?:work|reader)/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/work/${match.group(1)}');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('h1.book-title'));
    if (title == null) {
      throw SourceException('This is not an Author.Today book page.');
    }

    final authors = [
      for (final a in doc.querySelectorAll('.book-authors a')) squash(a.text),
    ];
    final status = textOf(doc.querySelector('.book-status-icon')?.parent)
        ?.toLowerCase();
    final annotation = doc.querySelector('.annotation .rich-content');
    final cover = metaContent(doc, 'og:image');
    final links = doc.querySelectorAll(
      'ul.table-of-content li a[href^="/reader/"]',
    );

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      // Published chapter by chapter; the "Фанфик" genre makes it fan
      // fiction (see storyType).
      type: WorkType.webnovel,
      title: title,
      author: authors.isEmpty ? null : authors.join(', '),
      summary: annotation == null
          ? null
          : htmlToPlainText(cleanHtml(annotation, base: storyUrl)),
      coverUrl: cover == null ? null : Uri.parse(cover),
      tags: [
        for (final a in doc.querySelectorAll('.book-genres a')) squash(a.text),
        for (final a in doc.querySelectorAll('.tags a')) squash(a.text),
      ],
      series: _series(doc),
      characterCount: parseCount(
        doc
            .querySelector('[data-hint^="Размер, кол-во знаков"]')
            ?.nodes
            .firstOrNull
            ?.text,
      ),
      isComplete: status == null
          ? null
          : status.contains('в процессе')
          ? false
          : status.contains('весь текст') || status.contains('завершен')
          ? true
          : null,
      chapters: [
        for (final (i, a) in links.indexed)
          ChapterRef(
            number: i + 1,
            title: squash(a.text),
            url: storyUrl.resolve(a.attributes['href']!),
          ),
      ],
    );
  }

  /// "Цикл: <a href="/work/series/1">🥥 Name</a><span>#2</span>".
  static ({String name, double? index})? _series(dom.Document doc) {
    final link = doc.querySelector('a[href^="/work/series/"]');
    final name = squash(link?.text ?? '')
        .replaceFirst(RegExp(r'^[^\p{L}\p{N}]+', unicode: true), '');
    if (link == null || name.isEmpty) return null;
    final number = RegExp(r'#\s*(\d+(?:[.,]\d+)?)')
        .firstMatch(link.nextElementSibling?.text ?? '')
        ?.group(1);
    return (
      name: name,
      index: number == null ? null : double.parse(number.replaceAll(',', '.')),
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final match = RegExp(r'^/reader/(\d+)/(\d+)').firstMatch(chapter.url.path);
    if (match == null) {
      throw SourceException('Unknown chapter link: ${chapter.url}');
    }
    final api = Uri.https(_host, '/reader/${match.group(1)}/chapter', {
      'id': match.group(2),
    });
    final response = await fetcher.getWithHeaders(
      api,
      headers: const {'X-Requested-With': 'XMLHttpRequest'},
    );
    final json = jsonDecode(response.body) as Map<String, Object?>;
    final data = json['data'] as Map<String, Object?>?;
    final encrypted = data?['text'] as String?;
    final secret = response.headers['reader-secret'];
    if (json['isSuccessful'] != true || encrypted == null || secret == null) {
      final errors = json['messages'] as List?;
      if (errors?.any((message) => '$message'.trim() == 'Unadulted') == true) {
        throw SourceAccessException(
          'Author.Today requires age confirmation for this 18+ book. '
          'Confirm your age or sign in in the ReadTrack browser window, '
          'then retry.',
        );
      }
      final messages = errors?.join(' ');
      throw SourceException(
        messages?.isNotEmpty == true
            ? messages!
            : 'Chapter "${chapter.title}" is not available to read for free.',
      );
    }
    final html = decryptChapter(
      encrypted,
      secret,
      userId: response.headers['readtrack-user-id'] ?? '',
    );
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(parseHtml(html).body!, base: chapter.url),
    );
  }

  /// The reader sends chapter text XOR-ed with a key derived from the
  /// `Reader-Secret` response header (reversed, plus "@_@" and the user id,
  /// which is empty for guests). This is what the site's own reader does.
  static String decryptChapter(
    String text,
    String secret, {
    String userId = '',
  }) {
    final key = '${secret.split('').reversed.join()}@_@$userId';
    final out = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      out.writeCharCode(text.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return out.toString();
  }
}
