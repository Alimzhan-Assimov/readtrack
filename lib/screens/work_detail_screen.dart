import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/library_scope.dart';
import '../sources/sources.dart';
import '../ui/format.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/work_cover.dart';
import 'read_section.dart';
import 'work_edit_screen.dart';

class WorkDetailScreen extends StatefulWidget {
  const WorkDetailScreen({
    super.key,
    required this.workId,
    this.embedded = false,
    this.onDeleted,
  });

  final int workId;

  /// Shown as the right-hand pane next to the list instead of as a page.
  final bool embedded;

  /// Called after deleting. Without a callback the page is closed.
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.linkOpenFailed)));
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

  /// Deletes right away and offers "Undo" instead of asking first.
  Future<void> _delete(Work w) async {
    final db = _db;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final storage = LibraryScope.of(context).storage;
    final deleted = await db.deleteWork(w.id);
    if (deleted == null || !mounted) return;
    if (widget.onDeleted case final onDeleted?) {
      onDeleted();
    } else {
      Navigator.of(context).pop();
    }
    final snackBar = messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.deletedMessage(w.title)),
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => db.restoreWork(deleted),
        ),
      ),
    );
    // Downloaded files are removed only once "Undo" is no longer possible.
    unawaited(
      snackBar.closed.then((reason) async {
        if (reason == SnackBarClosedReason.action) return;
        await storage.deleteBookFiles(w.id, [
          for (final d in deleted.downloads) ?d.filePath,
        ]);
      }),
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
                  : Text(context.l10n.notFound),
            ),
          );
        }
        return _buildDetails(context, item);
      },
    );
  }

  Widget _buildDetails(BuildContext context, WorkWithDetails item) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final w = item.work;
    final url = w.sourceUrl;
    final site = siteName(url);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => WorkEditScreen(existing: item)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteTooltip,
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
                Expanded(child: _buildHeader(theme, l10n, item)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(w.type.icon, size: 18),
                  label: Text(w.type.label(l10n)),
                ),
                Chip(
                  avatar: Icon(w.format.icon, size: 18),
                  label: Text(w.format.label(l10n)),
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
                if (w.chapterCount case final n?)
                  _StatBox(
                    value: l10n.formatNumber(n),
                    label: w.isComplete
                        ? l10n.chaptersComplete
                        : l10n.chaptersOngoing,
                  ),
                if (w.wordCount case final n?)
                  _StatBox(value: l10n.formatNumber(n), label: l10n.fieldWords),
                if (w.pageCount case final n?)
                  _StatBox(value: l10n.formatNumber(n), label: l10n.fieldPages),
              ],
            ),
            if (w.chapterCount != null || w.currentChapter != null)
              _buildProgress(l10n, w),
            if (url != null && sourceFor(Uri.parse(url)) != null)
              _Section(
                title: l10n.sectionRead,
                child: ReadSection(work: w),
              ),
            if (url != null)
              _Section(
                title: l10n.sectionLink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        site != null ? l10n.readOn(site) : l10n.readOnline,
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
                title: l10n.sectionTags,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in item.tags) Chip(label: Text(t.name)),
                  ],
                ),
              ),
            if (w.isbn case final isbn?)
              _Section(title: l10n.sectionIsbn, child: SelectableText(isbn)),
            if (w.summary case final summary?)
              _Section(title: l10n.sectionSummary, child: Text(summary)),
            if (w.notes case final notes?)
              _Section(title: l10n.sectionNotes, child: Text(notes)),
            const SizedBox(height: 24),
            Text(
              l10n.addedUpdated(w.addedAt, w.updatedAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    AppLocalizations l10n,
    WorkWithDetails item,
  ) {
    final w = item.work;
    final fandom = item.fandom;
    final rating = w.rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(w.title, style: theme.textTheme.headlineSmall),
        if (w.author case final author?)
          Text(
            l10n.byAuthor(author),
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

  Widget _buildProgress(AppLocalizations l10n, Work w) {
    final current = w.currentChapter ?? 0;
    final total = w.chapterCount;
    return _Section(
      title: l10n.sectionProgress,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  total != null
                      ? l10n.chapterProgress(current, total)
                      : l10n.chapterCurrent(current),
                ),
              ),
              IconButton.outlined(
                icon: const Icon(Icons.remove),
                tooltip: l10n.previousChapter,
                onPressed: current > 0
                    ? () => _setProgress(w, current - 1)
                    : null,
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                tooltip: l10n.nextChapter,
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
    final l10n = context.l10n;
    return MenuAnchor(
      menuChildren: [
        for (final s in ReadingStatus.values)
          MenuItemButton(
            leadingIcon: Icon(s.icon),
            trailingIcon: s == status ? const Icon(Icons.check) : null,
            onPressed: () => onChanged(s),
            child: Text(s.label(l10n)),
          ),
      ],
      builder: (context, controller, _) => ActionChip(
        tooltip: l10n.changeStatus,
        backgroundColor: scheme.primaryContainer,
        avatar: Icon(status.icon, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.label(l10n)),
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
