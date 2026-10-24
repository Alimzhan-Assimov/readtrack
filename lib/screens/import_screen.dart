import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../diagnostics/app_log.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/story_sync.dart';
import '../sources/sources.dart';
import '../ui/layout.dart';
import 'work_edit_screen.dart';

/// "Add from link": loads a story's details from its site and opens the
/// prefilled form. Pops with the new work's id.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _url = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _url.text = text;
      setState(() => _error = null);
    }
  }

  Future<void> _fetch() async {
    final l10n = context.l10n;
    final db = DatabaseScope.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final url = parseUserUrl(_url.text);
    final source = url == null ? null : sourceFor(url);
    if (url == null || source == null) {
      setState(
        () => _error = url == null
            ? l10n.importInvalidLink
            : l10n.importUnsupported,
      );
      return;
    }
    final existing = await db.workBySourceUrl(source.storyUrl(url).toString());
    if (existing != null) {
      final trashed = existing.deletedAt != null;
      if (trashed) await db.restoreFromTrash(existing.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            trashed ? l10n.restoredFromTrash : l10n.importAlreadyInLibrary,
          ),
        ),
      );
      navigator.pop(existing.id);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final info = await loadStoryInfo(source, url);
      if (!mounted) return;
      setState(() => _loading = false);
      final id = await navigator.push<int>(
        MaterialPageRoute(builder: (_) => WorkEditScreen(imported: info)),
      );
      if (id != null) navigator.pop(id);
    } on SourceException catch (e) {
      logWarning(
        'import',
        'Story failed to load',
        context: {'source': source.name, 'url': '$url'},
        error: e.message,
      );
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final url = parseUserUrl(_url.text);
    final source = url == null ? null : sourceFor(url);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: readablePadding(constraints.maxWidth, top: 8, bottom: 32),
          children: [
            Text(l10n.importIntro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _url,
              autofocus: true,
              enabled: !_loading,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n.importLinkLabel,
                hintText: 'https://www.fanfiction.net/s/…',
                errorText: _error,
                errorMaxLines: 4,
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: l10n.importPaste,
                  onPressed: _loading ? null : _paste,
                ),
              ),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _fetch(),
            ),
            if (source != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.importDetected(source.name),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _loading ? null : _fetch,
                icon: _loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(_loading ? l10n.importLoading : l10n.importFetch),
              ),
            ),
            if (_loading && source?.fetchMode == FetchMode.browser)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.readerBrowserHint,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 32),
            Text(
              l10n.importSupported,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in kSources) Chip(label: Text(s.name))],
            ),
            const SizedBox(height: 12),
            Text(l10n.importBrowserNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
