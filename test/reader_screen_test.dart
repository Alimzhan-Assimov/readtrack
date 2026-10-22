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
import 'package:readtrack/reader/reader_screen.dart';
import 'package:readtrack/screens/import_screen.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late LibraryStorage storage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final temp = Directory.systemTemp.createTempSync('readtrack_reader');
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/books'),
      exportDir: Directory('${temp.path}/exports'),
    );
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: LibraryScope(
          storage: storage,
          downloads: DownloadService(db, storage),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets(
    'reads a download, continues at the saved chapter and remembers it',
    (tester) async {
      late Work work;
      late Download download;
      await tester.runAsync(() async {
        final id = await db.saveWork(
          WorksCompanion.insert(
            type: WorkType.fanfiction,
            format: WorkFormat.online,
            title: 'Kingdom of Leaves',
            sourceUrl: const Value('https://www.royalroad.com/fiction/1'),
            currentChapter: const Value(2),
          ),
        );
        await db.saveChapterList(id, [
          for (var n = 1; n <= 3; n++)
            (
              number: n,
              title: 'Chapter $n',
              url: 'https://www.royalroad.com/c/$n',
              locked: false,
            ),
        ]);
        for (var n = 1; n <= 3; n++) {
          await db.saveChapterText(
            id,
            n,
            html: '<p>Text of chapter <em>$n</em>.</p>',
            wordCount: 4,
          );
        }
        await db.addDownload(
          DownloadsCompanion.insert(workId: id, fromChapter: 1, toChapter: 3),
        );
        work = (await db.watchWork(id).first)!.work;
        download = (await db.downloadsOf(id)).single;
      });

      await pump(
        tester,
        ReaderScreen(work: work, mode: DownloadReading(download)),
      );
      expect(find.textContaining('Text of chapter 2'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);

      await tester.tap(find.byTooltip('Next chapter').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Text of chapter 3'), findsOneWidget);
      expect(find.text('End of this download.'), findsOneWidget);

      final saved = await tester.runAsync(() => db.watchWork(work.id).first);
      expect(saved!.work.currentChapter, 3);
      expect(saved.work.status, ReadingStatus.reading);
      await unmount(tester);
    },
  );

  testWidgets('import explains unsupported sites', (tester) async {
    await pump(tester, const ImportScreen());
    await tester.enterText(
      find.byType(TextField),
      'https://example.com/story/1',
    );
    await tester.tap(find.text('Load details'));
    await tester.pumpAndSettle();
    expect(find.textContaining("isn't supported yet"), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'archiveofourown.org/works/123',
    );
    await tester.pump();
    expect(find.text('Recognized: AO3'), findsOneWidget);
    await unmount(tester);
  });
}
