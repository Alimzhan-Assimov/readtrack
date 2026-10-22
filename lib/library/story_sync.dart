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
Future<int> applyStoryInfo(AppDatabase db, Work work, StoryInfo info) async {
  final known = (await db.chaptersOf(work.id)).length;
  await db.saveChapterList(work.id, chapterListing(info));
  await db.updateWork(
    work.id,
    WorksCompanion(
      chapterCount: Value(info.chapters.length),
      wordCount: info.wordCount == null
          ? const Value.absent()
          : Value(info.wordCount),
      pageCount: info.pageCount == null
          ? const Value.absent()
          : Value(info.pageCount),
      isComplete: info.isComplete == null
          ? const Value.absent()
          : Value(info.isComplete!),
      coverUrl: info.coverUrl == null
          ? const Value.absent()
          : Value(info.coverUrl.toString()),
    ),
  );
  return info.chapters.length - known;
}

ChapterRef chapterRefOf(Chapter chapter) => ChapterRef(
  number: chapter.number,
  title: chapter.title ?? 'Chapter ${chapter.number}',
  url: Uri.parse(chapter.url!),
  locked: chapter.isLocked,
);
