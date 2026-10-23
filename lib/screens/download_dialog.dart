import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/exporters.dart';
import '../library/story_sync.dart';
import '../sources/sources.dart';

/// What the user chose in [DownloadDialog].
class DownloadChoice {
  const DownloadChoice({
    required this.from,
    required this.to,
    this.appendTo,
    this.format = ExportFormat.txt,
  });

  final int from;
  final int to;

  /// File format of a new download (an extended one keeps its format).
  final ExportFormat format;

  /// Extend this download instead of creating a new file.
  final Download? appendTo;
}

/// Checks the site for new chapters, then asks which chapters to download:
/// added to an existing download (1–30 becomes 1–40) or as a new file (31–40).
class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key, required this.work, required this.source});

  final Work work;
  final StorySource source;

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

enum _Mode { append, newFile }

class _DownloadDialogState extends State<DownloadDialog> {
  final _from = TextEditingController();
  final _to = TextEditingController();
  bool _checking = true;
  String? _checkError;
  int _newChapters = 0;
  List<Chapter> _chapters = const [];
  List<Download> _downloads = const [];
  _Mode _mode = _Mode.newFile;
  ExportFormat _format = ExportFormat.epub;

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checking && _chapters.isEmpty && _checkError == null) _check();
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final db = _db;
    try {
      final info = await loadStoryInfo(
        widget.source,
        Uri.parse(widget.work.sourceUrl!),
      );
      _newChapters = await applyStoryInfo(db, widget.work, info);
    } on SourceException catch (e) {
      // Still allow downloading the chapters we already know about.
      _checkError = e.message;
    }
    final chapters = await db.chaptersOf(widget.work.id);
    final downloads = await db.downloadsOf(widget.work.id);
    if (!mounted) return;
    final last = chapters.isEmpty ? 0 : chapters.last.number;
    final latest = _latest(downloads);
    final next = latest == null ? 1 : latest.toChapter + 1;
    setState(() {
      _checking = false;
      _chapters = chapters;
      _downloads = downloads;
      _mode = latest != null && next <= last ? _Mode.append : _Mode.newFile;
      _from.text = '${next <= last ? next : 1}';
      _to.text = '$last';
    });
  }

  static Download? _latest(List<Download> downloads) => downloads.isEmpty
      ? null
      : downloads.reduce((a, b) => a.toChapter >= b.toChapter ? a : b);

  int get _last => _chapters.isEmpty ? 0 : _chapters.last.number;

  ({int from, int to})? get _range {
    final from = int.tryParse(_from.text.trim());
    final to = int.tryParse(_to.text.trim());
    if (from == null || to == null || from < 1 || to > _last || from > to) {
      return null;
    }
    return (from: from, to: to);
  }

  void _confirm() {
    final latest = _latest(_downloads);
    if (_mode == _Mode.append && latest != null) {
      Navigator.pop(
        context,
        DownloadChoice(from: latest.toChapter + 1, to: _last, appendTo: latest),
      );
      return;
    }
    final range = _range;
    if (range != null) {
      Navigator.pop(
        context,
        DownloadChoice(from: range.from, to: range.to, format: _format),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (_checking) {
      return AlertDialog(
        title: Text(l10n.downloadTitle),
        content: Row(
          children: [
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.downloadChecking(widget.source.name))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      );
    }

    final latest = _latest(_downloads);
    final locked = _chapters.where((c) => c.isLocked).length;
    final canAppend = latest != null && latest.toChapter < _last;
    final range = _range;
    final valid = _mode == _Mode.append ? canAppend : range != null;

    return AlertDialog(
      title: Text(l10n.downloadTitle),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_checkError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.downloadCheckFailed(_checkError!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              Text(l10n.downloadAvailable(_last)),
              if (_newChapters > 0)
                Text(l10n.downloadNewChapters(_newChapters)),
              if (locked > 0)
                Text(
                  l10n.downloadLockedNote(locked),
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 16),
              if (_last == 0)
                Text(l10n.downloadNoChapters)
              else ...[
                if (latest != null && !canAppend)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l10n.downloadUpToDate),
                  ),
                RadioGroup<_Mode>(
                  groupValue: _mode,
                  onChanged: (m) => setState(() => _mode = m ?? _mode),
                  child: Column(
                    children: [
                      if (canAppend)
                        RadioListTile<_Mode>(
                          value: _Mode.append,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.downloadAppend(
                              latest.fromChapter,
                              latest.toChapter,
                              _last,
                            ),
                          ),
                        ),
                      RadioListTile<_Mode>(
                        value: _Mode.newFile,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.downloadNewFile),
                      ),
                    ],
                  ),
                ),
                if (_mode == _Mode.newFile) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SegmentedButton<ExportFormat>(
                      segments: [
                        for (final f in ExportFormat.values)
                          ButtonSegment(value: f, label: Text(f.label)),
                      ],
                      selected: {_format},
                      onSelectionChanged: (s) =>
                          setState(() => _format = s.first),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _from,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.downloadFrom,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _to,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.downloadTo,
                            helperText: l10n.downloadMax(_last),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.downloadFormatHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: valid && _last > 0 ? _confirm : null,
          child: Text(l10n.downloadStart),
        ),
      ],
    );
  }
}
