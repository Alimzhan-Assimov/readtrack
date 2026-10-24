import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../diagnostics/app_log.dart';
import '../data/database.dart';
import '../data/database_scope.dart';
import '../data/default_tags.dart';
import '../l10n/l10n.dart';
import '../library/book_importer.dart';
import '../library/file_import.dart';
import '../library/library_scope.dart';
import '../library/story_sync.dart';
import '../sources/fetcher.dart';
import '../sources/html_clean.dart';
import '../sources/isbn_lookup.dart';
import '../sources/sources.dart';
import '../data/adult_tags.dart';
import '../ui/app_settings.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/suggest_field.dart';
import '../widgets/tag_input.dart';
import '../widgets/value_picker.dart';

/// Form for creating ([existing] == null) or editing a work.
/// Pops with the work's id as the result after saving.
class WorkEditScreen extends StatefulWidget {
  const WorkEditScreen({
    super.key,
    this.existing,
    this.imported,
    this.file,
    this.details,
  });

  final WorkWithDetails? existing;

  /// Details loaded from a site to prefill a new entry.
  final StoryInfo? imported;

  /// A book file read for import; saving imports it with the form's values.
  final ({ImportedBook book, String path})? file;

  /// A paper book's details found by its ISBN.
  final BookDetails? details;

  @override
  State<WorkEditScreen> createState() => _WorkEditScreenState();
}

