import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/library_scope.dart';
import '../library/story_sync.dart';
import '../sources/sources.dart';
import '../ui/layout.dart';
import '../ui/app_settings.dart';
import 'chapter_blocks.dart';
import 'reader_sheets.dart';

/// What the reader shows: chapters live from the site, or a download.
sealed class ReaderMode {
  const ReaderMode();
}

class OnlineReading extends ReaderMode {
  const OnlineReading();
}

class DownloadReading extends ReaderMode {
  const DownloadReading(this.download);

  final Download download;
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    required this.work,
    required this.mode,
    this.startChapter,
    this.startOffset,
  });

  final Work work;
  final ReaderMode mode;

  /// Opens this chapter instead of the last reading position.
  final int? startChapter;

  /// Scroll position (0–1) within [startChapter], e.g. for a bookmark.
  final double? startOffset;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _scroll = ScrollController();
  List<Chapter> _chapters = const [];
  late int _current;
  Future<_LoadedChapter>? _content;
  final _onlineCache = <int, ChapterContent>{};
  StorySource? _source;
  PageFetcher? _fetcher;
  Timer? _saveOffset;
  double? _pendingOffset;

  /// Latest scroll position (0–1), so it can still be saved in [dispose].
  double? _offset;

  /// Text currently selected in the chapter, for quotes and notes.
  String? _selection;

  /// Settings used when there is no [SettingsScope] (e.g. in tests).
  ReaderPrefs _localPrefs = const ReaderPrefs();
  late Stream<List<Annotation>> _annotations;

  // Looked up once: inherited widgets aren't reachable in dispose().
  late final AppDatabase _db = DatabaseScope.of(context);

  Download? get _download => switch (widget.mode) {
    DownloadReading(:final download) => download,
    OnlineReading() => null,
  };

  int get _first => _download?.fromChapter ?? 1;
  int get _last =>
      _download?.toChapter ?? (_chapters.isEmpty ? 1 : _chapters.last.number);

  List<Chapter> get _inRange => [
    for (final c in _chapters)
      if (c.number >= _first && c.number <= _last) c,
  ];

  @override
  void initState() {
    super.initState();
    final url = widget.work.sourceUrl;
    _source = url == null ? null : sourceFor(Uri.parse(url));
    _scroll.addListener(_onScroll);
    final saved = widget.work.currentChapter;
    _current = widget.startChapter ?? saved ?? 1;
    if (widget.startChapter == null && saved != null && saved > 0) {
      _pendingOffset = widget.work.readOffset;
    }
    if (widget.startOffset case final offset?) _pendingOffset = offset;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_content == null) {
      _annotations = _db.watchAnnotations(widget.work.id);
      _init();
    }
  }

  ReaderPrefs get _prefs =>
      SettingsScope.maybeOf(context)?.reader ?? _localPrefs;

  void _setPrefs(ReaderPrefs prefs) {
    final settings = SettingsScope.maybeOf(context);
    if (settings != null) {
      settings.setReader(prefs);
    } else {
      setState(() => _localPrefs = prefs);
    }
  }

  void _showSettings() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => ReaderSettingsSheet(prefs: _prefs, onChanged: _setPrefs),
  );

  Future<void> _addBookmark() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    await _db.addAnnotation(
      AnnotationsCompanion.insert(
        workId: widget.work.id,
        chapterNumber: _current,
        kind: AnnotationKind.bookmark,
        offset: Value(_offset ?? 0),
      ),
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.bookmarkAdded)));
  }

  Future<void> _saveQuote(String quote, {bool withNote = false}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    String? note;
    if (withNote) {
      note = await askForNote(context, quote: quote);
      if (note == null) return;
    }
    await _db.addAnnotation(
      AnnotationsCompanion.insert(
        workId: widget.work.id,
        chapterNumber: _current,
        kind: withNote ? AnnotationKind.note : AnnotationKind.quote,
        quote: Value(quote),
        note: Value(note == null || note.isEmpty ? null : note),
        offset: Value(_offset ?? 0),
      ),
    );
    messenger.showSnackBar(
      SnackBar(content: Text(withNote ? l10n.noteSaved : l10n.quoteSaved)),
    );
  }

  Future<void> _addChapterNote() async {
    final note = await askForNote(context);
    if (note == null || note.isEmpty) return;
    await _db.addAnnotation(
      AnnotationsCompanion.insert(
        workId: widget.work.id,
        chapterNumber: _current,
        kind: AnnotationKind.note,
        note: Value(note),
        offset: Value(_offset ?? 0),
      ),
    );
  }

  Future<void> _editNote(Annotation a) async {
    final note = await askForNote(
      context,
      initial: a.note ?? '',
      quote: a.quote,
    );
    if (note != null) {
      await _db.updateAnnotationNote(a.id, note.isEmpty ? null : note);
    }
  }

  Future<void> _showAnnotations() async {
    final picked = await showModalBottomSheet<Annotation>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AnnotationsSheet(
        annotations: _annotations,
        chapterTitle: (n) =>
            _chapter(n)?.title ?? context.l10n.readerPosition(n, _last),
        onDelete: (a) => _db.deleteAnnotation(a.id),
        onEditNote: _editNote,
      ),
    );
    if (picked == null || !mounted) return;
    if (picked.chapterNumber < _first || picked.chapterNumber > _last) return;
    _pendingOffset = picked.offset;
    if (picked.chapterNumber == _current) {
      setState(() {});
    } else {
      _open(picked.chapterNumber, keepOffset: true);
    }
  }

  Future<void> _init() async {
    final chapters = await _db.chaptersOf(widget.work.id);
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _current = _current.clamp(_first, _last);
    });
    _open(_current, keepOffset: true);
  }

  @override
  void dispose() {
    if (_saveOffset?.isActive ?? false) _storeOffset();
    _saveOffset?.cancel();
    _scroll.dispose();
    unawaited(_fetcher?.close());
    super.dispose();
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    _offset = max <= 0 ? 0.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    _saveOffset?.cancel();
    _saveOffset = Timer(const Duration(milliseconds: 800), _storeOffset);
  }

  void _storeOffset() {
    final offset = _offset;
    if (offset == null) return;
    unawaited(
      _db.updateWork(widget.work.id, WorksCompanion(readOffset: Value(offset))),
    );
  }

  void _open(int number, {bool keepOffset = false}) {
    if (!keepOffset) _pendingOffset = null;
    setState(() {
      _current = number;
      _content = _load(number);
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    unawaited(
      _db.updateWork(
        widget.work.id,
        WorksCompanion(
          currentChapter: Value(number),
          readOffset: keepOffset ? const Value.absent() : const Value(0),
          status: widget.work.status == ReadingStatus.planned
              ? const Value(ReadingStatus.reading)
              : const Value.absent(),
        ),
      ),
    );
  }

  Chapter? _chapter(int number) =>
      _chapters.where((c) => c.number == number).firstOrNull;

  Future<_LoadedChapter> _load(int number) async {
    final chapter = _chapter(number);
    final l10n = context.l10n;
    if (chapter == null) throw SourceException(l10n.readerNoChapters);
    if (_download != null) {
      final latest = (await _db.chaptersOf(widget.work.id))
          .where((c) => c.number == number)
          .firstOrNull;
      final html = latest?.content;
      if (html == null) {
        throw SourceException(
          chapter.isLocked
              ? l10n.readerLockedChapter
              : l10n.readerNotDownloaded,
        );
      }
      return _LoadedChapter(chapter.title, html);
    }
    final source = _source;
    if (source == null || chapter.url == null) {
      throw SourceException(l10n.readerNoSource);
    }
    if (chapter.isLocked) throw SourceException(l10n.readerLockedChapter);
    final cached = _onlineCache[number] ??= await source.fetchChapter(
      chapterRefOf(chapter),
      _fetcher ??= openFetcher(source),
    );
    return _LoadedChapter(cached.title ?? chapter.title, cached.html);
  }

  ImageProvider? _resolveImage(String src) {
    if (src.startsWith('http')) return NetworkImage(src);
    final file = LibraryScope.of(context).storage.resolve(widget.work.id, src);
    return file.existsSync() ? FileImage(file) : null;
  }

  void _restoreOffset() {
    final offset = _pendingOffset;
    if (offset == null || !_scroll.hasClients) return;
    _pendingOffset = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(offset * _scroll.position.maxScrollExtent);
    });
  }

  bool get _hasPrevious => _current > _first;
  bool get _hasNext => _current < _last;

  void _previous() {
    if (_hasPrevious) _open(_current - 1);
  }

  void _next() {
    if (_hasNext) _open(_current + 1);
  }

  Future<void> _showChapterList() async {
    final chapters = _inRange;
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChapterListSheet(
        chapters: chapters,
        current: _current,
        showDownloaded: _download == null,
      ),
    );
    if (selected != null && mounted) _open(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final chapter = _chapter(_current);
    final chapterUrl = chapter?.url;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _previous,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _next,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: _prefs.theme.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter?.title ?? widget.work.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.work.title,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                tooltip: l10n.readerChapters,
                onPressed: _chapters.isEmpty ? null : _showChapterList,
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined),
                tooltip: l10n.addBookmark,
                onPressed: _addBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.text_fields),
                tooltip: l10n.readerSettings,
                onPressed: _showSettings,
              ),
              MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(
                      Icons.collections_bookmark_outlined,
                    ),
                    onPressed: _showAnnotations,
                    child: Text(l10n.annotationsTitle),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.sticky_note_2_outlined),
                    onPressed: _addChapterNote,
                    child: Text(l10n.addNote),
                  ),
                  if (chapterUrl != null)
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.open_in_new),
                      onPressed: () => launchUrl(
                        Uri.parse(chapterUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(l10n.readerOpenInBrowser),
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
            ],
          ),
          body: FutureBuilder<_LoadedChapter>(
            future: _content,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ReaderMessage(
                  icon: chapter?.isLocked == true
                      ? Icons.lock_outline
                      : Icons.cloud_off,
                  text: '${snapshot.error}',
                  action: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_download == null && chapter?.isLocked != true)
                        FilledButton.tonal(
                          onPressed: () => _open(_current),
                          child: Text(l10n.readerRetry),
                        ),
                      if (chapterUrl != null)
                        TextButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(chapterUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.readerOpenInBrowser),
                        ),
                    ],
                  ),
                );
              }
              final loaded = snapshot.data;
              if (loaded == null) {
                return _ReaderMessage(
                  icon: Icons.hourglass_top,
                  text:
                      _source != null &&
                          _source!.fetchMode != FetchMode.http &&
                          _download == null
                      ? '${l10n.readerLoading}\n${l10n.readerBrowserHint}'
                      : l10n.readerLoading,
                  loading: true,
                );
              }
              final prefs = _prefs;
              final textColor = prefs.theme.text ?? theme.colorScheme.onSurface;
              return StreamBuilder<List<Annotation>>(
                stream: _annotations,
                builder: (context, annotationSnapshot) {
                  final quotes = [
                    for (final a
                        in annotationSnapshot.data ?? const <Annotation>[])
                      if (a.chapterNumber == _current) ?a.quote,
                  ];
                  final blocks = buildChapterBlocks(
                    loaded.html,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontSize: prefs.fontSize,
                      height: prefs.lineHeight,
                      fontFamily: prefs.font.family,
                      color: textColor,
                    ),
                    resolveImage: _resolveImage,
                    colors: theme.colorScheme,
                    highlights: quotes,
                    textAlign: prefs.justify
                        ? TextAlign.justify
                        : TextAlign.start,
                  );
                  _restoreOffset();
                  // A full column (not a lazy list) so the scroll extent is
                  // exact and the reading position restores precisely.
                  return LayoutBuilder(
                    builder: (context, constraints) => SelectionArea(
                      onSelectionChanged: (content) =>
                          _selection = content?.plainText.trim(),
                      contextMenuBuilder: (context, state) {
                        final selected = _selection;
                        return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: state.contextMenuAnchors,
                          buttonItems: [
                            ...state.contextMenuButtonItems,
                            if (selected != null && selected.isNotEmpty) ...[
                              ContextMenuButtonItem(
                                label: l10n.saveQuote,
                                onPressed: () {
                                  state.hideToolbar();
                                  _saveQuote(selected);
                                },
                              ),
                              ContextMenuButtonItem(
                                label: l10n.addNote,
                                onPressed: () {
                                  state.hideToolbar();
                                  _saveQuote(selected, withNote: true);
                                },
                              ),
                            ],
                          ],
                        );
                      },
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: readablePadding(
                          constraints.maxWidth,
                          top: 16,
                          bottom: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Text(
                                loaded.title ?? '',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: textColor,
                                  fontFamily: prefs.font.family,
                                ),
                              ),
                            ),
                            ...blocks,
                            _buildEnd(l10n),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          bottomNavigationBar: BottomAppBar(
            height: 64,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.previousChapter,
                  onPressed: _hasPrevious ? _previous : null,
                ),
                Expanded(
                  child: Text(
                    l10n.readerPosition(_current, _last),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.nextChapter,
                  onPressed: _hasNext ? _next : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnd(AppLocalizations l10n) {
    if (_hasNext) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: FilledButton.icon(
            onPressed: _next,
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.nextChapter),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          _download == null
              ? l10n.readerLatestChapter
              : l10n.readerEndOfDownload,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _LoadedChapter {
  _LoadedChapter(this.title, this.html);

  final String? title;
  final String html;
}

class _ReaderMessage extends StatelessWidget {
  const _ReaderMessage({
    required this.icon,
    required this.text,
    this.action,
    this.loading = false,
  });

  final IconData icon;
  final String text;
  final Widget? action;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class _ChapterListSheet extends StatelessWidget {
  const _ChapterListSheet({
    required this.chapters,
    required this.current,
    required this.showDownloaded,
  });

  static const _rowHeight = 56.0;

  final List<Chapter> chapters;
  final int current;
  final bool showDownloaded;

  @override
  Widget build(BuildContext context) {
    final index = chapters.indexWhere((c) => c.number == current);
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView.builder(
          itemExtent: _rowHeight,
          // Start with the current chapter roughly in the middle.
          controller: ScrollController(
            initialScrollOffset:
                (index * _rowHeight - constraints.maxHeight / 2 + _rowHeight)
                    .clamp(0, double.infinity),
          ),
          itemCount: chapters.length,
          itemBuilder: (context, i) {
            final c = chapters[i];
            return ListTile(
              selected: c.number == current,
              leading: SizedBox(
                width: 48,
                child: Text('${c.number}', style: theme.textTheme.labelLarge),
              ),
              title: Text(
                c.title ?? 'Chapter ${c.number}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: c.isLocked
                  ? const Icon(Icons.lock_outline, size: 18)
                  : showDownloaded && c.content != null
                  ? const Icon(Icons.download_done, size: 18)
                  : null,
              onTap: () => Navigator.pop(context, c.number),
            );
          },
        ),
      ),
    );
  }
}

/// Opens [path] with the system's default app (e.g. a text editor).
Future<bool> openFile(String path) async {
  if (!File(path).existsSync()) return false;
  return launchUrl(Uri.file(path));
}
