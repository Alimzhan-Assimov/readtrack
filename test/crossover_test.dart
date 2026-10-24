import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/database_scope.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/library/download_service.dart';
import 'package:readtrack/library/library_scope.dart';
import 'package:readtrack/library/storage.dart';
import 'package:readtrack/screens/franchise_screen.dart';
import 'package:readtrack/sources/fanfiction_net.dart';

import 'dart:io';

import 'sources/fake_fetcher.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> add(
    String title, {
    WorkType type = WorkType.fanfiction,
    String? fandom,
    List<String>? crossovers,
    String? series,
    double? index,
  }) => db.saveWork(
    WorksCompanion.insert(
      type: type,
      format: WorkFormat.online,
      title: title,
      seriesIndex: Value(index),
    ),
    fandomName: fandom,
    crossoverNames: crossovers,
    seriesName: series,
  );

  test('a crossover shows under each franchise and is counted once', () async {
    final fic = await add(
      'Two Worlds',
      fandom: 'Naruto',
      crossovers: ['Harry Potter', 'Naruto (Anime & Manga)'],
    );
    await add('Only Naruto', fandom: 'Naruto');
    final w = (await db.watchWork(fic).first)!;
    expect(w.fandom!.name, 'Naruto');
    // The alias of the main category isn't added as a crossover.
    expect(w.crossovers.map((f) => f.name), ['Harry Potter']);

    final hp = w.crossovers.single;
    expect(
      [
        for (final x in await db.watchWorks(fandomId: hp.id).first)
          x.work.title,
      ],
      ['Two Worlds'],
    );
    expect((await db.usedFandoms()).map((f) => f.name), [
      'Harry Potter',
      'Naruto',
    ]);
    final counts = await db.usageCounts(UsageKind.fandom);
    expect(counts[w.fandom!.id], 2);
    expect(counts[hp.id], 1);
    expect(
      (await db.watchWorks(search: 'potter').first).single.work.title,
      'Two Worlds',
    );

    // Saving without crossover names keeps them; deleting and undoing too.
    await db.saveWork(
      WorksCompanion(id: Value(fic), title: const Value('Two Worlds')),
      fandomName: 'Naruto',
    );
    expect((await db.watchWork(fic).first)!.crossovers, hasLength(1));
    final deleted = await db.deleteWork(fic);
    await db.restoreWork(deleted!);
    expect((await db.watchWork(fic).first)!.crossovers, hasLength(1));
  });

  test('FanFiction.net: a crossover category gives both fandoms', () async {
    final story = Uri.parse('https://www.fanfiction.net/s/42/1');
    final info = await const FanFictionNetSource().fetchStory(
      story,
      FakeFetcher({
        '$story': '''
          <div id="pre_story_links"><a href="/crossovers/">Crossover</a><a href="/Harry-Potter-and-Naruto-Crossovers/224/1402/">Naruto + Harry Potter Crossover</a></div>
          <div id="profile_top"><b class="xcontrast_txt">Fox and Lion</b> By: <a href="/u/1/x">x</a>
          <span class="xgray xcontrast_txt">Rated: Fiction T - English - Adventure - Chapters: 1 - Words: 900 - Status: Complete - id: 42</span></div>
          <div id="storytext"><p>Hi.</p></div>''',
      }),
    );
    expect(info.fandom, 'Naruto');
    expect(info.crossovers, ['Harry Potter']);
  });

  testWidgets('the franchise page groups by type and series', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await add(
        'Naruto Vol. 2',
        type: WorkType.manga,
        fandom: 'Naruto',
        series: 'Naruto',
        index: 2,
      );
      await add(
        'Naruto Vol. 1',
        type: WorkType.manga,
        fandom: 'Naruto',
        series: 'Naruto',
        index: 1,
      );
      await add('A Fic', fandom: 'Naruto');
      await add('Crossing', fandom: 'Bleach', crossovers: ['Naruto']);
    });
    final naruto = (await tester.runAsync(db.usedFandoms))!
        .firstWhere((f) => f.name == 'Naruto');
    final temp = Directory.systemTemp.createTempSync('readtrack_fr');
    final storage = LibraryStorage(
      dataDir: Directory('${temp.path}/b'),
      exportDir: Directory('${temp.path}/e'),
    );
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: LibraryScope(
          storage: storage,
          downloads: DownloadService(db, storage),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FranchiseScreen(fandom: naruto),
          ),
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Durations.short1));
      await tester.pump();
    }
    expect(find.text('3 entries, 1 crossover'), findsOneWidget);
    double y(String text) => tester.getTopLeft(find.text(text).first).dy;
    expect(y('Manga'), lessThan(y('Naruto Vol. 1')));
    expect(y('Naruto Vol. 1'), lessThan(y('Naruto Vol. 2')));
    expect(y('Naruto Vol. 2'), lessThan(y('Fanfiction')));
    expect(y('Fanfiction'), lessThan(y('A Fic')));
    expect(y('A Fic'), lessThan(y('Crossovers from other categories')));
    expect(find.text('Crossing'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
