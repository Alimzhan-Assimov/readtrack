import '../data/enums.dart';
import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart';

/// Novel Updates only catalogs translated novels; the chapters live on the
/// translators' sites. Importing fills in the details for tracking.
class NovelUpdatesSource extends StorySource {
  const NovelUpdatesSource();

  static const _host = 'www.novelupdates.com';

  @override
  String get name => 'Novel Updates';

  @override
  List<String> get hosts => const ['novelupdates.com'];

  @override
  FetchMode get fetchMode => FetchMode.browser;

  @override
  bool get canRead => false;

  @override
  Uri? storyUrl(Uri uri) {
    final match = RegExp(r'^/series/([^/]+)').firstMatch(uri.path);
    if (match == null) return null;
    return Uri.https(_host, '/series/${match.group(1)}/');
  }

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) async {
    final doc = parseHtml(await fetcher.getText(storyUrl));
    final title = textOf(doc.querySelector('.seriestitlenu'));
    if (title == null) {
      throw SourceException('This is not a Novel Updates series page.');
    }
    final status = textOf(doc.querySelector('#editstatus')) ?? '';
    final cover = doc.querySelector('.seriesimg img')?.attributes['src'];
    final description = doc.querySelector('#editdescription');
    return StoryInfo(
      url: storyUrl,
      siteName: name,
      type: WorkType.webnovel,
      title: title,
      author: textOf(doc.querySelector('#authtag')),
      summary: description == null
          ? null
          : htmlToPlainText(cleanHtml(description, base: storyUrl)),
      coverUrl: cover == null || cover.contains('noimagefound')
          ? null
          : Uri.parse(cover),
      tags: [
        for (final a in doc.querySelectorAll('#seriesgenre a.genre'))
          squash(a.text),
        for (final a in doc.querySelectorAll('#showtags a.genre'))
          squash(a.text),
      ],
      // "93 Chapters (Ongoing)"
      chapterCount: parseCount(
        RegExp(r'(\d[\d,]*)\s+Chapters').firstMatch(status)?.group(1),
      ),
      isComplete: status.contains('Completed')
          ? true
          : status.contains('Ongoing')
          ? false
          : null,
      chapters: const [],
    );
  }

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) => throw SourceException(
    'Novel Updates only lists chapters; they are read on the translators\' sites.',
  );
}
