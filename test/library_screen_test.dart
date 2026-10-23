import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/download_service.dart';
import 'package:readtrack/library/storage.dart';
import 'package:readtrack/main.dart';
import 'package:readtrack/ui/app_settings.dart';
import 'package:readtrack/widgets/tag_input.dart';
import 'package:readtrack/widgets/work_grid_tile.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late LibraryStorage storage;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final temp = Directory.systemTemp.createTempSync('readtrack_test');
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/books'),
      exportDir: Directory('${temp.path}/exports'),
    );
    await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'The New Dawn',
        sourceUrl: const Value('https://www.fanfiction.net/s/1'),
      ),
      fandomName: 'Naruto',
      tagNames: ['Action'],
    );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester, {required double width}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ReadTrackApp(
        db: db,
        storage: storage,
        downloads: DownloadService(db, storage),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Tears down the widget tree so drift can finish its stream timers.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('narrow window opens details as a separate page', (tester) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    expect(find.text('Read on fanfiction.net'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('wide window shows details next to the list', (tester) async {
    await pumpApp(tester, width: 1200);
    expect(find.text('Select an entry on the left'), findsOneWidget);

    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    expect(find.text('Read on fanfiction.net'), findsOneWidget);
    // Once in the list, once in the detail pane.
    expect(find.text('The New Dawn'), findsNWidgets(2));
    await unmount(tester);
  });

  testWidgets('deleting asks first and can be undone', (tester) async {
    await pumpApp(tester, width: 1200);
    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsWidgets, reason: 'cancelled');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('deleted entries can be restored from the trash', (tester) async {
    await pumpApp(tester, width: 1200);
    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('1 entry'), findsOneWidget);
    await tester.tap(find.text('Trash'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();
    expect(find.text('The trash is empty'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('new entry is saved and shown', (tester) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter manually'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title *'),
      'Kingdom of Leaves',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Kingdom of Leaves'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('leaving with unsaved changes asks for confirmation', (
    tester,
  ) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter manually'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title *'),
      'Half done',
    );
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('My Library'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('all filters fit into the list pane without scrolling', (
    tester,
  ) async {
    await pumpApp(tester, width: 1200);
    for (final label in ['Type', 'Category', 'Tag']) {
      // The list pane is 400 dp wide; every chip must end inside it.
      expect(tester.getRect(find.text(label)).right, lessThan(400));
    }

    await tester.tap(find.text('Type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing found'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('existing tags and categories can be picked from a list', (
    tester,
  ) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter manually'));
    await tester.pumpAndSettle();

    // "Action" is used by the existing entry, so it is offered directly.
    final form = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Frequently used:'),
      300,
      scrollable: form,
    );
    expect(find.widgetWithText(ActionChip, 'Action'), findsOneWidget);

    // Pick a suggested tag from the full list.
    final browseTags = find.descendant(
      of: find.byType(TagInput).first,
      matching: find.byTooltip('Choose from existing'),
    );
    await tester.ensureVisible(browseTags);
    await tester.pumpAndSettle();
    await tester.tap(browseTags);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Search…'), 'marr');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marriage'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Marriage'), findsOneWidget);

    // Pick the existing category.
    await tester.scrollUntilVisible(
      find.text('Category / fandom'),
      -300,
      scrollable: form,
    );
    final browseCategory = find.descendant(
      of: find.widgetWithText(TextFormField, 'Category / fandom'),
      matching: find.byTooltip('Choose from existing'),
    );
    await tester.ensureVisible(browseCategory);
    await tester.pumpAndSettle();
    await tester.tap(browseCategory);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Naruto'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Naruto'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('18+ tags can be hidden in the settings', (tester) async {
    await tester.runAsync(() async {
      final id = (await db.watchWorks().first).single.work.id;
      final work = (await db.watchWork(id).first)!;
      await db.saveWork(
        work.work.toCompanion(false),
        fandomName: 'Naruto',
        tagNames: ['Action', 'Explicit Sex'],
      );
    });
    final settings = AppSettings(db);
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ReadTrackApp(
        db: db,
        storage: storage,
        downloads: DownloadService(db, storage),
        settings: settings,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Explicit Sex'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide 18+ tags'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Explicit Sex'), findsNothing);
    expect(find.text('Action'), findsOneWidget);
    expect(await tester.runAsync(() => db.setting('hideAdultTags')), 'true');
    await unmount(tester);
  });

  testWidgets('filters can be saved as a shelf; grid view', (tester) async {
    final settings = AppSettings(db);
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ReadTrackApp(
        db: db,
        storage: storage,
        downloads: DownloadService(db, storage),
        settings: settings,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Length'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50K+ words'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsNothing);

    await tester.tap(find.text('Save as shelf'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Long reads');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(settings.shelves.single.filter.minWords, 50000);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await tester.tap(find.text('Long reads'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsNothing);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Show as grid'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkGridTile), findsOneWidget);
    expect(settings.gridView, isTrue);
    await unmount(tester);
  });
}
