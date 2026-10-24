import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/l10n.dart';
import '../ui/app_settings.dart';
import '../ui/fonts.dart';
import '../ui/layout.dart';
import '../widgets/text_prompt.dart';

/// Bottom sheet with the reader's text settings; changes apply right away.
class ReaderSettingsSheet extends StatefulWidget {
  const ReaderSettingsSheet({
    super.key,
    required this.prefs,
    required this.onChanged,
    this.fonts = installedFontFamilies,
  });

  final ReaderPrefs prefs;
  final ValueChanged<ReaderPrefs> onChanged;

  /// Font families offered under "Other font".
  final Future<List<String>> Function() fonts;

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  late ReaderPrefs _prefs = widget.prefs;

  void _set(ReaderPrefs prefs) {
    setState(() => _prefs = prefs);
    widget.onChanged(prefs);
  }

  Future<void> _pickFont() async {
    final family = await showDialog<String>(
      context: context,
      builder: (_) =>
          _FontPicker(families: widget.fonts(), current: _prefs.fontFamily),
    );
    if (family != null && mounted) {
      _set(_prefs.copyWith(fontFamily: family));
    }
  }

  // Slider steps of 100 up to 1600; one more step means the whole window.
  static const _minWidth = 400.0, _maxWidth = 1600.0, _widthStep = 100.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: theme.textTheme.labelLarge),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.readerSettings, style: theme.textTheme.titleMedium),
            label(l10n.readerTextSize),
            Row(
              children: [
                IconButton.outlined(
                  icon: const Icon(Icons.text_decrease),
                  tooltip: l10n.readerSmaller,
                  onPressed: _prefs.fontSize <= 12
                      ? null
                      : () => _set(
                          _prefs.copyWith(fontSize: _prefs.fontSize - 1),
                        ),
                ),
                Expanded(
                  child: Slider(
                    min: 12,
                    max: 36,
                    divisions: 24,
                    value: _prefs.fontSize.clamp(12, 36),
                    label: '${_prefs.fontSize.round()}',
                    onChanged: (v) => _set(_prefs.copyWith(fontSize: v)),
                  ),
                ),
                IconButton.outlined(
                  icon: const Icon(Icons.text_increase),
                  tooltip: l10n.readerLarger,
                  onPressed: _prefs.fontSize >= 36
                      ? null
                      : () => _set(
                          _prefs.copyWith(fontSize: _prefs.fontSize + 1),
                        ),
                ),
              ],
            ),
            label(l10n.readerFont),
            SegmentedButton<ReaderFont>(
              segments: [
                for (final f in ReaderFont.values)
                  ButtonSegment(
                    value: f,
                    label: Text(switch (f) {
                      ReaderFont.system => l10n.readerFontSystem,
                      ReaderFont.serif => l10n.readerFontSerif,
                      ReaderFont.sans => l10n.readerFontSans,
                      ReaderFont.mono => l10n.readerFontMono,
                    }, style: TextStyle(fontFamily: f.family)),
                  ),
              ],
              emptySelectionAllowed: true,
              selected: {if (_prefs.fontFamily == null) _prefs.font},
              onSelectionChanged: (s) {
                if (s.isEmpty) return;
                _set(_prefs.copyWith(font: s.first, clearFontFamily: true));
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.font_download_outlined),
              label: Text(
                _prefs.fontFamily ?? l10n.readerFontOther,
                style: TextStyle(fontFamily: _prefs.fontFamily),
              ),
              onPressed: _pickFont,
            ),
            label(l10n.readerLineSpacing),
            SegmentedButton<double>(
              segments: [
                for (final h in const [1.3, 1.6, 1.9, 2.2])
                  ButtonSegment(value: h, label: Text(h.toStringAsFixed(1))),
              ],
              selected: {_prefs.lineHeight},
              onSelectionChanged: (s) =>
                  _set(_prefs.copyWith(lineHeight: s.first)),
            ),
            label(l10n.readerTheme),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in ReaderTheme.values)
                  ChoiceChip(
                    avatar: CircleAvatar(
                      backgroundColor: t == ReaderTheme.custom
                          ? _prefs.background
                          : t.background ?? theme.colorScheme.surface,
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 12,
                          color: t == ReaderTheme.custom
                              ? _prefs.textColor
                              : t.text ?? theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    label: Text(switch (t) {
                      ReaderTheme.app => l10n.readerThemeApp,
                      ReaderTheme.light => l10n.readerThemeLight,
                      ReaderTheme.sepia => l10n.readerThemeSepia,
                      ReaderTheme.dark => l10n.readerThemeDark,
                      ReaderTheme.black => l10n.readerThemeBlack,
                      ReaderTheme.custom => l10n.readerThemeCustom,
                    }),
                    selected: _prefs.theme == t,
                    onSelected: (_) => _set(_prefs.copyWith(theme: t)),
                  ),
              ],
            ),
            if (_prefs.theme == ReaderTheme.custom)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _HexColorField(
                        label: l10n.readerBackgroundColor,
                        color: _prefs.background,
                        onChanged: (c) => _set(_prefs.copyWith(background: c)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HexColorField(
                        label: l10n.readerTextColor,
                        color: _prefs.textColor,
                        onChanged: (c) => _set(_prefs.copyWith(textColor: c)),
                      ),
                    ),
                  ],
                ),
              ),
            label(l10n.readerTextWidth),
            Slider(
              min: _minWidth,
              max: _maxWidth + _widthStep,
              divisions: (_maxWidth - _minWidth) ~/ _widthStep + 1,
              value: _prefs.textWidth.isFinite
                  ? _prefs.textWidth.clamp(_minWidth, _maxWidth)
                  : _maxWidth + _widthStep,
              label: _prefs.textWidth.isFinite
                  ? '${_prefs.textWidth.round()}'
                  : l10n.readerWidthFull,
              onChanged: (v) => _set(
                _prefs.copyWith(textWidth: v > _maxWidth ? double.infinity : v),
              ),
            ),
            if (_prefs.textWidth != kReadableWidth)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      _set(_prefs.copyWith(textWidth: kReadableWidth)),
                  child: Text(l10n.readerWidthReset),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.readerJustify),
              value: _prefs.justify,
              onChanged: (v) => _set(_prefs.copyWith(justify: v)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A hex color input with a swatch; reports only valid colors.
class _HexColorField extends StatefulWidget {
  const _HexColorField({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  State<_HexColorField> createState() => _HexColorFieldState();
}

class _HexColorFieldState extends State<_HexColorField> {
  late final _controller = TextEditingController(
    text: hexOfColor(widget.color),
  );
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: '#RRGGBB',
        errorText: _invalid ? context.l10n.readerHexInvalid : null,
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: const SizedBox.square(dimension: 20),
          ),
        ),
      ),
      onChanged: (text) {
        final color = parseHexColor(text);
        setState(() => _invalid = color == null);
        if (color != null) widget.onChanged(color);
      },
    );
  }
}

