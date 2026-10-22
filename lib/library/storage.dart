import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where downloaded books live on disk.
///
/// - `dataDir/<workId>/` holds the cover and chapter images (app-private).
/// - [exportDir] holds the exported files (e.g. TXT) where the user can find
///   them: `~/Documents/ReadTrack` on Linux.
class LibraryStorage {
  LibraryStorage({required this.dataDir, required this.exportDir});

  static Future<LibraryStorage> open() async {
    final support = await getApplicationSupportDirectory();
    final documents = await getApplicationDocumentsDirectory();
    return LibraryStorage(
      dataDir: Directory(p.join(support.path, 'books')),
      exportDir: Directory(p.join(documents.path, 'ReadTrack')),
    );
  }

  final Directory dataDir;
  final Directory exportDir;

  Directory bookDir(int workId) => Directory(p.join(dataDir.path, '$workId'));

  /// Resolves an image reference stored in chapter HTML ("images/abc.jpg").
  File resolve(int workId, String relativePath) =>
      File(p.join(bookDir(workId).path, relativePath));

  /// Saves a chapter image and returns the reference to store in the HTML.
  Future<String> saveImage(int workId, Uri url, Uint8List bytes) async {
    final name = 'images/${_hash(url)}${_extension(url, bytes)}';
    final file = resolve(workId, name);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return name;
  }

  /// Saves the cover and returns its absolute path.
  Future<String> saveCover(int workId, Uri url, Uint8List bytes) async {
    final file = resolve(workId, 'cover${_extension(url, bytes)}');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// A file name for an export such as "Mother of Learning (Chapters 1–30).txt".
  File exportFile(String title, int from, int to, String extension) {
    final safe = title
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final name = safe.isEmpty ? 'Book' : safe;
    final shortName = name.length > 120 ? name.substring(0, 120).trim() : name;
    final range = from == to ? 'Chapter $from' : 'Chapters $from–$to';
    return File(p.join(exportDir.path, '$shortName ($range).$extension'));
  }

  Future<void> deleteBookFiles(int workId, Iterable<String> exportPaths) async {
    final dir = bookDir(workId);
    if (await dir.exists()) await dir.delete(recursive: true);
    for (final path in exportPaths) {
      await deleteFile(path);
    }
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  static String _hash(Uri url) =>
      sha1.convert(utf8.encode(url.toString())).toString().substring(0, 20);

  static String _extension(Uri url, Uint8List bytes) {
    // Prefer the real format over the URL, which often has none.
    if (bytes.length > 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50) return '.png';
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return '.jpg';
      if (bytes[0] == 0x47 && bytes[1] == 0x49) return '.gif';
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes.length > 12 &&
          bytes[8] == 0x57) {
        return '.webp';
      }
    }
    final ext = p.extension(url.path).toLowerCase();
    return const {'.png', '.jpg', '.jpeg', '.gif', '.webp'}.contains(ext)
        ? ext
        : '.img';
  }
}
