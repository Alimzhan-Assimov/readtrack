import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../sources/anilist.dart';

/// What taking AniList's details changed.
typedef AniListResult = ({int characters, int relations});

/// Fills [item] from AniList's [media]: the summary and cover if missing,
/// genres and well-fitting tags, the characters (with AniList ids and their
/// other names), and links to sequels, prequels, spin-offs and side
/// stories already in the library. AniList's titles become other names of
/// the work's category.
Future<AniListResult> applyAniList(
  AppDatabase db,
  WorkWithDetails item,
  AniListMedia media,
) async {
  final w = item.work;
  await db.saveWork(
    WorksCompanion(
      id: Value(w.id),
      title: Value(w.title),
      summary: w.summary == null && media.description != null
          ? Value(media.description)
          : const Value.absent(),
      coverUrl:
          w.coverPath == null && w.coverUrl == null && media.coverUrl != null
          ? Value('${media.coverUrl}')
          : const Value.absent(),
      anilistId: Value(media.id),
    ),
    fandomName: item.fandom?.name ?? media.title,
    tagNames: {
      for (final t in item.tags) t.name,
      ...media.genres,
      ...media.tags,
    }.toList(),
    pairingNames: [for (final p in item.pairings) p.name],
    characterNames: {
      for (final c in item.confirmedCharacters) c.name,
      for (final c in media.characters) c.name,
    }.toList(),
  );
  final saved = (await db.watchWork(w.id).first)!;
  final fandomId = saved.fandom?.id;
  for (final c in media.characters) {
    final id = await db.characterIdFor(c.name, fandomId);
    if (id == null) continue;
    await db.setCharacterAniListId(id, c.id);
    for (final other in c.otherNames) {
      await db.addCharacterAlias(id, other);
    }
  }
  if (fandomId != null) {
    for (final t in media.titles) {
      await db.addFandomAlias(fandomId, t);
    }
  }
  var linked = 0;
  // Already linked either way round (e.g. from the other work's lookup).
  final related = {
    for (final r in await db.watchRelations(w.id).first) r.work.id,
  };
  for (final r in media.relations) {
    final type = switch (r.type) {
      'SEQUEL' => RelationType.sequel,
      'PREQUEL' => RelationType.prequel,
      'SPIN_OFF' => RelationType.spinOff,
      'SIDE_STORY' => RelationType.sideStory,
      _ => null,
    };
    if (type == null) continue;
    final other = await db.workByAniListId(r.mediaId);
    if (other == null || other.id == w.id || !related.add(other.id)) {
      continue;
    }
    await db.addRelation(w.id, type, other.id);
    linked++;
  }
  return (
    characters: saved.characters.length - item.characters.length,
    relations: linked,
  );
}
