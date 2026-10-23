import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/l10n.dart';
import '../ui/app_settings.dart';
import '../ui/format.dart';
import '../ui/labels.dart';
import 'work_cover.dart';

class WorkTile extends StatelessWidget {
  const WorkTile({
    super.key,
    required this.item,
    required this.onTap,
    this.selected = false,
    this.heroTag,
  });

  final WorkWithDetails item;
  final VoidCallback onTap;

  /// Highlighted while the entry is open in the detail pane.
  final bool selected;
  final Object? heroTag;

  static const _maxTags = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final w = item.work;
    final subtitle = [?w.author, ?item.fandom?.name].join(' · ');
    final stats = workStats(w, context.l10n);
    final tags = SettingsScope.visibleTags(context, item.tags);
    final total = w.chapterCount ?? 0;
    final current = w.currentChapter ?? 0;

    return Card(
      color: selected ? scheme.secondaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkCover(work: w, width: 52, heroTag: heroTag),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (stats.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          stats.join(' · '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    if (item.pairings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 14,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.pairings.map((p) => p.name).join(', '),
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final tag in tags.take(_maxTags))
                              _SmallTag(tag.name),
                            if (tags.length > _maxTags)
                              _SmallTag('+${tags.length - _maxTags}'),
                          ],
                        ),
                      ),
                    if (total > 0 && current > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (current / total).clamp(0, 1).toDouble(),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$current/$total',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(w.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

/// Labeled reading status. An icon alone is easy to mistake for a button,
/// e.g. "Dropped" (⊗) looks like delete.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (status) {
      ReadingStatus.reading => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      ReadingStatus.finished => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.label(context.l10n),
              style: theme.textTheme.labelSmall?.copyWith(color: foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
