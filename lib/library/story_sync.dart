import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../sources/html_clean.dart';
import 'keyword_tags.dart';
import '../sources/sources.dart';

/// Loads a story's details from its site, opening and closing the fetcher.
Future<StoryInfo> loadStoryInfo(StorySource source, Uri url) async {
  final storyUrl = source.storyUrl(url);
  if (storyUrl == null) {
    throw SourceException(
      'This link does not point to a story on ${source.name}.',
    );
  }
  final fetcher = openFetcher(source);
  try {
    return await source.fetchStory(storyUrl, fetcher);
  } finally {
    await fetcher.close();
  }
}

List<ChapterListing> chapterListing(StoryInfo info) => [
  for (final c in info.chapters)
    (number: c.number, title: c.title, url: c.url.toString(), locked: c.locked),
];

/// Stores fresh details from the site. Returns how many chapters are new.
///
/// With [countAsNew], new chapters are added to the work's "new" badge.
Future<int> applyStoryInfo(
  AppDatabase db,
  Work work,
  StoryInfo info, {
  bool countAsNew = true,
  DateTime? now,
}) async {
  final time = now ?? DateTime.now();
  final known = (await db.chaptersOf(work.id)).length;
  await db.saveChapterList(work.id, chapterListing(info));
  // A story whose chapters weren't listed before has nothing "new" yet.
  final added = known == 0 ? 0 : max(0, info.chapters.length - known);
  final unseen = (await db.workById(work.id))?.newChapters ?? 0;
  await db.updateWork(
    work.id,
    WorksCompanion(
      chapterCount: Value(info.chapterCount),
      wordCount: info.wordCount == null
          ? const Value.absent()
          : Value(info.wordCount),
      wordsEstimated: info.wordCount == null
          ? const Value.absent()
          : const Value(false),
      pageCount: info.pageCount == null
          ? const Value.absent()
          : Value(info.pageCount),
      pagesEstimated: info.pageCount == null
          ? const Value.absent()
          : const Value(false),
      characterCount: info.characterCount == null
          ? const Value.absent()
          : Value(info.characterCount),
      isComplete: info.isComplete == null
          ? const Value.absent()
          : Value(info.isComplete!),
      coverUrl: info.coverUrl == null
          ? const Value.absent()
          : Value(info.coverUrl.toString()),
      checkedAt: Value(time),
      lastChapterAt: switch ((info.updatedOn, added)) {
        (final date?, _) => Value(date),
        (null, > 0) => Value(time),
        _ => const Value.absent(),
      },
      newChapters: countAsNew && added > 0
          ? Value(unseen + added)
          : const Value.absent(),
    ),
    // Checks that find nothing new shouldn't reorder the library.
    touch: added > 0,
  );
  await db.fillMissingCounts(work.id);
  return info.chapters.length - known;
}

ChapterRef chapterRefOf(Chapter chapter) => ChapterRef(
  number: chapter.number,
  title: chapter.title ?? 'Chapter ${chapter.number}',
  url: Uri.parse(chapter.url!),
  locked: chapter.isLocked,
);

/// Estimates the length of a story the site gives no size for: fetches up
/// to [samples] chapters spread over it (start, middle, end), and scales
/// their average up to all chapters. Returns the estimated words, or null
/// if no chapter could be read. The texts are not stored.
Future<int?> estimateLength(
  AppDatabase db,
  Work work,
  StorySource source, {
  int samples = 3,
  PageFetcher Function(StorySource source) open = openFetcher,
}) async {
  final chapters = await db.chaptersOf(work.id);
  final readable = [
    for (final c in chapters)
      if (!c.isLocked && c.url != null) c,
  ];
  if (readable.isEmpty) return null;
  final picks = {
    for (var i = 0; i < samples; i++)
      readable[samples == 1
          ? 0
          : (i * (readable.length - 1) / (samples - 1)).round()],
  };
  final fetcher = open(source);
  final counts = <int>[];
  try {
    for (final c in picks) {
      try {
        final content = await source.fetchChapter(chapterRefOf(c), fetcher);
        counts.add(countWords(htmlToPlainText(content.html)));
      } on SourceException {
        // Try the others.
      }
    }
  } finally {
    await fetcher.close();
  }
  if (counts.isEmpty) return null;
  final average = counts.reduce((a, b) => a + b) / counts.length;
  final total = max(work.chapterCount ?? 0, chapters.length);
  final words = (average * total).round();
  await db.updateWork(
    work.id,
    WorksCompanion(wordCount: Value(words), wordsEstimated: const Value(true)),
    touch: false,
  );
  await db.fillMissingCounts(work.id);
  return words;
}

/// Adds a story loaded from its site, as the edit form would with its
/// prefilled values, and returns the new id.
Future<int> addStory(
  AppDatabase db,
  StoryInfo info, {
  ReadingStatus status = ReadingStatus.planned,
  DateTime? now,
}) async {
  final id = await db.saveWork(
    WorksCompanion.insert(
      type: storyType(info),
      format: WorkFormat.online,
      title: info.title,
      author: Value(info.author),
      summary: Value(info.summary),
      sourceUrl: Value(info.url.toString()),
      coverUrl: Value(info.coverUrl?.toString()),
      status: Value(status),
      isComplete: Value(info.isComplete ?? false),
      chapterCount: Value(info.chapterCount),
      wordCount: Value(info.wordCount),
      pageCount: Value(info.pageCount),
      characterCount: Value(info.characterCount),
      seriesIndex: Value(info.series?.index),
      checkedAt: Value(now ?? DateTime.now()),
      lastChapterAt: Value(info.updatedOn),
    ),
    fandomName: await storyFandom(db, info),
    seriesName: info.series?.name,
    crossoverNames: info.crossovers,
    characterNames: info.characters,
    tagNames: info.tags,
    pairingNames: info.pairings,
    adultTags: info.adultTags,
  );
  await db.saveChapterList(id, chapterListing(info));
  await db.fillMissingCounts(id);
  await suggestKeywordTags(db, id, '${info.title}\n${info.summary ?? ''}');
  return id;
}

