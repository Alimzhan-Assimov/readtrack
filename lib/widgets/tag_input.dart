import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'suggest_field.dart';
import 'value_picker.dart';

/// Input for a list of names such as tags: Enter, a comma or a suggestion
/// adds one; the list button picks from all existing values, and
/// [frequent] values can be added with a tap.
class TagInput extends StatelessWidget {
  const TagInput({
    super.key,
    required this.controller,
    required this.tags,
    required this.suggestions,
    required this.onChanged,
    this.frequent = const [],
    this.label,
    this.hint,
    this.pickerTitle,
  });

  final TextEditingController controller;
  final List<String> tags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;

  /// Often used values, offered as one-tap chips.
  final List<String> frequent;

  /// Defaults to the texts for tags.
  final String? label;
  final String? hint;
  final String? pickerTitle;

  /// Adds the (comma-separated) tags in [raw] to [tags], skipping duplicates.
  static List<String> merge(List<String> tags, String raw) {
    final result = [...tags];
    for (final part in raw.split(',')) {
      final name = part.trim();
      final exists = result.any((t) => t.toLowerCase() == name.toLowerCase());
      if (name.isNotEmpty && !exists) result.add(name);
    }
    return result;
  }

  bool _has(String value) =>
      tags.any((t) => t.toLowerCase() == value.toLowerCase());

  void _add(String raw) {
    final next = merge(tags, raw);
    controller.clear();
    if (next.length != tags.length) onChanged(next);
  }

  Future<void> _browse(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await pickValues(
      context,
      title: pickerTitle ?? l10n.pickTags,
      options: suggestions,
      selected: tags,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = [
      for (final s in suggestions)
        if (!_has(s)) s,
    ];
    final quick = [
      for (final f in frequent)
        if (!_has(f)) f,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SuggestField(
          controller: controller,
          suggestions: available,
          decoration: InputDecoration(
            labelText: label ?? l10n.addTag,
            hintText: hint ?? l10n.addTagHint,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  tooltip: l10n.chooseExisting,
                  onPressed: () => _browse(context),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: label ?? l10n.addTag,
                  onPressed: () => _add(controller.text),
                ),
              ],
            ),
          ),
          onSubmitted: _add,
          onSelected: _add,
          onChanged: (value) {
            if (value.contains(',')) _add(value);
          },
        ),
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final tag in tags)
                  InputChip(
                    label: Text(tag),
                    onDeleted: () => onChanged([...tags]..remove(tag)),
                  ),
              ],
            ),
          ),
        if (quick.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.frequentlyUsed,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                for (final value in quick)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(value),
                    onPressed: () => _add(value),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