class _WorkEditScreenState extends State<WorkEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _fandom = TextEditingController();
  final _series = TextEditingController();
  final _seriesIndex = TextEditingController();
  final _url = TextEditingController();
  final _chapters = TextEditingController();
  final _currentChapter = TextEditingController();
  final _words = TextEditingController();
  final _pages = TextEditingController();
  final _isbn = TextEditingController();
  final _summary = TextEditingController();
  final _notes = TextEditingController();
  final _tagInput = TextEditingController();
  final _pairingInput = TextEditingController();

  late WorkType _type;
  late WorkFormat _format;
  late ReadingStatus _status;
  late bool _isComplete;
  int? _rating;
  late List<String> _tags;
  late List<String> _pairings;
  List<String> _pairingSuggestions = const [];

  /// Lower-case names of tags marked as 18+, known or from the site.
  Set<String> _adultTags = const {};
  List<String> _fandomSuggestions = const [];
  List<String> _seriesSuggestions = const [];
  List<String> _authorSuggestions = const [];
  List<String> _tagSuggestions = kDefaultTags;
  List<String> _frequentTags = const [];
  bool _suggestionsRequested = false;
  bool _saving = false;

  /// Whether anything changed since opening (to confirm before leaving).
  bool _dirty = false;

  AppDatabase get _db => DatabaseScope.of(context);

  List<TextEditingController> get _controllers => [
    _title,
    _author,
    _fandom,
    _series,
    _seriesIndex,
    _url,
    _chapters,
    _currentChapter,
    _words,
    _pages,
    _isbn,
    _summary,
    _notes,
    _tagInput,
    _pairingInput,
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final w = existing?.work;
    _type = w?.type ?? WorkType.fanfiction;
    _format = w?.format ?? _type.defaultFormat;
    _status = w?.status ?? ReadingStatus.planned;
    _isComplete = w?.isComplete ?? false;
    _rating = w?.rating;
    _tags = [for (final t in existing?.tags ?? const <Tag>[]) t.name];
    _pairings = [
      for (final p in existing?.pairings ?? const <Pairing>[]) p.name,
    ];
    _adultTags = {
      for (final t in existing?.tags ?? const <Tag>[])
        if (t.isAdult) t.name.toLowerCase(),
    };
    _title.text = w?.title ?? '';
    _author.text = w?.author ?? '';
    _fandom.text = existing?.fandom?.name ?? '';
    _series.text = existing?.series?.name ?? '';
    _seriesIndex.text = _formatIndex(w?.seriesIndex);
    _url.text = w?.sourceUrl ?? '';
    _chapters.text = w?.chapterCount?.toString() ?? '';
    _currentChapter.text = w?.currentChapter?.toString() ?? '';
    _words.text = w?.wordCount?.toString() ?? '';
    _pages.text = w?.pageCount?.toString() ?? '';
    _isbn.text = w?.isbn ?? '';
    _summary.text = w?.summary ?? '';
    _notes.text = w?.notes ?? '';
    if (widget.imported case final info?) _prefill(info);
    if (widget.file case final file?) _prefillFile(file.book);
    if (widget.details case final d?) {
      _type = WorkType.book;
      _format = WorkFormat.physical;
      _isComplete = true;
      _applyDetails(d);
      _dirty = true;
    }
    _initialWords = _words.text;
    _initialPages = _pages.text;
  }

  late final String _initialWords;
  late final String _initialPages;

  void _prefill(StoryInfo info) {
    _type = info.type;
    _format = WorkFormat.online;
    _isComplete = info.isComplete ?? false;
    _tags = TagInput.merge(const [], info.tags.join(','));
    _pairings = TagInput.merge(const [], info.pairings.join(','));
    _adultTags = {
      ..._adultTags,
      for (final t in info.adultTags) t.toLowerCase(),
    };
    _title.text = info.title;
    _author.text = info.author ?? '';
    _fandom.text = info.fandom ?? '';
    _series.text = info.series?.name ?? '';
    _seriesIndex.text = _formatIndex(info.series?.index);
    _url.text = info.url.toString();
    _chapters.text = '${info.chapterCount}';
    _words.text = info.wordCount?.toString() ?? '';
    _pages.text = info.pageCount?.toString() ?? '';
    _summary.text = info.summary ?? '';
    // Not saved yet, so leaving should ask first.
    _dirty = true;
  }

  /// Cover found by the ISBN lookup, saved with the entry.
  Uri? _coverUrl;
  bool _lookingUp = false;

  /// Fills the empty fields from [d]; what the user typed stays.
  void _applyDetails(BookDetails d) {
    void fill(TextEditingController c, String? value) {
      if (c.text.trim().isEmpty && value != null) c.text = value;
    }

    fill(_title, d.title);
    fill(_author, d.author);
    fill(_summary, d.summary);
    fill(_pages, d.pageCount?.toString());
    fill(_isbn, d.isbn);
    if (_tags.isEmpty) _tags = TagInput.merge(const [], d.tags.join(','));
    _coverUrl ??= d.coverUrl;
  }

  Future<void> _lookUpIsbn() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final isbn = isbnOf(_isbn.text);
    if (isbn == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.isbnInvalid)));
      return;
    }
    setState(() => _lookingUp = true);
    final fetcher = HttpFetcher();
    try {
      final details = await lookupIsbn(isbn, fetcher);
      if (!mounted) return;
      if (details == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.isbnNotFound)));
      } else {
        _change(() => _applyDetails(details));
      }
    } on SourceException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.isbnLookupFailed(e.message))),
      );
    } finally {
      await fetcher.close();
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  void _prefillFile(ImportedBook book) {
    final m = BookImporter.metadataOf(book);
    _type = m.type.value;
    _format = WorkFormat.digital;
    _isComplete = true;
    _tags = TagInput.merge(const [], book.tags.join(','));
    _title.text = book.title;
    _author.text = book.author ?? '';
    _url.text = book.sourceUrl ?? '';
    _isbn.text = book.isbn ?? '';
    _summary.text = book.summary ?? '';
    _chapters.text = '${book.chapters.length}';
    _words.text =
        '${[for (final c in book.chapters) countWords(htmlToPlainText(c.html))].fold<int>(0, (a, b) => a + b)}';
    _dirty = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_suggestionsRequested) {
      _suggestionsRequested = true;
      _loadSuggestions();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final fandoms = await _db.fandomNames();
    final seriesNames = await _db.seriesNames();
    final authors = await _db.authorNames();
    final tags = await _db.tagNames();
    final frequent = await _db.frequentTags();
    final allTags = await _db.allTags();
    final pairings = await _db.pairingNames();
    if (!mounted) return;
    setState(() {
      _pairingSuggestions = pairings;
      _adultTags = {
        ..._adultTags,
        for (final t in allTags)
          if (t.isAdult) t.name.toLowerCase(),
      };
      _fandomSuggestions = fandoms;
      _seriesSuggestions = seriesNames;
      _authorSuggestions = authors;
      _frequentTags = frequent;
      _tagSuggestions = TagInput.merge(tags, kDefaultTags.join(','))
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  /// Adult tags are hidden while the setting is on.
  bool _isHiddenTag(String tag) =>
      (SettingsScope.maybeOf(context)?.hideAdultTags ?? false) &&
      (_adultTags.contains(tag.toLowerCase()) || looksAdult(tag));

  /// Lets the user pick one of [options] for the field [controller].
  Future<void> _pickInto(
    TextEditingController controller,
    String title,
    List<String> options,
  ) async {
    final picked = await pickValues(
      context,
      title: title,
      options: options,
      selected: [if (controller.text.trim().isNotEmpty) controller.text.trim()],
      multiple: false,
    );
    if (picked != null && picked.isNotEmpty) {
      _change(() => controller.text = picked.single);
    }
  }

  Widget _pickButton(VoidCallback onPressed) => IconButton(
    icon: const Icon(Icons.checklist),
    tooltip: context.l10n.chooseExisting,
    onPressed: onPressed,
  );

  /// Changes state and records that there are unsaved changes.
  void _change(VoidCallback fn) => setState(() {
    fn();
    _dirty = true;
  });

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  static String _formatIndex(double? i) => i == null
      ? ''
      : i == i.roundToDouble()
      ? '${i.round()}'
      : '$i';

  /// "3", "2.5" or "2,5".
  static double? _parseIndex(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  /// Accepts input like "45,300", "45.300" or "45 300".
  static int? _parseInt(String raw) =>
      int.tryParse(raw.replaceAll(RegExp(r'[.,\s]'), ''));

  static String? _normalizeUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    return s.contains('://') ? s : 'https://$s';
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    // Include a tag that was typed but not confirmed yet.
    final tags = TagInput.merge(_tags, _tagInput.text);
    final pairings = TagInput.merge(_pairings, _pairingInput.text);
    final w = widget.existing?.work;
    final data = WorksCompanion(
      id: w == null ? const Value.absent() : Value(w.id),
      type: Value(_type),
      format: Value(_format),
      title: Value(_title.text.trim()),
      author: Value(_text(_author)),
      summary: Value(_text(_summary)),
      isbn: Value(_text(_isbn)?.replaceAll(RegExp(r'[-\s]'), '')),
      sourceUrl: Value(_normalizeUrl(_url.text)),
      status: Value(_status),
      isComplete: Value(_isComplete),
      chapterCount: Value(_parseInt(_chapters.text)),
      currentChapter: Value(_parseInt(_currentChapter.text)),
      wordCount: Value(_parseInt(_words.text)),
      pageCount: Value(_parseInt(_pages.text)),
      // A number the user typed is theirs; an unchanged estimate stays one.
      wordsEstimated: _words.text == _initialWords
          ? const Value.absent()
          : const Value(false),
      pagesEstimated: _pages.text == _initialPages
          ? const Value.absent()
          : const Value(false),
      characterCount: widget.imported?.characterCount == null
          ? const Value.absent()
          : Value(widget.imported!.characterCount),
      rating: Value(_rating),
      notes: Value(_text(_notes)),
      seriesIndex: Value(
        _series.text.trim().isEmpty ? null : _parseIndex(_seriesIndex.text),
      ),
      coverUrl: switch (widget.imported?.coverUrl ?? _coverUrl) {
        final cover? => Value(cover.toString()),
        null => const Value.absent(),
      },
      checkedAt: widget.imported == null
          ? const Value.absent()
          : Value(DateTime.now()),
      lastChapterAt: switch (widget.imported?.updatedOn) {
        final date? => Value(date),
        null => const Value.absent(),
      },
    );
    final int id;
    try {
      final file = widget.file;
      id = file != null
          ? await BookImporter(_db, LibraryScope.of(context).storage).store(
              file.book,
              original: File(file.path),
              work: data,
              fandomName: _fandom.text,
              seriesName: _series.text,
              tagNames: tags,
              pairingNames: pairings,
            )
          : await _db.saveWork(
              data,
              fandomName: _fandom.text,
              seriesName: _series.text,
              tagNames: tags,
              pairingNames: pairings,
              adultTags: widget.imported?.adultTags ?? const {},
            );
      if (widget.imported case final info?) {
        await _db.saveChapterList(id, chapterListing(info));
      }
      await _db.fillMissingCounts(id);
    } catch (e, stack) {
      logError('save', 'Saving an entry failed', error: e, stack: stack);
      // Never leave the button stuck without saying why.
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveFailed('$e'))));
      }
      return;
    }
    // Navigator.pop bypasses PopScope, so there is no prompt after saving.
    if (mounted) Navigator.of(context).pop(id);
  }

  Future<void> _confirmDiscard() async {
    final l10n = context.l10n;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardTitle),
        content: Text(l10n.discardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  InputDecoration _decoration(String label, {String? hint}) =>
      InputDecoration(labelText: label, hintText: hint);

  Widget _numberField(
    AppLocalizations l10n,
    TextEditingController controller,
    String label,
  ) => TextFormField(
    controller: controller,
    decoration: _decoration(label),
    keyboardType: TextInputType.number,
    validator: (v) => v == null || v.trim().isEmpty || _parseInt(v) != null
        ? null
        : l10n.numbersOnly,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.existing == null ? l10n.newEntry : l10n.editEntry,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            onChanged: () {
              if (!_dirty) setState(() => _dirty = true);
            },
            child: LayoutBuilder(
              builder: (context, constraints) => ListView(
                padding: readablePadding(
                  constraints.maxWidth,
                  top: 8,
                  bottom: 32,
                ),
                children: _buildFields(l10n),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields(AppLocalizations l10n) {
    const gap = SizedBox(height: 16);
    final hasIsbn = const {
      WorkType.book,
      WorkType.manga,
      WorkType.comic,
    }.contains(_type);

    final imported = widget.imported;
    final file = widget.file;
    return [
      if (file != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card.filled(
            child: ListTile(
              leading: const Icon(Icons.file_present_outlined),
              title: Text(
                l10n.importingFromFile(
                  file.path.split(Platform.pathSeparator).last,
                ),
              ),
              subtitle: Text(
                l10n.importedFileSummary(
                  file.book.format.label,
                  file.book.chapters.length,
                ),
              ),
            ),
          ),
        ),
      if (imported != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card.filled(
            child: ListTile(
              leading: const Icon(Icons.cloud_done_outlined),
              title: Text(l10n.importedFrom(imported.siteName)),
              subtitle: Text(l10n.importedSummary(imported.chapterCount)),
            ),
          ),
        ),
      DropdownButtonFormField<WorkType>(
        initialValue: _type,
        decoration: _decoration(l10n.fieldType),
        items: [
          for (final t in WorkType.values)
            DropdownMenuItem(
              value: t,
              child: Row(
                children: [
                  Icon(t.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(t.label(l10n)),
                ],
              ),
            ),
        ],
        onChanged: (t) {
          if (t == null) return;
          _change(() {
            _type = t;
            _format = t.defaultFormat;
          });
        },
      ),
      gap,
      SegmentedButton<WorkFormat>(
        segments: [
          for (final f in WorkFormat.values)
            ButtonSegment(
              value: f,
              icon: Icon(f.icon),
              label: Text(f.label(l10n)),
            ),
        ],
        selected: {_format},
        onSelectionChanged: (s) => _change(() => _format = s.first),
      ),
      gap,
      TextFormField(
        controller: _title,
        decoration: _decoration(l10n.fieldTitle),
        textCapitalization: TextCapitalization.sentences,
        autofocus: widget.existing == null,
        validator: (v) =>
            v == null || v.trim().isEmpty ? l10n.titleRequired : null,
      ),
      gap,
      SuggestField(
        controller: _author,
        suggestions: _authorSuggestions,
        decoration: _decoration(l10n.fieldAuthor).copyWith(
          suffixIcon: _pickButton(
            () => _pickInto(_author, l10n.pickAuthor, _authorSuggestions),
          ),
        ),
      ),
      gap,
      SuggestField(
        controller: _fandom,
        suggestions: _fandomSuggestions,
        decoration:
            _decoration(
              l10n.fieldCategory,
              hint: l10n.fieldCategoryHint,
            ).copyWith(
              suffixIcon: _pickButton(
                () => _pickInto(_fandom, l10n.pickCategory, _fandomSuggestions),
              ),
            ),
      ),
      gap,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SuggestField(
              controller: _series,
              suggestions: _seriesSuggestions,
              decoration:
                  _decoration(
                    l10n.fieldSeries,
                    hint: l10n.fieldSeriesHint,
                  ).copyWith(
                    suffixIcon: _pickButton(
                      () => _pickInto(
                        _series,
                        l10n.pickSeries,
                        _seriesSuggestions,
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _seriesIndex,
              decoration: _decoration(l10n.fieldSeriesIndex),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty || _parseIndex(v) != null
                  ? null
                  : l10n.numbersOnly,
            ),
          ),
        ],
      ),
      gap,
      TextFormField(
        controller: _url,
        decoration: _decoration(l10n.fieldLink, hint: l10n.fieldLinkHint),
        keyboardType: TextInputType.url,
        validator: (v) {
          final url = _normalizeUrl(v ?? '');
          if (url == null) return null;
          final uri = Uri.tryParse(url);
          return uri == null || uri.host.isEmpty ? l10n.invalidLink : null;
        },
      ),
      gap,
      DropdownButtonFormField<ReadingStatus>(
        initialValue: _status,
        decoration: _decoration(l10n.fieldStatus),
        items: [
          for (final s in ReadingStatus.values)
            DropdownMenuItem(
              value: s,
              child: Row(
                children: [
                  Icon(s.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(s.label(l10n)),
                ],
              ),
            ),
        ],
        onChanged: (s) => _change(() => _status = s ?? _status),
      ),
      _Heading(l10n.sectionLength),
      Row(
        children: [
          Expanded(child: _numberField(l10n, _chapters, l10n.fieldChapters)),
          const SizedBox(width: 12),
          Expanded(
            child: _numberField(
              l10n,
              _currentChapter,
              l10n.fieldCurrentChapter,
            ),
          ),
        ],
      ),
      gap,
      Row(
        children: [
          Expanded(child: _numberField(l10n, _words, l10n.fieldWords)),
          const SizedBox(width: 12),
          Expanded(child: _numberField(l10n, _pages, l10n.fieldPages)),
        ],
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.completeTitle),
        subtitle: Text(l10n.completeSubtitle),
        value: _isComplete,
        onChanged: (v) => _change(() => _isComplete = v),
      ),
      if (hasIsbn) ...[
        const SizedBox(height: 8),
        TextFormField(
          controller: _isbn,
          decoration: _decoration(l10n.fieldIsbn).copyWith(
            suffixIcon: _lookingUp
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.manage_search),
                    tooltip: l10n.isbnLookUp,
                    onPressed: _lookUpIsbn,
                  ),
          ),
          keyboardType: TextInputType.number,
          onFieldSubmitted: (_) => _lookUpIsbn(),
        ),
      ],
      _Heading(l10n.sectionTags),
      TagInput(
        controller: _tagInput,
        tags: _tags,
        suggestions: [
          for (final t in _tagSuggestions)
            if (!_isHiddenTag(t)) t,
        ],
        frequent: [
          for (final t in _frequentTags)
            if (!_isHiddenTag(t)) t,
        ],
        isHidden: _isHiddenTag,
        onChanged: (tags) => _change(() => _tags = tags),
      ),
      _Heading(l10n.sectionPairings),
      TagInput(
        controller: _pairingInput,
        tags: _pairings,
        suggestions: _pairingSuggestions,
        label: l10n.addPairing,
        hint: l10n.addPairingHint,
        pickerTitle: l10n.pickPairings,
        onChanged: (pairings) => _change(() => _pairings = pairings),
      ),
      _Heading(l10n.sectionRating),
      Row(
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              icon: Icon(
                _rating != null && i <= _rating!
                    ? Icons.star
                    : Icons.star_border,
              ),
              tooltip: l10n.starTooltip(i),
              // Tapping the same star again clears the rating.
              onPressed: () => _change(() => _rating = _rating == i ? null : i),
            ),
        ],
      ),
      _Heading(l10n.sectionDescription),
      TextFormField(
        controller: _summary,
        decoration: _decoration(l10n.fieldSummary),
        minLines: 3,
        maxLines: null,
      ),
      gap,
      TextFormField(
        controller: _notes,
        decoration: _decoration(l10n.fieldNotes),
        minLines: 2,
        maxLines: null,
      ),
    ];
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
