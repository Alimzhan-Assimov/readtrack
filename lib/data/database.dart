import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'enums.dart';
import 'fandom_names.dart';

export 'enums.dart';

part 'database.g.dart';

/// A category such as "Naruto" or "Harry Potter".
class Fandoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// A book, fanfic, manga, etc.
class Works extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<WorkType>()();
  TextColumn get format => textEnum<WorkFormat>()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get coverUrl => text().nullable()();

  /// Downloaded cover, so it shows offline.
  TextColumn get coverPath => text().nullable()();
  IntColumn get fandomId => integer().nullable().references(
    Fandoms,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get status => textEnum<ReadingStatus>().withDefault(
    Constant(ReadingStatus.planned.name),
  )();

  /// Whether the author has finished the story.
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  IntColumn get chapterCount => integer().nullable()();
  IntColumn get currentChapter => integer().nullable()();

  /// Scroll position within [currentChapter], from 0 (top) to 1 (end).
  RealColumn get readOffset => real().nullable()();
  IntColumn get wordCount => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();

  /// 1 to 5 stars.
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WorkTags extends Table {
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {workId, tagId};
}

/// Individual chapters whose text is stored for offline reading.
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get number => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get content => text().nullable()();
  IntColumn get wordCount => integer().nullable()();
  DateTimeColumn get downloadedAt => dateTime().nullable()();

  /// Paid or otherwise unavailable on the site.
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {workId, number},
  ];
}

/// A downloaded range of chapters, exported as a file (e.g. "Chapters 1–30").
/// The chapter text itself lives in [Chapters], shared between downloads.
class Downloads extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get fromChapter => integer()();
  IntColumn get toChapter => integer()();
  TextColumn get format => text().withDefault(const Constant('txt'))();
  TextColumn get filePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// A chapter as listed on the site, for [AppDatabase.saveChapterList].
typedef ChapterListing = ({int number, String title, String url, bool locked});

class WorkWithDetails {
  WorkWithDetails(this.work, this.fandom, this.tags);

  final Work work;
  final Fandom? fandom;
  final List<Tag> tags;
}

class DeletedWork {
  DeletedWork(this.work, this.tagIds, this.chapters, this.downloads);

  final Work work;
  final List<int> tagIds;
  final List<Chapter> chapters;
  final List<Download> downloads;
}

