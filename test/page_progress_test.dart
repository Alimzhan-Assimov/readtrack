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
import 'package:readtrack/screens/work_detail_screen.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a paper book tracks pages, statistics and page notes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final temp = Directory.systemTemp.createTempSync('readtrack_pages');
    final storage = LibraryStorage(
      dataDir: Directory('${temp.path}/b'),
      exportDir: Directory('${temp.path}/e'),
    );
    final id = (await tester.runAsync(
      () => db.saveWork(
        WorksCompanion.insert(
          type: WorkType.book,
          format: WorkFormat.physical,
          title: 'Der kleine Hobbit',
          pageCount: const Value(300),
        ),
      ),
    ))!;
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: LibraryScope(
          storage: storage,
          downloads: DownloadService(db, storage),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WorkDetailScreen(workId: id),
          ),
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
    expect(find.text('Page 0 of 300'), findsOneWidget);
    await tester.tap(find.text('Set page'));
    await settle();
    await tester.enterText(find.byType(TextField).last, '120');
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await settle();
    expect(find.text('Page 120 of 300'), findsOneWidget);
    final w = (await tester.runAsync(() => db.workById(id)))!;
    expect((w.currentPage, w.status), (120, ReadingStatus.reading));
    final log = (await tester.runAsync(db.readingLog))!;
    expect(log.single.$1.words, 120 * AppDatabase.wordsPerPage);

    await tester.tap(find.text('Add note'));
    await settle();
    await tester.enterText(find.byType(TextField).last, 'Bilbo leaves home');
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await settle();
    expect(find.text('Bilbo leaves home'), findsOneWidget);
    expect(find.text('Page 120'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
