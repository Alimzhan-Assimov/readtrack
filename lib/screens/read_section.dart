import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/book_importer.dart';
import '../library/exporters.dart';
import '../library/file_import.dart';
import '../library/library_scope.dart';
import '../library/story_sync.dart';
import '../reader/reader_screen.dart';
import '../reader/reader_sheets.dart';
import '../sources/sources.dart';
import 'catalog_screen.dart';
import 'download_dialog.dart';

/// "Read" part of the detail screen: read online, read a download, start a
/// download or check for new chapters.
class ReadSection extends StatefulWidget {
  const ReadSection({super.key, required this.work});

  final Work work;

  @override
  State<ReadSection> createState() => _ReadSectionState();
}

class _ReadSectionState extends State<ReadSection> {
  late Stream<List<Download>> _downloads;
  late Stream<int> _chapterCount;
  late Stream<List<int>> _missing;
  late Stream<List<Annotation>> _annotations;
  bool _checking = false;

  AppDatabase get _db => DatabaseScope.of(context);

  /// The site to read from, if it hosts the text.
  StorySource? get _source {
    final url = widget.work.sourceUrl;
    final source = url == null ? null : sourceFor(Uri.parse(url));
    return source != null && source.canRead ? source : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _downloads = _db.watchDownloads(widget.work.id);
    _chapterCount = _db.watchChapterCount(widget.work.id);
    _missing = _db.watchMissingChapters(widget.work.id);
    _annotations = _db.watchAnnotations(widget.work.id);
  }

