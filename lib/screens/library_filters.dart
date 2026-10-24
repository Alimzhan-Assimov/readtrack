import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/l10n.dart';
import '../ui/app_settings.dart';
import '../ui/labels.dart';

/// The library's current filters, with the chosen categories, tags and
/// pairings as objects so their names can be shown.
class LibraryFilters {
  LibraryFilters({
    this.type,
    this.fandom,
    this.tag,
    this.pairing,
    this.series,
    this.character,
    this.status,
    this.minWords,
    this.complete,
    this.sort = WorkSort.updated,
  });

  WorkType? type;
  Fandom? fandom;
  Tag? tag;
  Pairing? pairing;
  SeriesItem? series;
  Character? character;
  ReadingStatus? status;
  int? minWords;
  bool? complete;
  WorkSort sort;

  /// Word-count thresholds offered by the length filter.
  static const lengths = [10000, 50000, 100000, 250000];

  LibraryFilters copy() => LibraryFilters(
    type: type,
    fandom: fandom,
    tag: tag,
    pairing: pairing,
    series: series,
    character: character,
    status: status,
    minWords: minWords,
    complete: complete,
    sort: sort,
  );

  /// How many filters narrow the list (sorting doesn't count).
  int get activeCount => [
    type,
    fandom,
    tag,
    pairing,
    series,
    character,
    status,
    minWords,
    complete,
  ].nonNulls.length;

  void clear() {
    type = null;
    fandom = null;
    tag = null;
    pairing = null;
    series = null;
    character = null;
    status = null;
    minWords = null;
    complete = null;
  }

  Stream<List<WorkWithDetails>> watch(AppDatabase db, {String search = ''}) =>
      db.watchWorks(
        search: search,
        type: type,
        fandomId: fandom?.id,
        tagId: tag?.id,
        pairingId: pairing?.id,
        seriesId: series?.id,
        characterId: character?.id,
        status: status,
        minWords: minWords,
        complete: complete,
        sort: sort,
      );
}

/// The row under the search bar: the filter button, the sort, and one chip
/// per active filter that removes it.
class ActiveFilters extends StatelessWidget {
  const ActiveFilters({
    super.key,
    required this.filters,
    required this.onOpenPanel,
    required this.onChanged,
    this.onSaveShelf,
  });

  final LibraryFilters filters;
  final VoidCallback onOpenPanel;
  final ValueChanged<LibraryFilters> onChanged;
  final VoidCallback? onSaveShelf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = filters;
    Widget active(
      IconData icon,
      String label,
      void Function(LibraryFilters) clear,
    ) => InputChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: true,
      showCheckmark: false,
      onPressed: onOpenPanel,
      onDeleted: () => onChanged(f.copy()..apply(clear)),
      deleteButtonTooltipMessage: l10n.removeFilter,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(
            isLabelVisible: f.activeCount > 0,
            label: Text('${f.activeCount}'),
            child: ActionChip(
              avatar: const Icon(Icons.tune, size: 18),
              label: Text(l10n.filtersButton),
              onPressed: onOpenPanel,
            ),
          ),
          MenuAnchor(
            menuChildren: [
              for (final s in WorkSort.values)
                MenuItemButton(
                  leadingIcon: Icon(s == f.sort ? Icons.check : null, size: 18),
                  onPressed: () => onChanged(f.copy()..sort = s),
                  child: Text(s.label(l10n)),
                ),
            ],
            builder: (context, controller, _) => ActionChip(
              avatar: const Icon(Icons.sort, size: 18),
              label: Text(f.sort.label(l10n)),
              tooltip: l10n.sortTooltip,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
          if (f.status case final s?)
            active(s.icon, s.label(l10n), (f) => f.status = null),
          if (f.type case final t?)
            active(t.icon, t.label(l10n), (f) => f.type = null),
          if (f.fandom case final x?)
            active(Icons.category_outlined, x.name, (f) => f.fandom = null),
          if (f.tag case final x?)
            active(Icons.sell_outlined, x.name, (f) => f.tag = null),
          if (f.pairing case final x?)
            active(Icons.favorite_border, x.name, (f) => f.pairing = null),
          if (f.character case final x?)
            active(Icons.person_outline, x.name, (f) => f.character = null),
          if (f.series case final x?)
            active(
              Icons.collections_bookmark_outlined,
              x.name,
              (f) => f.series = null,
            ),
          if (f.minWords case final n?)
            active(
              Icons.straighten,
              l10n.atLeastWords(n),
              (f) => f.minWords = null,
            ),
          if (f.complete case final c?)
            active(
              Icons.flag_outlined,
              c ? l10n.completeOnly : l10n.ongoingOnly,
              (f) => f.complete = null,
            ),
          if (f.activeCount > 0) ...[
            if (onSaveShelf != null)
              ActionChip(
                avatar: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: Text(l10n.saveShelf),
                onPressed: onSaveShelf,
              ),
            if (f.activeCount > 1)
              TextButton(
                onPressed: () => onChanged(f.copy()..clear()),
                child: Text(l10n.clearFilters),
              ),
          ],
        ],
      ),
    );
  }
}

