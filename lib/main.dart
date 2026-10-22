import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/database_scope.dart';
import 'l10n/l10n.dart';
import 'library/download_service.dart';
import 'library/library_scope.dart';
import 'library/storage.dart';
import 'screens/library_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final storage = await LibraryStorage.open();
  runApp(
    ReadTrackApp(
      db: db,
      storage: storage,
      downloads: DownloadService(db, storage),
    ),
  );
}

class ReadTrackApp extends StatelessWidget {
  const ReadTrackApp({
    super.key,
    required this.db,
    required this.storage,
    required this.downloads,
  });

  final AppDatabase db;
  final LibraryStorage storage;
  final DownloadService downloads;

  @override
  Widget build(BuildContext context) {
    return DatabaseScope(
      db: db,
      child: LibraryScope(
        storage: storage,
        downloads: downloads,
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
      ),
    );
  }
}
