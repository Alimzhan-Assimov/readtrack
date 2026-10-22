import 'package:flutter/material.dart';

import 'suggest_field.dart';

/// Eingabe für Tags: Enter, Komma oder ein Vorschlag fügt einen Tag hinzu.
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

  /// Fügt die (kommagetrennten) Tags aus [raw] zu [tags] hinzu, ohne Duplikate.
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
            labelText: 'Tag hinzufügen',
            hintText: 'z. B. Action, Harem, Kingdom Building',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Tag hinzufügen',
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
