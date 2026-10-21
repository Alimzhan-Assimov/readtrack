import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/database_scope.dart';
import 'screens/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LesetrackerApp(db: AppDatabase()));
}

class LesetrackerApp extends StatelessWidget {
  const LesetrackerApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6B4E9B);
    return DatabaseScope(
      db: db,
      child: MaterialApp(
        title: 'Lesetracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.light),
        darkTheme: ThemeData(
          colorSchemeSeed: seed,
          brightness: Brightness.dark,
        ),
        home: const LibraryScreen(),
      ),
    );
  }
}
