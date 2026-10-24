import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import 'work_detail_screen.dart';

/// The rest of a work's series, and works related to it (sequel, prequel,
/// spin-off, side story), with a way to add relations.
class RelatedSection extends StatefulWidget {
  const RelatedSection({super.key, required this.item});

  final WorkWithDetails item;

  @override
  State<RelatedSection> createState() => _RelatedSectionState();
}

class _RelatedSectionState extends State<RelatedSection> {
  late Stream<List<({WorkRelation relation, Work work})>> _relations;
  Stream<List<Work>>? _series;
  int? _seriesId;

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watch();
  }

  @override
  void didUpdateWidget(RelatedSection old) {
    super.didUpdateWidget(old);
    if (old.item.work.id != widget.item.work.id ||
        widget.item.series?.id != _seriesId) {
      _watch();
    }
  }

  void _watch() {
    _relations = _db.watchRelations(widget.item.work.id);
    _seriesId = widget.item.series?.id;
    _series = _seriesId == null ? null : _db.watchSeries(_seriesId!);
  }

  void _open(Work w) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => WorkDetailScreen(workId: w.id)));

  /// The relation's name as seen from this work.
  String _label(AppLocalizations l10n, WorkRelation r) {
    final outgoing = r.fromWorkId == widget.item.work.id;
    return switch ((r.type, outgoing)) {
      (RelationType.sequel, true) ||
      (RelationType.prequel, false) => l10n.relationSequel,
      (RelationType.prequel, true) ||
      (RelationType.sequel, false) => l10n.relationPrequel,
      (RelationType.spinOff, true) => l10n.relationSpinOff,
      (RelationType.spinOff, false) => l10n.relationSpinOffOf,
      (RelationType.sideStory, true) => l10n.relationSideStory,
      (RelationType.sideStory, false) => l10n.relationSideStoryOf,
    };
  }

  Future<void> _add() async {
    final picked = await showDialog<(RelationType, Work)>(
      context: context,
      builder: (_) => _AddRelationDialog(db: _db, self: widget.item.work),
    );
    if (picked != null) {
      await _db.addRelation(widget.item.work.id, picked.$1, picked.$2.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final heading = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.primary,
    );
    final series = widget.item.series;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (series != null && _series != null)
          StreamBuilder<List<Work>>(
            stream: _series,
            builder: (context, snapshot) {
              final parts = snapshot.data ?? const <Work>[];
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.sectionSeries(series.name), style: heading),
                    for (final w in parts)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        selected: w.id == widget.item.work.id,
                        leading: SizedBox(
                          width: 32,
                          child: Text(
                            w.seriesIndex == null
                                ? '–'
                                : '#${w.seriesIndex == w.seriesIndex!.roundToDouble() ? w.seriesIndex!.round() : w.seriesIndex}',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        title: Text(w.title),
                        onTap: w.id == widget.item.work.id
                            ? null
                            : () => _open(w),
                      ),
                  ],
                ),
              );
            },
          ),
        StreamBuilder<List<({WorkRelation relation, Work work})>>(
          stream: _relations,
          builder: (context, snapshot) {
            final related = snapshot.data ?? const [];
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.sectionRelated, style: heading),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add_link, size: 18),
                        label: Text(l10n.addRelation),
                        onPressed: _add,
                      ),
                    ],
                  ),
                  for (final r in related)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(r.work.title),
                      subtitle: Text(_label(l10n, r.relation)),
                      onTap: () => _open(r.work),
                      trailing: IconButton(
                        icon: const Icon(Icons.link_off),
                        tooltip: l10n.removeRelation,
                        onPressed: () => _db.removeRelation(r.relation),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AddRelationDialog extends StatefulWidget {
  const _AddRelationDialog({required this.db, required this.self});

  final AppDatabase db;
  final Work self;

  @override
  State<_AddRelationDialog> createState() => _AddRelationDialogState();
}

class _AddRelationDialogState extends State<_AddRelationDialog> {
  RelationType _type = RelationType.sequel;
  String _query = '';
  late final Future<List<WorkWithDetails>> _works = widget.db
      .watchWorks(sort: WorkSort.title)
      .first;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase();
    return AlertDialog(
      title: Text(l10n.addRelationTitle(widget.self.title)),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: 420,
        height: 480,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<RelationType>(
                segments: [
                  for (final t in RelationType.values)
                    ButtonSegment(
                      value: t,
                      label: Text(switch (t) {
                        RelationType.sequel => l10n.relationSequel,
                        RelationType.prequel => l10n.relationPrequel,
                        RelationType.spinOff => l10n.relationSpinOff,
                        RelationType.sideStory => l10n.relationSideStory,
                      }),
                    ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchFilterValues,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<WorkWithDetails>>(
                future: _works,
                builder: (context, snapshot) => ListView(
                  children: [
                    for (final w in snapshot.data ?? const <WorkWithDetails>[])
                      if (w.work.id != widget.self.id &&
                          w.work.title.toLowerCase().contains(q))
                        ListTile(
                          title: Text(w.work.title),
                          subtitle: w.work.author == null
                              ? null
                              : Text(w.work.author!),
                          onTap: () => Navigator.pop(context, (_type, w.work)),
                        ),
                  ],
                ),
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
