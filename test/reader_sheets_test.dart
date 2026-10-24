import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/reader/reader_sheets.dart';
import 'package:readtrack/ui/app_settings.dart';

void main() {
  late ReaderPrefs prefs;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    prefs = const ReaderPrefs();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReaderSettingsSheet(
            prefs: prefs,
            onChanged: (p) => prefs = p,
            fonts: () async => ['Fira Code', 'Noto Serif'],
          ),
        ),
      ),
    );
  }

  testWidgets('custom colors are taken from hex input', (tester) async {
    await pump(tester);
    expect(find.text('Background'), findsNothing);
    await tester.tap(find.text('Custom'));
    await tester.pump();
    expect(prefs.theme, ReaderTheme.custom);

    final background = find.widgetWithText(TextField, 'Background');
    await tester.enterText(background, '#12');
    await tester.pump();
    expect(find.text('Use #RRGGBB'), findsOneWidget);
    expect(prefs.pageColor, const ReaderPrefs().background);

    await tester.enterText(background, '#102030');
    await tester.enterText(find.widgetWithText(TextField, 'Text'), 'eeeeee');
    await tester.pump();
    expect(find.text('Use #RRGGBB'), findsNothing);
    expect(
      (prefs.pageColor, prefs.inkColor),
      (const Color(0xFF102030), const Color(0xFFEEEEEE)),
    );
  });

  testWidgets('the text width slider reaches the full window', (tester) async {
    await pump(tester);
    final slider = find.byType(Slider).last;
    await tester.drag(slider, const Offset(1000, 0));
    await tester.pump();
    expect(prefs.textWidth, double.infinity);

    await tester.tap(find.text('Default width'));
    await tester.pump();
    expect(prefs.textWidth, 720);
  });

  testWidgets('a typed font name can be used and reset', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Other font…'));
    await tester.pumpAndSettle();
    expect(find.text('Noto Serif'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'noto');
    await tester.pumpAndSettle();
    expect(find.text('Fira Code'), findsNothing);
    await tester.tap(find.text('Noto Serif'));
    await tester.pumpAndSettle();
    expect(prefs.family, 'Noto Serif');

    await tester.tap(find.text('Noto Serif'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My Font');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use “My Font”'));
    await tester.pumpAndSettle();
    expect(prefs.family, 'My Font');
    expect(find.text('My Font'), findsOneWidget);

    await tester.tap(find.text('Sans'));
    await tester.pump();
    expect((prefs.fontFamily, prefs.family), (null, 'sans-serif'));
  });
}
