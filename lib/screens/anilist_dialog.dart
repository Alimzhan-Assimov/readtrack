import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../diagnostics/app_log.dart';
import '../l10n/l10n.dart';
import '../library/anilist_apply.dart';
import '../sources/anilist.dart';
import '../sources/fetcher.dart';

/// Searches AniList for [item] and, once one result is picked, fills the
/// entry from it. Returns what changed, or null if cancelled.
Future<AniListResult?> lookUpOnAniList(
  BuildContext context,
  WorkWithDetails item, {
  AniListClient? client,
}) => showDialog<AniListResult>(
  context: context,
  builder: (_) => _AniListDialog(item: item, client: client),
);

class _AniListDialog extends StatefulWidget {
  const _AniListDialog({required this.item, this.client});

  final WorkWithDetails item;
  final AniListClient? client;

  @override
  State<_AniListDialog> createState() => _AniListDialogState();
}

class _AniListDialogState extends State<_AniListDialog> {
  late final _client = widget.client ?? AniListClient();
  late final _query = TextEditingController(text: widget.item.work.title);
  List<AniListMedia>? _results;
  String? _error;
  bool _busy = false;

  /// Anime adaptations matter less for a reading app.
  String? get _type =>
      widget.item.work.type == WorkType.fanfiction ? null : 'MANGA';

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _query.dispose();
    if (widget.client == null) _client.close();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final results = await _client.search(_query.text.trim(), type: _type);
      if (mounted) setState(() => _results = results);
    } on SourceException catch (e) {
      logWarning('anilist', 'Search failed', error: e.message);
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _take(AniListMedia media) async {
    setState(() => _busy = true);
    final db = DatabaseScope.of(context);
    final result = await applyAniList(db, widget.item, media);
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final results = _results;
    return AlertDialog(
      title: Text(l10n.aniListTitle),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: 440,
        height: 520,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _query,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  errorText: _error,
                  errorMaxLines: 3,
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            if (_busy) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(l10n.aniListHint, style: theme.textTheme.bodySmall),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (results != null && results.isEmpty)
                    ListTile(enabled: false, title: Text(l10n.pickerEmpty)),
                  for (final m in results ?? const <AniListMedia>[])
                    ListTile(
                      enabled: !_busy,
                      leading: SizedBox(
                        width: 40,
                        child: m.coverUrl == null
                            ? const Icon(Icons.image_not_supported_outlined)
                            : Image.network(
                                '${m.coverUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              ),
                      ),
                      title: Text(m.title),
                      subtitle: Text(
                        [
                          if (m.titles.firstOrNull case final t?
                              when t != m.title)
                            t,
                          ?m.format?.replaceAll('_', ' ').toLowerCase(),
                          if (m.year case final y?) '$y',
                          if (m.isAdult) '18+',
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _take(m),
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
