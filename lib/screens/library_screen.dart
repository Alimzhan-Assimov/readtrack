import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../ui/labels.dart';
import '../widgets/work_tile.dart';
import 'work_edit_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _search = TextEditingController();
  WorkType? _type;
  Fandom? _fandom;
  Tag? _tag;
  late Stream<List<WorkWithDetails>> _works;

  AppDatabase get _db => DatabaseScope.of(context);

  bool get _isFiltered =>
      _search.text.trim().isNotEmpty ||
      _type != null ||
      _fandom != null ||
      _tag != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateQuery();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _updateQuery() {
    _works = _db.watchWorks(
      search: _search.text,
      type: _type,
      fandomId: _fandom?.id,
      tagId: _tag?.id,
    );
  }

  void _setFilter(VoidCallback change) => setState(() {
    change();
    _updateQuery();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Bibliothek')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _search,
              hintText: 'Titel, Autor oder Kategorie suchen',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (_) => _setFilter(() {}),
              trailing: [
                if (_search.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Suche leeren',
                    onPressed: () => _setFilter(_search.clear),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _PickerChip<Fandom>(
                  icon: Icons.category_outlined,
                  emptyLabel: 'Kategorie',
                  selected: _fandom,
                  loadOptions: _db.usedFandoms,
                  nameOf: (f) => f.name,
                  onSelected: (f) => _setFilter(() => _fandom = f),
                ),
                const SizedBox(width: 8),
                _PickerChip<Tag>(
                  icon: Icons.sell_outlined,
                  emptyLabel: 'Tag',
                  selected: _tag,
                  loadOptions: _db.usedTags,
                  nameOf: (t) => t.name,
                  onSelected: (t) => _setFilter(() => _tag = t),
                ),
                const VerticalDivider(indent: 12, endIndent: 12, width: 24),
                ChoiceChip(
                  label: const Text('Alle'),
                  selected: _type == null,
                  onSelected: (_) => _setFilter(() => _type = null),
                ),
                for (final t in WorkType.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(t.icon, size: 18),
                    showCheckmark: false,
                    label: Text(t.label),
                    selected: _type == t,
                    onSelected: (sel) =>
                        _setFilter(() => _type = sel ? t : null),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<WorkWithDetails>>(
              stream: _works,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                }
                final items = snapshot.data;
                if (items == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) return _EmptyState(filtered: _isFiltered);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                  itemCount: items.length,
                  itemBuilder: (context, i) => WorkTile(item: items[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const WorkEditScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Hinzufügen'),
      ),
    );
  }
}

/// Filter-Chip, der beim Antippen eine Auswahlliste öffnet.
class _PickerChip<T> extends StatelessWidget {
  const _PickerChip({
    required this.icon,
    required this.emptyLabel,
    required this.selected,
    required this.loadOptions,
    required this.nameOf,
    required this.onSelected,
  });

  final IconData icon;
  final String emptyLabel;
  final T? selected;
  final Future<List<T>> Function() loadOptions;
  final String Function(T) nameOf;
  final ValueChanged<T?> onSelected;

  Future<void> _pick(BuildContext context) async {
    final options = await loadOptions();
    if (!context.mounted) return;
    // Record statt T?, damit „Alle“ (null) von „abgebrochen“ unterscheidbar ist.
    final result = await showModalBottomSheet<(T?,)>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Alle'),
            selected: selected == null,
            onTap: () => Navigator.pop<(T?,)>(context, (null,)),
          ),
          if (options.isEmpty)
            const ListTile(enabled: false, title: Text('Noch keine Einträge')),
          for (final option in options)
            ListTile(
              title: Text(nameOf(option)),
              selected: option == selected,
              onTap: () => Navigator.pop<(T?,)>(context, (option,)),
            ),
        ],
      ),
    );
    if (result != null) onSelected(result.$1);
  }

  @override
  Widget build(BuildContext context) {
    final sel = selected;
    return FilterChip(
      avatar: Icon(icon, size: 18),
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sel == null ? emptyLabel : nameOf(sel)),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
      selected: sel != null,
      onSelected: (_) => _pick(context),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? 'Nichts gefunden' : 'Deine Bibliothek ist noch leer',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              filtered ? 'Probier andere Filter oder Suchbegriffe.' : 'Füge dein erstes Buch oder deine erste Fanfic über „Hinzufügen“ hinzu.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