extension on LibraryFilters {
  void apply(void Function(LibraryFilters) change) => change(this);
}

/// All filters at a glance. Changes apply right away; the button shows how
/// many entries match.
class FilterPanel extends StatefulWidget {
  const FilterPanel({
    super.key,
    required this.db,
    required this.filters,
    required this.search,
    required this.onChanged,
  });

  final AppDatabase db;
  final LibraryFilters filters;
  final String search;
  final ValueChanged<LibraryFilters> onChanged;

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late LibraryFilters _f = widget.filters.copy();
  late Stream<List<WorkWithDetails>> _matches = _f.watch(
    widget.db,
    search: widget.search,
  );

  void _set(void Function(LibraryFilters f) change) {
    setState(() {
      _f = _f.copy();
      change(_f);
      _matches = _f.watch(widget.db, search: widget.search);
    });
    widget.onChanged(_f);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );
    Widget choices<T>(
      List<T> values,
      T? selected,
      String Function(T) label,
      void Function(LibraryFilters f, T? value) set, {
      IconData Function(T)? icon,
      bool allowAll = true,
    }) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (allowAll)
          ChoiceChip(
            label: Text(l10n.filterAll),
            selected: selected == null,
            onSelected: (_) => _set((f) => set(f, null)),
          ),
        for (final v in values)
          ChoiceChip(
            avatar: icon == null ? null : Icon(icon(v), size: 18),
            label: Text(label(v)),
            selected: v == selected,
            onSelected: (_) => _set((f) => set(f, v)),
          ),
      ],
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.filtersButton,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    if (_f.activeCount > 0)
                      TextButton(
                        onPressed: () => _set((f) => f.clear()),
                        child: Text(l10n.clearFilters),
                      ),
                  ],
                ),
                heading(l10n.filterStatus),
                choices(
                  ReadingStatus.values,
                  _f.status,
                  (s) => s.label(l10n),
                  (f, s) => f.status = s,
                  icon: (s) => s.icon,
                ),
                heading(l10n.filterType),
                choices(
                  WorkType.values,
                  _f.type,
                  (t) => t.label(l10n),
                  (f, t) => f.type = t,
                  icon: (t) => t.icon,
                ),
                heading(l10n.filterCompletion),
                choices(
                  const [true, false],
                  _f.complete,
                  (c) => c ? l10n.completeOnly : l10n.ongoingOnly,
                  (f, c) => f.complete = c,
                ),
                heading(l10n.filterLength),
                choices(
                  LibraryFilters.lengths,
                  _f.minWords,
                  l10n.atLeastWords,
                  (f, n) => f.minWords = n,
                ),
                const SizedBox(height: 8),
                _PickerTile<Fandom>(
                  icon: Icons.category_outlined,
                  label: l10n.filterCategory,
                  selected: _f.fandom,
                  nameOf: (x) => x.name,
                  idOf: (x) => x.id,
                  load: widget.db.usedFandoms,
                  counts: () => widget.db.usageCounts(UsageKind.fandom),
                  onSelected: (x) => _set((f) => f.fandom = x),
                ),
                _PickerTile<Tag>(
                  icon: Icons.sell_outlined,
                  label: l10n.filterTag,
                  selected: _f.tag,
                  nameOf: (x) => x.name,
                  idOf: (x) => x.id,
                  load: () async {
                    final tags = await widget.db.usedTags();
                    return context.mounted
                        ? SettingsScope.visibleTags(context, tags)
                        : tags;
                  },
                  counts: () => widget.db.usageCounts(UsageKind.tag),
                  onSelected: (x) => _set((f) => f.tag = x),
                ),
                _PickerTile<Pairing>(
                  icon: Icons.favorite_border,
                  label: l10n.filterPairing,
                  selected: _f.pairing,
                  nameOf: (x) => x.name,
                  idOf: (x) => x.id,
                  load: widget.db.usedPairings,
                  counts: () => widget.db.usageCounts(UsageKind.pairing),
                  onSelected: (x) => _set((f) => f.pairing = x),
                ),
                _PickerTile<Character>(
                  icon: Icons.person_outline,
                  label: l10n.filterCharacter,
                  selected: _f.character,
                  nameOf: (x) => x.name,
                  idOf: (x) => x.id,
                  load: widget.db.usedCharacters,
                  counts: () => widget.db.usageCounts(UsageKind.character),
                  onSelected: (x) => _set((f) => f.character = x),
                ),
                _PickerTile<SeriesItem>(
                  icon: Icons.collections_bookmark_outlined,
                  label: l10n.filterSeries,
                  selected: _f.series,
                  nameOf: (x) => x.name,
                  idOf: (x) => x.id,
                  load: widget.db.usedSeries,
                  counts: () => widget.db.usageCounts(UsageKind.series),
                  onSelected: (x) => _set((f) => f.series = x),
                ),
                heading(l10n.sortTooltip),
                choices(
                  WorkSort.values,
                  _f.sort,
                  (s) => s.label(l10n),
                  (f, s) => f.sort = s ?? WorkSort.updated,
                  allowAll: false,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: StreamBuilder<List<WorkWithDetails>>(
                stream: _matches,
                builder: (context, snapshot) => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      snapshot.data == null
                          ? l10n.showEntriesLoading
                          : l10n.showEntries(snapshot.data!.length),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row for a filter with many values; opens a searchable list with how
/// many entries use each value.
class _PickerTile<T> extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.nameOf,
    required this.idOf,
    required this.load,
    required this.counts,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final T? selected;
  final String Function(T) nameOf;
  final int Function(T) idOf;
  final Future<List<T>> Function() load;
  final Future<Map<int, int>> Function() counts;
  final ValueChanged<T?> onSelected;

  Future<void> _pick(BuildContext context) async {
    final options = await load();
    final usage = await counts();
    if (!context.mounted) return;
    // A record instead of T? so "All" (null) is distinguishable from closing.
    final result = await showDialog<(T?,)>(
      context: context,
      builder: (_) => _SearchList<T>(
        title: label,
        options: options,
        selected: selected,
        nameOf: nameOf,
        countOf: (x) => usage[idOf(x)] ?? 0,
      ),
    );
    if (result != null) onSelected(result.$1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sel = selected;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(sel == null ? l10n.filterAll : nameOf(sel)),
      trailing: sel == null
          ? const Icon(Icons.chevron_right)
          : IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.removeFilter,
              onPressed: () => onSelected(null),
            ),
      onTap: () => _pick(context),
    );
  }
}