/// Lists the installed fonts, each shown in itself; any typed name can be
/// used too. Returns the chosen family.
class _FontPicker extends StatefulWidget {
  const _FontPicker({required this.families, this.current});

  final Future<List<String>> families;
  final String? current;

  @override
  State<_FontPicker> createState() => _FontPickerState();
}

class _FontPickerState extends State<_FontPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _query.trim();
    return AlertDialog(
      title: Text(l10n.readerFontPick),
      content: SizedBox(
        width: 400,
        height: 480,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.readerFontSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) Navigator.pop(context, v.trim());
              },
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: widget.families,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final lower = query.toLowerCase();
                  final matches = [
                    for (final f in snapshot.data!)
                      if (f.toLowerCase().contains(lower)) f,
                  ];
                  final typed =
                      query.isNotEmpty &&
                      !matches.any((f) => f.toLowerCase() == lower);
                  if (matches.isEmpty && !typed) {
                    return Center(
                      child: Text(
                        l10n.readerFontNone,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      if (typed)
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(l10n.readerFontUse(query)),
                          onTap: () => Navigator.pop(context, query),
                        ),
                      for (final f in matches)
                        ListTile(
                          selected: f == widget.current,
                          title: Text(f, style: TextStyle(fontFamily: f)),
                          onTap: () => Navigator.pop(context, f),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

/// A work's bookmarks, quotes and notes. Tapping one returns it.
class AnnotationsSheet extends StatelessWidget {
  const AnnotationsSheet({
    super.key,
    required this.annotations,
    required this.chapterTitle,
    required this.onDelete,
    this.onEditNote,
  });

  final Stream<List<Annotation>> annotations;
  final String Function(int chapter) chapterTitle;
  final ValueChanged<Annotation> onDelete;
  final ValueChanged<Annotation>? onEditNote;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: StreamBuilder<List<Annotation>>(
        stream: annotations,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Annotation>[];
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.annotationsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.annotationsEmpty),
                ),
              for (final a in items)
                AnnotationTile(
                  annotation: a,
                  chapterTitle: chapterTitle(a.chapterNumber),
                  onTap: () => Navigator.pop(context, a),
                  onDelete: () => onDelete(a),
                  onEditNote: onEditNote == null ? null : () => onEditNote!(a),
                ),
            ],
          );
        },
      ),
    );
  }
}

class AnnotationTile extends StatelessWidget {
  const AnnotationTile({
    super.key,
    required this.annotation,
    required this.chapterTitle,
    required this.onTap,
    this.onDelete,
    this.onEditNote,
  });

  final Annotation annotation;
  final String chapterTitle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEditNote;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final a = annotation;
    return ListTile(
      leading: Icon(switch (a.kind) {
        AnnotationKind.bookmark => Icons.bookmark,
        AnnotationKind.quote => Icons.format_quote,
        AnnotationKind.note => Icons.sticky_note_2_outlined,
      }),
      title: Text(
        switch (a.kind) {
          AnnotationKind.bookmark => l10n.bookmarkAt((a.offset * 100).round()),
          _ => a.quote ?? a.note ?? '',
        },
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: a.kind == AnnotationKind.quote
            ? const TextStyle(fontStyle: FontStyle.italic)
            : null,
      ),
      subtitle: Text(
        [
          if (a.kind != AnnotationKind.bookmark &&
              a.quote != null &&
              a.note != null)
            a.note!,
          chapterTitle,
        ].join('\n'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      onTap: onTap,
      trailing: onDelete == null && onEditNote == null
          ? null
          : MenuAnchor(
              menuChildren: [
                if (onEditNote != null && a.kind != AnnotationKind.bookmark)
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_note),
                    onPressed: onEditNote,
                    child: Text(l10n.editNote),
                  ),
                if (onDelete != null)
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    child: Text(l10n.deleteTooltip),
                  ),
              ],
              builder: (context, controller, _) => IconButton(
                icon: const Icon(Icons.more_vert),
                tooltip: l10n.moreOptions,
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
              ),
            ),
    );
  }
}

/// Asks for a note's text; returns null when cancelled.
Future<String?> askForNote(
  BuildContext context, {
  String? initial,
  String? quote,
}) {
  final l10n = context.l10n;
  return showTextPrompt(
    context,
    title: initial == null ? l10n.addNote : l10n.editNote,
    hint: l10n.noteHint,
    initial: initial,
    multiline: true,
    header: quote == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '„$quote“',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
  );
}
