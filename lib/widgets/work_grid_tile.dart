import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/l10n.dart';
import '../library/update_checker.dart';
import 'work_cover.dart';
import 'work_tile.dart';

/// Library entry for the grid view: cover, title, status and progress.
class WorkGridTile extends StatelessWidget {
  const WorkGridTile({
    super.key,
    required this.item,
    required this.onTap,
    this.selected = false,
    this.heroTag,
  });

  final WorkWithDetails item;
  final VoidCallback onTap;
  final bool selected;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = item.work;
    final total = w.chapterCount ?? 0;
    final current = w.currentChapter ?? 0;

    return Card(
      color: selected ? theme.colorScheme.secondaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      children: [
                        WorkCover(
                          work: w,
                          // Covers are 2:3; fit the space without overflowing.
                          width: constraints.maxWidth
                              .clamp(0, constraints.maxHeight / 1.5)
                              .toDouble(),
                          heroTag: heroTag,
                        ),
                        if (w.newChapters > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: NewChaptersBadge(w.newChapters),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                w.title,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (w.author case final author?)
                Text(
                  author,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(child: StatusBadge(w.status)),
                  if (looksAbandoned(w))
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Tooltip(
                        message: context.l10n.abandonedBadge,
                        child: Icon(
                          Icons.hourglass_disabled,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (total > 0 && current > 0)
                    Text('$current/$total', style: theme.textTheme.labelSmall),
                ],
              ),
              if (total > 0 && current > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(
                    value: (current / total).clamp(0, 1).toDouble(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
