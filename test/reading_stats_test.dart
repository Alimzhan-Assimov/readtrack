import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/database_scope.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/library/reading_stats.dart';
import 'package:readtrack/library/reading_tracker.dart';
import 'package:readtrack/screens/stats_screen.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late int a, b;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    a = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.webnovel,
        format: WorkFormat.online,
        title: 'Alpha',
      ),
    );
    b = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.book,
        format: WorkFormat.digital,
        title: 'Beta',
      ),
    );
  });
  tearDown(() => db.close());

  test(
    'the tracker counts active time and each finished chapter once',
    () async {
      var now = DateTime(2026, 10, 24, 20);
      final t = ReadingTracker(db, a, clock: () => now);
      await t.activity();
      for (var i = 0; i < 4; i++) {
        now = now.add(const Duration(seconds: 30));
        await t.activity(); // two minutes in total: written at one minute
      }
      now = now.add(const Duration(minutes: 30)); // left open: not counted
      await t.activity();
      await t.chapterRead(3, 2500);
      await t.chapterRead(3, 2500);
      await t.flush();
      final day = (await db.readingLog()).single.$1;
      expect(
        (day.day, day.seconds, day.words, day.chapters),
        ('2026-10-24', 120, 2500, 1),
      );
    },
  );

  test('totals, streaks and the year in review', () async {
    Future<void> read(int work, DateTime d, int words) =>
        db.addReading(work, d, words: words, seconds: words ~/ 4, chapters: 1);
    await read(a, DateTime(2025, 12, 30), 1000);
    await read(a, DateTime(2026, 10, 19), 100); // Monday
    await read(a, DateTime(2026, 10, 21), 200);
    await read(b, DateTime(2026, 10, 22), 300);
    await read(a, DateTime(2026, 10, 23), 400);
    await read(b, DateTime(2026, 10, 23), 50);
    final stats = ReadingStats(
      await db.readingLog(),
      today: DateTime(2026, 10, 24, 9),
    );
    // Nothing yet today; the streak runs until yesterday.
    expect(stats.currentStreak, 3);
    expect(stats.longestStreak, 3);
    expect(stats.thisWeek.words, 1050);
    expect(stats.thisMonth.chapters, 5);
    expect(stats.year(2025).words, 1000);
    expect(stats.years, [2026, 2025]);
    expect(stats.daysReadIn(2026), 4);
    expect(
      [for (final w in stats.topWorks(2026)) (w.work.title, w.totals.words)],
      [('Alpha', 700), ('Beta', 350)],
    );
    final days = stats.lastDays(7);
    expect(days.first.$1, DateTime(2026, 10, 18));
    expect(days.last.$1, DateTime(2026, 10, 24));
    expect([for (final d in days) d.$2.words], [0, 100, 0, 200, 300, 450, 0]);
  });

  test('finishing sets the date, also kept through the trash', () async {
    expect((await db.workById(a))!.finishedAt, isNull);
    await db.updateWork(
      a,
      const WorksCompanion(status: Value(ReadingStatus.finished)),
    );
    final finished = (await db.workById(a))!.finishedAt;
    expect(finished, isNotNull);
    expect(await db.finishedIn(finished!.year), hasLength(1));

    // Changing other fields keeps the date.
    await db.updateWork(a, const WorksCompanion(rating: Value(5)));
    expect((await db.workById(a))!.finishedAt, finished);

    final deleted = await db.deleteWork(a);
    await db.restoreWork(deleted!);
    expect((await db.workById(a))!.finishedAt, finished);
  });

  testWidgets('the statistics screen shows totals and the year', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(
      () =>
          db.addReading(a, DateTime(2026, 10, 24), words: 1234, seconds: 3900),
    );
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StatsScreen(today: DateTime(2026, 10, 24, 22)),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Durations.short1));
      await tester.pump();
    }
    expect(find.text('Most in a day: 1,234 words'), findsOneWidget);
    expect(find.text('2026 in review'), findsOneWidget);
    expect(find.text('1 h 5 min'), findsWidgets);
    expect(find.text('1 day'), findsWidgets);
    expect(find.text('Alpha'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
