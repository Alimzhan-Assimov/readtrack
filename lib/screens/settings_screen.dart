import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
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
