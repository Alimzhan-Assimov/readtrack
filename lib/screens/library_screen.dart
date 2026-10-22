import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/work_tile.dart';
import 'work_detail_screen.dart';
import 'work_edit_screen.dart';

/// Startseite. In schmalen Fenstern (Handy) eine Liste, aus der die Details
/// als eigene Seite geöffnet werden; ab [Breakpoints.expanded] stehen Liste
/// und Details nebeneinander (Material-3-Muster „List-Detail“).
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _listPaneWidth = 400.0;

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _searchDebounce;
  WorkType? _type;
  Fandom? _fandom;
  Tag? _tag;
  WorkSort _sort = WorkSort.updated;
  int? _selectedId;
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
    _searchDebounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _updateQuery() {
    _works = _db.watchWorks(
      search: _search.text,
      type: _type,
      fandomId: _fandom?.id,
      tagId: _tag?.id,
      sort: _sort,
    );
  }

  void _setFilter(VoidCallback change) => setState(() {
    change();
    _updateQuery();
  });

  /// Fragt erst nach einer kurzen Tipp-Pause die Datenbank ab.
  void _onSearchChanged(String _) {
    setState(() {}); // Löschen-Button ein-/ausblenden
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _setFilter(() {}),
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _setFilter(_search.clear);
  }

  void _open(int id, {required bool wide}) {
    if (wide) {
      setState(() => _selectedId = id);
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => WorkDetailScreen(workId: id)));
    }
  }

  Future<void> _create({required bool wide}) async {
    final id = await Navigator.of(context)
        .push<int>(MaterialPageRoute(builder: (_) => const WorkEditScreen()));
    if (id != null && mounted) _open(id, wide: wide);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;
    final list = _buildListPane(context, wide: wide);
    final selectedId = _selectedId;

    // Im breiten Layout umschließt ein äußeres Scaffold beide Spalten, damit
    // Snackbars nur einmal über die ganze Breite erscheinen.
    final body = !wide
        ? list
        : Scaffold(
            body: Row(
              children: [
                SizedBox(width: _listPaneWidth, child: list),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedId == null
                      ? const _NoSelection()
                      : WorkDetailScreen(
                          key: ValueKey(selectedId),
                          workId: selectedId,
                          embedded: true,
                          onDeleted: () => setState(() => _selectedId = null),
                        ),
                ),
              ],
            ),
          );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            _create(wide: wide),
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _searchFocus.requestFocus,
      },
      child: Focus(autofocus: true, child: body),
    );
  }

  Widget _buildListPane(BuildContext context, {required bool wide}) {
    final theme = Theme.of(context);
    return Scaffold(
      body: StreamBuilder<List<WorkWithDetails>>(
        stream: _works,
        builder: (context, snapshot) {
          final items = snapshot.data;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Meine Bibliothek'),
                floating: true,
                snap: true,
                actions: [
                  PopupMenuButton<WorkSort>(
                    icon: const Icon(Icons.sort),
                    tooltip: 'Sortieren',
                    initialValue: _sort,
                    onSelected: (s) => _setFilter(() => _sort = s),
                    itemBuilder: (context) => [
                      for (final s in WorkSort.values)
                        CheckedPopupMenuItem(
                          value: s,
                          checked: s == _sort,
                          child: Text(s.label),
                        ),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: SearchBar(
                    controller: _search,
                    focusNode: _searchFocus,
                    hintText: 'Titel, Autor oder Kategorie suchen',
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: _onSearchChanged,
                    trailing: [
                      if (_search.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Suche leeren',
                          onPressed: _clearSearch,
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildFilters()),
              if (snapshot.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Fehler: ${snapshot.error}')),
                )
              else if (items == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(filtered: _isFiltered),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      items.length == 1
                          ? '1 Eintrag'
                          : '${items.length} Einträge',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final id = items[i].work.id;
                      return WorkTile(
                        item: items[i],
                        selected: wide && id == _selectedId,
                        // Hero-Animation nur beim Seitenwechsel (schmales Layout).
                        heroTag: wide ? null : 'cover-$id',
                        onTap: () => _open(id, wide: wide),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(wide: wide),
        tooltip: 'Neuer Eintrag (Strg+N)',
        icon: const Icon(Icons.add),
        label: const Text('Hinzufügen'),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
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
              onSelected: (sel) => _setFilter(() => _type = sel ? t : null),
            ),
          ],
        ],
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
              filtered ? Icons.search_off : Icons.auto_stories_outlined,
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

class _NoSelection extends StatelessWidget {
  const _NoSelection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Wähle links einen Eintrag aus',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
