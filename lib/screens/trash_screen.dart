import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/library_scope.dart';
import '../library/trash.dart';
import '../ui/format.dart';
import '../ui/layout.dart';
import '../widgets/work_cover.dart';

/// Deleted works, which can be restored for half a year.
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late Stream<List<Work>> _trash;

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trash = _db.watchTrash();
  }

  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.deleteForever),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteForever(Work w) async {
    final l10n = context.l10n;
    final storage = LibraryScope.of(context).storage;
    if (!await _confirm(l10n.deleteForeverTitle(w.title), l10n.cannotUndo)) {
      return;
    }
    await deleteFromTrash(_db, storage, id: w.id);
  }

  Future<void> _emptyTrash(int count) async {
    final l10n = context.l10n;
    final storage = LibraryScope.of(context).storage;
    if (!await _confirm(l10n.emptyTrashTitle(count), l10n.cannotUndo)) return;
    await deleteFromTrash(_db, storage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return StreamBuilder<List<Work>>(
      stream: _trash,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Work>[];
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.trashTitle),
            actions: [
              if (items.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(l10n.emptyTrash),
                  onPressed: () => _emptyTrash(items.length),
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => ListView(
              padding: readablePadding(constraints.maxWidth, bottom: 32),
              children: [
                Text(l10n.trashHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                if (snapshot.hasData && items.isEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline),
                    title: Text(l10n.trashEmpty),
                  ),
                for (final w in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: WorkCover(work: w, width: 32),
                    title: Text(w.title),
                    subtitle: Text(
                      l10n.trashDates(
                        formatDate(context, w.deletedAt!),
                        formatDate(context, purgeDate(w.deletedAt!)),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore_from_trash_outlined),
                          tooltip: l10n.restore,
                          onPressed: () => _db.restoreFromTrash(w.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_outlined),
                          tooltip: l10n.deleteForever,
                          onPressed: () => _deleteForever(w),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
