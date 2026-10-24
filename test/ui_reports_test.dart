import 'dart:io';

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
import 'package:readtrack/screens/read_section.dart';
import 'package:readtrack/screens/settings_screen.dart';
import 'package:readtrack/ui/app_settings.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late LibraryStorage storage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final temp = Directory.systemTemp.createTempSync('readtrack_ui');
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/b'),
      exportDir: Directory('${temp.path}/e'),
    );
  });
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Durations.short1));
      await tester.pump(Durations.short4);
    }
  }

  Widget app(Widget home, {AppSettings? settings}) => DatabaseScope(
    db: db,
    child: LibraryScope(
      storage: storage,
      downloads: DownloadService(db, storage),
      child: SettingsScope(
        settings: settings ?? AppSettings(db),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    ),
  );

  testWidgets('settings hide 18+ tags while "Hide 18+" is on', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = AppSettings(db);
    await tester.runAsync(() async {
      await db.saveWork(
        WorksCompanion.insert(
          type: WorkType.fanfiction,
          format: WorkFormat.online,
          title: 'A',
        ),
        tagNames: ['Fluff', 'Smut'],
        adultTags: {'Smut'},
      );
      await settings.setHideAdultTags(true);
    });
    await tester.pumpWidget(app(const SettingsScreen(), settings: settings));
    await settle(tester);
    expect(find.text('Fluff'), findsOneWidget);
    expect(find.text('Smut'), findsNothing);
    expect(find.textContaining('1 tag marked 18+ is hidden'), findsOneWidget);

    await tester.runAsync(() => settings.setHideAdultTags(false));
    await settle(tester);
    expect(find.text('Smut'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('the download button comes before the bookmarks', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final work = (await tester.runAsync(() async {
      final id = await db.saveWork(
        WorksCompanion.insert(
          type: WorkType.fanfiction,
          format: WorkFormat.online,
          title: 'A',
          sourceUrl: const Value('https://archiveofourown.org/works/1'),
        ),
      );
      await db.saveChapterList(id, [
        (
          number: 1,
          title: 'One',
          url: 'https://archiveofourown.org/works/1/chapters/1',
          locked: false,
        ),
      ]);
      await db.addAnnotation(
        AnnotationsCompanion.insert(
          workId: id,
          chapterNumber: 1,
          kind: AnnotationKind.bookmark,
        ),
      );
      return (await db.workById(id))!;
    }))!;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: SingleChildScrollView(child: ReadSection(work: work)),
        ),
      ),
    );
    await settle(tester);
    final button = tester.getTopLeft(find.text('Download…')).dy;
    final bookmarks = tester
        .getTopLeft(find.text('Bookmarks, quotes & notes'))
        .dy;
    expect(button, lessThan(bookmarks));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