  void _read(ReaderMode mode, {int? chapter, double? offset}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          work: widget.work,
          mode: mode,
          startChapter: chapter,
          startOffset: offset,
        ),
      ),
    );
  }

  /// Opens the place of [annotation]: from a download that has the chapter,
  /// otherwise online.
  void _openAnnotation(Annotation annotation, List<Download> downloads) {
    final download = downloads
        .where(
          (d) =>
              d.fromChapter <= annotation.chapterNumber &&
              annotation.chapterNumber <= d.toChapter,
        )
        .firstOrNull;
    final ReaderMode mode;
    if (download != null) {
      mode = DownloadReading(download);
    } else if (_source != null) {
      mode = const OnlineReading();
    } else {
      return;
    }
    _read(mode, chapter: annotation.chapterNumber, offset: annotation.offset);
  }

  Future<void> _checkForNew() async {
    final source = _source;
    if (source == null) return;
    final l10n = context.l10n;
    final db = _db;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    try {
      final info = await loadStoryInfo(
        source,
        Uri.parse(widget.work.sourceUrl!),
      );
      final added = await applyStoryInfo(db, widget.work, info);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            added > 0 ? l10n.newChaptersFound(added) : l10n.noNewChapters,
          ),
        ),
      );
    } on SourceException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _download() async {
    final source = _source;
    if (source == null) return;
    final choice = await showDialog<DownloadChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DownloadDialog(work: widget.work, source: source),
    );
    if (choice == null || !mounted) return;
    await _runDownload(
      source,
      from: choice.from,
      to: choice.to,
      appendTo: choice.appendTo,
      format: choice.format,
      withImages: choice.withImages,
    );
  }

  /// Fetches the chapters of [download] that have no text yet.
  Future<void> _loadMissing(Download download) async {
    final source = _source;
    if (source == null) return;
    await _runDownload(
      source,
      from: download.fromChapter,
      to: download.toChapter,
      appendTo: download,
    );
  }

  Future<void> _runDownload(
    StorySource source, {
    required int from,
    required int to,
    Download? appendTo,
    ExportFormat format = ExportFormat.txt,
    bool withImages = true,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final service = LibraryScope.of(context).downloads;
    final latest = await (_db.select(
      _db.works,
    )..where((w) => w.id.equals(widget.work.id))).getSingle();
    final result = await service.download(
      work: latest,
      source: source,
      from: from,
      to: to,
      appendTo: appendTo,
      format: format,
      withImages: withImages,
    );
    final file = result.file;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          (result.cancelled
                  ? l10n.downloadCancelled(result.downloaded)
                  : result.failed > 0
                  ? l10n.downloadDoneWithErrors(
                      result.downloaded,
                      result.failed,
                    )
                  : l10n.downloadDone(result.downloaded)) +
              (result.firstError == null ? '' : '\n${result.firstError}'),
        ),
        action: file == null
            ? null
            : SnackBarAction(
                label: l10n.openFile,
                onPressed: () => openFile(file.path),
              ),
      ),
    );
  }

  /// For entries without text, e.g. a paper book: attach a file the user
  /// has, or look for a free legal edition.
  Widget _buildNoText(AppLocalizations l10n, ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          l10n.sectionRead,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      Text(l10n.noTextHint, style: theme.textTheme.bodyMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: Text(l10n.attachFile),
            onPressed: _attachFile,
          ),
          if (widget.work.type == WorkType.book)
            OutlinedButton.icon(
              icon: const Icon(Icons.travel_explore),
              label: Text(l10n.findFreeEditions),
              onPressed: () => Navigator.of(context).push(
                catalogRoute(
                  widget.work.id,
                  (_) => FreeEditionsScreen(
                    query: [widget.work.title, ?widget.work.author].join(' '),
                    attachTo: widget.work.id,
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );

  Future<void> _attachFile() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final importer = BookImporter(_db, LibraryScope.of(context).storage);
    final file = await fs.openFile(
      acceptedTypeGroups: [
        fs.XTypeGroup(label: l10n.bookFiles, extensions: kImportExtensions),
      ],
    );
    if (file == null) return;
    try {
      final book = await readBookFile(file.path);
      await importer.attach(widget.work.id, book, original: File(file.path));
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.catalogAttached(file.name))),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
    }
  }

  Future<void> _exportAs(Download download, ExportFormat format) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final file = await LibraryScope.of(context).downloads
        .exportAs(download, format);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.exportedAs(format.label)),
        action: SnackBarAction(
          label: l10n.openFile,
          onPressed: () => openFile(file.path),
        ),
      ),
    );
  }

  Future<void> _deleteDownload(Download download) async {
    final storage = LibraryScope.of(context).storage;
    await _db.deleteDownload(download.id);
    await _db.purgeUncoveredText(widget.work.id);
    if (download.filePath case final path?) await storage.deleteFile(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final source = _source;
    final service = LibraryScope.of(context).downloads;
    final current = widget.work.currentChapter;

    return StreamBuilder<List<Download>>(
      stream: _downloads,
      builder: (context, downloadsSnapshot) {
        final downloads = downloadsSnapshot.data ?? const <Download>[];
        return StreamBuilder<int>(
          stream: _chapterCount,
          builder: (context, countSnapshot) => StreamBuilder<List<int>>(
            stream: _missing,
            builder: (context, missingSnapshot) {
              final known = countSnapshot.data ?? 0;
              final missing = missingSnapshot.data ?? const <int>[];
              int missingIn(Download d) => missing
                  .where((n) => n >= d.fromChapter && n <= d.toChapter)
                  .length;
              if (source == null && downloads.isEmpty) {
                return _buildNoText(l10n, theme);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: Text(
                      l10n.sectionRead,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (source != null && known > 0)
                        FilledButton.icon(
                          icon: const Icon(Icons.public),
                          label: Text(
                            current != null && current > 0
                                ? l10n.continueOnline(current)
                                : l10n.readOnlineInApp,
                          ),
                          onPressed: () => _read(const OnlineReading()),
                        ),
                      if (source != null && known == 0)
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.list),
                          label: Text(l10n.loadChapterList),
                          onPressed: _checking ? null : _checkForNew,
                        ),
                      if (source != null && known > 0)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.checkForNewChapters),
                          onPressed: _checking ? null : _checkForNew,
                        ),
                    ],
                  ),
                  if (_checking)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.downloadsHeading,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (downloads.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.noDownloadsYet,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  for (final d in downloads)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: missingIn(d) > 0
                          ? Icon(
                              Icons.warning_amber,
                              color: theme.colorScheme.error,
                            )
                          : const Icon(Icons.download_done),
                      title: Text(
                        l10n.downloadRange(d.fromChapter, d.toChapter),
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          text: l10n.downloadSubtitle(
                            d.format.toUpperCase(),
                            d.updatedAt,
                          ),
                          children: [
                            if (missingIn(d) > 0)
                              TextSpan(
                                text:
                                    '\n${l10n.downloadIncomplete(missingIn(d))}',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      onTap: () => _read(DownloadReading(d)),
                      trailing: MenuAnchor(
                        menuChildren: [
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.menu_book),
                            onPressed: () => _read(DownloadReading(d)),
                            child: Text(l10n.readDownload),
                          ),
                          if (source != null && missingIn(d) > 0)
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.sync),
                              onPressed: service.isRunning(widget.work.id)
                                  ? null
                                  : () => _loadMissing(d),
                              child: Text(l10n.loadMissingChapters),
                            ),
                          if (d.filePath case final path?)
                            MenuItemButton(
                              leadingIcon: const Icon(
                                Icons.description_outlined,
                              ),
                              onPressed: () => openFile(path),
                              child: Text(
                                l10n.openFileFormat(d.format.toUpperCase()),
                              ),
                            ),
                          SubmenuButton(
                            leadingIcon: const Icon(Icons.ios_share),
                            menuChildren: [
                              for (final f in ExportFormat.values)
                                if (f.name != d.format)
                                  MenuItemButton(
                                    onPressed: () => _exportAs(d, f),
                                    child: Text(f.label),
                                  ),
                            ],
                            child: Text(l10n.exportAs),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteDownload(d),
                            child: Text(l10n.deleteDownload),
                          ),
                        ],
                        builder: (context, controller, _) => IconButton(
                          icon: const Icon(Icons.more_vert),
                          tooltip: l10n.moreOptions,
                          onPressed: () => controller.isOpen
                              ? controller.close()
                              : controller.open(),
                        ),
                      ),
                    ),
                  _AnnotationsPreview(
                    annotations: _annotations,
                    onOpen: (a) => _openAnnotation(a, downloads),
                    onDelete: (a) => _db.deleteAnnotation(a.id),
                  ),
                  ListenableBuilder(
                    listenable: service,
                    builder: (context, _) {
                      final progress = service.progressOf(widget.work.id);
                      if (progress == null) {
                        return source == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.download),
                                  label: Text(l10n.downloadButton),
                                  onPressed: _download,
                                ),
                              );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: progress.total == 0
                                  ? null
                                  : progress.fraction,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    progress.total == 0
                                        ? l10n.downloadPreparing
                                        : l10n.downloadProgress(
                                            progress.done + 1,
                                            progress.total,
                                          ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      service.cancel(widget.work.id),
                                  child: Text(l10n.cancel),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// The latest bookmarks, quotes and notes, with a way to see all of them.
class _AnnotationsPreview extends StatelessWidget {
  const _AnnotationsPreview({
    required this.annotations,
    required this.onOpen,
    required this.onDelete,
  });

  static const _shown = 3;

  final Stream<List<Annotation>> annotations;
  final ValueChanged<Annotation> onOpen;
  final ValueChanged<Annotation> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return StreamBuilder<List<Annotation>>(
      stream: annotations,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Annotation>[];
        if (items.isEmpty) return const SizedBox.shrink();
        final latest = [...items]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        String chapter(Annotation a) => l10n.chapterCurrent(a.chapterNumber);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.annotationsTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            for (final a in latest.take(_shown))
              AnnotationTile(
                annotation: a,
                chapterTitle: chapter(a),
                onTap: () => onOpen(a),
                onDelete: () => onDelete(a),
              ),
            if (items.length > _shown)
              TextButton(
                onPressed: () async {
                  final picked = await showModalBottomSheet<Annotation>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => AnnotationsSheet(
                      annotations: annotations,
                      chapterTitle: (n) => l10n.chapterCurrent(n),
                      onDelete: onDelete,
                    ),
                  );
                  if (picked != null) onOpen(picked);
                },
                child: Text(l10n.showAllAnnotations(items.length)),
              ),
          ],
        );
      },
    );
  }
}
