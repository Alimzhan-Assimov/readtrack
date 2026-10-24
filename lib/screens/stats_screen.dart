import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/reading_stats.dart';
import '../ui/layout.dart';

/// Reading statistics: recent days, totals, streaks and a year in review.
/// Counts what was read in the app's reader.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, this.today});

  /// For tests; now otherwise.
  final DateTime? today;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<(ReadingStats, Map<int, List<Work>>)> _data;
  int? _year;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = _load(DatabaseScope.of(context));
  }

  Future<(ReadingStats, Map<int, List<Work>>)> _load(AppDatabase db) async {
    final stats = ReadingStats(
      await db.readingLog(),
      today: widget.today ?? DateTime.now(),
    );
    final years = {...stats.years, stats.today.year};
    return (stats, {for (final y in years) y: await db.finishedIn(y)});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final (stats, finished) = data;
          final years = finished.keys.toList()..sort((a, b) => b - a);
          final year = _year ?? years.first;
          final yearTotals = stats.year(year);
          Widget heading(String text) => Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          );
          return LayoutBuilder(
            builder: (context, constraints) => ListView(
              padding: readablePadding(constraints.maxWidth, bottom: 32),
              children: [
                Text(l10n.statsIntro, style: theme.textTheme.bodySmall),
                heading(l10n.statsLast30Days),
                _DayBars(days: stats.lastDays(30)),
                heading(l10n.statsTotals),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tile(l10n.statsThisWeek, stats.thisWeek),
                    _Tile(l10n.statsThisMonth, stats.thisMonth),
                    _Tile(l10n.statsThisYear, stats.thisYear),
                  ],
                ),
                heading(l10n.statsStreaks),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Number(
                      l10n.statsCurrentStreak,
                      l10n.statsDays(stats.currentStreak),
                    ),
                    _Number(
                      l10n.statsLongestStreak,
                      l10n.statsDays(stats.longestStreak),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: heading(l10n.statsYearInReview('$year'))),
                    if (years.length > 1)
                      DropdownButton<int>(
                        value: year,
                        items: [
                          for (final y in years)
                            DropdownMenuItem(value: y, child: Text('$y')),
                        ],
                        onChanged: (y) => setState(() => _year = y),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tile(l10n.statsRead, yearTotals),
                    _Number(
                      l10n.statsDaysRead,
                      l10n.statsDays(stats.daysReadIn(year)),
                    ),
                    _Number(
                      l10n.statsFinished,
                      l10n.formatNumber(finished[year]?.length ?? 0),
                    ),
                  ],
                ),
                if (stats.topWorks(year) case final top
                    when top.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l10n.statsMostRead, style: theme.textTheme.titleSmall),
                  for (final (i, t) in top.indexed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(t.work.title),
                      subtitle: Text(
                        [
                          l10n.wordCount(t.totals.words),
                          _duration(l10n, t.totals.seconds),
                        ].join(' · '),
                      ),
                    ),
                ],
                if (finished[year] case final done? when done.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.statsFinishedList,
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final w in done)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(w.title),
                      subtitle: w.author == null ? null : Text(w.author!),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

String _duration(AppLocalizations l10n, int seconds) {
  final minutes = seconds ~/ 60;
  return minutes < 60
      ? l10n.statsMinutes(minutes)
      : l10n.statsHours(minutes ~/ 60, minutes % 60);
}

/// Words and time of a span.
class _Tile extends StatelessWidget {
  const _Tile(this.label, this.totals);

  final String label;
  final ReadingTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return _Box(
      children: [
        Text(
          l10n.formatNumber(totals.words),
          style: theme.textTheme.titleLarge,
        ),
        Text(l10n.statsWordsIn(label), style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          _duration(l10n, totals.seconds),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _Number extends StatelessWidget {
  const _Number(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Box(
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 140),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

/// Words per day as thin bars on a baseline; each bar has a tooltip with
/// the date, words and time.
class _DayBars extends StatelessWidget {
  const _DayBars({required this.days});

  final List<(DateTime, ReadingTotals)> days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final most = days.fold<int>(0, (m, d) => d.$2.words > m ? d.$2.words : m);
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    String date(DateTime d) =>
        MaterialLocalizations.of(context).formatShortMonthDay(d);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          most == 0
              ? l10n.statsNothingYet
              : l10n.statsMostInADay(l10n.formatNumber(most)),
          style: muted,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (day, t) in days)
                  Expanded(
                    child: Tooltip(
                      message: [
                        date(day),
                        l10n.wordCount(t.words),
                        _duration(l10n, t.seconds),
                      ].join('\n'),
                      child: Container(
                        // The whole column is the hit target, not just the bar.
                        color: Colors.transparent,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: FractionallySizedBox(
                          heightFactor: most == 0 ? 0 : t.words / most,
                          child: Container(
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date(days.first.$1), style: muted),
            Text(date(days.last.$1), style: muted),
          ],
        ),
      ],
    );
  }
}
