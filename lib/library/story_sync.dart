import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
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
