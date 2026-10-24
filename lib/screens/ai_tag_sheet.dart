import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../ai/ai_client.dart';
import '../ai/ai_tags.dart';
import '../data/database.dart';
import '../data/database_scope.dart';
import '../diagnostics/app_log.dart';
import '../l10n/l10n.dart';
import '../sources/fetcher.dart';

/// Asks how much of [item] to send, says how many words that is, and asks
/// the AI for tag suggestions. Returns how many it suggested, or null.
Future<int?> suggestTagsWithAiSheet(
  BuildContext context,
  WorkWithDetails item,
  AiConfig config, {
  KeyStore keys = const SecureKeyStore(),
  AiClient Function(AiConfig config, String? key)? openClient,
}) => showModalBottomSheet<int>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _AiTagSheet(
    item: item,
    config: config,
    keys: keys,
    openClient: openClient ?? (c, k) => AiClient(c, apiKey: k),
  ),
);

class _AiTagSheet extends StatefulWidget {
  const _AiTagSheet({
    required this.item,
    required this.config,
    required this.keys,
    required this.openClient,
  });

  final WorkWithDetails item;
  final AiConfig config;
  final KeyStore keys;
  final AiClient Function(AiConfig config, String? key) openClient;

  @override
  State<_AiTagSheet> createState() => _AiTagSheetState();
}

class _AiTagSheetState extends State<_AiTagSheet> {
  List<Chapter>? _chapters;
  late AiTagMode _mode = (widget.item.work.aiAnalyzedChapter ?? 0) > 0
      ? AiTagMode.newChapters
      : AiTagMode.quick;
  bool _sending = false;
  String? _error;

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_chapters != null) return;
    _chapters = const [];
    _db.chaptersOf(widget.item.work.id).then((c) {
      if (mounted) setState(() => _chapters = c);
    });
  }

  AiExcerpt get _excerpt => pickExcerpt(
    _chapters ?? const [],
    _mode,
    analyzedUpTo: widget.item.work.aiAnalyzedChapter ?? 0,
  );

  Future<void> _send() async {
    final excerpt = _excerpt;
    setState(() {
      _sending = true;
      _error = null;
    });
    final key = await widget.keys.read(widget.config.provider);
    final client = widget.openClient(widget.config, key);
    try {
      final w = widget.item.work;
      final found = await suggestTagsWithAi(
        client,
        work: w,
        currentTags: [for (final t in widget.item.tags) t.name],
        allowed: await allowedTags(_db),
        excerpt: excerpt,
      );
      final added = await _db.suggestTags(
        w.id,
        found,
        source: widget.config.provider.label,
      );
      await _db.updateWork(
        w.id,
        WorksCompanion(aiAnalyzedChapter: Value(excerpt.lastChapter)),
        touch: false,
      );
      if (mounted) Navigator.pop(context, added);
    } on SourceException catch (e) {
      logWarning(
        'ai',
        'Tag suggestion failed',
        context: {'provider': widget.config.provider.name},
        error: e.message,
      );
      if (mounted) setState(() => _error = e.message);
    } on FormatException {
      if (mounted) setState(() => _error = context.l10n.aiTestOdd);
    } finally {
      client.close();
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final excerpt = _excerpt;
    final analyzed = widget.item.work.aiAnalyzedChapter ?? 0;
    final summaryWords = (widget.item.work.summary ?? '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aiSuggestTags, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioGroup<AiTagMode>(
              groupValue: _mode,
              onChanged: (m) => setState(() => _mode = m ?? _mode),
              child: Column(
                children: [
                  for (final (mode, title, hint) in [
                    (AiTagMode.quick, l10n.aiModeQuick, l10n.aiModeQuickHint),
                    (
                      AiTagMode.thorough,
                      l10n.aiModeThorough,
                      l10n.aiModeThoroughHint,
                    ),
                    if (analyzed > 0)
                      (
                        AiTagMode.newChapters,
                        l10n.aiModeNew,
                        l10n.aiModeNewHint(analyzed),
                      ),
                  ])
                    RadioListTile<AiTagMode>(
                      value: mode,
                      contentPadding: EdgeInsets.zero,
                      title: Text(title),
                      subtitle: Text(hint),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aiWillSend(
                excerpt.words + summaryWords,
                widget.config.provider.label,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (excerpt.words == 0)
              Text(l10n.aiNoChapters, style: theme.textTheme.bodySmall),
            if (_error case final e?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  e,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: _sending
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(l10n.aiSend),
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
