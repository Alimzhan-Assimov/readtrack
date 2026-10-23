import 'package:flutter/widgets.dart';

import 'download_service.dart';
import 'storage.dart';
import 'update_checker.dart';

/// Provides file storage and the download service to the screens below.
class LibraryScope extends InheritedWidget {
  const LibraryScope({
    super.key,
    required this.storage,
    required this.downloads,
    this.updates,
    required super.child,
  });

  final LibraryStorage storage;
  final DownloadService downloads;

  /// Null where nothing should be fetched in the background, e.g. in tests.
  final UpdateChecker? updates;

  static LibraryScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LibraryScope>()!;

  @override
  bool updateShouldNotify(LibraryScope oldWidget) =>
      storage != oldWidget.storage ||
      downloads != oldWidget.downloads ||
      updates != oldWidget.updates;
}
