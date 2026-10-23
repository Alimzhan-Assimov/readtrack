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
