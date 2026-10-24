import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../ui/labels.dart';
import '../ui/layout.dart';
import '../widgets/work_tile.dart';
import 'work_detail_screen.dart';

/// Everything in the library for one franchise: its works by type (canon
/// first, fan fiction last), each series in order, then crossovers from
/// other franchises.
class FranchiseScreen extends StatefulWidget {
  const FranchiseScreen({super.key, required this.fandom});

  final Fandom fandom;

  @override
  State<FranchiseScreen> createState() => _FranchiseScreenState();
}

class _FranchiseScreenState extends State<FranchiseScreen> {
  late Stream<List<WorkWithDetails>> _works;

  /// Canon before fan works.
  static const _typeOrder = [
    WorkType.book,
    WorkType.manga,
    WorkType.comic,
    WorkType.webnovel,
    WorkType.fanfiction,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _works = DatabaseScope.of(context)
        .watchWorks(fandomId: widget.fandom.id, sort: WorkSort.title);
  }

  void _open(int id) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => WorkDetailScreen(workId: id)));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget heading(String text, {IconData? icon}) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.fandom.name)),
      body: StreamBuilder<List<WorkWithDetails>>(
        stream: _works,
        builder: (context, snapshot) {
          final all = snapshot.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final own = [
            for (final w in all)
              if (w.fandom?.id == widget.fandom.id) w,
          ];
          final crossovers = [
            for (final w in all)
              if (w.fandom?.id != widget.fandom.id) w,
          ];
          return LayoutBuilder(
            builder: (context, constraints) => ListView(
              padding: readablePadding(constraints.maxWidth, bottom: 32),
              children: [
                Text(
                  l10n.franchiseSummary(own.length, crossovers.length),
                  style: theme.textTheme.bodySmall,
                ),
                for (final type in _typeOrder)
                  if ([
                        for (final w in own)
                          if (w.work.type == type) w,
                      ]
                      case final ofType when ofType.isNotEmpty) ...[
                    heading(type.label(l10n), icon: type.icon),
                    ..._bySeries(ofType, l10n, theme),
                  ],
                if (crossovers.isNotEmpty) ...[
                  heading(l10n.franchiseCrossovers, icon: Icons.join_inner),
                  for (final w in crossovers)
                    WorkTile(item: w, onTap: () => _open(w.work.id)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Each series together and in order, then the works outside a series.
  List<Widget> _bySeries(
    List<WorkWithDetails> works,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final series = <int, List<WorkWithDetails>>{};
    final single = <WorkWithDetails>[];
    for (final w in works) {
      if (w.series case final s?) {
        series.putIfAbsent(s.id, () => []).add(w);
      } else {
        single.add(w);
      }
    }
    final groups = series.values.toList()
      ..sort((a, b) => a.first.series!.name.compareTo(b.first.series!.name));
    return [
      for (final group in groups) ...[
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            l10n.sectionSeries(group.first.series!.name),
            style: theme.textTheme.labelLarge,
          ),
        ),
        for (final w
            in group..sort(
              (a, b) => (a.work.seriesIndex ?? double.infinity).compareTo(
                b.work.seriesIndex ?? double.infinity,
              ),
            ))
          WorkTile(item: w, onTap: () => _open(w.work.id)),
      ],
      for (final w in single) WorkTile(item: w, onTap: () => _open(w.work.id)),
    ];
  }
}
