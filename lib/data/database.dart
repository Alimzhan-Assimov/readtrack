import 'dart:io';
import 'dart:math' show max;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'adult_tags.dart';
import 'enums.dart';
import 'fandom_list.dart';
import 'fandom_names.dart';
import 'pairing_tags.dart';
import 'tag_synonyms.dart';

export 'enums.dart';

part 'database.g.dart';

/// A category such as "Naruto" or "Harry Potter".
class Fandoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// Another name of a category the user merged into it, so later imports
/// with that name land in it.
class FandomAliases extends Table {
  /// [fandomKey] of the other name.
  TextColumn get aliasKey => text()();
  IntColumn get fandomId =>
      integer().references(Fandoms, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {aliasKey};
}

/// How a further category takes part in a work besides its main one.
enum FandomRole { crossover, guest }

/// Categories a work belongs to besides [Works.fandomId], e.g. the second
/// franchise of a crossover. It shows up under each of them.
class WorkFandoms extends Table {
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get fandomId =>
      integer().references(Fandoms, #id, onDelete: KeyAction.cascade)();
  TextColumn get role =>
      textEnum<FandomRole>().withDefault(const Constant('crossover'))();

  @override
  Set<Column> get primaryKey => {workId, fandomId};
}

/// A series of works read in order, e.g. "Harry Potter".
@DataClassName('SeriesItem')
class Series extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// How one work relates to another outside a series.
enum RelationType { sequel, prequel, spinOff, sideStory }

/// "[fromWorkId] has [toWorkId] as its [type]", e.g. A has B as its sequel.
class WorkRelations extends Table {
  IntColumn get fromWorkId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get toWorkId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<RelationType>()();

  @override
  Set<Column> get primaryKey => {fromWorkId, toWorkId, type};
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();

  /// Adult content; hidden when the "hide 18+ tags" setting is on.
  BoolColumn get isAdult => boolean().withDefault(const Constant(false))();
}

/// A relationship such as "Naruto/Hinata", kept apart from tags.
/// A character of a franchise, e.g. "Fujiwara Chika" in Kaguya-sama.
class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get fandomId => integer().nullable().references(
    Fandoms,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// The character's AniList id, once looked up there.
  IntColumn get anilistId => integer().nullable()();
}

/// Other names of a character ("Chika", "Fujiwara Chika").
class CharacterAliases extends Table {
  IntColumn get characterId =>
      integer().references(Characters, #id, onDelete: KeyAction.cascade)();
  TextColumn get alias => text()();

  @override
  Set<Column> get primaryKey => {characterId, alias};
}

class WorkCharacters extends Table {
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get characterId =>
      integer().references(Characters, #id, onDelete: KeyAction.cascade)();

  /// 1 when the site or the user names the character; lower when guessed.
  RealColumn get confidence => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {workId, characterId};
}

/// A tag the app proposes for a work (from keywords in the summary, or an
/// AI provider), with why; it becomes a real tag once the user confirms
/// it. Dismissed ones are kept so they aren't proposed again.
class TagSuggestions extends Table {
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  /// e.g. "The summary mentions “reborn”".
  TextColumn get reason => text().nullable()();

  /// "keywords", or the AI provider's name.
  TextColumn get source => text().withDefault(const Constant('keywords'))();
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {workId, tagId};
}

/// Another name for a tag: tags saved under it go to [tagId] instead.
class TagSynonyms extends Table {
  /// Lowercase.
  TextColumn get synonym => text()();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {synonym};
}

class Pairings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class WorkPairings extends Table {
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get pairingId =>
      integer().references(Pairings, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {workId, pairingId};
}

enum AnnotationKind { bookmark, quote, note }

/// A bookmark, a saved quote (shown highlighted) or a note in a work.
class Annotations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();
  IntColumn get chapterNumber => integer()();
  TextColumn get kind => textEnum<AnnotationKind>()();

  /// The quoted text (quotes, and notes made on a selection).
  TextColumn get quote => text().nullable()();

  /// The user's own words (notes).
  TextColumn get note => text().nullable()();

  /// Scroll position in the chapter, from 0 to 1.
  RealColumn get offset => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// App settings as key/value pairs.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
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

  /// When the site was last checked for new chapters.
  DateTimeColumn get checkedAt => dateTime().nullable()();

  /// When the latest chapter came out: the site's date if it shows one,
  /// otherwise when ReadTrack first saw it.
  DateTimeColumn get lastChapterAt => dateTime().nullable()();

  /// Chapters found by update checks that the user hasn't looked at yet.
  IntColumn get newChapters => integer().withDefault(const Constant(0))();

  /// Set while the work is in the trash.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// When the status last became "finished" (kept by a trigger).
  DateTimeColumn get finishedAt => dateTime().nullable()();

  /// Where the reader is in a paper book.
  IntColumn get currentPage => integer().nullable()();

  /// The work's id on AniList, once looked up there.
  IntColumn get anilistId => integer().nullable()();

  /// The last chapter an AI tag analysis read, so later ones can send only
  /// what's new.
  IntColumn get aiAnalyzedChapter => integer().nullable()();

  /// The user also has the book on paper (for digital or online entries).
  BoolColumn get ownsPhysicalCopy =>
      boolean().withDefault(const Constant(false))();

