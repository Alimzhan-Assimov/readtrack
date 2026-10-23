import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/book_importer.dart';
import '../library/file_import.dart';
import '../library/library_scope.dart';
import '../library/shelves.dart';
import '../ui/app_settings.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/text_prompt.dart';
import '../widgets/work_grid_tile.dart';
import '../widgets/work_tile.dart';
import 'import_screen.dart';
import 'settings_screen.dart';
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
  Pairing? _pairing;
  ReadingStatus? _status;
  int? _minWords;
  bool? _complete;
  WorkSort _sort = WorkSort.updated;

  /// Word-count thresholds offered by the length filter.
  static const _lengths = [10000, 50000, 100000, 250000];
  int? _selectedId;
  late Stream<List<WorkWithDetails>> _works;

  AppDatabase get _db => DatabaseScope.of(context);

  bool get _isFiltered =>
      _search.text.trim().isNotEmpty ||
      _type != null ||
      _fandom != null ||
      _tag != null ||
      _pairing != null ||
      _status != null ||
      _minWords != null ||
      _complete != null;

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
      pairingId: _pairing?.id,
      status: _status,
      minWords: _minWords,
      complete: _complete,
      sort: _sort,
    );
  }

  LibraryFilter get _filter => LibraryFilter(
    type: _type,
    fandomId: _fandom?.id,
    tagId: _tag?.id,
    pairingId: _pairing?.id,
    status: _status,
    minWords: _minWords,
    complete: _complete,
    sort: _sort,
  );

  /// Applies a saved shelf; categories, tags and pairings are looked up by id.
  Future<void> _applyShelf(Shelf shelf) async {
    final f = shelf.filter;
    final fandoms = await _db.usedFandoms();
    final tags = await _db.usedTags();
    final pairings = await _db.usedPairings();
    if (!mounted) return;
    _setFilter(() {
      _type = f.type;
      _fandom = fandoms.where((x) => x.id == f.fandomId).firstOrNull;
      _tag = tags.where((x) => x.id == f.tagId).firstOrNull;
      _pairing = pairings.where((x) => x.id == f.pairingId).firstOrNull;
      _status = f.status;
      _minWords = f.minWords;
      _complete = f.complete;
      _sort = f.sort;
    });
  }

  Future<void> _saveShelf() async {
    final l10n = context.l10n;
    final settings = SettingsScope.maybeOf(context);
    if (settings == null) return;
    final name = await showTextPrompt(
      context,
      title: l10n.saveShelfTitle,
      hint: l10n.shelfNameHint,
    );
    if (name == null || name.isEmpty) return;
    await settings.saveShelf(Shelf(name, _filter));
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
  /// Asks how to add an entry (link, file or by hand), then opens it.
  Future<void> _create({required bool wide}) async {
    final l10n = context.l10n;
    final kind = await showModalBottomSheet<_AddKind>(
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
              onTap: () => Navigator.pop(context, _AddKind.link),
            ),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(l10n.addFromFile),
              subtitle: Text(l10n.addFromFileHint),
              onTap: () => Navigator.pop(context, _AddKind.file),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l10n.addManually),
              subtitle: Text(l10n.addManuallyHint),
              onTap: () => Navigator.pop(context, _AddKind.manual),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (kind == null || !mounted) return;
    final int? id;
    if (kind == _AddKind.file) {
      id = await _importFile();
    } else {
      id = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => kind == _AddKind.link
              ? const ImportScreen()
              : const WorkEditScreen(),
        ),
      );
    }
    if (id != null && mounted) _open(id, wide: wide);
  }

  /// Lets the user pick a book file and adds it; returns the new id.
  Future<int?> _importFile() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final importer = BookImporter(_db, LibraryScope.of(context).storage);
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: l10n.bookFiles, extensions: kImportExtensions),
      ],
    );
    if (file == null || !mounted) return null;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.importingFile(file.name))),
            ],
          ),
        ),
      ),
    );
    try {
      final id = await importer.importFile(file.path);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importedFile(file.name))),
      );
      return id;
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
      return null;
    } finally {
      navigator.pop(); // the progress dialog
    }
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
                  if (SettingsScope.maybeOf(context) case final settings?)
                    IconButton(
                      icon: Icon(
                        settings.gridView
                            ? Icons.view_list_outlined
                            : Icons.grid_view,
                      ),
                      tooltip: settings.gridView
                          ? l10n.showAsList
                          : l10n.showAsGrid,
                      onPressed: () => settings.setGridView(!settings.gridView),
                    ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: l10n.settingsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
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
              if (SettingsScope.maybeOf(context)?.shelves case final shelves?
                  when shelves.isNotEmpty)
                SliverToBoxAdapter(child: _buildShelves(l10n, shelves)),
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
                if (SettingsScope.maybeOf(context)?.gridView ?? false)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 170,
                            childAspectRatio: 0.52,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final id = items[i].work.id;
                        return WorkGridTile(
                          item: items[i],
                          selected: wide && id == _selectedId,
                          heroTag: wide ? null : 'cover-$id',
                          onTap: () => _open(id, wide: wide),
                        );
                      },
                    ),
                  )
                else
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

  Widget _buildShelves(AppLocalizations l10n, List<Shelf> shelves) {
    final settings = SettingsScope.maybeOf(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final shelf in shelves)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: InputChip(
                avatar: const Icon(Icons.shelves, size: 18),
                label: Text(shelf.name),
                tooltip: l10n.openShelf,
                onPressed: () => _applyShelf(shelf),
                onDeleted: () => settings.deleteShelf(shelf.name),
                deleteButtonTooltipMessage: l10n.deleteShelf,
              ),
            ),
        ],
      ),
    );
  }

  bool get _isFilteredByChips =>
      _type != null ||
      _fandom != null ||
      _tag != null ||
      _pairing != null ||
      _status != null ||
      _minWords != null ||
      _complete != null;

  void _clearFilters() => _setFilter(() {
    _type = null;
    _fandom = null;
    _tag = null;
    _pairing = null;
    _status = null;
    _minWords = null;
    _complete = null;
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
            loadOptions: () async {
              final tags = await _db.usedTags();
              return mounted ? SettingsScope.visibleTags(context, tags) : tags;
            },
            nameOf: (t) => t.name,
            onSelected: (t) => _setFilter(() => _tag = t),
          ),
          _PickerChip<Pairing>(
            icon: Icons.favorite_border,
            emptyLabel: l10n.filterPairing,
            selected: _pairing,
            loadOptions: _db.usedPairings,
            nameOf: (p) => p.name,
            onSelected: (p) => _setFilter(() => _pairing = p),
          ),
          _PickerChip<ReadingStatus>(
            icon: Icons.bookmark_outline,
            emptyLabel: l10n.filterStatus,
            selected: _status,
            loadOptions: () async => ReadingStatus.values,
            nameOf: (s) => s.label(l10n),
            iconOf: (s) => s.icon,
            onSelected: (s) => _setFilter(() => _status = s),
          ),
          _PickerChip<int>(
            icon: Icons.straighten,
            emptyLabel: l10n.filterLength,
            selected: _minWords,
            loadOptions: () async => _lengths,
            nameOf: (n) => l10n.atLeastWords(n),
            onSelected: (n) => _setFilter(() => _minWords = n),
          ),
          _PickerChip<bool>(
            icon: Icons.flag_outlined,
            emptyLabel: l10n.filterCompletion,
            selected: _complete,
            loadOptions: () async => const [true, false],
            nameOf: (c) => c ? l10n.completeOnly : l10n.ongoingOnly,
            onSelected: (c) => _setFilter(() => _complete = c),
          ),
          if (_isFilteredByChips) ...[
            ActionChip(
              avatar: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: Text(l10n.saveShelf),
              onPressed: _saveShelf,
            ),
            ActionChip(
              avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(l10n.clearFilters),
              onPressed: _clearFilters,
            ),
          ],
        ],
      ),
    );
  }
}

enum _AddKind { link, file, manual }

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
