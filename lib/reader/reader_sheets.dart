import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/l10n.dart';
import '../ui/app_settings.dart';

/// Bottom sheet with the reader's text settings; changes apply right away.
class ReaderSettingsSheet extends StatefulWidget {
  const ReaderSettingsSheet({
    super.key,
    required this.prefs,
    required this.onChanged,
  });

  final ReaderPrefs prefs;
  final ValueChanged<ReaderPrefs> onChanged;

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  late ReaderPrefs _prefs = widget.prefs;

  void _set(ReaderPrefs prefs) {
    setState(() => _prefs = prefs);
    widget.onChanged(prefs);
  }

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
              selected: {_prefs.font},
              onSelectionChanged: (s) => _set(_prefs.copyWith(font: s.first)),
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
                      backgroundColor:
                          t.background ?? theme.colorScheme.surface,
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 12,
                          color: t.text ?? theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    label: Text(switch (t) {
                      ReaderTheme.app => l10n.readerThemeApp,
                      ReaderTheme.light => l10n.readerThemeLight,
                      ReaderTheme.sepia => l10n.readerThemeSepia,
                      ReaderTheme.dark => l10n.readerThemeDark,
                      ReaderTheme.black => l10n.readerThemeBlack,
                    }),
                    selected: _prefs.theme == t,
                    onSelected: (_) => _set(_prefs.copyWith(theme: t)),
                  ),
              ],
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
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initial == null ? l10n.addNote : l10n.editNote),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quote != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '„$quote“',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(hintText: l10n.noteHint),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
