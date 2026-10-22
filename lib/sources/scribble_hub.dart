import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Scribble Hub. Behind Cloudflare, so it is read through the browser.
class ScribbleHubSource extends StorySource {
  const ScribbleHubSource();

  static const _host = 'www.scribblehub.com';

  @override
  String get name => 'Scribble Hub';

  @override
  List<String> get hosts => const ['scribblehub.com'];

  @override
  FetchMode get fetchMode => FetchMode.browser;

  @override
  Uri? storyUrl(Uri uri) {
    final series = RegExp(r'^/series/(\d+)/([^/]+)').firstMatch(uri.path);
    if (series != null) {
      return Uri.https(_host, '/series/${series.group(1)}/${series.group(2)}/');
    }
    // Chapter links: /read/123-slug/chapter/456/
    final read = RegExp(r'^/read/(\d+)-([^/]+)').firstMatch(uri.path);
    if (read != null) {
      return Uri.https(_host, '/series/${read.group(1)}/${read.group(2)}/');
    }
    return null;
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('.fic_title'));
    if (title == null) {
      throw SourceException('This is not a Scribble Hub series page.');
    }

    final id = RegExp(r'^/series/(\d+)').firstMatch(storyUrl.path)!.group(1)!;
    final description = doc.querySelector('.wi_fic_desc');
    final cover = doc.querySelector('.fic_image img')?.attributes['src'];
    // <li><span><i class="fa status"></i></span><span>Ongoing - Updated …</span></li>
    final status = RegExp(r'^(Ongoing|Completed|Hiatus)\b')
        .firstMatch(textOf(doc.querySelector('i.status')?.parent?.parent) ?? '')
        ?.group(1);

    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: doc.querySelector('a.fic_genre[href*="/fanfiction/"]') != null
          ? WorkType.fanfiction
          : WorkType.webnovel,
      title: title,
      author: textOf(doc.querySelector('.auth_name_fic')),
      summary: description == null
          ? null
          : htmlToPlainText(cleanHtml(description, base: storyUrl)),
      coverUrl: cover == null || cover.contains('noimagefound')
          ? null
          : storyUrl.resolve(cover),
      tags: [
        for (final a in doc.querySelectorAll('a.fic_genre')) squash(a.text),
        for (final a in doc.querySelectorAll('a.stag')) squash(a.text),
      ],
      isComplete: status == null ? null : status == 'Completed',
      chapters: await _chapters(id, fetcher),
    );
  }

  /// The table of contents is paginated; "pagenum=-1" returns all of it.
  Future<List<ChapterRef>> _chapters(
    String seriesId,
    PageFetcher fetcher,
  ) async {
    final html = await fetcher.postForm(
      Uri.https(_host, '/wp-admin/admin-ajax.php'),
      {
        'action': 'wi_getreleases_pagination',
        'pagenum': '-1',
        'mypostid': seriesId,
      },
    );
    final items = parseHtml('<ul>$html</ul>').querySelectorAll('li.toc_w')
      ..sort(
        (a, b) => (int.tryParse(a.attributes['order'] ?? '') ?? 0).compareTo(
          int.tryParse(b.attributes['order'] ?? '') ?? 0,
        ),
      );
    return [
      for (final (i, li) in items.indexed)
        if (li.querySelector('a.toc_a') case final a?)
          ChapterRef(
            number: i + 1,
            title: squash(a.text),
            url: Uri.parse(a.attributes['href']!),
          ),
    ];
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final doc = parseHtml(await fetcher.getText(chapter.url));
    final content = doc.querySelector('#chp_raw');
    if (content == null) {
      throw SourceException('Chapter "${chapter.title}" has no readable text.');
    }
    return ChapterContent(
      title: textOf(doc.querySelector('.chapter-title')),
      html: cleanHtml(content, base: chapter.url),
    );
  }
}
