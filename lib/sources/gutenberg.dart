import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Project Gutenberg. Each book is one large HTML file; chapters are split
/// at its `<h2>` headings.
class GutenbergSource extends StorySource {
  const GutenbergSource();

  static const _host = 'www.gutenberg.org';

  /// The last book file, so downloading many chapters fetches it only once.
  static ({Uri url, List<({String title, String html})> parts})? _lastBook;

  @override
  String get name => 'Project Gutenberg';

  @override
  List<String> get hosts => const ['gutenberg.org'];

  @override
  FetchMode get fetchMode => FetchMode.http;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/(?:ebooks|cache/epub)/(\d+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/ebooks/${match.group(1)}');
  }

  static Uri _bookFile(String id) =>
      Uri.https(_host, '/cache/epub/$id/pg$id-images.html');

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('[itemprop="headline"]'));
    if (title == null) {
      throw SourceException('This is not a Project Gutenberg book page.');
    }
    final id = storyUrl.pathSegments.last;
    final summary = doc
        .querySelectorAll('tr')
        .where((tr) => textOf(tr.querySelector('th')) == 'Summary')
        .map((tr) => textOf(tr.querySelector('td')))
        .firstOrNull;
    final cover = doc.querySelector('img.cover-art')?.attributes['src'];
    final parts = await _parts(_bookFile(id), fetcher);

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.book,
      title: title,
      author: [
        for (final a in doc.querySelectorAll('a[itemprop="creator"]'))
          _displayName(squash(a.text)),
      ].join(', '),
      summary: summary?.replaceFirst(
        RegExp(r'\s*\(This is an automatically generated summary\.\)$'),
        '',
      ),
      coverUrl: cover == null ? null : storyUrl.resolve(cover),
      tags: [
        for (final a in doc.querySelectorAll('a[href*="/ebooks/subject/"]'))
          squash(a.text),
      ],
      isComplete: true,
      chapters: [
        for (final (i, part) in parts.indexed)
          ChapterRef(
            number: i + 1,
            title: part.title,
            url: _bookFile(id).replace(fragment: 'part-${i + 1}'),
          ),
      ],
    );
  }

  /// "Austen, Jane, 1775-1817" -> "Jane Austen"
  static String _displayName(String creator) {
    final parts = creator.split(',').map((p) => p.trim()).toList();
    if (parts.length >= 2 && !RegExp(r'\d').hasMatch(parts[1])) {
      return '${parts[1]} ${parts[0]}';
    }
    return parts.first;
  }

  /// Splits the book file at `<h2>` headings, between Gutenberg's header and
  /// footer. Headings that are only page markers ("{ix}") don't start parts.
  static Future<List<({String title, String html})>> _parts(
    Uri file,
    PageFetcher fetcher,
  ) async {
    final cached = _lastBook;
    if (cached != null && cached.url == file) return cached.parts;

    final doc = parseHtml(await fetcher.getText(file));
    // Gutenberg's license header and footer are not part of the book.
    doc.getElementById('pg-header')?.remove();
    doc.getElementById('pg-footer')?.remove();
    final body = doc.body?.innerHtml ?? '';
    final starts = <int>[];
    final titles = <String>[];
    for (final m in RegExp(
      r'<h2[^>]*>(.*?)</h2>',
      dotAll: true,
    ).allMatches(body)) {
      final title = squash(parseHtml(m.group(1)!).body?.text ?? '');
      if (title.isEmpty || title.startsWith('{')) continue;
      starts.add(m.start);
      titles.add(title);
    }
    final parts = <({String title, String html})>[];
    // Prefaces and introductions often come before the first heading.
    if (starts.isNotEmpty) {
      final front = cleanHtml(
        parseHtml('<div>${body.substring(0, starts.first)}</div>').body!,
        base: file,
      );
      if (countWords(htmlToPlainText(front)) >= 200) {
        parts.add((title: 'Front matter', html: front));
      }
    }
    for (var i = 0; i < starts.length; i++) {
      final end = i + 1 < starts.length ? starts[i + 1] : body.length;
      final chunk = body
          .substring(starts[i], end)
          .replaceFirst(RegExp(r'<h2[^>]*>.*?</h2>', dotAll: true), '')
          // Page-number headings like "{3}".
          .replaceAll(
            RegExp(r'<h2[^>]*>\s*\{[^}]*\}\s*</h2>', dotAll: true),
            '',
          );
      parts.add((
        title: titles[i],
        html: cleanHtml(parseHtml('<div>$chunk</div>').body!, base: file),
      ));
    }
    if (parts.isEmpty) {
      parts.add((
        title: 'Text',
        html: cleanHtml(parseHtml(body).body!, base: file),
      ));
    }
    _lastBook = (url: file, parts: parts);
    return parts;
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final parts = await _parts(chapter.url.removeFragment(), fetcher);
    final index =
        int.tryParse(chapter.url.fragment.replaceFirst('part-', '')) ??
        chapter.number;
    if (index < 1 || index > parts.length) {
      throw SourceException(
        '"${chapter.title}" was not found in the book file.',
      );
    }
    final part = parts[index - 1];
    return ChapterContent(title: part.title, html: part.html);
  }
}
