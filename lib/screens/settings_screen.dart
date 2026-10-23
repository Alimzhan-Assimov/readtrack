import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../library/backup.dart';
import '../library/library_scope.dart';
import '../ui/app_settings.dart';
import '../ui/layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _search = TextEditingController();
  late Stream<List<Tag>> _tags;

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tags = _db.watchAllTags();
  }

  bool _busy = false;

  Future<void> _createBackup() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final storage = LibraryScope.of(context).storage;
    setState(() => _busy = true);
    try {
      final backup = await LibraryBackup.open(storage);
      final file = await backup.create(
        _db,
        Directory(p.join(storage.exportDir.path, 'Backups')),
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupCreated(file.path))),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final storage = LibraryScope.of(context).storage;
    final picked = await openFile(
      initialDirectory: p.join(storage.exportDir.path, 'Backups'),
      acceptedTypeGroups: [
        XTypeGroup(label: l10n.backupFiles, extensions: const ['zip']),
      ],
    );
    if (picked == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreBackupTitle),
        content: Text(l10n.restoreBackupWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.restoreBackup),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final backup = await LibraryBackup.open(storage);
      await backup.stageRestore(File(picked.path));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(l10n.restoreReadyTitle),
          content: Text(l10n.restoreReadyHint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.later),
            ),
            FilledButton(onPressed: () => exit(0), child: Text(l10n.closeApp)),
          ],
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.restoreFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = SettingsScope.maybeOf(context);
    final query = _search.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) => StreamBuilder<List<Tag>>(
          stream: _tags,
          builder: (context, snapshot) {
            final tags = [
              for (final t in snapshot.data ?? const <Tag>[])
                if (t.name.toLowerCase().contains(query)) t,
            ];
            return ListView(
              padding: readablePadding(constraints.maxWidth, bottom: 32),
              children: [
                if (settings != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.visibility_off_outlined),
                    title: Text(l10n.hideAdultTags),
                    subtitle: Text(l10n.hideAdultTagsHint),
                    value: settings.hideAdultTags,
                    onChanged: settings.setHideAdultTags,
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.backupHeading,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.backupHint, style: theme.textTheme.bodySmall),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !_busy,
                  leading: const Icon(Icons.archive_outlined),
                  title: Text(l10n.createBackup),
                  onTap: _createBackup,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !_busy,
                  leading: const Icon(Icons.settings_backup_restore),
                  title: Text(l10n.restoreBackup),
                  onTap: _restoreBackup,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.adultTagsHeading,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.adultTagsHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: l10n.pickerSearch,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                if (tags.isEmpty)
                  ListTile(enabled: false, title: Text(l10n.pickerEmpty)),
                for (final tag in tags)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(tag.name),
                    secondary: tag.isAdult ? const Text('18+') : null,
                    value: tag.isAdult,
                    onChanged: (adult) =>
                        _db.setTagAdult(tag.id, adult ?? false),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