/// Proposes default tags whose keywords appear in [text] (a title and
/// summary), with the English reason. Returns how many are new.
Future<int> suggestKeywordTags(AppDatabase db, int workId, String text) =>
    db.suggestTags(workId, {
      for (final MapEntry(key: tag, value: word) in keywordTags(text).entries)
        tag: 'The summary mentions “$word”',
    });

/// Adds [fresh] chapters after the known ones (e.g. from a site's feed) and
/// counts them as new; records the check either way.
Future<void> appendChapters(
  AppDatabase db,
  Work work,
  List<ChapterRef> fresh, {
  DateTime? lastChapterAt,
  DateTime? now,
}) async {
  final time = now ?? DateTime.now();
  final last = (await db.chaptersOf(work.id)).lastOrNull?.number ?? 0;
  await db.saveChapterList(work.id, [
    for (final (i, c) in fresh.indexed)
      (
        number: last + i + 1,
        title: c.title,
        url: c.url.toString(),
        locked: c.locked,
      ),
  ]);
  final unseen = (await db.workById(work.id))?.newChapters ?? 0;
  await db.updateWork(
    work.id,
    WorksCompanion(
      checkedAt: Value(time),
      chapterCount: fresh.isEmpty
          ? const Value.absent()
          : Value(last + fresh.length),
      newChapters: fresh.isEmpty
          ? const Value.absent()
          : Value(unseen + fresh.length),
      lastChapterAt: fresh.isEmpty
          ? const Value.absent()
          : Value(lastChapterAt ?? time),
    ),
    touch: false,
  );
  if (fresh.isNotEmpty) await db.fillMissingCounts(work.id);
}

/// Tags that mark a story as fan fiction, whatever kind of site it's on.
const _fanfictionTags = {
  'фанфик',
  'фанфики',
  'fanfic',
  'fanfiction',
  'fan fiction',
};

/// The kind of work [info] is: what the site says, unless its tags call it
/// fan fiction (Author.Today's "Фанфик" genre, for example).
WorkType storyType(StoryInfo info) =>
    info.tags.any((t) => _fanfictionTags.contains(t.trim().toLowerCase()))
    ? WorkType.fanfiction
    : info.type;

/// The franchise of [info]: the site's, or a guess from its tags (and, for
/// fan fiction, its title).
Future<String?> storyFandom(AppDatabase db, StoryInfo info) async =>
    info.fandom ??
    await db.guessFandom(
      title: info.title,
      tags: info.tags,
      useTitle: storyType(info) == WorkType.fanfiction,
    );

/// Takes the site's details into an existing entry, e.g. one imported
/// before ReadTrack kept characters or series: the chapter list and counts
/// as [applyStoryInfo] does, the kind of work from the site, and whatever
/// the entry lacks (franchise, summary, cover, series); tags, pairings,
/// characters and crossovers are added to the entry's own.
Future<void> refreshFromSite(
  AppDatabase db,
  WorkWithDetails item,
  StoryInfo info, {
  DateTime? now,
}) async {
  final w = item.work;
  await applyStoryInfo(db, w, info, countAsNew: true, now: now);
  final series = item.series?.name ?? info.series?.name;
  await db.saveWork(
    WorksCompanion(
      id: Value(w.id),
      title: Value(w.title),
      type: Value(storyType(info)),
      author: w.author == null ? Value(info.author) : const Value.absent(),
      summary: w.summary == null ? Value(info.summary) : const Value.absent(),
      coverUrl: w.coverUrl == null && w.coverPath == null
          ? Value(info.coverUrl?.toString())
          : const Value.absent(),
      seriesIndex: item.series == null && info.series != null
          ? Value(info.series!.index)
          : const Value.absent(),
    ),
    fandomName: item.fandom?.name ?? await storyFandom(db, info),
    seriesName: series ?? '',
    crossoverNames: {
      for (final f in item.crossovers) f.name,
      ...info.crossovers,
    }.toList(),
    characterNames: {
      for (final c in item.confirmedCharacters) c.name,
      ...info.characters,
    }.toList(),
    tagNames: {for (final t in item.tags) t.name, ...info.tags}.toList(),
    pairingNames: {
      for (final p in item.pairings) p.name,
      ...info.pairings,
    }.toList(),
    adultTags: info.adultTags,
  );
}

/// [refreshFromSite] for every online entry whose site can be read, one
/// at a time. Calls [onProgress] after each; returns the failures by title.
Future<Map<String, String>> refreshAllFromSites(
  AppDatabase db, {
  void Function(int done, int total)? onProgress,
  Future<StoryInfo> Function(StorySource source, Uri url) load = loadStoryInfo,
  Duration pause = const Duration(seconds: 1),
}) async {
  final works = [
    for (final w in await db.worksWithSource())
      if (sourceFor(Uri.parse(w.sourceUrl!)) case final s? when s.canRead)
        (work: w, source: s),
  ];
  final failed = <String, String>{};
  for (final (i, entry) in works.indexed) {
    try {
      final item = (await db.watchWork(entry.work.id).first)!;
      final info = await load(entry.source, Uri.parse(entry.work.sourceUrl!));
      await refreshFromSite(db, item, info);
    } on SourceException catch (e) {
      failed[entry.work.title] = e.message;
    }
    onProgress?.call(i + 1, works.length);
    if (i < works.length - 1) await Future<void>.delayed(pause);
  }
  return failed;
}
