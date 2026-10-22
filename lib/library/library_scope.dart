import 'package:flutter/widgets.dart';

import 'download_service.dart';
import 'storage.dart';

/// Provides file storage and the download service to the screens below.
class LibraryScope extends InheritedWidget {
  const LibraryScope({
    super.key,
    required this.storage,
    required this.downloads,
    required super.child,
  });

  final LibraryStorage storage;
  final DownloadService downloads;

  static LibraryScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LibraryScope>()!;

  @override
  bool updateShouldNotify(LibraryScope oldWidget) =>
      storage != oldWidget.storage || downloads != oldWidget.downloads;
}