  IntColumn get seriesId => integer().nullable().references(
    Series,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Position in the series; may be fractional (2.5 for a side story).
  RealColumn get seriesIndex => real().nullable()();

  /// Whether [wordCount] / [pageCount] were worked out by the app because
  /// the site didn't give them; such values are updated as more is known.
  BoolColumn get wordsEstimated =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get pagesEstimated =>
      boolean().withDefault(const Constant(false))();

  /// Size in characters (with spaces), for sites that give only that.
  IntColumn get characterCount => integer().nullable()();
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

  /// False when chapter images were left out to save space.
  BoolColumn get withImages => boolean().withDefault(const Constant(true))();
  TextColumn get filePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// A chapter as listed on the site, for [AppDatabase.saveChapterList].
/// [url] is null for chapters of imported files.
typedef ChapterListing = ({int number, String title, String? url, bool locked});

enum UsageKind { fandom, tag, pairing, series, character }

class WorkWithDetails {
  WorkWithDetails(
    this.work,
    this.fandom,
    this.tags, {
    this.pairings = const [],
    this.series,
    this.crossovers = const [],
    this.characters = const [],
    this.suggestedCharacters = const {},
  });

  /// Including [suggestedCharacters].
  final List<Character> characters;

  /// Ids of characters found in the text but not confirmed yet.
  final Set<int> suggestedCharacters;

  List<Character> get confirmedCharacters => [
    for (final c in characters)
      if (!suggestedCharacters.contains(c.id)) c,
  ];

  /// Further categories, e.g. the other side of a crossover.
  final List<Fandom> crossovers;

  final SeriesItem? series;

  final Work work;
  final Fandom? fandom;
  final List<Tag> tags;
  final List<Pairing> pairings;
}

class DeletedWork {
  DeletedWork(
    this.work,
    this.tagIds,
    this.chapters,
    this.downloads, {
    this.pairingIds = const [],
    this.annotations = const [],
    this.relations = const [],
    this.readingDays = const [],
    this.crossovers = const [],
    this.characters = const [],
  });

  final Work work;
  final List<WorkCharacter> characters;
  final List<WorkFandom> crossovers;
  final List<WorkRelation> relations;
  final List<ReadingDay> readingDays;
  final List<int> tagIds;
  final List<int> pairingIds;
  final List<Annotation> annotations;
  final List<Chapter> chapters;
  final List<Download> downloads;
}

/// Reading done in the app, per work and day: active time, and the words
/// and chapters of the chapters read to the end.
class ReadingDays extends Table {
  IntColumn get workId =>
      integer().references(Works, #id, onDelete: KeyAction.cascade)();

  /// Local date as "YYYY-MM-DD".
  TextColumn get day => text()();
  IntColumn get seconds => integer().withDefault(const Constant(0))();
  IntColumn get words => integer().withDefault(const Constant(0))();
  IntColumn get chapters => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {workId, day};
}

@DriftDatabase(
  tables: [
    TagSuggestions,
    FandomAliases,
    TagSynonyms,
    Characters,
    CharacterAliases,
    WorkCharacters,
    WorkFandoms,
    Series,
    WorkRelations,
    ReadingDays,
    Fandoms,
    Tags,
    Works,
    WorkTags,
    Chapters,
    Downloads,
    Pairings,
    WorkPairings,
    Settings,
    Annotations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 20;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createFinishedTriggers();
    },
    onUpgrade: (m, from, to) async {
      // Earlier steps read whole rows of works, which needs every
      // non-nullable column to exist already.
      if (from < 15) {
        await _addColumnIfMissing(m, works, works.ownsPhysicalCopy);
      }
      if (from < 2) {
        await m.addColumn(works, works.coverPath);
        await m.addColumn(works, works.readOffset);
        await m.addColumn(chapters, chapters.isLocked);
        await m.createTable(downloads);
      }
      if (from < 3) {
        await m.addColumn(tags, tags.isAdult);
        await m.createTable(pairings);
        await m.createTable(workPairings);
        await m.createTable(settings);
        // Flag the adult tags that already exist.
        for (final tag in await select(tags).get()) {
          if (looksAdult(tag.name)) {
            await (update(tags)..where((t) => t.id.equals(tag.id))).write(
              const TagsCompanion(isAdult: Value(true)),
            );
          }
        }
      }
      if (from < 4) await moveRelationshipTagsToPairings();
      if (from < 5) await m.createTable(annotations);
      if (from < 6) {
        await _addColumnIfMissing(m, works, works.checkedAt);
        await _addColumnIfMissing(m, works, works.lastChapterAt);
        await _addColumnIfMissing(m, works, works.newChapters);
      }
      if (from < 7) await _addColumnIfMissing(m, works, works.deletedAt);
      if (from < 8) {
        await _addColumnIfMissing(m, works, works.wordsEstimated);
        await _addColumnIfMissing(m, works, works.pagesEstimated);
        for (final w in await select(works).get()) {
          await fillMissingCounts(w.id);
        }
      }
      if (from < 9) {
        await _addColumnIfMissing(m, downloads, downloads.withImages);
      }
      if (from < 10) {
        await _addColumnIfMissing(m, works, works.characterCount);
      }
      if (from < 11) {
        await _addColumnIfMissing(m, works, works.finishedAt);
        await m.createTable(readingDays);
        await _createFinishedTriggers();
        // Finished before this was tracked: the last change is the best guess.
        await customStatement(
          "UPDATE works SET finished_at = updated_at WHERE status = 'finished'",
        );
      }
      if (from < 13) await m.createTable(workFandoms);
      if (from < 15) await m.createTable(tagSynonyms);
      if (from < 16) await _addColumnIfMissing(m, works, works.currentPage);
      if (from < 17) await m.createTable(fandomAliases);
      if (from < 18) await _addColumnIfMissing(m, works, works.anilistId);
      if (from < 19) await m.createTable(tagSuggestions);
      if (from < 20) {
        await _addColumnIfMissing(m, works, works.aiAnalyzedChapter);
      }
      if (from < 14) {
        await m.createTable(characters);
        await m.createTable(characterAliases);
        await m.createTable(workCharacters);
      }
      if (from < 12) {
        await m.createTable(series);
        await m.createTable(workRelations);
        await _addColumnIfMissing(m, works, works.seriesId);
        await _addColumnIfMissing(m, works, works.seriesIndex);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await mergeSimilarFandoms();
      await mergeSynonymTags();
      await mergeEquivalentPairings();
    },
  );

  /// Sets works.finished_at whenever the status becomes "finished", however
  /// it is changed.
  Future<void> _createFinishedTriggers() async {
    for (final (event, condition) in [
      // A restored work brings its date along.
      ('INSERT', "NEW.status = 'finished' AND NEW.finished_at IS NULL"),
      (
        'UPDATE OF status',
        "NEW.status = 'finished' AND OLD.status IS NOT 'finished'",
      ),
    ]) {
      final name = event == 'INSERT'
          ? 'works_finished_insert'
          : 'works_finished_update';
      await customStatement('DROP TRIGGER IF EXISTS $name');
      await customStatement(
        'CREATE TRIGGER $name AFTER $event ON works '
        'WHEN $condition BEGIN '
        "UPDATE works SET finished_at = CAST(strftime('%s', 'now') AS INTEGER) "
        'WHERE id = NEW.id; END',
      );
    }
  }

  /// Adds reading done on [day] to [workId]'s log.
  Future<void> addReading(
    int workId,
    DateTime day, {
    int seconds = 0,
    int words = 0,
    int chapters = 0,
  }) => customStatement(
    'INSERT INTO reading_days (work_id, day, seconds, words, chapters) '
    'VALUES (?, ?, ?, ?, ?) ON CONFLICT (work_id, day) DO UPDATE SET '
    'seconds = seconds + excluded.seconds, words = words + excluded.words, '
    'chapters = chapters + excluded.chapters',
    [workId, dayKey(day), seconds, words, chapters],
  );

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// The whole reading log, oldest first, with each work's details.
  Future<List<(ReadingDay, Work)>> readingLog() async {
    final rows = await (select(readingDays).join([
      innerJoin(works, works.id.equalsExp(readingDays.workId)),
    ])..orderBy([OrderingTerm.asc(readingDays.day)])).get();
    return [
      for (final r in rows) (r.readTable(readingDays), r.readTable(works)),
    ];
  }

  /// Works finished in [year] (not in the trash).
  Future<List<Work>> finishedIn(int year) =>
      (select(works)..where(
            (w) =>
                w.deletedAt.isNull() &
                w.finishedAt.isBiggerOrEqualValue(DateTime(year)) &
                w.finishedAt.isSmallerThanValue(DateTime(year + 1)),
          ))
          .get();

  /// Adds [column] unless a development build already did; adding it twice
  /// would stop the database from opening.
  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final existing = await customSelect(
      'SELECT name FROM pragma_table_info(?)',
      variables: [Variable.withString(table.actualTableName)],
    ).map((row) => row.read<String>('name')).get();
    if (!existing.contains(column.name)) await m.addColumn(table, column);
  }

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
    int? pairingId,
    int? seriesId,
    int? characterId,
    ReadingStatus? status,

    /// At least this many words.
    int? minWords,

    /// Only finished (true) or ongoing (false) stories.
    bool? complete,
    WorkSort sort = WorkSort.updated,
  }) {
    final query = _worksWithFandom()..where(works.deletedAt.isNull());
    if (type != null) query.where(works.type.equalsValue(type));
    if (fandomId != null) {
      query.where(
        works.fandomId.equals(fandomId) |
            works.id.isInQuery(
              selectOnly(workFandoms)
                ..addColumns([workFandoms.workId])
                ..where(workFandoms.fandomId.equals(fandomId)),
            ),
      );
    }
    if (seriesId != null) query.where(works.seriesId.equals(seriesId));
    if (characterId != null) {
      query.where(
        works.id.isInQuery(
          selectOnly(workCharacters)
            ..addColumns([workCharacters.workId])
            ..where(workCharacters.characterId.equals(characterId)),
        ),
      );
    }
    if (status != null) query.where(works.status.equalsValue(status));
    if (minWords != null) {
      query.where(works.wordCount.isBiggerOrEqualValue(minWords));
    }
    if (complete != null) query.where(works.isComplete.equals(complete));
    if (pairingId != null) {
      query.where(
        works.id.isInQuery(
          selectOnly(workPairings)
            ..addColumns([workPairings.workId])
            ..where(workPairings.pairingId.equals(pairingId)),
        ),
      );
    }
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
      WorkSort.status => [
        OrderingTerm.asc(_statusOrder),
        OrderingTerm.desc(works.updatedAt),
      ],
      WorkSort.rating => [
        OrderingTerm(
          expression: works.rating,
          mode: OrderingMode.desc,
          nulls: NullsOrder.last,
        ),
        byTitle,
      ],
    });
    final words = search.toLowerCase().split(RegExp(r'\s+'))
      ..removeWhere((w) => w.isEmpty);
    return query.watch().asyncMap((rows) async {
      var result = await _withTags(rows);
      // In Dart, because SQLite's LIKE ignores case only for A–Z.
      if (words.isNotEmpty) {
        result = [
          for (final w in result)
            if (words.every(_searchTextOf(w).contains)) w,
        ];
      }
      if (sort == WorkSort.title) {
        result.sort(
          (a, b) =>
              a.work.title.toLowerCase().compareTo(b.work.title.toLowerCase()),
        );
      }
      return result;
    });
  }

