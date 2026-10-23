import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import 'storage.dart';

class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Saves the whole library (database and downloaded books) into one zip
/// file, and restores it again.
///
/// Restoring can't replace the open database, so the backup is unpacked
/// next to it and swapped in by [applyPendingRestore] on the next start.
class LibraryBackup {
  LibraryBackup({required this.supportDir, required this.booksDir});

  static Future<LibraryBackup> open(LibraryStorage storage) async =>
      LibraryBackup(
        supportDir: await getApplicationSupportDirectory(),
        booksDir: storage.dataDir,
      );

  /// Where the database lives (the app support directory).
  final Directory supportDir;

  /// The downloaded books, covers and images.
  final Directory booksDir;

  static const _database = 'readtrack.sqlite';
  static const _manifest = 'readtrack-backup.json';
  static const _books = 'books';

  Directory get _staging => Directory(p.join(supportDir.path, 'restore'));

  /// Writes a backup into [dir] and returns the file.
  Future<File> create(AppDatabase db, Directory dir, {DateTime? now}) async {
    final time = now ?? DateTime.now();
    await dir.create(recursive: true);
    final stamp = time
        .toIso8601String()
        .substring(0, 16)
        .replaceAll(':', '-')
        .replaceAll('T', ' ');
    final target = File(p.join(dir.path, 'ReadTrack backup $stamp.zip'));

    final temp = await Directory.systemTemp.createTemp('readtrack_backup');
    try {
      // A consistent copy of the database, even while it's in use.
      final snapshot = p.join(temp.path, _database);
      await db.customStatement('VACUUM INTO ?', [snapshot]);
      await File(p.join(temp.path, _manifest)).writeAsString(
        jsonEncode({
          'app': 'ReadTrack',
          'schemaVersion': db.schemaVersion,
          'createdAt': time.toUtc().toIso8601String(),
          'booksDir': booksDir.path,
        }),
      );
      final books = booksDir.path;
      await Isolate.run(() async {
        final zip = ZipFileEncoder()..create(target.path);
        await zip.addFile(File(p.join(temp.path, _manifest)), _manifest);
        await zip.addFile(File(snapshot), _database);
        if (Directory(books).existsSync()) {
          for (final entry in Directory(books).listSync(recursive: true)) {
            if (entry is! File) continue;
            final name = p.posix.joinAll([
              _books,
              ...p.split(p.relative(entry.path, from: books)),
            ]);
            await zip.addFile(entry, name);
          }
        }
        await zip.close();
      });
    } finally {
      await temp.delete(recursive: true);
    }
    return target;
  }

  /// Checks and unpacks [backup]; it replaces the library on the next start.
  /// Returns when the backup was made.
  Future<DateTime?> stageRestore(File backup) async {
    final staging = _staging;
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    try {
      await Isolate.run(() => extractFileToDisk(backup.path, staging.path))
          .catchError((Object e) => throw BackupException('$e'));
      final manifest = File(p.join(staging.path, _manifest));
      if (!await manifest.exists() ||
          !await File(p.join(staging.path, _database)).exists()) {
        throw BackupException('Not a ReadTrack backup');
      }
      final json = jsonDecode(await manifest.readAsString());
      return json is Map
          ? DateTime.tryParse('${json['createdAt']}')?.toLocal()
          : null;
    } catch (_) {
      await staging.delete(recursive: true);
      rethrow;
    }
  }

  /// Swaps in a staged backup, before the database is opened. The replaced
  /// library is kept as "*.before-restore". Returns the books folder the
  /// backup came from, so that stored cover paths can be moved over.
  Future<String?> applyPendingRestore() async {
    final staging = _staging;
    final staged = File(p.join(staging.path, _database));
    if (!await staged.exists()) return null;

    String? oldBooks;
    try {
      final json = jsonDecode(
        await File(p.join(staging.path, _manifest)).readAsString(),
      );
      if (json is Map) oldBooks = json['booksDir'] as String?;
    } catch (_) {}

    final current = File(p.join(supportDir.path, _database));
    if (await current.exists()) {
      await current.rename('${current.path}.before-restore');
    }
    // Leftovers of the old database's write-ahead log must not be applied
    // to the restored one.
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final f = File('${current.path}$suffix');
      if (await f.exists()) await f.delete();
    }
    await staged.rename(current.path);

    final previous = Directory('${booksDir.path}.before-restore');
    if (await previous.exists()) await previous.delete(recursive: true);
    if (await booksDir.exists()) await booksDir.rename(previous.path);
    final stagedBooks = Directory(p.join(staging.path, _books));
    if (await stagedBooks.exists()) {
      await stagedBooks.rename(booksDir.path);
    }
    await staging.delete(recursive: true);
    return oldBooks;
  }
}
