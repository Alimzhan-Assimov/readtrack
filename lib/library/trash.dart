import '../data/database.dart';
import 'storage.dart';

/// How long deleted works stay in the trash.
const kTrashKeep = Duration(days: 183);

/// When a work deleted at [deletedAt] is removed for good.
DateTime purgeDate(DateTime deletedAt) => deletedAt.add(kTrashKeep);

/// Deletes works in the trash for good, with their downloaded files: one
/// ([id]), those deleted before [before], or all. Returns how many.
Future<int> deleteFromTrash(
  AppDatabase db,
  LibraryStorage storage, {
  int? id,
  DateTime? before,
}) async {
  final removed = await db.emptyTrash(id: id, before: before);
  for (final MapEntry(key: workId, value: files) in removed.entries) {
    await storage.deleteBookFiles(workId, files);
  }
  return removed.length;
}
