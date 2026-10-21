import 'package:flutter/widgets.dart';

import 'database.dart';

/// Stellt die Datenbank allen Screens unterhalb zur Verfügung.
class DatabaseScope extends InheritedWidget {
  const DatabaseScope({super.key, required this.db, required super.child});

  final AppDatabase db;

  static AppDatabase of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DatabaseScope>()!.db;

  @override
  bool updateShouldNotify(DatabaseScope oldWidget) => db != oldWidget.db;
}
