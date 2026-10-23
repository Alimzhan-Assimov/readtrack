import 'dart:convert';

import 'package:html/dom.dart' as dom;

import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Wikisource (ru, en, de, uk), through the MediaWiki API. A work's chapters
/// are the subpages its page links to directly (e.g. the volumes); a work
/// without subpages is a single chapter.
class WikisourceSource extends StorySource {
  const WikisourceSource();

  @override
  String get name => 'Wikisource';

  @override
  List<String> get hosts => const [
    'ru.wikisource.org',
    'en.wikisource.org',
    'de.wikisource.org',
    'uk.wikisource.org',
  ];

  @override
  FetchMode get fetchMode => FetchMode.http;

  @override
  Uri? storyUrl(Uri uri) {
    if (!uri.path.startsWith('/wiki/') || uri.path.length <= 6) return null;
    final title = Uri.decodeComponent(uri.path.substring(6));
    // Author pages, categories and other namespaces are not works.
    if (RegExp(r'^[^/()]+:').hasMatch(title)) return null;
    return Uri.https(uri.host, '/wiki/${title.replaceAll(' ', '_')}');
  }

  /// Decodes percent-encoding; links with raw (unencoded) characters are
  /// kept as they are, which Uri.decodeComponent would reject.
  static String _decode(String text) {
    try {
      return Uri.decodeComponent(text);
    } on ArgumentError {
      return text;
    }
  }

  static String _title(Uri url) =>
      Uri.decodeComponent(url.path.substring(6)).replaceAll('_', ' ');

  /// Rendered page content from the API.
  static Future<dom.Element> _parse(
    String host,
    String title,
    PageFetcher fetcher,
  ) async {
    final json = jsonDecode(
      await fetcher.getText(
        Uri.https(host, '/w/api.php', {
          'action': 'parse',
          'page': title,
          'prop': 'text',
          'format': 'json',
          'formatversion': '2',
          'disabletoc': '1',
          'redirects': '1',
        }),
      ),
    ) as Map<String, Object?>;
    final text = (json['parse'] as Map?)?['text'] as String?;
    if (text == null) throw SourceException('Wikisource has no page "$title".');
    return parseHtml('<div>$text</div>').body!;
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final title = _title(storyUrl);
    final content = await _parse(storyUrl.host, title, fetcher);

    // Subpages linked from the page, in reading order; direct children first.
    final linked = <String>[];
    for (final a in content.querySelectorAll('a[href^="/wiki/"]')) {
      final target = _decode(
        a.attributes['href']!.substring(6).split('#').first,
      ).replaceAll('_', ' ');
      if (target.startsWith('$title/') && !linked.contains(target)) {
        linked.add(target);
      }
    }
    final direct = [
      for (final t in linked)
        if (!t.substring(title.length + 1).contains('/')) t,
    ];
    final children = direct.isNotEmpty ? direct : linked;

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.book,
      // "Война и мир (Толстой)" -> "Война и мир"
      title:
          textOf(content.querySelector('#ws-title')) ??
          title.replaceFirst(RegExp(r'\s*\([^)]*\)$'), ''),
      author:
          textOf(content.querySelector('#ws-author a')) ??
          RegExp(r'\(([^)]*)\)$').firstMatch(title)?.group(1),
      isComplete: true,
      chapters: children.isEmpty
          ? [ChapterRef(number: 1, title: title, url: storyUrl)]
          : [
              for (final (i, child) in children.indexed)
                ChapterRef(
                  number: i + 1,
                  title: child
                      .substring(title.length + 1)
                      .replaceAll('/', ' · '),
                  url: Uri.https(
                    storyUrl.host,
                    '/wiki/${child.replaceAll(' ', '_')}',
                  ),
                ),
            ],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final content = await _parse(
      chapter.url.host,
      _title(chapter.url),
      fetcher,
    );
    // Header boxes, page numbers, edit links and footnote markers.
    for (final extra in content.querySelectorAll(
      '#headertemplate, .ws-noexport, .noprint, .mw-editsection, sup.reference, .mw-references-wrap',
    )) {
      extra.remove();
    }
    return ChapterContent(
      title: chapter.title,
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
