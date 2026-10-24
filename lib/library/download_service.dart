import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../sources/html_clean.dart';
import '../sources/fetcher.dart' show SourceAccessException;
import '../sources/sources.dart';
import 'storage.dart';
import 'story_sync.dart';
import 'exporters.dart';

@immutable
class DownloadProgress {
  const DownloadProgress({
    required this.done,
    required this.total,
    this.chapterTitle,
  });

  final int done;
  final int total;
  final String? chapterTitle;

  double get fraction => total == 0 ? 0 : done / total;
}

@immutable
class DownloadResult {
  const DownloadResult({
    required this.downloaded,
    required this.failed,
    required this.locked,
    required this.cancelled,
    this.file,
    this.firstError,
  });

  final int downloaded;
  final int failed;
  final int locked;
  final bool cancelled;

  /// The exported file, unless the download was cancelled.
  final File? file;

  /// The first failed chapter's explanation, for the completion message.
  final String? firstError;
}

/// Downloads chapters in the background and exports them, one job per work.
/// Screens listen to it for progress.
class DownloadService extends ChangeNotifier {
  DownloadService(this._db, this.storage, {this.openFetcherFor = openFetcher});

  final AppDatabase _db;
  final LibraryStorage storage;
  final PageFetcher Function(StorySource source) openFetcherFor;
  final _progress = <int, DownloadProgress>{};
  final _cancelled = <int>{};

  DownloadProgress? progressOf(int workId) => _progress[workId];

  bool isRunning(int workId) => _progress.containsKey(workId);

  void cancel(int workId) => _cancelled.add(workId);

  /// Downloads chapters [from] to [to] and exports them. With [appendTo], the
  /// existing download is extended to [to] instead of creating a new one.
  Future<DownloadResult> download({
    required Work work,
    required StorySource source,
    required int from,
    required int to,
    Download? appendTo,
    ExportFormat format = ExportFormat.txt,
  }) async {
    if (isRunning(work.id)) throw StateError('A download is already running.');
    final id = work.id;
    _cancelled.remove(id);
    _progress[id] = const DownloadProgress(done: 0, total: 0);
    notifyListeners();
    final fetcher = openFetcherFor(source);
    var downloaded = 0, failed = 0;
    String? firstError;
    try {
      await _saveCover(work, fetcher);
      final start = appendTo?.fromChapter ?? from;
      final inRange = (await _db.chaptersOf(id))
          .where((c) => c.number >= start && c.number <= to)
          .toList();
      final locked = inRange
          .where((c) => c.isLocked && c.content == null)
          .length;
      final todo = inRange
          .where((c) => c.content == null && !c.isLocked && c.url != null)
          .toList();

      for (final chapter in todo) {
        if (_cancelled.contains(id)) break;
        _progress[id] = DownloadProgress(
          done: downloaded + failed,
          total: todo.length,
          chapterTitle: chapter.title,
        );
        notifyListeners();
        try {
          final content = await source.fetchChapter(
            chapterRefOf(chapter),
            fetcher,
          );
          final html = await _saveImages(id, content.html, fetcher);
          await _db.saveChapterText(
            id,
            chapter.number,
            html: html,
            wordCount: countWords(htmlToPlainText(html)),
          );
          downloaded++;
        } on SourceException catch (error) {
          failed++;
          firstError ??= error.message;
          if (error is SourceAccessException) {
            failed = todo.length - downloaded;
            break;
          }
        }
      }

      if (_cancelled.contains(id)) {
        return DownloadResult(
          downloaded: downloaded,
          failed: failed,
          locked: locked,
          cancelled: true,
          firstError: firstError,
        );
      }
      final stored = await _db.chaptersOf(id);
      final hasText = stored.any(
        (chapter) =>
            chapter.number >= start &&
            chapter.number <= to &&
            chapter.content != null,
      );
      if (!hasText) {
        return DownloadResult(
          downloaded: downloaded,
          failed: failed,
          locked: locked,
          cancelled: false,
          firstError: firstError ?? 'No chapter text is available to download.',
        );
      }
      final file = await _export(
        work,
        start,
        to,
        appendTo,
        // An extended download keeps its format.
        appendTo == null ? format : ExportFormat.fromName(appendTo.format),
      );
      return DownloadResult(
        downloaded: downloaded,
        failed: failed,
        locked: locked,
        cancelled: false,
        file: file,
        firstError: firstError,
      );
    } finally {
      await fetcher.close();
      _progress.remove(id);
      _cancelled.remove(id);
      notifyListeners();
    }
  }

  /// Writes the file for chapters [from]..[to] and records the download.
  Future<File> _export(
    Work work,
    int from,
    int to,
    Download? appendTo,
    ExportFormat format,
  ) async {
    final file = await _write(work.id, from, to, format);
    if (appendTo == null) {
      await _db.addDownload(
        DownloadsCompanion.insert(
          workId: work.id,
          fromChapter: from,
          toChapter: to,
          format: Value(format.name),
          filePath: Value(file.path),
        ),
      );
    } else {
      final old = appendTo.filePath;
      if (old != null && old != file.path) await storage.deleteFile(old);
      await _db.updateDownload(
        appendTo.id,
        DownloadsCompanion(toChapter: Value(to), filePath: Value(file.path)),
      );
    }
    return file;
  }

  Future<File> _write(int workId, int from, int to, ExportFormat format) async {
    final details = (await _db.watchWork(workId).first)!;
    final file = storage.exportFile(
      details.work.title,
      from,
      to,
      format.extension,
    );
    await writeExport(
      format,
      ExportBook(
        work: details.work,
        chapters: await _db.chaptersOf(workId),
        from: from,
        to: to,
        storage: storage,
        tags: [for (final t in details.tags) t.name],
      ),
      file,
    );
    return file;
  }

  /// Saves an existing download again in another [format], next to it.
  /// The download itself (and its file) stays as it is.
  Future<File> exportAs(Download download, ExportFormat format) =>
      _write(download.workId, download.fromChapter, download.toChapter, format);

  Future<void> _saveCover(Work work, PageFetcher fetcher) async {
    final url = work.coverUrl;
    if (url == null || work.coverPath != null) return;
    try {
      final uri = Uri.parse(url);
      final path = await storage.saveCover(
        work.id,
        uri,
        await fetcher.getBytes(uri),
      );
      await _db.updateWork(work.id, WorksCompanion(coverPath: Value(path)));
    } on Exception {
      // A missing cover is not worth failing the download for.
    }
  }

  /// Downloads the chapter's images and points the HTML at the local copies.
  Future<String> _saveImages(
    int workId,
    String html,
    PageFetcher fetcher,
  ) async {
    final matches = RegExp(r'<img src="(https?://[^"]+)"')
        .allMatches(html)
        .toList();
    var result = html;
    for (final m in matches) {
      final url = Uri.parse(m.group(1)!.replaceAll('&amp;', '&'));
      try {
        final local = await storage.saveImage(
          workId,
          url,
          await fetcher.getBytes(url),
        );
        result = result.replaceAll('src="${m.group(1)}"', 'src="$local"');
      } on Exception {
        // Keep the online link; the reader shows it when there's a connection.
      }
    }
    return result;
  }
}
