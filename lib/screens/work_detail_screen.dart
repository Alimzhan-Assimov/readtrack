import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../ui/format.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/work_cover.dart';
import 'work_edit_screen.dart';

class WorkDetailScreen extends StatefulWidget {
  const WorkDetailScreen({
    super.key,
    required this.workId,
    this.embedded = false,
    this.onDeleted,
  });

  final int workId;

  /// Als rechte Spalte neben der Liste statt als eigene Seite.
  final bool embedded;

  /// Wird nach dem Löschen aufgerufen. Ohne Callback wird die Seite geschlossen.
  final VoidCallback? onDeleted;

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late Stream<WorkWithDetails?> _work;

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _work = _db.watchWork(widget.workId);
  }

  Future<void> _openUrl(String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link konnte nicht geöffnet werden')),
      );
    }
  }

  Future<void> _setProgress(Work w, int chapter) {
    return _db.updateWork(
      w.id,
      WorksCompanion(
        currentChapter: Value(chapter),
        status: w.status == ReadingStatus.planned && chapter > 0
            ? const Value(ReadingStatus.reading)
            : const Value.absent(),
      ),
    );
  }

  /// Löscht sofort und bietet „Rückgängig“ an, statt vorher nachzufragen.
  Future<void> _delete(Work w) async {
    final db = _db;
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await db.deleteWork(w.id);
    if (deleted == null || !mounted) return;
    if (widget.onDeleted case final onDeleted?) {
      onDeleted();
    } else {
      Navigator.of(context).pop();
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text('„${w.title}“ gelöscht'),
        persist: false,
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => db.restoreWork(deleted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WorkWithDetails?>(
      stream: _work,
      builder: (context, snapshot) {
        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(automaticallyImplyLeading: !widget.embedded),
            body: Center(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const Text('Eintrag nicht gefunden'),
            ),
          );
        }
        return _buildDetails(context, item);
      },
    );
  }

  Widget _buildDetails(BuildContext context, WorkWithDetails item) {
    final theme = Theme.of(context);
    final w = item.work;
    final url = w.sourceUrl;
    final site = siteName(url);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Bearbeiten',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => WorkEditScreen(existing: item)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Löschen',
            onPressed: () => _delete(w),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: readablePadding(constraints.maxWidth, bottom: 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkCover(
                  work: w,
                  width: 96,
                  heroTag: widget.embedded ? null : 'cover-${w.id}',
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildHeader(theme, item)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(w.type.icon, size: 18),
                  label: Text(w.type.label),
                ),
                Chip(
                  avatar: Icon(w.format.icon, size: 18),
                  label: Text(w.format.label),
                ),
                _StatusMenu(
                  status: w.status,
                  onChanged: (s) =>
                      _db.updateWork(w.id, WorksCompanion(status: Value(s))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (w.chapterCount != null)
                  _StatBox(
                    value: formatNumber(w.chapterCount!),
                    label: w.isComplete
                        ? 'Kapitel · abgeschlossen'
                        : 'Kapitel · laufend',
                  ),
                if (w.wordCount != null)
                  _StatBox(value: formatNumber(w.wordCount!), label: 'Wörter'),
                if (w.pageCount != null)
                  _StatBox(value: formatNumber(w.pageCount!), label: 'Seiten'),
              ],
            ),
            if (w.chapterCount != null || w.currentChapter != null)
              _buildProgress(w),
            if (url != null)
              _Section(
                title: 'Link',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        site != null ? 'Auf $site lesen' : 'Online lesen',
                      ),
                      onPressed: () => _openUrl(url),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(url, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            if (item.tags.isNotEmpty)
              _Section(
                title: 'Tags',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in item.tags) Chip(label: Text(t.name)),
                  ],
                ),
              ),
            if (w.isbn != null)
              _Section(title: 'ISBN', child: SelectableText(w.isbn!)),
            if (w.summary != null)
              _Section(title: 'Zusammenfassung', child: Text(w.summary!)),
            if (w.notes != null)
              _Section(title: 'Notizen', child: Text(w.notes!)),
            const SizedBox(height: 24),
            Text(
              'Hinzugefügt am ${formatDate(w.addedAt)} · '
              'zuletzt geändert am ${formatDate(w.updatedAt)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, WorkWithDetails item) {
    final w = item.work;
    final fandom = item.fandom;
    final rating = w.rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(w.title, style: theme.textTheme.headlineSmall),
        if (w.author != null)
          Text(
            'von ${w.author}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (fandom != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.category_outlined, size: 18),
                const SizedBox(width: 6),
                Flexible(child: Text(fandom.name)),
              ],
            ),
          ),
        if (rating != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    i <= rating ? Icons.star : Icons.star_border,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgress(Work w) {
    final current = w.currentChapter ?? 0;
    final total = w.chapterCount;
    return _Section(
      title: 'Lesefortschritt',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  total != null
                      ? 'Kapitel $current von $total'
                      : 'Kapitel $current',
                ),
              ),
              IconButton.outlined(
                icon: const Icon(Icons.remove),
                tooltip: 'Ein Kapitel zurück',
                onPressed: current > 0
                    ? () => _setProgress(w, current - 1)
                    : null,
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                tooltip: 'Ein Kapitel weiter',
                onPressed: total == null || current < total
                    ? () => _setProgress(w, current + 1)
                    : null,
              ),
            ],
          ),
          if (total != null && total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                value: (current / total).clamp(0, 1).toDouble(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({required this.status, required this.onChanged});

  final ReadingStatus status;
  final ValueChanged<ReadingStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: [
        for (final s in ReadingStatus.values)
          MenuItemButton(
            leadingIcon: Icon(s.icon),
            trailingIcon: s == status ? const Icon(Icons.check) : null,
            onPressed: () => onChanged(s),
            child: Text(s.label),
          ),
      ],
      builder: (context, controller, _) => ActionChip(
        tooltip: 'Lesestatus ändern',
        backgroundColor: scheme.primaryContainer,
        avatar: Icon(status.icon, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.label),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
