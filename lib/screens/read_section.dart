import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/library_scope.dart';
import '../library/story_sync.dart';
import '../reader/reader_screen.dart';
import '../sources/sources.dart';
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
  bool _checking = false;

  AppDatabase get _db => DatabaseScope.of(context);

  StorySource? get _source {
    final url = widget.work.sourceUrl;
    return url == null ? null : sourceFor(Uri.parse(url));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _downloads = _db.watchDownloads(widget.work.id);
    _chapterCount = _db.watchChapterCount(widget.work.id);
  }

  void _read(ReaderMode mode, {int? chapter}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ReaderScreen(work: widget.work, mode: mode, startChapter: chapter),
      ),
    );
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
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final service = LibraryScope.of(context).downloads;
    final choice = await showDialog<DownloadChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DownloadDialog(work: widget.work, source: source),
    );
    if (choice == null || !mounted) return;
    final latest = await (_db.select(
      _db.works,
    )..where((w) => w.id.equals(widget.work.id))).getSingle();
    final result = await service.download(
      work: latest,
      source: source,
      from: choice.from,
      to: choice.to,
      appendTo: choice.appendTo,
    );
    final file = result.file;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.cancelled
              ? l10n.downloadCancelled(result.downloaded)
              : result.failed > 0
              ? l10n.downloadDoneWithErrors(result.downloaded, result.failed)
              : l10n.downloadDone(result.downloaded),
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
          builder: (context, countSnapshot) {
            final known = countSnapshot.data ?? 0;
            if (source == null && downloads.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    leading: const Icon(Icons.download_done),
                    title: Text(l10n.downloadRange(d.fromChapter, d.toChapter)),
                    subtitle: Text(
                      l10n.downloadSubtitle(
                        d.format.toUpperCase(),
                        d.updatedAt,
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
                        if (d.filePath case final path?)
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.description_outlined),
                            onPressed: () => openFile(path),
                            child: Text(
                              l10n.openFileFormat(d.format.toUpperCase()),
                            ),
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
                                onPressed: () => service.cancel(widget.work.id),
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
        );
      },
    );
  }
}