  /// What the library search looks through, lowercased.
  static String _searchTextOf(WorkWithDetails w) => [
    w.work.title,
    w.work.author ?? '',
    w.fandom?.name ?? '',
    for (final c in w.crossovers) c.name,
    w.series?.name ?? '',
    for (final t in w.tags) t.name,
    for (final p in w.pairings) p.name,
    for (final c in w.characters) c.name,
  ].join('\n').toLowerCase();

  /// How many entries (not in the trash) use each category, tag, pairing or
  /// series, by id.
  Future<Map<int, int>> usageCounts(UsageKind kind) async {
    final (sql, column) = switch (kind) {
      UsageKind.fandom => (
        // Main category or crossover, each work once.
        'SELECT f AS id, COUNT(DISTINCT w) AS n FROM ('
            'SELECT fandom_id AS f, id AS w FROM works '
            'WHERE deleted_at IS NULL AND fandom_id IS NOT NULL '
            'UNION SELECT x.fandom_id, x.work_id FROM work_fandoms x '
            'JOIN works ON works.id = x.work_id WHERE works.deleted_at IS NULL'
            ') GROUP BY f',
        'id',
      ),
      UsageKind.tag => (
        'SELECT t.tag_id AS id, COUNT(*) AS n FROM work_tags t '
            'JOIN works w ON w.id = t.work_id WHERE w.deleted_at IS NULL '
            'GROUP BY t.tag_id',
        'id',
      ),
      UsageKind.character => (
        'SELECT c.character_id AS id, COUNT(*) AS n FROM work_characters c '
            'JOIN works w ON w.id = c.work_id WHERE w.deleted_at IS NULL '
            'GROUP BY c.character_id',
        'id',
      ),
      UsageKind.series => (
        'SELECT series_id AS id, COUNT(*) AS n FROM works '
            'WHERE deleted_at IS NULL AND series_id IS NOT NULL GROUP BY series_id',
        'id',
      ),
      UsageKind.pairing => (
        'SELECT p.pairing_id AS id, COUNT(*) AS n FROM work_pairings p '
            'JOIN works w ON w.id = p.work_id WHERE w.deleted_at IS NULL '
            'GROUP BY p.pairing_id',
        'id',
      ),
    };
    final rows = await customSelect(sql).get();
    return {for (final r in rows) r.read<int>(column): r.read<int>('n')};
  }

  /// Reading first, then what's planned or paused, then finished and dropped.
  static const _statusRank = [
    ReadingStatus.reading,
    ReadingStatus.planned,
    ReadingStatus.paused,
    ReadingStatus.finished,
    ReadingStatus.dropped,
  ];

  Expression<int> get _statusOrder => CustomExpression<int>(
    'CASE "works"."status" '
    '${[for (final (i, s) in _statusRank.indexed) "WHEN '${s.name}' THEN $i"].join(' ')} '
    'ELSE ${_statusRank.length} END',
  );

