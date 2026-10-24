import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/update_checker.dart';

import 'sources/fake_fetcher.dart';

void main() {
  late AppDatabase db;
  late Map<String, String> pages;
  final now = DateTime(2026, 10, 23, 12);
  const story = 'https://archiveofourown.org/works/7';

  void serve({required int chapters, String updated = '2026-10-20'}) {
    pages
      ..['$story?view_adult=true'] =
          '<h2 class="title heading">Two Strangers</h2>'
          '<dd class="status">$updated</dd>'
          '<dd class="chapters">$chapters/?</dd>'
      ..['$story/navigate'] =
          '<ol class="chapter index group">${[for (var i = 1; i <= chapters; i++) '<li><a href="/works/7/chapters/$i">$i. C$i</a></li>'].join()}</ol>';
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    pages = {};
  });
  tearDown(() => db.close());

  UpdateChecker checker() =>
      UpdateChecker(db, openFetcher: () => FakeFetcher(pages));

  Future<Work> work() async => (await db.worksWithSource()).single;

  test('new chapters are counted, then cleared when seen', () async {
    await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'Two Strangers',
        sourceUrl: const Value(story),
      ),
    );
    // The first check only learns the chapter list.
    serve(chapters: 2);
    var summary = await checker().check(now: now);
    expect((summary.checked, summary.newChapters), (1, 0));
    expect((await work()).lastChapterAt, DateTime(2026, 10, 20));

    // Not due again within six hours of a recently updated story …
    serve(chapters: 4, updated: '2026-10-23');
    summary = await checker().check(now: now.add(const Duration(hours: 1)));
    expect(summary.checked, 0);

    // … but checking everything finds the two new chapters.
    summary = await checker().check(all: true, now: now);
    expect((summary.updatedWorks, summary.newChapters), (1, 2));
    final w = await work();
    expect((w.newChapters, w.chapterCount), (2, 4));
    expect(w.lastChapterAt, DateTime(2026, 10, 23));

    await db.markChaptersSeen(w.id);
    expect((await work()).newChapters, 0);
  });

  test('Royal Road: the RSS feed finds new chapters without the story page', () async {
    const rr = 'https://www.royalroad.com/fiction/21220';
    final id = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.webnovel,
        format: WorkFormat.online,
        title: 'Mother of Learning',
        sourceUrl: const Value(rr),
        chapterCount: const Value(2),
      ),
    );
    await db.saveChapterList(id, [
      for (final (n, c) in [(1, 101), (2, 102)])
        (
          number: n,
          title: 'Chapter $n',
          url: '$rr/mother-of-learning/chapter/$c/chapter-$n',
          locked: false,
        ),
    ]);
    String feed(List<int> ids) =>
        '<?xml version="1.0" encoding="utf-8"?><rss version="2.0"><channel>'
        '<title>Mother of Learning</title>'
        '${[for (final c in ids.reversed) '<item><title>Mother of Learning - Chapter ${c - 100}</title>'
              '<link>https://www.royalroad.com/fiction/chapter/$c</link>'
              '<pubDate>Fri, 23 Oct 2026 0${c - 100}:00:00 GMT</pubDate></item>'].join()}'
        '</channel></rss>';
    const rss = 'https://www.royalroad.com/fiction/syndication/21220';

    // Nothing new: only the feed is read (the story page isn't served).
    pages[rss] = feed([101, 102]);
    var summary = await checker().check(all: true, now: now);
    expect((summary.newChapters, summary.failed), (0, 0));
    expect((await work()).checkedAt, now);

    pages[rss] = feed([101, 102, 103, 104]);
    summary = await checker().check(all: true, now: now);
    expect(
      (summary.updatedWorks, summary.newChapters, summary.failed),
      (1, 2, 0),
    );
    final w = await work();
    expect((w.newChapters, w.chapterCount), (2, 4));
    expect(w.lastChapterAt!.toUtc(), DateTime.utc(2026, 10, 23, 4));
    final chapters = await db.chaptersOf(id);
    expect(
      [for (final c in chapters) '${c.number} ${c.title}'],
      ['1 Chapter 1', '2 Chapter 2', '3 Chapter 3', '4 Chapter 4'],
    );

    // No overlap with the known chapters: the story page is needed.
    pages[rss] = feed([110, 111]);
    summary = await checker().check(all: true, now: now);
    expect(summary.failed, 1); // the story page isn't served here
  });

  test('check intervals and abandoned stories', () {
    Work make({
      bool complete = false,
      DateTime? last,
      DateTime? checked,
      ReadingStatus status = ReadingStatus.reading,
      String url = story,
    }) => Work(
      id: 1,
      type: WorkType.fanfiction,
      format: WorkFormat.online,
      title: 'x',
      sourceUrl: url,
      status: status,
      isComplete: complete,
      addedAt: DateTime(2024),
      updatedAt: DateTime(2024),
      checkedAt: checked,
      lastChapterAt: last,
      newChapters: 0,
      wordsEstimated: false,
      pagesEstimated: false,
      ownsPhysicalCopy: false,
    );

    expect(
      UpdateChecker.intervalFor(make(complete: true), now),
      const Duration(days: 30),
    );
    expect(
      UpdateChecker.intervalFor(make(last: DateTime(2026, 10, 1)), now),
      const Duration(hours: 6),
    );
    expect(
      UpdateChecker.intervalFor(make(last: DateTime(2023)), now),
      const Duration(days: 7),
    );

    expect(UpdateChecker.isDue(make(), now), isTrue);
    expect(
      UpdateChecker.isDue(make(status: ReadingStatus.dropped), now),
      isFalse,
    );
    // FanFiction.Net needs a browser window, so it isn't checked in the
    // background.
    expect(
      UpdateChecker.isDue(make(url: 'https://www.fanfiction.net/s/1'), now),
      isFalse,
    );

    expect(looksAbandoned(make(last: DateTime(2025, 1, 1)), now: now), isFalse);
    expect(
      looksAbandoned(
        make(last: DateTime(2025, 1, 1), checked: DateTime(2026, 10)),
        now: now,
      ),
      isTrue,
    );
    expect(
      looksAbandoned(
        make(complete: true, last: DateTime(2020), checked: DateTime(2026, 10)),
        now: now,
      ),
      isFalse,
    );
  });
}
