import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesetracker/data/database.dart';
import 'package:lesetracker/main.dart';

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
    await tester.pumpWidget(LesetrackerApp(db: db));
    await tester.pumpAndSettle();
  }

  /// Baut den Widget-Baum ab, damit drift seine Stream-Timer beenden kann.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('schmales Fenster öffnet Details als eigene Seite', (
    tester,
  ) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    expect(find.text('Auf fanfiction.net lesen'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('breites Fenster zeigt Details neben der Liste', (tester) async {
    await pumpApp(tester, width: 1200);
    expect(find.text('Wähle links einen Eintrag aus'), findsOneWidget);

    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    expect(find.text('Auf fanfiction.net lesen'), findsOneWidget);
    // Einmal in der Liste, einmal in der Detailspalte.
    expect(find.text('The New Dawn'), findsNWidgets(2));
    await unmount(tester);
  });

  testWidgets('Löschen lässt sich per Snackbar rückgängig machen', (
    tester,
  ) async {
    await pumpApp(tester, width: 1200);
    await tester.tap(find.text('The New Dawn'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsNothing);

    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();
    expect(find.text('The New Dawn'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('neuer Eintrag wird gespeichert und angezeigt', (tester) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titel *'),
      'Kingdom of Leaves',
    );
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(find.text('Kingdom of Leaves'), findsOneWidget);
    expect(find.byTooltip('Bearbeiten'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('Verlassen mit ungespeicherten Änderungen fragt nach', (
    tester,
  ) async {
    await pumpApp(tester, width: 400);
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titel *'),
      'Halb fertig',
    );
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Änderungen verwerfen?'), findsOneWidget);

    await tester.tap(find.text('Verwerfen'));
    await tester.pumpAndSettle();
    expect(find.text('Meine Bibliothek'), findsOneWidget);
    await unmount(tester);
  });
}
