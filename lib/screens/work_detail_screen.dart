import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../ui/format.dart';
import '../ui/labels.dart';
import 'work_edit_screen.dart';

class WorkDetailScreen extends StatefulWidget {
  const WorkDetailScreen({super.key, required this.workId});

  final int workId;

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

  Future<void> _confirmDelete(Work w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: Text(
          '„${w.title}“ wird endgültig aus deiner Bibliothek entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _db.deleteWork(w.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WorkWithDetails?>(
      stream: _work,
      builder: (context, snapshot) {
        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
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
            onPressed: () => _confirmDelete(w),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
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
              PopupMenuButton<ReadingStatus>(
                initialValue: w.status,
                tooltip: 'Lesestatus ändern',
                onSelected: (s) =>
                    _db.updateWork(w.id, WorksCompanion(status: Value(s))),
                itemBuilder: (context) => [
                  for (final s in ReadingStatus.values)
                    PopupMenuItem(
                      value: s,
                      child: ListTile(
                        leading: Icon(s.icon),
                        title: Text(s.label),
                      ),
                    ),
                ],
                child: Chip(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  avatar: Icon(w.status.icon, size: 18),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(w.status.label),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(w.title, style: theme.textTheme.headlineSmall),
          if (w.author != null)
            Text(
              'von ${w.author}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (item.fandom != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.category_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(item.fandom!.name),
                ],
              ),
            ),
          if (w.rating != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= w.rating! ? Icons.star : Icons.star_border,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
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
                      ? 'Kapitel · fertig'
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
