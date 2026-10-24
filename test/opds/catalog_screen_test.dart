import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/database_scope.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/library/book_importer.dart';
import 'package:readtrack/library/download_service.dart';
import 'package:readtrack/library/exporters.dart';
import 'package:readtrack/library/file_import.dart';
import 'package:readtrack/library/library_scope.dart';
import 'package:readtrack/library/storage.dart';
import 'package:readtrack/opds/opds.dart';
import 'package:readtrack/screens/catalog_screen.dart';
import 'package:readtrack/screens/work_edit_screen.dart';

import '../sources/fake_fetcher.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late LibraryStorage storage;
  late List<int> epub;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final temp = Directory.systemTemp.createTempSync('readtrack_opds');
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/books'),
      exportDir: Directory('${temp.path}/exports'),
    );
    epub = buildEpub(
      ExportBook(
        work: Work(
          id: 1,
          type: WorkType.book,
          format: WorkFormat.digital,
          title: 'War and Peace',
          author: 'Leo Tolstoy',
          status: ReadingStatus.planned,
          isComplete: true,
          addedAt: DateTime(2026),
          updatedAt: DateTime(2026),
          newChapters: 0,
          wordsEstimated: false,
          pagesEstimated: false,
        ),
        chapters: [
          Chapter(
            id: 1,
            workId: 1,
            number: 1,
            title: 'Book One',
            content: '<p>Well, Prince, so Genoa and Lucca.</p>',
            isLocked: false,
          ),
        ],
        from: 1,
        to: 1,
        storage: storage,
      ),
    );
  });

  tearDown(() => db.close());

  FakeFetcher catalog() => FakeFetcher(
    {
      'https://cat.test/root':
          '<feed xmlns="http://www.w3.org/2005/Atom"><title>Cat</title>'
          '<entry><title>Classics</title><link rel="subsection" type="application/atom+xml;profile=opds-catalog" href="/classics"/></entry></feed>',
      'https://cat.test/classics':
          '<feed xmlns="http://www.w3.org/2005/Atom"><title>Classics</title>'
          '<entry><title>War and Peace</title><author><name>Leo Tolstoy</name></author>'
          '<link rel="alternate" type="text/html" href="/books/2600"/>'
          '<link rel="http://opds-spec.org/acquisition" type="application/epub+zip" href="/books/2600.epub"/></entry></feed>',
    },
    bytes: {'https://cat.test/books/2600.epub': epub},
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(Durations.short1));
      await tester.pump(Durations.short4);
    }
  }

  Widget app(Widget home) => DatabaseScope(
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
  );

  final cat = OpdsCatalog('Cat', Uri.parse('https://cat.test/root'));

  testWidgets('a catalog book opens the form with its details', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        CatalogFeedScreen(
          catalog: cat,
          url: cat.url,
          title: 'Cat',
          fetcher: catalog(),
        ),
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Classics'));
    await settle(tester);
    expect(find.text('War and Peace'), findsOneWidget);
    await tester.tap(find.byTooltip('Add to library'));
    await settle(tester);
    expect(find.byType(WorkEditScreen), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Leo Tolstoy'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'https://cat.test/books/2600'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('a catalog book can be attached to a paper book', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final id = (await tester.runAsync(
      () => db.saveWork(
        WorksCompanion.insert(
          type: WorkType.book,
          format: WorkFormat.physical,
          title: 'Война и мир',
          isbn: const Value('9783161484100'),
        ),
      ),
    ))!;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              catalogRoute(
                id,
                (_) => CatalogFeedScreen(
                  catalog: cat,
                  url: Uri.parse('https://cat.test/classics'),
                  title: 'Classics',
                  attachTo: id,
                  fetcher: catalog(),
                ),
              ),
            ),
            child: const Text('detail'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('detail'));
    await settle(tester);
    await tester.tap(find.byTooltip('Attach to this entry'));
    await settle(tester);
    // Back on the entry, which keeps its details and can now be read.
    expect(find.text('detail'), findsOneWidget);
    final w = (await tester.runAsync(() => db.workById(id)))!;
    expect(
      (w.title, w.format, w.isbn, w.chapterCount),
      ('Война и мир', WorkFormat.physical, '9783161484100', 1),
    );
    final chapters = (await tester.runAsync(() => db.chaptersOf(id)))!;
    expect(chapters.single.content, contains('Genoa'));
    expect(
      (await tester.runAsync(() => db.downloadsOf(id)))!.single.format,
      'epub',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  test('attaching keeps the entry and fills only what it lacks', () async {
    final id = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.book,
        format: WorkFormat.physical,
        title: 'Mine',
        summary: const Value('My summary'),
      ),
    );
    final file = File('${storage.dataDir.parent.path}/x.epub')
      ..createSync(recursive: true)
      ..writeAsBytesSync(epub);
    final book = await readBookFile(file.path);
    await BookImporter(db, storage).attach(id, book, original: file);
    final w = (await db.workById(id))!;
    expect((w.title, w.summary, w.chapterCount), ('Mine', 'My summary', 1));
    expect(w.wordCount, greaterThan(0));
  });
}
