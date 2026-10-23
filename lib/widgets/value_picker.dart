import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// Opens a searchable list of existing [options]. With [multiple] the user
/// ticks any number and confirms; otherwise tapping one picks it. A search
/// that matches nothing can be added as a new value.
///
/// Returns the chosen values, or null if the sheet was dismissed.
Future<List<String>?> pickValues(
  BuildContext context, {
  required String title,
  required List<String> options,
  List<String> selected = const [],
  bool multiple = true,
}) => showModalBottomSheet<List<String>>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _ValuePicker(
    title: title,
    options: options,
    selected: selected,
    multiple: multiple,
  ),
);

class _ValuePicker extends StatefulWidget {
  const _ValuePicker({
    required this.title,
    required this.options,
    required this.selected,
    required this.multiple,
  });

  final String title;
  final List<String> options;
  final List<String> selected;
  final bool multiple;

  @override
  State<_ValuePicker> createState() => _ValuePickerState();
}

class _ValuePickerState extends State<_ValuePicker> {
  final _query = TextEditingController();
  late final List<String> _chosen = [...widget.selected];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _isChosen(String value) =>
      _chosen.any((c) => c.toLowerCase() == value.toLowerCase());

  void _toggle(String value) {
    if (!widget.multiple) {
      Navigator.pop(context, [value]);
      return;
    }
    setState(() {
      if (_isChosen(value)) {
        _chosen.removeWhere((c) => c.toLowerCase() == value.toLowerCase());
      } else {
        _chosen.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final query = _query.text.trim();
    final lower = query.toLowerCase();
    // Selected values that aren't options yet (e.g. just typed) stay visible.
    final all = {...widget.options, ..._chosen}.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final matches = [
      for (final o in all)
        if (o.toLowerCase().contains(lower)) o,
    ];
    final canAdd =
        query.isNotEmpty && !all.any((o) => o.toLowerCase() == lower);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: theme.textTheme.titleMedium),
                ),
                if (widget.multiple)
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _chosen),
                    child: Text(l10n.pickerDone),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _query,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.pickerSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (canAdd) {
                  _toggle(query);
                  _query.clear();
                  setState(() {});
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                if (canAdd)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(l10n.pickerAdd(query)),
                    onTap: () {
                      _toggle(query);
                      _query.clear();
                      setState(() {});
                    },
                  ),
                if (matches.isEmpty && !canAdd)
                  ListTile(enabled: false, title: Text(l10n.pickerEmpty)),
                for (final option in matches)
                  widget.multiple
                      ? CheckboxListTile(
                          value: _isChosen(option),
                          title: Text(option),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (_) => _toggle(option),
                        )
                      : ListTile(
                          title: Text(option),
                          selected: _isChosen(option),
                          trailing: _isChosen(option)
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => _toggle(option),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
