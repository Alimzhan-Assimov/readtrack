import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/work_tile.dart';
import 'import_screen.dart';
import 'work_detail_screen.dart';
import 'work_edit_screen.dart';

/// Home screen. In narrow windows (phones) it is a list that opens details as
/// separate pages; from [Breakpoints.expanded] on, list and details sit side
/// by side (the Material 3 "list-detail" layout).
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

  /// Only queries the database once typing pauses briefly.
  void _onSearchChanged(String _) {
    setState(() {}); // show/hide the clear button
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

  /// Asks whether to add from a link or by hand, then opens the new entry.
  Future<void> _create({required bool wide}) async {
    final l10n = context.l10n;
    final fromLink = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.addFromLink),
              subtitle: Text(l10n.addFromLinkHint),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l10n.addManually),
              subtitle: Text(l10n.addManuallyHint),
              onTap: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (fromLink == null || !mounted) return;
    final id = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            fromLink ? const ImportScreen() : const WorkEditScreen(),
      ),
    );
    if (id != null && mounted) _open(id, wide: wide);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;
    final list = _buildListPane(context, wide: wide);
    final selectedId = _selectedId;

    // In the wide layout an outer Scaffold wraps both panes so snackbars
    // appear once across the full width.
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
    final l10n = context.l10n;
    return Scaffold(
      body: StreamBuilder<List<WorkWithDetails>>(
        stream: _works,
        builder: (context, snapshot) {
          final items = snapshot.data;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(l10n.libraryTitle),
                floating: true,
                snap: true,
                actions: [
                  PopupMenuButton<WorkSort>(
                    icon: const Icon(Icons.sort),
                    tooltip: l10n.sortTooltip,
                    initialValue: _sort,
                    onSelected: (s) => _setFilter(() => _sort = s),
                    itemBuilder: (context) => [
                      for (final s in WorkSort.values)
                        CheckedPopupMenuItem(
                          value: s,
                          checked: s == _sort,
                          child: Text(s.label(l10n)),
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
                    hintText: l10n.searchHint,
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: _onSearchChanged,
                    trailing: [
                      if (_search.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: l10n.clearSearch,
                          onPressed: _clearSearch,
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildFilters(l10n)),
              if (snapshot.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(l10n.errorMessage(snapshot.error!)),
                  ),
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
                      l10n.entryCount(items.length),
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
                        // Hero animation only on page transitions (narrow layout).
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
        tooltip: l10n.addTooltip,
        icon: const Icon(Icons.add),
        label: Text(l10n.addButton),
      ),
    );
  }

  void _clearFilters() => _setFilter(() {
    _type = null;
    _fandom = null;
    _tag = null;
  });

  /// All filters are compact picker chips, so they fit the 400 dp list pane
  /// without horizontal scrolling; long selections wrap to a second line.
  Widget _buildFilters(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _PickerChip<WorkType>(
            icon: Icons.auto_stories_outlined,
            emptyLabel: l10n.filterType,
            selected: _type,
            loadOptions: () async => WorkType.values,
            nameOf: (t) => t.label(l10n),
            iconOf: (t) => t.icon,
            onSelected: (t) => _setFilter(() => _type = t),
          ),
          _PickerChip<Fandom>(
            icon: Icons.category_outlined,
            emptyLabel: l10n.filterCategory,
            selected: _fandom,
            loadOptions: _db.usedFandoms,
            nameOf: (f) => f.name,
            onSelected: (f) => _setFilter(() => _fandom = f),
          ),
          _PickerChip<Tag>(
            icon: Icons.sell_outlined,
            emptyLabel: l10n.filterTag,
            selected: _tag,
            loadOptions: _db.usedTags,
            nameOf: (t) => t.name,
            onSelected: (t) => _setFilter(() => _tag = t),
          ),
          if (_type != null || _fandom != null || _tag != null)
            ActionChip(
              avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(l10n.clearFilters),
              onPressed: _clearFilters,
            ),
        ],
      ),
    );
  }
}

/// Filter chip that opens a list of options when tapped.
class _PickerChip<T> extends StatelessWidget {
  const _PickerChip({
    required this.icon,
    required this.emptyLabel,
    required this.selected,
    required this.loadOptions,
    required this.nameOf,
    required this.onSelected,
    this.iconOf,
  });

  final IconData icon;
  final String emptyLabel;
  final T? selected;
  final Future<List<T>> Function() loadOptions;
  final String Function(T) nameOf;
  final ValueChanged<T?> onSelected;

  /// Optional icon per option, shown in the list and on the selected chip.
  final IconData Function(T)? iconOf;

  Future<void> _pick(BuildContext context) async {
    final l10n = context.l10n;
    final options = await loadOptions();
    if (!context.mounted) return;
    // A record instead of T? so "All" (null) is distinguishable from dismissing.
    final result = await showModalBottomSheet<(T?,)>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: Text(l10n.filterAll),
            selected: selected == null,
            onTap: () => Navigator.pop<(T?,)>(context, (null,)),
          ),
          if (options.isEmpty)
            ListTile(enabled: false, title: Text(l10n.pickerEmpty)),
          for (final option in options)
            ListTile(
              leading: iconOf == null ? null : Icon(iconOf!(option)),
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
      avatar: Icon(
        sel != null && iconOf != null ? iconOf!(sel) : icon,
        size: 18,
      ),
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
    final l10n = context.l10n;
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
              filtered ? l10n.noResultsTitle : l10n.emptyLibraryTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              filtered ? l10n.noResultsBody : l10n.emptyLibraryBody,
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
            context.l10n.noSelection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
