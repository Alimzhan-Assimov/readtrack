import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/database_scope.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/screens/list_import_screen.dart';

import 'sources/fake_fetcher.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  String story(String id, String title) =>
      'https://www.wattpad.com/api/v3/stories/$id?fields=id%2Ctitle%2Cuser%28name%29%2Cdescription%2Ccover%2Ccompleted%2Ctags%2CmainCategory%2Cparts%28id%2Ctitle%2CwordCount%2Curl%2Cdraft%2Cdeleted%29';

  testWidgets('a reading list is loaded, picked from and added', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.runAsync(
      () => db.saveWork(
        WorksCompanion.insert(
          type: WorkType.webnovel,
          format: WorkFormat.online,
          title: 'Two',
          sourceUrl: const Value('https://www.wattpad.com/story/2'),
        ),
      ),
    );
    final fetcher = FakeFetcher({
      'https://www.wattpad.com/api/v3/lists/42/stories?limit=100&fields=stories%28id%2Ctitle%29%2CnextUrl': '{"stories":[{"id":"1","title":"One"},{"id":"2","title":"Two"},{"id":"3","title":"Three"}]}',
      story('1', 'One'): '{"id":"1","title":"One","user":{"name":"A"},"tags":["romance"],"parts":[{"id":10,"title":"P1","wordCount":1500,"url":"https://www.wattpad.com/10-p1"}]}',
    });
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ListImportScreen(open: (_) => fetcher, pause: Duration.zero),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'https://www.wattpad.com/list/42-faves',
    );
    await tester.tap(find.byTooltip('Load list'));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Durations.short1));
      await tester.pump();
    }
    expect(find.text('3 stories, 1 already in your library'), findsOneWidget);
    expect(find.text('Already in your library'), findsOneWidget);
    expect(find.text('Add 2 stories'), findsOneWidget);

    // Leave out "Three" (it would fail: no fake page).
    await tester.tap(find.text('Three'));
    await tester.pump();
    await tester.tap(find.text('Add 1 story'));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Durations.short1));
      await tester.pump();
    }
    expect(find.text('Added 1, 0 failed'), findsOneWidget);
    final added = await tester.runAsync(
      () => db.workBySourceUrl('https://www.wattpad.com/story/1'),
    );
    expect(
      (added!.title, added.author, added.status),
      ('One', 'A', ReadingStatus.planned),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('a single story link is pointed to the link import', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ListImportScreen(open: (_) => FakeFetcher(const {})),
        ),
      ),
    );
    await tester.enterText(
      find.byType(TextField),
      'https://archiveofourown.org/works/1',
    );
    await tester.tap(find.byTooltip('Load list'));
    await tester.pump();
    expect(find.textContaining('single story'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'https://example.com/x');
    await tester.tap(find.byTooltip('Load list'));
    await tester.pump();
    expect(find.text("This isn't a link to a supported site."), findsOneWidget);
  });
}
