import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'enums.dart';

export 'enums.dart';

part 'database.g.dart';

/// Eine Kategorie wie „Naruto“ oder „Harry Potter“.
class Fandoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// Ein Buch, eine Fanfic, ein Manga usw.
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
  IntColumn get fandomId => integer().nullable().references(
    Fandoms,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get status => textEnum<ReadingStatus>().withDefault(
    Constant(ReadingStatus.planned.name),
  )();

  /// Ob der Autor die Geschichte abgeschlossen hat.
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  IntColumn get chapterCount => integer().nullable()();
  IntColumn get currentChapter => integer().nullable()();
  IntColumn get wordCount => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();

  /// 1 bis 5 Sterne.
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

/// Einzelne Kapitel, deren Text für das Offline-Lesen gespeichert wird.
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

  @override
  List<Set<Column>> get uniqueKeys => [
    {workId, number},
  ];
}

class WorkWithDetails {
  WorkWithDetails(this.work, this.fandom, this.tags);

  final Work work;
  final Fandom? fandom;
  final List<Tag> tags;
}

class DeletedWork {
  DeletedWork(this.work, this.tagIds, this.chapters);

  final Work work;
  final List<int> tagIds;
  final List<Chapter> chapters;
}

@DriftDatabase(tables: [Fandoms, Tags, Works, WorkTags, Chapters])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'lesetracker',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );

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

  /// Kategorien, denen mindestens ein Werk zugeordnet ist.
  Future<List<Fandom>> usedFandoms() =>
      (select(fandoms)
            ..where(
              (f) => f.id.isInQuery(
                selectOnly(works)..addColumns([works.fandomId]),
              ),
            )
            ..orderBy([(f) => OrderingTerm.asc(f.name)]))
          .get();

  /// Tags, die mindestens einem Werk zugeordnet sind.
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

  /// Legt ein Werk an oder aktualisiert es (wenn `data.id` gesetzt ist).
  /// Kategorie und Tags werden bei Bedarf neu angelegt; Groß-/Kleinschreibung
  /// wird dabei ignoriert, damit „naruto“ und „Naruto“ dieselbe Kategorie sind.
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

  /// Löscht ein Werk und gibt alles zurück, was [restoreWork] zum
  /// Rückgängigmachen braucht.
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
      await (delete(works)..where((w) => w.id.equals(id))).go();
      return DeletedWork(work, tagIds, savedChapters);
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
      });
    });
  }

  Future<int?> _fandomIdFor(String? name) async {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return null;
    final existing = await (select(
      fandoms,
    )..where((f) => f.name.lower().equals(n.toLowerCase()))).getSingleOrNull();
    return existing?.id ??
        await into(fandoms).insert(FandomsCompanion.insert(name: n));
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
