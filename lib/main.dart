import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/database_scope.dart';
import 'screens/library_screen.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LesetrackerApp(db: AppDatabase()));
}

class LesetrackerApp extends StatelessWidget {
  const LesetrackerApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return DatabaseScope(
      db: db,
      // Nutzt auf Android 12+ die Akzentfarbe des Systems (Material You).
      // Das Schema wird trotzdem per fromSeed erzeugt, weil die Schemata von
      // dynamic_color nicht alle aktuellen Material-3-Farbrollen enthalten.
      child: DynamicColorBuilder(
        builder: (light, dark) => MaterialApp(
          title: 'Lesetracker',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(light?.primary ?? kSeedColor, Brightness.light),
          darkTheme: buildTheme(dark?.primary ?? kSeedColor, Brightness.dark),
          home: const LibraryScreen(),
        ),
      ),
    );
  }
}
