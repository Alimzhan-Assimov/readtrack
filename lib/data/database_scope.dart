import 'package:flutter/widgets.dart';

import 'database.dart';

/// Provides the database to all screens below it.
class DatabaseScope extends InheritedWidget {
  const DatabaseScope({super.key, required this.db, required super.child});

  final AppDatabase db;

  static AppDatabase of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DatabaseScope>()!.db;

  @override
  bool updateShouldNotify(DatabaseScope oldWidget) => db != oldWidget.db;
}
