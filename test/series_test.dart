import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/database_scope.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/screens/related_section.dart';
import 'package:readtrack/sources/ao3.dart';

import 'sources/fake_fetcher.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> add(String title, {String? series, double? index}) => db.saveWork(
    WorksCompanion.insert(
      type: WorkType.book,
      format: WorkFormat.physical,
      title: title,
      seriesIndex: Value(index),
    ),
    seriesName: series,
  );

  test('series keep their reading order and can be filtered', () async {
    final three = await add('Prisoner', series: 'Harry Potter', index: 3);
    await add('Stone', series: 'harry potter', index: 1);
    await add('Unnumbered', series: 'Harry Potter');
    await add('Hobbit');
    final w = (await db.watchWork(three).first)!;
    expect(w.series!.name, 'Harry Potter');
    expect(
      [for (final x in await db.watchSeries(w.series!.id).first) x.title],
      ['Stone', 'Prisoner', 'Unnumbered'],
    );
    expect(await db.usedSeries(), hasLength(1));
    expect((await db.watchWorks(seriesId: w.series!.id).first).length, 3);
    expect([
      for (final x in await db.watchWorks(search: 'potter').first) x.work.title,
    ], hasLength(3));

    // Saving without a series name leaves it; an empty one removes it.
    await db.saveWork(
      WorksCompanion(id: Value(three), title: const Value('Prisoner')),
    );
    expect((await db.workById(three))!.seriesId, w.series!.id);
    await db.saveWork(
      WorksCompanion(id: Value(three), title: const Value('Prisoner')),
      seriesName: '',
    );
    expect((await db.workById(three))!.seriesId, isNull);
  });

  test('relations show from both sides and survive undoing a delete', () async {
    final naruto = await add('Naruto');
    final boruto = await add('Boruto');
    await db.addRelation(naruto, RelationType.sequel, boruto);
    await db.addRelation(naruto, RelationType.sequel, naruto); // ignored
    final fromNaruto = await db.watchRelations(naruto).first;
    expect(fromNaruto.single.work.title, 'Boruto');
    expect(fromNaruto.single.relation.fromWorkId, naruto);
    final fromBoruto = await db.watchRelations(boruto).first;
    expect(fromBoruto.single.work.title, 'Naruto');
    expect(fromBoruto.single.relation.fromWorkId, naruto);

    final deleted = await db.deleteWork(boruto);
    expect(await db.watchRelations(naruto).first, isEmpty);
    await db.restoreWork(deleted!);
    expect(await db.watchRelations(naruto).first, hasLength(1));

    await db.removeRelation(fromBoruto.single.relation);
    expect(await db.watchRelations(naruto).first, isEmpty);
  });

  test('AO3: the series and the part number are read', () async {
    final story = Uri.parse('https://archiveofourown.org/works/7');
    final info = await const Ao3Source().fetchStory(
      story,
      FakeFetcher({
        'https://archiveofourown.org/works/7?view_adult=true': '''
          <h2 class="title heading">Second Part</h2>
          <dl class="work meta group"><dd class="series"><span class="series"><span class="position">Part 2 of the <a href="/series/5">Long Saga</a> series</span></span></dd></dl>
          <div id="chapters"><div class="userstuff"><p>x</p></div></div>''',
        'https://archiveofourown.org/works/7/navigate':
            '<ol class="chapter index"></ol>',
      }),
    );
    expect(info.series, (name: 'Long Saga', index: 2.0));
  });

  testWidgets('the detail section lists the series and adds a relation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ids = (await tester.runAsync(() async {
      final a = await add('Stone', series: 'Harry Potter', index: 1);
      final b = await add('Chamber', series: 'Harry Potter', index: 2);
      final c = await add('Fantastic Beasts');
      return [a, b, c];
    }))!;
    final item = (await tester.runAsync(() => db.watchWork(ids[0]).first))!;
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RelatedSection(item: item)),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(Durations.short1));
        await tester.pump(Durations.short4);
      }
    }

    await settle();
    expect(find.text('Series: Harry Potter'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('Chamber'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await settle();
    await tester.tap(find.text('Spin-off'));
    await settle();
    await tester.tap(find.text('Fantastic Beasts'));
    await settle();
    expect(find.text('Spin-off'), findsOneWidget);
    expect(
      (await tester.runAsync(() => db.watchRelations(ids[2]).first))!
          .single
          .relation
          .type,
      RelationType.spinOff,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
