import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../sources/html_clean.dart';
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
      type: info.type,
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
    fandomName: info.fandom,
    seriesName: info.series?.name,
    crossoverNames: info.crossovers,
    tagNames: info.tags,
    pairingNames: info.pairings,
    adultTags: info.adultTags,
  );
  await db.saveChapterList(id, chapterListing(info));
  await db.fillMissingCounts(id);
  return id;
}
