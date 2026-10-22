import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/main.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
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
    await tester.pumpWidget(ReadTrackApp(db: db));
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

  testWidgets('deleting can be undone from the snackbar', (tester) async {
    await pumpApp(tester, width: 1200);
    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('new entry is saved and shown', (tester) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('Add'));
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
}