  Stream<WorkWithDetails?> watchWork(int id) {
    final query = _worksWithFandom()..where(works.id.equals(id));
    return query.watch().asyncMap(
      (rows) async => (await _withTags(rows)).firstOrNull,
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _worksWithFandom() =>
      select(works).join([
        leftOuterJoin(fandoms, fandoms.id.equalsExp(works.fandomId)),
        leftOuterJoin(series, series.id.equalsExp(works.seriesId)),
      ]);

  Future<List<WorkWithDetails>> _withTags(List<TypedResult> rows) async {
    final ids = [for (final r in rows) r.readTable(works).id];
    final crossoverRows = ids.isEmpty
        ? const <TypedResult>[]
        : await (select(workFandoms).join([
                  innerJoin(
                    fandoms,
                    fandoms.id.equalsExp(workFandoms.fandomId),
                  ),
                ])
                ..where(workFandoms.workId.isIn(ids))
                ..orderBy([OrderingTerm.asc(fandoms.name)]))
              .get();
    final characterRows = ids.isEmpty
        ? const <TypedResult>[]
        : await (select(workCharacters).join([
                  innerJoin(
                    characters,
                    characters.id.equalsExp(workCharacters.characterId),
                  ),
                ])
                ..where(workCharacters.workId.isIn(ids))
                ..orderBy([OrderingTerm.asc(characters.name)]))
              .get();
    final charactersByWork = <int, List<Character>>{};
    final suggestedByWork = <int, Set<int>>{};
    for (final r in characterRows) {
      final link = r.readTable(workCharacters);
      charactersByWork
          .putIfAbsent(link.workId, () => [])
          .add(r.readTable(characters));
      if (link.confidence < 1) {
        suggestedByWork
            .putIfAbsent(link.workId, () => {})
            .add(link.characterId);
      }
    }
    final crossoversByWork = <int, List<Fandom>>{};
    for (final r in crossoverRows) {
      crossoversByWork
          .putIfAbsent(r.readTable(workFandoms).workId, () => [])
          .add(r.readTable(fandoms));
    }
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
    final pairingRows = ids.isEmpty
        ? const <TypedResult>[]
        : await (select(workPairings).join([
                  innerJoin(
                    pairings,
                    pairings.id.equalsExp(workPairings.pairingId),
                  ),
                ])
                ..where(workPairings.workId.isIn(ids))
                ..orderBy([OrderingTerm.asc(pairings.name)]))
              .get();
    final pairingsByWork = <int, List<Pairing>>{};
    for (final r in pairingRows) {
      pairingsByWork
          .putIfAbsent(r.readTable(workPairings).workId, () => [])
          .add(r.readTable(pairings));
    }
    return [
      for (final r in rows)
        WorkWithDetails(
          r.readTable(works),
          r.readTableOrNull(fandoms),
          tagsByWork[r.readTable(works).id] ?? const [],
          pairings: pairingsByWork[r.readTable(works).id] ?? const [],
          series: r.readTableOrNull(series),
          crossovers: crossoversByWork[r.readTable(works).id] ?? const [],
          characters: charactersByWork[r.readTable(works).id] ?? const [],
          suggestedCharacters:
              suggestedByWork[r.readTable(works).id] ?? const {},
        ),
    ];
  }

  /// Categories that at least one work belongs to.
  Future<List<Fandom>> usedFandoms() =>
      (select(fandoms)
            ..where(
              (f) =>
                  f.id.isInQuery(
                    selectOnly(works)
                      ..addColumns([works.fandomId])
                      ..where(works.deletedAt.isNull()),
                  ) |
                  f.id.isInQuery(
                    selectOnly(workFandoms).join([
                        innerJoin(
                          works,
                          works.id.equalsExp(workFandoms.workId),
                        ),
                      ])
                      ..addColumns([workFandoms.fandomId])
                      ..where(works.deletedAt.isNull()),
                  ),
            )
            ..orderBy([(f) => OrderingTerm.asc(f.name)]))
          .get();

  /// Tags that are assigned to at least one work.
  Future<List<Tag>> usedTags() =>
      (select(tags)
            ..where(
              (t) => t.id.isInQuery(
                selectOnly(workTags).join([
                    innerJoin(works, works.id.equalsExp(workTags.workId)),
                  ])
                  ..addColumns([workTags.tagId])
                  ..where(works.deletedAt.isNull()),
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

  /// Distinct author names, for picking an existing author.
  Future<List<String>> authorNames() async {
    final query = selectOnly(works, distinct: true)
      ..addColumns([works.author])
      ..where(works.author.isNotNull())
      ..orderBy([OrderingTerm.asc(works.author.collate(Collate.noCase))]);
    return query.map((row) => row.read(works.author)!).get();
  }

  /// The tags used on the most works, most used first.
  Future<List<String>> frequentTags({int limit = 12}) async {
    final uses = workTags.workId.count();
    final query = selectOnly(workTags)
      ..join([innerJoin(tags, tags.id.equalsExp(workTags.tagId))])
      ..addColumns([tags.name, uses])
      ..groupBy([tags.id])
      ..orderBy([OrderingTerm.desc(uses), OrderingTerm.asc(tags.name)])
      ..limit(limit);
    return query.map((row) => row.read(tags.name)!).get();
  }

  /// Inserts a work, or updates it if `data.id` is set. Category and tags are
  /// created as needed, ignoring case so "naruto" and "Naruto" end up as the
  /// same category.
  Future<int> saveWork(
    WorksCompanion data, {
    String? fandomName,

    /// Null leaves the series as it is; empty removes it.
    String? seriesName,

    /// Categories besides [fandomName]; null leaves them as they are.
    List<String>? crossoverNames,

    /// Null leaves the characters as they are.
    List<String>? characterNames,
    List<String> tagNames = const [],
    List<String> pairingNames = const [],

    /// Tags the site marks as adult content (detected ones are added).
    Set<String> adultTags = const {},
  }) {
    // A tag such as "Naruto/Hinata" is a pairing.
    final pairingLike = [
      for (final t in tagNames)
        if (looksLikePairing(t)) t,
    ];
    if (pairingLike.isNotEmpty) {
      tagNames = [
        for (final t in tagNames)
          if (!looksLikePairing(t)) t,
      ];
      pairingNames = [...pairingNames, ...pairingLike];
    }
    return transaction(() async {
      var row = data.copyWith(
        fandomId: Value(await _fandomIdFor(fandomName)),
        updatedAt: Value(DateTime.now()),
      );
      if (seriesName != null) {
        row = row.copyWith(seriesId: Value(await _seriesIdFor(seriesName)));
      }
      final int id;
      if (data.id.present) {
        id = data.id.value;
        await (update(works)..where((w) => w.id.equals(id))).write(row);
      } else {
        id = await into(works).insert(row);
      }
      if (crossoverNames != null) {
        await (delete(workFandoms)..where((f) => f.workId.equals(id))).go();
        final main = row.fandomId.value;
        for (final name in crossoverNames) {
          final fandomId = await _fandomIdFor(name);
          if (fandomId == null || fandomId == main) continue;
          await into(workFandoms).insert(
            WorkFandomsCompanion.insert(workId: id, fandomId: fandomId),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
      await (delete(workTags)..where((t) => t.workId.equals(id))).go();
      final adult = {for (final t in adultTags) t.toLowerCase()};
      for (final name in tagNames) {
        final tagId = await _tagIdFor(
          name,
          adult: adult.contains(name.trim().toLowerCase()),
        );
        if (tagId == null) continue;
        await into(workTags).insert(
          WorkTagsCompanion.insert(workId: id, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
      }
      if (characterNames != null) {
        // Suggestions found in the text stay until confirmed or dismissed.
        await (delete(workCharacters)..where(
              (c) => c.workId.equals(id) & c.confidence.isBiggerOrEqualValue(1),
            ))
            .go();
        for (final name in characterNames) {
          final characterId = await _characterIdFor(name, row.fandomId.value);
          if (characterId == null) continue;
          // Naming a suggested character confirms it.
          await into(workCharacters).insertOnConflictUpdate(
            WorkCharactersCompanion.insert(
              workId: id,
              characterId: characterId,
            ),
          );
        }
      }
      await (delete(workPairings)..where((p) => p.workId.equals(id))).go();
      for (final name in pairingNames) {
        final pairingId = await _pairingIdFor(name);
        if (pairingId == null) continue;
        await into(workPairings).insert(
          WorkPairingsCompanion.insert(workId: id, pairingId: pairingId),
          mode: InsertMode.insertOrIgnore,
        );
      }
      return id;
    });
  }

  /// With [touch], the work moves up in the "recently updated" order.
  Future<void> updateWork(
    int id,
    WorksCompanion changes, {
    bool touch = true,
  }) => (update(works)..where((w) => w.id.equals(id))).write(
    touch ? changes.copyWith(updatedAt: Value(DateTime.now())) : changes,
  );

  /// Moves a work to the trash; [restoreFromTrash] brings it back.
  Future<void> moveToTrash(int id, {DateTime? now}) =>
      (update(works)..where((w) => w.id.equals(id))).write(
        WorksCompanion(deletedAt: Value(now ?? DateTime.now())),
      );

  Future<void> restoreFromTrash(int id) =>
      (update(works)..where((w) => w.id.equals(id))).write(
        const WorksCompanion(deletedAt: Value(null)),
      );

  /// Works in the trash, most recently deleted first.
  Stream<List<Work>> watchTrash() =>
      (select(works)
            ..where((w) => w.deletedAt.isNotNull())
            ..orderBy([(w) => OrderingTerm.desc(w.deletedAt)]))
          .watch();

  /// Deletes works in the trash for good: one ([id]), those deleted before
  /// [before], or all. Returns each work's id with its downloaded files, so
  /// the caller can remove them.
  Future<Map<int, List<String>>> emptyTrash({int? id, DateTime? before}) =>
      transaction(() async {
        final query = select(works)..where((w) => w.deletedAt.isNotNull());
        if (id != null) query.where((w) => w.id.equals(id));
        if (before != null) {
          query.where((w) => w.deletedAt.isSmallerThanValue(before));
        }
        final ids = [for (final w in await query.get()) w.id];
        final files = {for (final i in ids) i: <String>[]};
        for (final d in await (select(
          downloads,
        )..where((d) => d.workId.isIn(ids))).get()) {
          if (d.filePath case final path?) files[d.workId]!.add(path);
        }
        await (delete(works)..where((w) => w.id.isIn(ids))).go();
        return files;
      });

  /// Deletes a work for good and returns everything [restoreWork] needs to
  /// undo it.
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
      final pairingIds =
          await (selectOnly(workPairings)
                ..addColumns([workPairings.pairingId])
                ..where(workPairings.workId.equals(id)))
              .map((r) => r.read(workPairings.pairingId)!)
              .get();
      final savedChapters = await (select(
        chapters,
      )..where((c) => c.workId.equals(id))).get();
      final savedDownloads = await (select(
        downloads,
      )..where((d) => d.workId.equals(id))).get();
      final savedAnnotations = await (select(
        annotations,
      )..where((a) => a.workId.equals(id))).get();
      final savedRelations = await (select(
        workRelations,
      )..where((r) => r.fromWorkId.equals(id) | r.toWorkId.equals(id))).get();
      final savedReading = await (select(
        readingDays,
      )..where((r) => r.workId.equals(id))).get();
      final savedCrossovers = await (select(
        workFandoms,
      )..where((f) => f.workId.equals(id))).get();
      final savedCharacters = await (select(
        workCharacters,
      )..where((c) => c.workId.equals(id))).get();
      await (delete(works)..where((w) => w.id.equals(id))).go();
      return DeletedWork(
        work,
        tagIds,
        savedChapters,
        savedDownloads,
        pairingIds: pairingIds,
        annotations: savedAnnotations,
        relations: savedRelations,
        readingDays: savedReading,
        crossovers: savedCrossovers,
        characters: savedCharacters,
      );
    });
  }

  Future<void> restoreWork(DeletedWork deleted) {
    return transaction(() async {
      await into(works).insert(deleted.work);
      final ids = {
        for (final w in await (selectOnly(works)..addColumns([works.id])).get())
          w.read(works.id),
      };
      await batch((b) {
        b.insertAll(workTags, [
          for (final tagId in deleted.tagIds)
            WorkTagsCompanion.insert(workId: deleted.work.id, tagId: tagId),
        ]);
        b.insertAll(workPairings, [
          for (final pairingId in deleted.pairingIds)
            WorkPairingsCompanion.insert(
              workId: deleted.work.id,
              pairingId: pairingId,
            ),
        ]);
        b.insertAll(chapters, deleted.chapters);
        b.insertAll(downloads, deleted.downloads);
        b.insertAll(annotations, deleted.annotations);
        b.insertAll(readingDays, deleted.readingDays);
        b.insertAll(workFandoms, deleted.crossovers);
        b.insertAll(workCharacters, deleted.characters);
        // The other work may be gone by now.
        b.insertAll(workRelations, [
          for (final r in deleted.relations)
            if (ids.contains(r.fromWorkId) && ids.contains(r.toWorkId)) r,
        ]);
      });
    });
  }

  Stream<List<Chapter>> watchChapters(int workId) =>
      (select(chapters)
            ..where((c) => c.workId.equals(workId))
            ..orderBy([(c) => OrderingTerm.asc(c.number)]))
          .watch();

  /// Numbers of the chapters that could be downloaded but have no text yet.
  Stream<List<int>> watchMissingChapters(int workId) {
    final query = selectOnly(chapters)
      ..addColumns([chapters.number])
      ..where(
        chapters.workId.equals(workId) &
            chapters.content.isNull() &
            chapters.isLocked.equals(false) &
            chapters.url.isNotNull(),
      );
    return query.watch().map(
      (rows) => [for (final r in rows) r.read(chapters.number)!],
    );
  }

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
  }) async {
    await (update(
      chapters,
    )..where((c) => c.workId.equals(workId) & c.number.equals(number))).write(
      ChaptersCompanion(
        content: Value(html),
        wordCount: Value(wordCount),
        downloadedAt: Value(DateTime.now()),
      ),
    );
    await fillMissingCounts(workId);
  }

  /// Words per page for estimates (a typical paperback page).
  static const wordsPerPage = 250;

  /// Characters (with spaces) per word, measured on Russian prose.
  static const charactersPerWord = 6.4;

  /// Works out word and page counts the site didn't give: words from the
  /// site's character count, else from the chapters read so far (scaled up
  /// to all chapters), pages from words, or words from pages. Values from
  /// the site or the user are kept.
  Future<void> fillMissingCounts(int workId) async {
    final w = await workById(workId);
    if (w == null) return;
    final words = chapters.wordCount.sum();
    final counted = chapters.wordCount.count();
    final row =
        await (selectOnly(chapters)
              ..addColumns([words, counted])
              ..where(
                chapters.workId.equals(workId) & chapters.wordCount.isNotNull(),
              ))
            .getSingle();
    final known = row.read(counted) ?? 0;
    final sum = row.read(words) ?? 0;
    final total = max(w.chapterCount ?? 0, known);
    final givenPages = w.pagesEstimated ? null : w.pageCount;
    final chars = w.characterCount;

    final wordCount = !(w.wordCount == null || w.wordsEstimated)
        ? w.wordCount
        : chars != null && chars > 0
        ? (chars / charactersPerWord).round()
        : known > 0 && sum > 0
        ? (sum * total / known).round()
        : givenPages != null
        // Royal Road counts 275 words per page.
        ? givenPages * 275
        // E.g. from sample chapters; kept until something better is known.
        : w.wordCount;
    final pageCount = !(w.pageCount == null || w.pagesEstimated)
        ? w.pageCount
        : wordCount == null
        ? null
        : max(1, (wordCount / wordsPerPage).round());

    final wordsEstimated =
        wordCount != null && (w.wordCount == null || w.wordsEstimated);
    final pagesEstimated =
        pageCount != null && (w.pageCount == null || w.pagesEstimated);
    if (wordCount == w.wordCount &&
        pageCount == w.pageCount &&
        wordsEstimated == w.wordsEstimated &&
        pagesEstimated == w.pagesEstimated) {
      return;
    }
    await updateWork(
      workId,
      WorksCompanion(
        wordCount: Value(wordCount),
        pageCount: Value(pageCount),
        wordsEstimated: Value(wordsEstimated),
        pagesEstimated: Value(pagesEstimated),
      ),
      touch: false,
    );
  }

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

  Future<Work?> workById(int id) =>
      (select(works)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Online stories that update checks can look at.
  Future<List<Work>> worksWithSource() => (select(
    works,
  )..where((w) => w.sourceUrl.isNotNull() & w.deletedAt.isNull())).get();

  /// Clears the "new chapters" badge, e.g. when the story is opened.
  Future<void> markChaptersSeen(int id) =>
      (update(
            works,
          )..where((w) => w.id.equals(id) & w.newChapters.isBiggerThanValue(0)))
          .write(const WorksCompanion(newChapters: Value(0)));

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
  Future<int?> _seriesIdFor(String name) async {
    final n = name.trim();
    if (n.isEmpty) return null;
    for (final s in await select(series).get()) {
      if (s.name.toLowerCase() == n.toLowerCase()) return s.id;
    }
    return into(series).insert(SeriesCompanion.insert(name: n));
  }

  Future<List<String>> seriesNames() => (select(
    series,
  )..orderBy([(s) => OrderingTerm.asc(s.name)])).map((s) => s.name).get();

  /// Series that at least one work (not in the trash) belongs to.
  Future<List<SeriesItem>> usedSeries() =>
      (select(series)
            ..where(
              (s) => s.id.isInQuery(
                selectOnly(works)
                  ..addColumns([works.seriesId])
                  ..where(works.deletedAt.isNull()),
              ),
            )
            ..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .get();

  /// The works of a series in reading order (unnumbered ones last).
  Stream<List<Work>> watchSeries(int seriesId) =>
      (select(works)
            ..where((w) => w.seriesId.equals(seriesId) & w.deletedAt.isNull())
            ..orderBy([
              (w) => OrderingTerm(
                expression: w.seriesIndex,
                nulls: NullsOrder.last,
              ),
              (w) => OrderingTerm.asc(w.title),
            ]))
          .watch();

  /// [workId]'s relations in both directions, with the other work.
  Stream<List<({WorkRelation relation, Work work})>> watchRelations(
    int workId,
  ) {
    final other = alias(works, 'other');
    final query = select(workRelations).join([
      innerJoin(
        other,
        (workRelations.fromWorkId.equals(workId) &
                other.id.equalsExp(workRelations.toWorkId)) |
            (workRelations.toWorkId.equals(workId) &
                other.id.equalsExp(workRelations.fromWorkId)),
      ),
    ])..where(other.deletedAt.isNull());
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          (relation: r.readTable(workRelations), work: r.readTable(other)),
      ],
    );
  }

  Future<void> addRelation(int from, RelationType type, int to) async {
    if (from == to) return;
    await into(workRelations).insert(
      WorkRelationsCompanion.insert(fromWorkId: from, toWorkId: to, type: type),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeRelation(WorkRelation r) =>
      (delete(workRelations)..where(
            (x) =>
                x.fromWorkId.equals(r.fromWorkId) &
                x.toWorkId.equals(r.toWorkId) &
                x.type.equalsValue(r.type),
          ))
          .go();

  /// The franchise a story without one most likely belongs to, from its
  /// tags ("наруто", "мир наруто", "Naruto (Anime)") or else its title
  /// ("Наруто с чит-кодами"; only with [useTitle], since an original novel
  /// may be called "Twist of Fate"): the listed franchises and the
  /// library's own categories are tried. Null if nothing fits.
  Future<String?> guessFandom({
    required String title,
    List<String> tags = const [],
    bool useTitle = true,
  }) async {
    final known = {
      ...FandomList.namesByKey(),
      for (final f in await select(fandoms).get())
        if (fandomKey(f.name).length >= 4) fandomKey(f.name): f.name,
    };
    final aliases = {
      for (final a in await select(fandomAliases).get())
        if (a.aliasKey.length >= 4) a.aliasKey: a.fandomId,
    };
    final names = {for (final f in await select(fandoms).get()) f.id: f.name};
    String? byKey(String text) {
      final key = fandomKey(text);
      if (key.isEmpty) return null;
      if (aliases[key] case final id?) return names[id];
      return known[key];
    }

    final prefix = RegExp(
      r'^(мир|вселенная|world of|universe of|welt von)\s+',
      caseSensitive: false,
    );
    for (final tag in tags) {
      final found = byKey(tag) ?? byKey(tag.replaceFirst(prefix, ''));
      if (found != null) return found;
    }
    if (!useTitle) return null;
    // Runs of up to four words of the title, longest first.
    final words = title
        .split(RegExp(r'[^\p{L}\p{N}\-:]+', unicode: true))
        .where((w) => w.isNotEmpty)
        .toList();
    for (var n = 4; n >= 1; n--) {
      for (var i = 0; i + n <= words.length; i++) {
        final found = byKey(words.sublist(i, i + n).join(' '));
        if (found != null) return found;
      }
    }
    return null;
  }

  Future<int?> _fandomIdFor(String? name) async {
    var n = name?.trim() ?? '';
    if (n.isEmpty) return null;
    final alias = await (select(
      fandomAliases,
    )..where((a) => a.aliasKey.equals(fandomKey(n)))).getSingleOrNull();
    if (alias != null) return alias.fandomId;
    n = FandomList.canonical(n) ?? n;
    final key = FandomList.groupKey(n);
    for (final fandom in await select(fandoms).get()) {
      if (FandomList.groupKey(fandom.name) == key) return fandom.id;
    }
    return into(fandoms)
        .insert(FandomsCompanion.insert(name: baseFandomName(n)));
  }

  /// Moves everything of category [fromId] to [intoId], deletes it and
  /// remembers its name as an alias.
  Future<void> mergeFandom(int fromId, int intoId) {
    if (fromId == intoId) return Future.value();
    return transaction(() async {
      final from = await (select(
        fandoms,
      )..where((f) => f.id.equals(fromId))).getSingle();
      await _moveFandom(fromId, intoId);
      await into(fandomAliases).insertOnConflictUpdate(
        FandomAliasesCompanion.insert(
          aliasKey: fandomKey(from.name),
          fandomId: intoId,
        ),
      );
    });
  }

  Stream<List<Fandom>> watchFandoms() =>
      (select(fandoms)..orderBy([(f) => OrderingTerm.asc(f.name)])).watch();

  Future<void> renameFandom(int id, String name) =>
      (update(fandoms)..where((f) => f.id.equals(id))).write(
        FandomsCompanion(name: Value(name.trim())),
      );

  /// Each category's learned other names, by id (as comparison keys).
  Stream<Map<int, List<String>>> watchFandomAliases() =>
      select(fandomAliases).watch().map((rows) {
        final byFandom = <int, List<String>>{};
        for (final r in rows) {
          byFandom.putIfAbsent(r.fandomId, () => []).add(r.aliasKey);
        }
        return byFandom;
      });

  Future<void> removeFandomAlias(String aliasKey) =>
      (delete(fandomAliases)..where((a) => a.aliasKey.equals(aliasKey))).go();

  Future<void> _moveFandom(int fromId, int intoId) async {
    await (update(works)..where((w) => w.fandomId.equals(fromId))).write(
      WorksCompanion(fandomId: Value(intoId)),
    );
    await customStatement(
      'UPDATE characters SET fandom_id = ? WHERE fandom_id = ?',
      [intoId, fromId],
    );
    // Crossover links too; one already pointing at [intoId] wins.
    await customStatement(
      'UPDATE OR IGNORE work_fandoms SET fandom_id = ? WHERE fandom_id = ?',
      [intoId, fromId],
    );
    await customStatement(
      'UPDATE fandom_aliases SET fandom_id = ? WHERE fandom_id = ?',
      [intoId, fromId],
    );
    await (delete(fandoms)..where((f) => f.id.equals(fromId))).go();
    // A crossover with its own main category says nothing.
    await customStatement(
      'DELETE FROM work_fandoms WHERE fandom_id = ? AND work_id IN '
      '(SELECT id FROM works WHERE fandom_id = ?)',
      [intoId, intoId],
    );
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
        groups
            .putIfAbsent(FandomList.groupKey(fandom.name), () => [])
            .add(fandom);
      }
      for (final group in groups.values) {
        final keep = group.first;
        for (final duplicate in group.skip(1)) {
          await _moveFandom(duplicate.id, keep.id);
        }
        final base = baseFandomName(
          FandomList.canonical(keep.name) ?? keep.name,
        );
        if (base != keep.name) {
          await (update(fandoms)..where((f) => f.id.equals(keep.id))).write(
            FandomsCompanion(name: Value(base)),
          );
        }
      }
    });
  }

  /// Finds the row named [name], ignoring case. Compared in Dart because
  /// SQLite's lower() only knows ASCII: "Фанфик" wouldn't match "фанфик".
  static T? _sameName<T>(List<T> rows, String Function(T) nameOf, String name) {
    final key = name.toLowerCase();
    return rows.where((r) => nameOf(r) == name).firstOrNull ??
        rows.where((r) => nameOf(r).toLowerCase() == key).firstOrNull;
  }

  Future<int?> _tagIdFor(String name, {bool adult = false}) async {
    var n = name.trim();
    if (n.isEmpty) return null;
    final synonym = await (select(
      tagSynonyms,
    )..where((s) => s.synonym.equals(n.toLowerCase()))).getSingleOrNull();
    if (synonym != null) return synonym.tagId;
    n = kTagSynonyms[n.toLowerCase()] ?? n;
    final existing = _sameName(await select(tags).get(), (t) => t.name, n);
    if (existing != null) {
      if (adult && !existing.isAdult) await setTagAdult(existing.id, true);
      return existing.id;
    }
    return into(tags).insert(
      TagsCompanion.insert(name: n, isAdult: Value(adult || looksAdult(n))),
    );
  }

  /// The character [name] of [fandomId], matched by its name or an alias
  /// in any order of the parts; created if new.
  Future<int?> _characterIdFor(String name, int? fandomId) async {
    final n = name.trim();
    if (n.isEmpty) return null;
    final key = characterKey(n);
    final candidates =
        await (select(characters)..where(
              (c) => fandomId == null
                  ? c.fandomId.isNull()
                  : c.fandomId.equals(fandomId),
            ))
            .get();
    for (final c in candidates) {
      if (characterKey(c.name) == key) return c.id;
    }
    final aliases =
        await (select(characterAliases).join([
              innerJoin(
                characters,
                characters.id.equalsExp(characterAliases.characterId),
              ),
            ])..where(
              fandomId == null
                  ? characters.fandomId.isNull()
                  : characters.fandomId.equals(fandomId),
            ))
            .get();
    for (final a in aliases) {
      if (characterKey(a.readTable(characterAliases).alias) == key) {
        return a.readTable(characterAliases).characterId;
      }
    }
    return into(characters)
        .insert(CharactersCompanion.insert(name: n, fandomId: Value(fandomId)));
  }

  /// Characters that appear in at least one work (not in the trash).
  Future<List<Character>> usedCharacters() =>
      (select(characters)
            ..where(
              (c) => c.id.isInQuery(
                selectOnly(workCharacters).join([
                    innerJoin(works, works.id.equalsExp(workCharacters.workId)),
                  ])
                  ..addColumns([workCharacters.characterId])
                  ..where(works.deletedAt.isNull()),
              ),
            )
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();

  Future<List<String>> characterNames() =>
      (select(characters)..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .map((c) => c.name)
          .get()
          .then((names) => names.toSet().toList());

  /// The character [name] of [fandomId] (created if new).
  Future<int?> characterIdFor(String name, int? fandomId) =>
      _characterIdFor(name, fandomId);

  /// The characters of category [fandomId] with all their names.
  Future<List<({Character character, List<String> names})>> charactersOf(
    int fandomId,
  ) async {
    final rows = await (select(
      characters,
    )..where((c) => c.fandomId.equals(fandomId))).get();
    final aliases = await (select(
      characterAliases,
    )..where((a) => a.characterId.isIn([for (final c in rows) c.id]))).get();
    return [
      for (final c in rows)
        (
          character: c,
          names: [
            c.name,
            for (final a in aliases)
              if (a.characterId == c.id) a.alias,
          ],
        ),
    ];
  }

  /// Adds characters found in the text with how sure the guess is (below
  /// 1); confirmed ones stay as they are.
  Future<void> suggestCharacters(int workId, Map<int, double> found) =>
      batch((b) {
        for (final MapEntry(key: id, value: confidence) in found.entries) {
          b.insert(
            workCharacters,
            WorkCharactersCompanion.insert(
              workId: workId,
              characterId: id,
              confidence: Value(confidence.clamp(0, 0.99)),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });

  Future<void> confirmCharacter(int workId, int characterId) =>
      (update(workCharacters)..where(
            (c) => c.workId.equals(workId) & c.characterId.equals(characterId),
          ))
          .write(const WorkCharactersCompanion(confidence: Value(1)));

  Future<void> removeCharacter(int workId, int characterId) =>
      (delete(workCharacters)..where(
            (c) => c.workId.equals(workId) & c.characterId.equals(characterId),
          ))
          .go();

  /// The text of [workId]'s chapters that have any, up to [maxChars].
  Future<String> textOf(int workId, {int maxChars = 400000}) async {
    final buffer = StringBuffer();
    for (final c in await chaptersOf(workId)) {
      final html = c.content;
      if (html == null) continue;
      buffer.writeln(html.replaceAll(RegExp(r'<[^>]*>'), ' '));
      if (buffer.length > maxChars) break;
    }
    return '$buffer';
  }

  Future<void> setCharacterAniListId(int characterId, int anilistId) =>
      (update(characters)..where((c) => c.id.equals(characterId))).write(
        CharactersCompanion(anilistId: Value(anilistId)),
      );

  Future<Work?> workByAniListId(int anilistId) =>
      (select(works)
            ..where((w) => w.anilistId.equals(anilistId) & w.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();

  /// Remembers [name] as another name of category [fandomId], unless it
  /// already names a category.
  Future<void> addFandomAlias(int fandomId, String name) async {
    final key = fandomKey(name);
    if (key.isEmpty) return;
    for (final f in await select(fandoms).get()) {
      if (fandomKey(f.name) == key) return;
    }
    await into(fandomAliases).insert(
      FandomAliasesCompanion.insert(aliasKey: key, fandomId: fandomId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> addCharacterAlias(int characterId, String alias) =>
      into(characterAliases).insert(
        CharacterAliasesCompanion.insert(
          characterId: characterId,
          alias: alias.trim(),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<int?> _pairingIdFor(String name) async {
    final n = normalizePairing(name);
    if (n.isEmpty) return null;
    final existing = _sameName(await select(pairings).get(), (p) => p.name, n);
    return existing?.id ??
        await into(pairings).insert(PairingsCompanion.insert(name: n));
  }

  /// Turns tags that name a relationship ("Naruto/Hinata") into pairings,
  /// keeping them on the same works. Earlier imports stored AO3
  /// relationships as tags.
  Future<void> moveRelationshipTagsToPairings() {
    return transaction(() async {
      for (final tag in await select(tags).get()) {
        if (!looksLikePairing(tag.name)) continue;
        final pairingId = await _pairingIdFor(tag.name);
        final workIds =
            await (selectOnly(workTags)
                  ..addColumns([workTags.workId])
                  ..where(workTags.tagId.equals(tag.id)))
                .map((r) => r.read(workTags.workId)!)
                .get();
        for (final workId in workIds) {
          await into(workPairings).insert(
            WorkPairingsCompanion.insert(workId: workId, pairingId: pairingId!),
            mode: InsertMode.insertOrIgnore,
          );
        }
        await (delete(tags)..where((t) => t.id.equals(tag.id))).go();
      }
    });
  }

  /// Merges pairings that differ only in how original characters are
  /// written ("Naruto/OC" and "Naruto/Original Character(s)"), keeping their
  /// works, and writes the remaining one the normal way.
  Future<void> mergeEquivalentPairings() => transaction(() async {
    final groups = <String, List<Pairing>>{};
    for (final p in await (select(
      pairings,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get()) {
      groups
          .putIfAbsent(normalizePairing(p.name).toLowerCase(), () => [])
          .add(p);
    }
    for (final group in groups.values) {
      final keep = group.first;
      for (final other in group.skip(1)) {
        await customStatement(
          'INSERT OR IGNORE INTO work_pairings (work_id, pairing_id) '
          'SELECT work_id, ? FROM work_pairings WHERE pairing_id = ?',
          [keep.id, other.id],
        );
        await (delete(pairings)..where((p) => p.id.equals(other.id))).go();
      }
      final name = normalizePairing(keep.name);
      if (name != keep.name) {
        await (update(pairings)..where((p) => p.id.equals(keep.id))).write(
          PairingsCompanion(name: Value(name)),
        );
      }
    }
  });

  /// Merges tags that are known spellings or translations of another
  /// ([kTagSynonyms]: "экшн", "Aktion" → "Action") into it, so existing
  /// works are filtered together. A missing target is made by renaming.
  Future<void> mergeSynonymTags() async {
    final all = await select(tags).get();
    final byName = {for (final t in all) t.name.toLowerCase(): t};
    for (final tag in all) {
      final canonical = kTagSynonyms[tag.name.toLowerCase().trim()];
      if (canonical == null ||
          canonical.toLowerCase() == tag.name.toLowerCase()) {
        continue;
      }
      final target = byName[canonical.toLowerCase()];
      if (target == null) {
        await (update(tags)..where((t) => t.id.equals(tag.id))).write(
          TagsCompanion(name: Value(canonical)),
        );
        byName[canonical.toLowerCase()] = tag.copyWith(name: canonical);
      } else if (target.id != tag.id) {
        await mergeTag(tag.id, target.id);
      }
    }
  }

  /// Moves [fromId]'s works to [intoId] and deletes it; its name becomes a
  /// synonym, so later imports land on [intoId] too.
  Future<void> mergeTag(int fromId, int intoId) {
    if (fromId == intoId) return Future.value();
    return transaction(() async {
      final from = await (select(
        tags,
      )..where((t) => t.id.equals(fromId))).getSingle();
      await customStatement(
        'INSERT OR IGNORE INTO work_tags (work_id, tag_id) '
        'SELECT work_id, ? FROM work_tags WHERE tag_id = ?',
        [intoId, fromId],
      );
      // Synonyms of the old tag follow it.
      await (update(tagSynonyms)..where((s) => s.tagId.equals(fromId))).write(
        TagSynonymsCompanion(tagId: Value(intoId)),
      );
      await (delete(tags)..where((t) => t.id.equals(fromId))).go();
      await into(tagSynonyms).insertOnConflictUpdate(
        TagSynonymsCompanion.insert(
          synonym: from.name.toLowerCase(),
          tagId: intoId,
        ),
      );
    });
  }

  /// Each tag's synonyms, by tag id.
  Stream<Map<int, List<String>>> watchTagSynonyms() =>
      select(tagSynonyms).watch().map((rows) {
        final byTag = <int, List<String>>{};
        for (final r in rows) {
          byTag.putIfAbsent(r.tagId, () => []).add(r.synonym);
        }
        return byTag;
      });

  Future<void> removeTagSynonym(String synonym) =>
      (delete(tagSynonyms)..where((s) => s.synonym.equals(synonym))).go();

  /// Open suggestions for [workId] (not dismissed, not already tags).
  Stream<List<({Tag tag, TagSuggestion suggestion})>> watchTagSuggestions(
    int workId,
  ) {
    final query =
        select(tagSuggestions)
            .join([innerJoin(tags, tags.id.equalsExp(tagSuggestions.tagId))])
          ..where(
            tagSuggestions.workId.equals(workId) &
                tagSuggestions.dismissed.equals(false) &
                tagSuggestions.tagId
                    .isInQuery(
                      selectOnly(workTags)
                        ..addColumns([workTags.tagId])
                        ..where(workTags.workId.equals(workId)),
                    )
                    .not(),
          )
          ..orderBy([OrderingTerm.asc(tags.name)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          (tag: r.readTable(tags), suggestion: r.readTable(tagSuggestions)),
      ],
    );
  }

  /// Proposes tags by name with a reason each; ones the work has, or the
  /// user dismissed before, are skipped. Returns how many are new.
  Future<int> suggestTags(
    int workId,
    Map<String, String> reasons, {
    String source = 'keywords',
  }) async {
    var added = 0;
    final has = {
      for (final t in (await watchWork(workId).first)?.tags ?? const <Tag>[])
        t.id,
    };
    for (final MapEntry(key: name, value: reason) in reasons.entries) {
      final tagId = await _tagIdFor(name);
      if (tagId == null || has.contains(tagId)) continue;
      final known =
          await (select(tagSuggestions)
                ..where((x) => x.workId.equals(workId) & x.tagId.equals(tagId)))
              .getSingleOrNull();
      if (known != null) continue;
      await into(tagSuggestions).insert(
        TagSuggestionsCompanion.insert(
          workId: workId,
          tagId: tagId,
          reason: Value(reason),
          source: Value(source),
        ),
      );
      added++;
    }
    return added;
  }

  Future<void> acceptTagSuggestion(int workId, int tagId) =>
      transaction(() async {
        await into(workTags).insert(
          WorkTagsCompanion.insert(workId: workId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
        await (delete(
          tagSuggestions,
        )..where((s) => s.workId.equals(workId) & s.tagId.equals(tagId))).go();
      });

  Future<void> dismissTagSuggestion(int workId, int tagId) =>
      (update(tagSuggestions)
            ..where((s) => s.workId.equals(workId) & s.tagId.equals(tagId)))
          .write(const TagSuggestionsCompanion(dismissed: Value(true)));

  Future<void> setTagAdult(int tagId, bool adult) =>
      (update(tags)..where((t) => t.id.equals(tagId))).write(
        TagsCompanion(isAdult: Value(adult)),
      );

  Future<List<Tag>> allTags() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<Tag>> watchAllTags() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  /// Pairings that at least one work has.
  Future<List<Pairing>> usedPairings() =>
      (select(pairings)
            ..where(
              (p) => p.id.isInQuery(
                selectOnly(workPairings).join([
                    innerJoin(works, works.id.equalsExp(workPairings.workId)),
                  ])
                  ..addColumns([workPairings.pairingId])
                  ..where(works.deletedAt.isNull()),
              ),
            )
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get();

  Future<List<String>> pairingNames() => (select(
    pairings,
  )..orderBy([(p) => OrderingTerm.asc(p.name)])).map((p) => p.name).get();

  Stream<List<Annotation>> watchAnnotations(int workId) =>
      (select(annotations)
            ..where((a) => a.workId.equals(workId))
            ..orderBy([
              (a) => OrderingTerm.asc(a.chapterNumber),
              (a) => OrderingTerm.asc(a.offset),
            ]))
          .watch();

  Future<int> addAnnotation(AnnotationsCompanion data) =>
      into(annotations).insert(data);

  Future<void> updateAnnotationNote(int id, String? note) =>
      (update(annotations)..where((a) => a.id.equals(id))).write(
        AnnotationsCompanion(note: Value(note)),
      );

  Future<void> deleteAnnotation(int id) =>
      (delete(annotations)..where((a) => a.id.equals(id))).go();

  Future<String?> setting(String key) async => (await (select(
    settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  /// After restoring a backup made elsewhere, points the stored cover paths
  /// at this device's books folder.
  Future<void> moveCoverPaths(String from, String to) async {
    if (from == to) return;
    await customUpdate(
      'UPDATE works SET cover_path = ? || substr(cover_path, ?) '
      'WHERE substr(cover_path, 1, ?) = ?',
      variables: [
        Variable.withString(to),
        Variable.withInt(from.length + 1),
        Variable.withInt(from.length),
        Variable.withString(from),
      ],
      updates: {works},
    );
  }

  Future<void> setSetting(String key, String value) => into(settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}

/// Matches a character's names regardless of order and a franchise note:
/// "Fujiwara Chika", "Chika Fujiwara" and "Fujiwara Chika (Kaguya-sama)".
String characterKey(String name) {
  final words =
      name
          .replaceAll(RegExp(r'\([^)]*\)'), ' ')
          .toLowerCase()
          .split(RegExp(r'[\s.,]+'))
          .where((w) => w.isNotEmpty)
          .toList()
        ..sort();
  return words.join(' ');
}
