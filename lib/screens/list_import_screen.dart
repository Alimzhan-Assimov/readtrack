import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../diagnostics/app_log.dart';
import '../l10n/l10n.dart';
import '../library/story_sync.dart';
import '../sources/sources.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';

/// Takes over a list from a site (bookmarks, favorites, a reading list):
/// loads it, lets the user pick stories, and adds them one by one.
/// Pops with the number of stories added.
class ListImportScreen extends StatefulWidget {
  const ListImportScreen({
    super.key,
    this.open = openFetcher,
    this.pause = const Duration(seconds: 1),
  });

  final PageFetcher Function(StorySource source) open;

  /// Wait between stories, to go easy on the site.
  final Duration pause;

  @override
  State<ListImportScreen> createState() => _ListImportScreenState();
}

class _ListImportScreenState extends State<ListImportScreen> {
  final _url = TextEditingController();
  StorySource? _source;
  PageFetcher? _fetcher;
  bool _loading = false;
  String? _error;
  List<ListedStory>? _stories;
  Set<String> _inLibrary = const {};
  final _selected = <String>{};
  ReadingStatus _status = ReadingStatus.planned;

  // While importing.
  int? _done;
  bool _cancelled = false;
  int _added = 0;
  final _failed = <(ListedStory, String)>[];

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void dispose() {
    _url.dispose();
    _fetcher?.close();
    super.dispose();
  }

  Future<void> _load() async {
    final l10n = context.l10n;
    final uri = parseUserUrl(_url.text);
    final source = uri == null ? null : siteFor(uri);
    if (uri == null || source == null) {
      setState(() => _error = l10n.listImportUnsupported);
      return;
    }
    if (source.storyUrl(uri) != null) {
      setState(() => _error = l10n.listImportIsStory);
      return;
    }
    await _fetcher?.close();
    setState(() {
      _source = source;
      _fetcher = widget.open(source);
      _loading = true;
      _error = null;
      _stories = null;
    });
    try {
      final stories = await source.fetchList(uri, _fetcher!);
      final inLibrary = {
        for (final s in stories)
          if (await _db.workBySourceUrl('${s.url}') != null) '${s.url}',
      };
      if (!mounted) return;
      setState(() {
        _stories = stories;
        _inLibrary = inLibrary;
        _selected
          ..clear()
          ..addAll([
            for (final s in stories)
              if (!inLibrary.contains('${s.url}')) '${s.url}',
          ]);
        if (stories.isEmpty) _error = l10n.listImportEmpty;
      });
    } on SourceException catch (e) {
      logWarning(
        'import',
        'List failed to load',
        context: {'source': source.name, 'url': '$uri'},
        error: e.message,
      );
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _import() async {
    final source = _source!;
    final fetcher = _fetcher!;
    final picked = [
      for (final s in _stories!)
        if (_selected.contains('${s.url}')) s,
    ];
    setState(() {
      _done = 0;
      _cancelled = false;
      _added = 0;
      _failed.clear();
    });
    for (final (i, story) in picked.indexed) {
      if (_cancelled || !mounted) break;
      try {
        // A story may have been added meanwhile, e.g. twice in the list.
        if (await _db.workBySourceUrl('${story.url}') == null) {
          final info = await source.fetchStory(story.url, fetcher);
          await addStory(_db, info, status: _status);
          _added++;
        }
      } on SourceException catch (e) {
        _failed.add((story, e.message));
        logWarning(
          'import',
          'Story from a list failed',
          context: {'source': source.name, 'url': '${story.url}'},
          error: e.message,
        );
      }
      if (!mounted) return;
      setState(() => _done = i + 1);
      if (i < picked.length - 1) await Future<void>.delayed(widget.pause);
    }
    if (!mounted) return;
    setState(() => _inLibrary = {..._inLibrary, ..._selected});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final stories = _stories;
    final importing = _done != null && _done! < _selected.length && !_cancelled;
    final finished = _done != null && !importing;
    return PopScope(
      canPop: !importing,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.listImportTitle),
          leading: finished
              ? CloseButton(onPressed: () => Navigator.pop(context, _added))
              : null,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: readablePadding(constraints.maxWidth, top: 8, bottom: 32),
            children: [
              Text(l10n.listImportIntro, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _url,
                enabled: !_loading && _done == null,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.listImportUrl,
                  hintText: 'https://archiveofourown.org/users/…/bookmarks',
                  errorText: _error,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: l10n.listImportLoad,
                    onPressed: _loading || _done != null ? null : _load,
                  ),
                ),
                onSubmitted: (_) => _load(),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (stories != null && stories.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (_done == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.listImportFound(
                            stories.length,
                            _inLibrary.length,
                          ),
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          final open = [
                            for (final s in stories)
                              if (!_inLibrary.contains('${s.url}')) '${s.url}',
                          ];
                          if (_selected.length == open.length) {
                            _selected.clear();
                          } else {
                            _selected.addAll(open);
                          }
                        }),
                        child: Text(l10n.listImportToggleAll),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<ReadingStatus>(
                    initialValue: _status,
                    decoration: InputDecoration(
                      labelText: l10n.listImportStatus,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      for (final s in ReadingStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label(l10n))),
                    ],
                    onChanged: (s) => setState(() => _status = s ?? _status),
                  ),
                  const SizedBox(height: 8),
                  for (final s in stories)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value:
                          _inLibrary.contains('${s.url}') ||
                          _selected.contains('${s.url}'),
                      onChanged: _inLibrary.contains('${s.url}')
                          ? null
                          : (v) => setState(
                              () => v == true
                                  ? _selected.add('${s.url}')
                                  : _selected.remove('${s.url}'),
                            ),
                      title: Text(s.title),
                      subtitle: Text(
                        _inLibrary.contains('${s.url}')
                            ? l10n.listImportInLibrary
                            : '${s.url}',
                      ),
                    ),
                ] else ...[
                  LinearProgressIndicator(
                    value: _selected.isEmpty ? 1 : _done! / _selected.length,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    finished
                        ? l10n.listImportDone(_added, _failed.length)
                        : l10n.listImportProgress(_done!, _selected.length),
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final (story, error) in _failed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(story.title),
                      subtitle: Text(error),
                    ),
                ],
              ],
            ],
          ),
        ),
        bottomNavigationBar: stories == null || stories.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: importing
                      ? OutlinedButton(
                          onPressed: () => setState(() => _cancelled = true),
                          child: Text(l10n.cancel),
                        )
                      : finished
                      ? FilledButton(
                          onPressed: () => Navigator.pop(context, _added),
                          child: Text(l10n.listImportClose),
                        )
                      : FilledButton.icon(
                          icon: const Icon(Icons.library_add),
                          onPressed: _selected.isEmpty ? null : _import,
                          label: Text(l10n.listImportAdd(_selected.length)),
                        ),
                ),
              ),
      ),
    );
  }
}
