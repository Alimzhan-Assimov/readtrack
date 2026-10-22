import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../sources/html_clean.dart';
import '../sources/sources.dart';
import 'storage.dart';
import 'story_sync.dart';
import 'txt_export.dart';

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
  });

  final int downloaded;
  final int failed;
  final int locked;
  final bool cancelled;

  /// The exported file, unless the download was cancelled.
  final File? file;
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
  }) async {
    if (isRunning(work.id)) throw StateError('A download is already running.');
    final id = work.id;
    _cancelled.remove(id);
    _progress[id] = const DownloadProgress(done: 0, total: 0);
    notifyListeners();
    final fetcher = openFetcherFor(source);
    var downloaded = 0, failed = 0;
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
        } on SourceException {
          failed++;
        }
      }

      if (_cancelled.contains(id)) {
        return DownloadResult(
          downloaded: downloaded,
          failed: failed,
          locked: locked,
          cancelled: true,
        );
      }
      final file = await _export(work, start, to, appendTo);
      return DownloadResult(
        downloaded: downloaded,
        failed: failed,
        locked: locked,
        cancelled: false,
        file: file,
      );
    } finally {
      await fetcher.close();
      _progress.remove(id);
      _cancelled.remove(id);
      notifyListeners();
    }
  }

  /// Writes the TXT file for chapters [from]..[to] and records the download.
  Future<File> _export(Work work, int from, int to, Download? appendTo) async {
    final latest = await (_db.select(
      _db.works,
    )..where((w) => w.id.equals(work.id))).getSingle();
    final chapters = await _db.chaptersOf(work.id);
    final file = storage.exportFile(latest.title, from, to, 'txt');
    await file.parent.create(recursive: true);
    await file.writeAsString(
      buildTxt(work: latest, chapters: chapters, from: from, to: to),
    );
    if (appendTo == null) {
      await _db.addDownload(
        DownloadsCompanion.insert(
          workId: work.id,
          fromChapter: from,
          toChapter: to,
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
