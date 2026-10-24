import 'dart:async';

import '../data/database.dart';
import '../sources/fetcher.dart';
import '../sources/sources.dart';
import 'story_sync.dart';

/// Result of one round of update checks.
class UpdateSummary {
  const UpdateSummary({
    this.checked = 0,
    this.updatedWorks = 0,
    this.newChapters = 0,
    this.failed = 0,
  });

  final int checked;

  /// Stories that got new chapters.
  final int updatedWorks;
  final int newChapters;
  final int failed;
}

/// A story without new chapters for this long is probably abandoned.
const kAbandonedAfter = Duration(days: 365);

/// Whether an ongoing story hasn't been updated for over a year.
bool looksAbandoned(Work work, {DateTime? now}) {
  if (work.isComplete || work.checkedAt == null) return false;
  final last = work.lastChapterAt ?? work.addedAt;
  return (now ?? DateTime.now()).difference(last) > kAbandonedAfter;
}

/// Looks for new chapters of the online stories in the library.
///
/// Only plain HTTP is used, so checks never open browser windows; sites
/// that need the browser are checked from a story's page instead.
class UpdateChecker {
  UpdateChecker(this._db, {PageFetcher Function()? openFetcher})
    : _openFetcher = openFetcher ?? HttpFetcher.new;

  final AppDatabase _db;
  final PageFetcher Function() _openFetcher;
  Future<UpdateSummary>? _running;

  /// How long to wait between checks: stories that update often are
  /// checked more often, finished ones rarely.
  static Duration intervalFor(Work work, DateTime now) {
    if (work.isComplete) return const Duration(days: 30);
    final last = work.lastChapterAt;
    if (last == null) return const Duration(days: 1);
    final age = now.difference(last);
    if (age < const Duration(days: 30)) return const Duration(hours: 6);
    if (age < kAbandonedAfter) return const Duration(days: 1);
    return const Duration(days: 7);
  }

  static StorySource? checkableSource(Work work) {
    final url = Uri.tryParse(work.sourceUrl ?? '');
    final source = url == null ? null : sourceFor(url);
    if (source == null || !source.canRead) return null;
    if (source.fetchMode == FetchMode.browser) return null;
    return source;
  }

  static bool isDue(Work work, DateTime now) {
    if (work.status == ReadingStatus.dropped) return false;
    if (checkableSource(work) == null) return false;
    final checked = work.checkedAt;
    return checked == null || now.difference(checked) >= intervalFor(work, now);
  }

  /// Checks the stories that are due, or all checkable ones with [all].
  /// Calls while a round is running wait for that round.
  Future<UpdateSummary> check({bool all = false, DateTime? now}) =>
      _running ??= _check(
        all: all,
        now: now ?? DateTime.now(),
      ).whenComplete(() => _running = null);

  /// Updates [work] from the site's feed of recent chapters, if it has one
  /// and it covers everything new; false means the whole story is needed.
  Future<bool> _fromFeed(
    StorySource source,
    Work work,
    Uri url,
    PageFetcher fetcher,
    DateTime now,
  ) async {
    final List<({ChapterRef chapter, DateTime? date})>? recent;
    try {
      recent = await source.recentChapters(url, fetcher);
    } on SourceException {
      return false;
    }
    if (recent == null || recent.isEmpty) return false;
    final known = await _db.chaptersOf(work.id);
    if (known.isEmpty) return false;
    final keys = {
      for (final c in known)
        if (c.url case final u?) source.chapterKey(Uri.parse(u)),
    };
    final fresh = [
      for (final r in recent)
        if (!keys.contains(source.chapterKey(r.chapter.url))) r,
    ];
    // Without overlap, chapters between the feed and the list are missing.
    if (fresh.length == recent.length) return false;
    await appendChapters(
      _db,
      work,
      [for (final r in fresh) r.chapter],
      lastChapterAt: fresh.lastOrNull?.date,
      now: now,
    );
    return true;
  }

  Future<UpdateSummary> _check({
    required bool all,
    required DateTime now,
  }) async {
    final works = [
      for (final w in await _db.worksWithSource())
        if (all
            ? w.status != ReadingStatus.dropped && checkableSource(w) != null
            : isDue(w, now))
          w,
    ];
    // One site at a time per host, but different sites in parallel.
    final bySource = <StorySource, List<Work>>{};
    for (final w in works) {
      bySource.putIfAbsent(checkableSource(w)!, () => []).add(w);
    }
    var updated = 0, added = 0, failed = 0;
    await Future.wait([
      for (final MapEntry(key: source, value: list) in bySource.entries)
        () async {
          final fetcher = _openFetcher();
          try {
            for (final work in list) {
              try {
                final url = source.storyUrl(Uri.parse(work.sourceUrl!));
                if (url == null) continue;
                if (!await _fromFeed(source, work, url, fetcher, now)) {
                  final info = await source.fetchStory(url, fetcher);
                  await applyStoryInfo(_db, work, info, now: now);
                }
                final after = await _db.workById(work.id);
                final fresh = (after?.newChapters ?? 0) - work.newChapters;
                if (fresh > 0) {
                  updated++;
                  added += fresh;
                }
              } catch (_) {
                failed++;
              }
            }
          } finally {
            await fetcher.close();
          }
        }(),
    ]);
    return UpdateSummary(
      checked: works.length,
      updatedWorks: updated,
      newChapters: added,
      failed: failed,
    );
  }
}
