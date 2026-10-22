import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../data/default_tags.dart';
import '../l10n/l10n.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/suggest_field.dart';
import '../widgets/tag_input.dart';

/// Form for creating ([existing] == null) or editing a work.
/// Pops with the work's id as the result after saving.
class WorkEditScreen extends StatefulWidget {
  const WorkEditScreen({super.key, this.existing});

  final WorkWithDetails? existing;

  @override
  State<WorkEditScreen> createState() => _WorkEditScreenState();
}

class _WorkEditScreenState extends State<WorkEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _fandom = TextEditingController();
  final _url = TextEditingController();
  final _chapters = TextEditingController();
  final _currentChapter = TextEditingController();
  final _words = TextEditingController();
  final _pages = TextEditingController();
  final _isbn = TextEditingController();
  final _summary = TextEditingController();
  final _notes = TextEditingController();
  final _tagInput = TextEditingController();

  late WorkType _type;
  late WorkFormat _format;
  late ReadingStatus _status;
  late bool _isComplete;
  int? _rating;
  late List<String> _tags;
  List<String> _fandomSuggestions = const [];
  List<String> _tagSuggestions = kDefaultTags;
  bool _suggestionsRequested = false;
  bool _saving = false;

  /// Whether anything changed since opening (to confirm before leaving).
  bool _dirty = false;

  AppDatabase get _db => DatabaseScope.of(context);

  List<TextEditingController> get _controllers => [
    _title,
    _author,
    _fandom,
    _url,
    _chapters,
    _currentChapter,
    _words,
    _pages,
    _isbn,
    _summary,
    _notes,
    _tagInput,
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
    _title.text = w?.title ?? '';
    _author.text = w?.author ?? '';
    _fandom.text = existing?.fandom?.name ?? '';
    _url.text = w?.sourceUrl ?? '';
    _chapters.text = w?.chapterCount?.toString() ?? '';
    _currentChapter.text = w?.currentChapter?.toString() ?? '';
    _words.text = w?.wordCount?.toString() ?? '';
    _pages.text = w?.pageCount?.toString() ?? '';
    _isbn.text = w?.isbn ?? '';
    _summary.text = w?.summary ?? '';
    _notes.text = w?.notes ?? '';
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
    final tags = await _db.tagNames();
    if (!mounted) return;
    setState(() {
      _fandomSuggestions = fandoms;
      _tagSuggestions = TagInput.merge(tags, kDefaultTags.join(','))
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  /// Changes state and records that there are unsaved changes.
  void _change(VoidCallback fn) => setState(() {
    fn();
    _dirty = true;
  });

  static String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

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
      rating: Value(_rating),
      notes: Value(_text(_notes)),
    );
    final id = await _db.saveWork(
      data,
      fandomName: _fandom.text,
      tagNames: tags,
    );
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

    return [
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
      TextFormField(
        controller: _author,
        decoration: _decoration(l10n.fieldAuthor),
        textCapitalization: TextCapitalization.words,
      ),
      gap,
      SuggestField(
        controller: _fandom,
        suggestions: _fandomSuggestions,
        decoration: _decoration(
          l10n.fieldCategory,
          hint: l10n.fieldCategoryHint,
        ),
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
          decoration: _decoration(l10n.fieldIsbn),
          keyboardType: TextInputType.number,
        ),
      ],
      _Heading(l10n.sectionTags),
      TagInput(
        controller: _tagInput,
        tags: _tags,
        suggestions: _tagSuggestions,
        onChanged: (tags) => _change(() => _tags = tags),
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
