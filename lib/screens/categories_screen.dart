import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/database_scope.dart';
import '../l10n/l10n.dart';
import '../ui/layout.dart';
import '../widgets/text_prompt.dart';
import 'franchise_screen.dart';

/// The library's categories (franchises): open, rename, or merge one into
/// another. A merged name is remembered, so later imports land right.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Stream<List<Fandom>> _fandoms;
  late Stream<Map<int, List<String>>> _aliases;
  Map<int, int> _counts = const {};

  AppDatabase get _db => DatabaseScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fandoms = _db.watchFandoms();
    _aliases = _db.watchFandomAliases();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final counts = await _db.usageCounts(UsageKind.fandom);
    if (mounted) setState(() => _counts = counts);
  }

  Future<void> _rename(Fandom f) async {
    final name = await showTextPrompt(
      context,
      title: context.l10n.renameCategory,
      initial: f.name,
    );
    if (name != null && name.isNotEmpty) await _db.renameFandom(f.id, name);
  }

  Future<void> _merge(Fandom f, List<Fandom> all) async {
    final l10n = context.l10n;
    final into = await showDialog<Fandom>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.mergeCategoryTitle(f.name)),
        children: [
          for (final other in all)
            if (other.id != f.id)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, other),
                child: Text(other.name),
              ),
        ],
      ),
    );
    if (into == null) return;
    await _db.mergeFandom(f.id, into.id);
    await _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      body: StreamBuilder<List<Fandom>>(
        stream: _fandoms,
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Fandom>[];
          return StreamBuilder<Map<int, List<String>>>(
            stream: _aliases,
            builder: (context, aliasSnapshot) {
              final aliases = aliasSnapshot.data ?? const {};
              return LayoutBuilder(
                builder: (context, constraints) => ListView(
                  padding: readablePadding(constraints.maxWidth, bottom: 32),
                  children: [
                    Text(l10n.categoriesHint, style: theme.textTheme.bodySmall),
                    if (all.isEmpty)
                      ListTile(enabled: false, title: Text(l10n.pickerEmpty)),
                    for (final f in all)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(f.name),
                        subtitle: Text(
                          [
                            l10n.entryCount(_counts[f.id] ?? 0),
                            if (aliases[f.id] case final a?)
                              l10n.categoryAliases(a.length),
                          ].join(' · '),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FranchiseScreen(fandom: f),
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          tooltip: l10n.moreOptions,
                          onSelected: (action) => switch (action) {
                            'rename' => _rename(f),
                            'merge' => _merge(f, all),
                            final key => _db.removeFandomAlias(key),
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text(l10n.renameCategory),
                            ),
                            PopupMenuItem(
                              value: 'merge',
                              child: Text(l10n.mergeCategoryInto),
                            ),
                            for (final key in aliases[f.id] ?? const [])
                              PopupMenuItem(
                                value: key,
                                child: Text(l10n.removeSynonym(key)),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