@DriftDatabase(tables: [Fandoms, Tags, Works, WorkTags, Chapters, Downloads])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(works, works.coverPath);
        await m.addColumn(works, works.readOffset);
        await m.addColumn(chapters, chapters.isLocked);
        await m.createTable(downloads);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await mergeSimilarFandoms();
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'readtrack',
    native: const DriftNativeOptions(databaseDirectory: _databaseDirectory),
  );

  static Future<Directory> _databaseDirectory() async {
    final dir = await getApplicationSupportDirectory();
    await _copyLegacyDatabase(dir);
    return dir;
  }

  /// The app used to be called "Lesetracker" (app id de.alimi.lesetracker).
  /// Copies that database once so existing entries survive the rename; the
  /// old file stays in place as a backup.
  static Future<void> _copyLegacyDatabase(Directory dir) async {
    final target = File(p.join(dir.path, 'readtrack.sqlite'));
    if (await target.exists()) return;
    final legacyDir = dir.path.replaceFirst(
      RegExp(r'de\.alimi\.readtrack$'),
      'de.alimi.lesetracker',
    );
    final legacy = File(p.join(legacyDir, 'lesetracker.sqlite'));
    if (legacyDir == dir.path || !await legacy.exists()) return;
    await dir.create(recursive: true);
    await legacy.copy(target.path);
  }

  Stream<List<WorkWithDetails>> watchWorks({
    String search = '',
    WorkType? type,
    int? fandomId,
    int? tagId,
    WorkSort sort = WorkSort.updated,
  }) {
    final query = _worksWithFandom();
    final term = search.trim();
    if (term.isNotEmpty) {
      final pattern = '%$term%';
      query.where(
        works.title.like(pattern) |
            works.author.like(pattern) |
            fandoms.name.like(pattern),
      );
    }
    if (type != null) query.where(works.type.equalsValue(type));
    if (fandomId != null) query.where(works.fandomId.equals(fandomId));
    if (tagId != null) {
      query.where(
        works.id.isInQuery(
          selectOnly(workTags)
            ..addColumns([workTags.workId])
            ..where(workTags.tagId.equals(tagId)),
        ),
      );
    }
    final byTitle = OrderingTerm.asc(works.title.collate(Collate.noCase));
    query.orderBy(switch (sort) {
      WorkSort.updated => [OrderingTerm.desc(works.updatedAt)],
      WorkSort.added => [OrderingTerm.desc(works.addedAt)],
      WorkSort.title => [byTitle],
      WorkSort.rating => [
        OrderingTerm(
          expression: works.rating,
          mode: OrderingMode.desc,
          nulls: NullsOrder.last,
        ),
        byTitle,
      ],
    });
    return query.watch().asyncMap(_withTags);
  }

  Stream<WorkWithDetails?> watchWork(int id) {
    final query = _worksWithFandom()..where(works.id.equals(id));
    return query.watch().asyncMap(
      (rows) async => (await _withTags(rows)).firstOrNull,
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _worksWithFandom() =>
      select(works)
          .join([leftOuterJoin(fandoms, fandoms.id.equalsExp(works.fandomId))]);

  Future<List<WorkWithDetails>> _withTags(List<TypedResult> rows) async {
    final ids = [for (final r in rows) r.readTable(works).id];
    final tagRows = ids.isEmpty
        ? const <TypedResult>[]
        : await (select(workTags)
                  .join([innerJoin(tags, tags.id.equalsExp(workTags.tagId))])
                ..where(workTags.workId.isIn(ids))
                ..orderBy([OrderingTerm.asc(tags.name)]))
              .get();
    final tagsByWork = <int, List<Tag>>{};
    for (final r in tagRows) {
      tagsByWork
          .putIfAbsent(r.readTable(workTags).workId, () => [])
          .add(r.readTable(tags));
    }
    return [
      for (final r in rows)
        WorkWithDetails(
          r.readTable(works),
          r.readTableOrNull(fandoms),
          tagsByWork[r.readTable(works).id] ?? const [],
        ),
    ];
  }

  /// Categories that at least one work belongs to.
  Future<List<Fandom>> usedFandoms() =>
      (select(fandoms)
            ..where(
              (f) => f.id.isInQuery(
                selectOnly(works)..addColumns([works.fandomId]),
              ),
            )
            ..orderBy([(f) => OrderingTerm.asc(f.name)]))
          .get();

  /// Tags that are assigned to at least one work.
  Future<List<Tag>> usedTags() =>
      (select(tags)
            ..where(
              (t) => t.id.isInQuery(
                selectOnly(workTags)..addColumns([workTags.tagId]),
              ),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<List<String>> fandomNames() => (select(
    fandoms,
  )..orderBy([(f) => OrderingTerm.asc(f.name)])).map((f) => f.name).get();

  Future<List<String>> tagNames() => (select(
    tags,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).map((t) => t.name).get();

  /// Inserts a work, or updates it if `data.id` is set. Category and tags are
  /// created as needed, ignoring case so "naruto" and "Naruto" end up as the
  /// same category.
  Future<int> saveWork(
    WorksCompanion data, {
    String? fandomName,
    List<String> tagNames = const [],
  }) {
    return transaction(() async {
      final row = data.copyWith(
        fandomId: Value(await _fandomIdFor(fandomName)),
        updatedAt: Value(DateTime.now()),
      );
      final int id;
      if (data.id.present) {
        id = data.id.value;
        await (update(works)..where((w) => w.id.equals(id))).write(row);
      } else {
        id = await into(works).insert(row);
      }
      await (delete(workTags)..where((t) => t.workId.equals(id))).go();
      for (final name in tagNames) {
        final tagId = await _tagIdFor(name);
        if (tagId == null) continue;
        await into(workTags).insert(
          WorkTagsCompanion.insert(workId: id, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
      }
      return id;
    });
  }

  Future<void> updateWork(int id, WorksCompanion changes) =>
      (update(works)..where((w) => w.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(DateTime.now())),
      );

  /// Deletes a work and returns everything [restoreWork] needs to undo it.
  Future<DeletedWork?> deleteWork(int id) {
    return transaction(() async {
      final work = await (select(
        works,
      )..where((w) => w.id.equals(id))).getSingleOrNull();
      if (work == null) return null;
      final tagIds =
          await (selectOnly(workTags)
                ..addColumns([workTags.tagId])
                ..where(workTags.workId.equals(id)))
              .map((r) => r.read(workTags.tagId)!)
              .get();
      final savedChapters = await (select(
        chapters,
      )..where((c) => c.workId.equals(id))).get();
      final savedDownloads = await (select(
        downloads,
      )..where((d) => d.workId.equals(id))).get();
      await (delete(works)..where((w) => w.id.equals(id))).go();
      return DeletedWork(work, tagIds, savedChapters, savedDownloads);
    });
  }

  Future<void> restoreWork(DeletedWork deleted) {
    return transaction(() async {
      await into(works).insert(deleted.work);
      await batch((b) {
        b.insertAll(workTags, [
          for (final tagId in deleted.tagIds)
            WorkTagsCompanion.insert(workId: deleted.work.id, tagId: tagId),
        ]);
        b.insertAll(chapters, deleted.chapters);
        b.insertAll(downloads, deleted.downloads);
      });
    });
  }

  Stream<List<Chapter>> watchChapters(int workId) =>
      (select(chapters)
            ..where((c) => c.workId.equals(workId))
            ..orderBy([(c) => OrderingTerm.asc(c.number)]))
          .watch();

  Future<List<Chapter>> chaptersOf(int workId) =>
      (select(chapters)
            ..where((c) => c.workId.equals(workId))
            ..orderBy([(c) => OrderingTerm.asc(c.number)]))
          .get();

  /// Stores the site's chapter list. Titles, links and lock state are
  /// updated; text that was already downloaded is kept.
  Future<void> saveChapterList(int workId, List<ChapterListing> listing) {
    return batch((b) {
      for (final c in listing) {
        b.insert(
          chapters,
          ChaptersCompanion.insert(
            workId: workId,
            number: c.number,
            title: Value(c.title),
            url: Value(c.url),
            isLocked: Value(c.locked),
          ),
          onConflict: DoUpdate(
            (old) => ChaptersCompanion(
              title: Value(c.title),
              url: Value(c.url),
              isLocked: Value(c.locked),
            ),
            target: [chapters.workId, chapters.number],
          ),
        );
      }
    });
  }

  Future<void> saveChapterText(
    int workId,
    int number, {
    required String html,
    required int wordCount,
  }) =>
      (update(
        chapters,
      )..where((c) => c.workId.equals(workId) & c.number.equals(number))).write(
        ChaptersCompanion(
          content: Value(html),
          wordCount: Value(wordCount),
          downloadedAt: Value(DateTime.now()),
        ),
      );

  /// Forgets the downloaded text of chapters no download covers anymore.
  Future<void> purgeUncoveredText(int workId) async {
    final ranges = await downloadsOf(workId);
    await (update(chapters)..where((c) {
          var uncovered = c.workId.equals(workId) & c.content.isNotNull();
          for (final r in ranges) {
            uncovered &= c.number.isBetweenValues(
              r.fromChapter,
              r.toChapter,
              not: true,
            );
          }
          return uncovered;
        }))
        .write(
          const ChaptersCompanion(
            content: Value(null),
            downloadedAt: Value(null),
          ),
        );
  }

  /// How many chapters of the work are known (listed on the site).
  Stream<int> watchChapterCount(int workId) {
    final count = chapters.id.count();
    return (selectOnly(chapters)
          ..addColumns([count])
          ..where(chapters.workId.equals(workId)))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Future<Work?> workBySourceUrl(String url) =>
      (select(works)..where((w) => w.sourceUrl.equals(url))).getSingleOrNull();

  Stream<List<Download>> watchDownloads(int workId) =>
      (select(downloads)
            ..where((d) => d.workId.equals(workId))
            ..orderBy([(d) => OrderingTerm.asc(d.fromChapter)]))
          .watch();

  Future<List<Download>> downloadsOf(int workId) =>
      (select(downloads)
            ..where((d) => d.workId.equals(workId))
            ..orderBy([(d) => OrderingTerm.asc(d.fromChapter)]))
          .get();

  Future<int> addDownload(DownloadsCompanion data) =>
      into(downloads).insert(data);

  Future<void> updateDownload(int id, DownloadsCompanion changes) =>
      (update(downloads)..where((d) => d.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> deleteDownload(int id) =>
      (delete(downloads)..where((d) => d.id.equals(id))).go();

  /// Finds the category for [name], treating variants of a franchise as the
  /// same category (see [fandomKey]); a new one is stored under its base name.
  Future<int?> _fandomIdFor(String? name) async {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return null;
    final key = fandomKey(n);
    for (final fandom in await select(fandoms).get()) {
      if (fandomKey(fandom.name) == key) return fandom.id;
    }
    return into(fandoms)
        .insert(FandomsCompanion.insert(name: baseFandomName(n)));
  }

  /// Merges categories that are variants of the same franchise, e.g. ones
  /// created before categories were matched this way. Keeps the oldest one,
  /// named after the base name.
  Future<void> mergeSimilarFandoms() {
    return transaction(() async {
      final groups = <String, List<Fandom>>{};
      for (final fandom in await (select(
        fandoms,
      )..orderBy([(f) => OrderingTerm.asc(f.id)])).get()) {
        groups.putIfAbsent(fandomKey(fandom.name), () => []).add(fandom);
      }
      for (final group in groups.values) {
        final keep = group.first;
        for (final duplicate in group.skip(1)) {
          await (update(works)..where((w) => w.fandomId.equals(duplicate.id)))
              .write(WorksCompanion(fandomId: Value(keep.id)));
          await (delete(fandoms)..where((f) => f.id.equals(duplicate.id))).go();
        }
        final base = baseFandomName(keep.name);
        if (base != keep.name) {
          await (update(fandoms)..where((f) => f.id.equals(keep.id))).write(
            FandomsCompanion(name: Value(base)),
          );
        }
      }
    });
  }

  Future<int?> _tagIdFor(String name) async {
    final n = name.trim();
    if (n.isEmpty) return null;
    final existing = await (select(
      tags,
    )..where((t) => t.name.lower().equals(n.toLowerCase()))).getSingleOrNull();
    return existing?.id ??
        await into(tags).insert(TagsCompanion.insert(name: n));
  }
}
