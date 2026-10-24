import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../sources/html_clean.dart';
import 'file_import.dart';
import 'storage.dart';

/// Adds a local book file to the library: the entry, its chapters (with
/// images saved locally), the cover, a copy of the file and a download that
/// makes it readable in the app.
class BookImporter {
  BookImporter(this._db, this._storage);

  final AppDatabase _db;
  final LibraryStorage _storage;

  /// Imports the file at [path] and returns the new work's id.
  Future<int> importFile(String path) async {
    final book = await readBookFile(path);
    return store(book, original: File(path));
  }

  /// Stores [book]. With [work] (e.g. from the edit form), its fields are
  /// used instead of the file's; chapter and word counts still come from
  /// the file unless given.
  Future<int> store(
    ImportedBook book, {
    File? original,
    WorksCompanion? work,
    String? fandomName,
    List<String>? tagNames,
    List<String> pairingNames = const [],
    Set<String> adultTags = const {},
  }) async {
    final chapters = book.chapters;
    final words = [
      for (final c in chapters) countWords(htmlToPlainText(c.html)),
    ];
    final defaults = metadataOf(book);
    final given = work ?? defaults;
    final id = await _db.saveWork(
      given.copyWith(
        format: const Value(WorkFormat.digital),
        chapterCount: given.chapterCount.value == null
            ? Value(chapters.length)
            : given.chapterCount,
        wordCount: given.wordCount.value == null
            ? Value(words.fold<int>(0, (a, b) => a + b))
            : given.wordCount,
      ),
      fandomName: fandomName,
      tagNames: tagNames ?? book.tags,
      pairingNames: pairingNames,
      adultTags: adultTags,
    );
    await _storeContent(id, book, original: original, words: words);
    return id;
  }

  /// Adds [book]'s text to the existing entry [workId] (e.g. a paper book
  /// the user also has as an EPUB), keeping the entry's details. Fills in
  /// only what the entry lacks.
  Future<void> attach(int workId, ImportedBook book, {File? original}) async {
    final words = [
      for (final c in book.chapters) countWords(htmlToPlainText(c.html)),
    ];
    final w = await _db.workById(workId);
    if (w == null) return;
    final countsMissing = w.wordCount == null || w.wordsEstimated;
    await _db.updateWork(
      workId,
      WorksCompanion(
        chapterCount: Value(w.chapterCount ?? book.chapters.length),
        wordCount: countsMissing
            ? Value(words.fold<int>(0, (a, b) => a + b))
            : const Value.absent(),
        wordsEstimated: countsMissing
            ? const Value(false)
            : const Value.absent(),
        summary: w.summary == null ? Value(book.summary) : const Value.absent(),
        isbn: w.isbn == null ? Value(book.isbn) : const Value.absent(),
      ),
    );
    await _storeContent(
      workId,
      book,
      original: original,
      words: words,
      cover: w.coverPath == null,
    );
  }

  Future<void> _storeContent(
    int id,
    ImportedBook book, {
    required File? original,
    required List<int> words,
    bool cover = true,
  }) async {
    final chapters = book.chapters;
    if (book.cover case final bytes? when cover) {
      final path = await _storage.saveCover(
        id,
        Uri.https(kBookHost, '/cover'),
        bytes,
      );
      await _db.updateWork(id, WorksCompanion(coverPath: Value(path)));
    }

    // Images used by the chapters go next to the book's other files.
    final localImages = <String, String>{};
    for (final MapEntry(key: url, value: bytes) in book.images.entries) {
      localImages[url] = await _storage.saveImage(id, Uri.parse(url), bytes);
    }

    await _db.saveChapterList(id, [
      for (final (i, c) in chapters.indexed)
        (number: i + 1, title: c.title, url: null, locked: false),
    ]);
    for (final (i, c) in chapters.indexed) {
      var html = c.html;
      for (final MapEntry(key: url, value: local) in localImages.entries) {
        html = html.replaceAll('src="$url"', 'src="$local"');
      }
      // Images that weren't in the file can't be shown.
      html = html.replaceAll(
        RegExp('<img src="https://$kBookHost/[^"]*"[^>]*>'),
        '',
      );
      await _db.saveChapterText(id, i + 1, html: html, wordCount: words[i]);
    }

    final copy = original == null ? null : await _keepCopy(original);
    await _db.addDownload(
      DownloadsCompanion.insert(
        workId: id,
        fromChapter: 1,
        toChapter: chapters.length,
        format: Value(book.format.name),
        filePath: Value(copy?.path),
      ),
    );
  }

  /// The entry fields the file itself provides.
  static WorksCompanion metadataOf(ImportedBook book) => WorksCompanion.insert(
    type: book.isFanfiction ? WorkType.fanfiction : WorkType.book,
    format: WorkFormat.digital,
    title: book.title,
    author: Value(book.author),
    summary: Value(book.summary),
    sourceUrl: Value(book.sourceUrl),
    isbn: Value(book.isbn),
    chapterCount: Value(book.chapters.length),
    isComplete: const Value(true),
  );

  /// Copies the imported file into the ReadTrack folder (unless it's already
  /// there), without overwriting another file.
  Future<File> _keepCopy(File original) async {
    final dir = _storage.exportDir;
    if (p.equals(p.dirname(original.path), dir.path)) return original;
    await dir.create(recursive: true);
    final base = p.basenameWithoutExtension(original.path);
    final extension = p.extension(original.path);
    var target = File(p.join(dir.path, '$base$extension'));
    for (var n = 2; await target.exists(); n++) {
      target = File(p.join(dir.path, '$base ($n)$extension'));
    }
    return original.copy(target.path);
  }
}
