import 'package:flutter/material.dart';

/// Textfeld, das beim Tippen passende Vorschläge anzeigt.
class SuggestField extends StatefulWidget {
  const SuggestField({
    super.key,
    required this.controller,
    required this.suggestions,
    this.decoration,
    this.onSubmitted,
    this.onSelected,
    this.onChanged,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final InputDecoration? decoration;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onChanged;

  @override
  State<SuggestField> createState() => _SuggestFieldState();
}

class _SuggestFieldState extends State<SuggestField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const [];
        return widget.suggestions
            .where((s) {
              final lower = s.toLowerCase();
              return lower.contains(query) && lower != query;
            })
            .take(8);
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, _) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: widget.decoration,
        textCapitalization: TextCapitalization.words,
        onChanged: widget.onChanged,
        // Mit eigenem onSubmitted bleibt der Fokus im Feld, damit man
        // mehrere Einträge (z. B. Tags) nacheinander tippen kann.
        onEditingComplete: widget.onSubmitted == null ? null : () {},
        onFieldSubmitted: widget.onSubmitted,
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
