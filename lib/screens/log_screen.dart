import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../diagnostics/app_log.dart';
import '../l10n/l10n.dart';
import '../library/library_scope.dart';
import '../reader/reader_screen.dart' show openFile;

/// Shows the diagnostic log, newest lines last, and lets it be copied,
/// saved as a file for a bug report, or cleared.
class LogScreen extends StatefulWidget {
  const LogScreen({super.key, this.log});

  /// Defaults to [AppLog.instance].
  final AppLog? log;

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  AppLog? get _log => widget.log ?? AppLog.instance;
  late Future<String> _text = _load();
  final _scroll = ScrollController();

  Future<String> _load() async => await _log?.read() ?? '';

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final log = _log;
    if (log == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final stamp = DateTime.now()
        .toIso8601String()
        .split('.')
        .first
        .replaceAll(':', '-');
    final file = await log.export(
      File(
        p.join(
          LibraryScope.of(context).storage.exportDir.path,
          'Logs',
          'readtrack-$stamp.log',
        ),
      ),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.logExported(file.path)),
        action: SnackBarAction(
          label: l10n.openFile,
          onPressed: () => openFile(file.path),
        ),
      ),
    );
  }

  Future<void> _clear() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearLogTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clearLog),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _log?.clear();
    setState(() => _text = _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logTitle),
        actions: [
          FutureBuilder<String>(
            future: _text,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(Icons.copy),
              tooltip: l10n.copyLog,
              onPressed: snapshot.data?.isNotEmpty == true
                  ? () => Clipboard.setData(ClipboardData(text: snapshot.data!))
                  : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: l10n.exportLog,
            onPressed: _log == null ? null : _export,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.clearLog,
            onPressed: _log == null ? null : _clear,
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _text,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final text = snapshot.data!;
          if (text.isEmpty) {
            return Center(child: Text(l10n.logEmpty));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.jumpTo(_scroll.position.maxScrollExtent);
            }
          });
          return Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
