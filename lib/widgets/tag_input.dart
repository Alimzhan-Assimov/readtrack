import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'suggest_field.dart';

/// Tag input: Enter, a comma or picking a suggestion adds a tag.
class TagInput extends StatelessWidget {
  const TagInput({
    super.key,
    required this.controller,
    required this.tags,
    required this.suggestions,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<String> tags;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;

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

  void _add(String raw) {
    final next = merge(tags, raw);
    controller.clear();
    if (next.length != tags.length) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = suggestions
        .where((s) => !tags.any((t) => t.toLowerCase() == s.toLowerCase()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SuggestField(
          controller: controller,
          suggestions: available,
          decoration: InputDecoration(
            labelText: l10n.addTag,
            hintText: l10n.addTagHint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.addTag,
              onPressed: () => _add(controller.text),
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
      ],
    );
  }
}
