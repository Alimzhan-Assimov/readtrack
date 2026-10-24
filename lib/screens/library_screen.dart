import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/file_import.dart';
import '../library/library_scope.dart';
import '../library/shelves.dart';
import '../ui/app_settings.dart';
import '../ui/layout.dart';
import '../widgets/text_prompt.dart';
import '../widgets/work_grid_tile.dart';
import '../widgets/work_tile.dart';
import 'import_screen.dart';
import 'library_filters.dart';
import 'list_import_screen.dart';
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
  LibraryFilters _filters = LibraryFilters();
  int? _selectedId;
  late Stream<List<WorkWithDetails>> _works;

  AppDatabase get _db => DatabaseScope.of(context);

  bool get _isFiltered =>
      _search.text.trim().isNotEmpty || _filters.activeCount > 0;

  bool _checking = false;
  bool _checkedOnStart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateQuery();
    if (!_checkedOnStart) {
      _checkedOnStart = true;
      if (SettingsScope.maybeOf(context)?.checkOnStart ?? false) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _checkForUpdates(quiet: true),
        );
      }
    }
  }

  /// Looks for new chapters; with [quiet], only reports when there are some.
  Future<void> _checkForUpdates({bool quiet = false}) async {
    final checker = LibraryScope.of(context).updates;
    if (checker == null || !mounted) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    try {
      final summary = await checker.check(all: !quiet);
      if (summary.newChapters > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.updatesFound(summary.newChapters, summary.updatedWorks),
            ),
          ),
        );
      } else if (!quiet) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              summary.failed > 0
                  ? l10n.updatesFailed(summary.failed)
                  : l10n.noUpdatesFound,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _updateQuery() {
    _works = _filters.watch(_db, search: _search.text);
  }

  LibraryFilter get _filter => LibraryFilter(
    type: _filters.type,
    fandomId: _filters.fandom?.id,
    tagId: _filters.tag?.id,
    pairingId: _filters.pairing?.id,
    status: _filters.status,
    minWords: _filters.minWords,
    complete: _filters.complete,
    sort: _filters.sort,
  );

  /// Applies a saved shelf; categories, tags and pairings are looked up by id.
  Future<void> _applyShelf(Shelf shelf) async {
    final f = shelf.filter;
    final fandoms = await _db.usedFandoms();
    final tags = await _db.usedTags();
    final pairings = await _db.usedPairings();
    if (!mounted) return;
    _setFilters(
      LibraryFilters(
        type: f.type,
        fandom: fandoms.where((x) => x.id == f.fandomId).firstOrNull,
        tag: tags.where((x) => x.id == f.tagId).firstOrNull,
        pairing: pairings.where((x) => x.id == f.pairingId).firstOrNull,
        status: f.status,
        minWords: f.minWords,
        complete: f.complete,
        sort: f.sort,
      ),
    );
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

  void _setFilters(LibraryFilters filters) =>
      _setFilter(() => _filters = filters);

  void _openFilterPanel() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => FilterPanel(
      db: _db,
      filters: _filters,
      search: _search.text,
      onChanged: _setFilters,
    ),
  );

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
              leading: const Icon(Icons.playlist_add),
              title: Text(l10n.addFromList),
              subtitle: Text(l10n.addFromListHint),
              onTap: () => Navigator.pop(context, _AddKind.list),
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
    if (kind == _AddKind.list) {
      await Navigator.of(
        context,
      ).push<int>(MaterialPageRoute(builder: (_) => const ListImportScreen()));
      return;
    }
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

  /// Lets the user pick a book file, shows its details in the form and
  /// adds it on save; returns the new id.
  Future<int?> _importFile() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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
    final ImportedBook book;
    try {
      book = await readBookFile(file.path);
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
      return null;
    } finally {
      navigator.pop(); // the progress dialog
    }
    final id = await navigator.push<int>(
      MaterialPageRoute(
        builder: (_) => WorkEditScreen(file: (book: book, path: file.path)),
      ),
    );
    if (id != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importedFile(file.name))),
      );
    }
    return id;
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
          final list = CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(l10n.libraryTitle),
                floating: true,
                snap: true,
                actions: [
                  if (LibraryScope.of(context).updates != null)
                    IconButton(
                      icon: _checking
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      tooltip: l10n.checkForUpdates,
                      onPressed: _checking ? null : _checkForUpdates,
                    ),
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
              SliverToBoxAdapter(
                child: ActiveFilters(
                  filters: _filters,
                  onOpenPanel: _openFilterPanel,
                  onChanged: _setFilters,
                  onSaveShelf: SettingsScope.maybeOf(context) == null
                      ? null
                      : _saveShelf,
                ),
              ),
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
          return LibraryScope.of(context).updates == null
              ? list
              : RefreshIndicator(onRefresh: _checkForUpdates, child: list);
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
}

enum _AddKind { link, list, file, manual }

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
