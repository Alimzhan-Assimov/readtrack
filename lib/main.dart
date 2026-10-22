import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/database_scope.dart';
import 'l10n/l10n.dart';
import 'screens/library_screen.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ReadTrackApp(db: AppDatabase()));
}

class ReadTrackApp extends StatelessWidget {
  const ReadTrackApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return DatabaseScope(
      db: db,
      // Uses the system accent color on Android 12+ (Material You). The
      // scheme is still built with fromSeed because dynamic_color's schemes
      // lack some of the current Material 3 color roles.
      child: DynamicColorBuilder(
        builder: (light, dark) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(light?.primary ?? kSeedColor, Brightness.light),
          darkTheme: buildTheme(dark?.primary ?? kSeedColor, Brightness.dark),
          home: const LibraryScreen(),
        ),
      ),
    );
  }
}