class _SearchList<T> extends StatefulWidget {
  const _SearchList({
    required this.title,
    required this.options,
    required this.selected,
    required this.nameOf,
    required this.countOf,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) nameOf;
  final int Function(T) countOf;

  @override
  State<_SearchList<T>> createState() => _SearchListState<T>();
}

class _SearchListState<T> extends State<_SearchList<T>> {
  String _query = '';
  bool _byCount = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final o in widget.options)
        if (widget.nameOf(o).toLowerCase().contains(q)) o,
    ];
    if (_byCount) {
      shown.sort((a, b) => widget.countOf(b).compareTo(widget.countOf(a)));
    }
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: 400,
        height: 480,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchFilterValues,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _byCount ? Icons.sort_by_alpha : Icons.bar_chart,
                    ),
                    tooltip: _byCount ? l10n.sortByName : l10n.sortByCount,
                    onPressed: () => setState(() => _byCount = !_byCount),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (q.isEmpty)
                    ListTile(
                      leading: const Icon(Icons.clear_all),
                      title: Text(l10n.filterAll),
                      selected: widget.selected == null,
                      onTap: () => Navigator.pop<(T?,)>(context, (null,)),
                    ),
                  if (shown.isEmpty)
                    ListTile(enabled: false, title: Text(l10n.pickerEmpty)),
                  for (final o in shown)
                    ListTile(
                      title: Text(widget.nameOf(o)),
                      trailing: Text('${widget.countOf(o)}'),
                      selected: o == widget.selected,
                      onTap: () => Navigator.pop<(T?,)>(context, (o,)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
