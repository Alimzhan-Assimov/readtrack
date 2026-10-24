import '../data/database.dart';
import '../diagnostics/app_log.dart';
import '../sources/sources.dart';
import 'download_service.dart';

/// Extends the newest download of each story with new chapters, so they
/// can be read offline without asking. Only stories that already have a
/// download; each keeps its format and image choice. Returns how many
/// chapters were downloaded.
Future<int> downloadNewChapters(
  AppDatabase db,
  DownloadService service, {
  StorySource? Function(Uri url) find = sourceFor,
}) async {
  var total = 0;
  for (final work in await db.worksWithSource()) {
    if (work.newChapters <= 0 || service.isRunning(work.id)) continue;
    final source = find(Uri.parse(work.sourceUrl!));
    if (source == null || !source.canRead) continue;
    final downloads = await db.downloadsOf(work.id);
    if (downloads.isEmpty) continue;
    final latest = downloads.reduce(
      (a, b) => a.toChapter >= b.toChapter ? a : b,
    );
    final last = (await db.chaptersOf(work.id)).lastOrNull?.number ?? 0;
    if (last <= latest.toChapter) continue;
    try {
      final result = await service.download(
        work: work,
        source: source,
        from: latest.toChapter + 1,
        to: last,
        appendTo: latest,
      );
      total += result.downloaded;
    } on Exception catch (e) {
      logWarning(
        'download',
        'Automatic download failed',
        context: {'workId': work.id},
        error: e,
      );
    }
  }
  return total;
}
