import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../data/database_scope.dart';
import '../diagnostics/app_log.dart';
import '../l10n/l10n.dart';
import '../library/book_importer.dart';
import '../library/file_import.dart';
import '../library/library_scope.dart';
import '../opds/opds.dart';
import '../sources/fetcher.dart';
import '../ui/app_settings.dart';
import '../ui/layout.dart';
import 'work_edit_screen.dart';

/// Name of the catalog pages opened to attach a book to an entry, so they
/// can all be closed once it is attached.
const kAttachRoute = 'catalog-attach';

/// A catalog page route; named [kAttachRoute] when attaching to an entry.
MaterialPageRoute<T> catalogRoute<T>(int? attachTo, WidgetBuilder builder) =>
    MaterialPageRoute<T>(
      builder: builder,
      settings: RouteSettings(name: attachTo == null ? null : kAttachRoute),
    );

/// Downloads [entry]'s best file to a temporary folder and reads it.
Future<(ImportedBook, File)> downloadCatalogBook(
  OpdsEntry entry,
  PageFetcher fetcher,
) async {
  final file = entry.bestFile;
  if (file == null) {
    throw SourceException('This catalog offers no EPUB, FB2 or text file.');
  }
  final extension = file.type.contains('epub')
      ? 'epub'
      : file.type.contains('fb2') || file.type.contains('fictionbook')
      ? 'fb2'
      : 'txt';
  final dir = await Directory.systemTemp.createTemp('readtrack_opds');
  final name = entry.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final target = File(p.join(dir.path, '$name.$extension'));
  await target.writeAsBytes(await fetcher.getBytes(file.url));
  final book = await readBookFile(target.path);
  // The catalog's page beats the file's own link, which is often outdated.
  final page = entry.pageUrl;
  return (page == null ? book : book.withSource('$page'), target);
}

/// The catalogs to browse: the free ones and the user's own.
class CatalogsScreen extends StatelessWidget {
  const CatalogsScreen({super.key, this.attachTo});

  /// Attach a chosen book to this entry instead of adding a new one.
  final int? attachTo;

  Future<void> _add(BuildContext context, AppSettings settings) async {
    final catalog = await showDialog<OpdsCatalog>(
      context: context,
      builder: (_) => const _AddCatalogDialog(),
    );
    if (catalog != null) await settings.addCatalog(catalog);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = SettingsScope.maybeOf(context);
    final own = settings?.catalogs ?? const <OpdsCatalog>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogsTitle)),
      floatingActionButton: settings == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(l10n.addCatalog),
              onPressed: () => _add(context, settings),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: readablePadding(constraints.maxWidth, top: 8, bottom: 96),
          children: [
            Text(l10n.catalogsIntro),
            const SizedBox(height: 8),
            for (final c in [...kDefaultCatalogs, ...own])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_library_outlined),
                title: Text(c.name),
                subtitle: Text(c.url.host),
                trailing: own.contains(c)
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.removeCatalog,
                        onPressed: () => settings!.removeCatalog(c.url),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  catalogRoute(
                    attachTo,
                    (_) => CatalogFeedScreen(
                      catalog: c,
                      url: c.url,
                      title: c.name,
                      attachTo: attachTo,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddCatalogDialog extends StatefulWidget {
  const _AddCatalogDialog();

  @override
  State<_AddCatalogDialog> createState() => _AddCatalogDialogState();
}

class _AddCatalogDialogState extends State<_AddCatalogDialog> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _url.text.trim();
    final url = Uri.tryParse(raw.contains('://') ? raw : 'http://$raw');
    if (url == null || url.host.isEmpty) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final fetcher = HttpFetcher();
    try {
      final feed = await OpdsClient(fetcher).feed(url);
      if (!mounted) return;
      final name = _name.text.trim();
      Navigator.pop(
        context,
        OpdsCatalog(
          name.isNotEmpty
              ? name
              : (feed.title.isNotEmpty ? feed.title : url.host),
          url,
        ),
      );
    } on SourceException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      await fetcher.close();
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.addCatalog),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _url,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l10n.catalogUrl,
              hintText: 'http://localhost:8080/opds',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onSubmitted: (_) => _submit(),
          ),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.catalogName),
          ),
          if (_checking)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _checking ? null : _submit,
          child: Text(l10n.addCatalog),
        ),
      ],
    );
  }
}

/// One page of a catalog: its sections and books, a search if the catalog
/// has one, and more pages on request.
class CatalogFeedScreen extends StatefulWidget {
  const CatalogFeedScreen({
    super.key,
    required this.catalog,
    required this.url,
    required this.title,
    this.attachTo,
    this.query,
    this.fetcher,
    this.embedded = false,
  });

  /// Shown inside another page (e.g. a tab), without its own app bar.
  final bool embedded;

  final OpdsCatalog catalog;
  final Uri url;
  final String title;
  final int? attachTo;

  /// Search the catalog for this instead of showing [url].
  final String? query;

  /// For tests; a plain HTTP fetcher otherwise.
  final PageFetcher? fetcher;

  @override
  State<CatalogFeedScreen> createState() => _CatalogFeedScreenState();
}

class _CatalogFeedScreenState extends State<CatalogFeedScreen> {
  late final PageFetcher _fetcher = widget.fetcher ?? HttpFetcher();
  late final _client = OpdsClient(_fetcher);
  final _entries = <OpdsEntry>[];
  Uri? _next;
  bool _loading = true;
  String? _error;
  String? _busyTitle;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load(first: true);
    }
  }

  @override
  void dispose() {
    if (widget.fetcher == null) _fetcher.close();
    super.dispose();
  }

  Future<void> _load({bool first = false}) async {
    final noSearch = context.l10n.catalogNoSearch;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final OpdsFeed? feed;
      if (first && widget.query != null) {
        feed = await _client.search(widget.catalog, widget.query!);
        if (feed == null) {
          throw SourceException(noSearch);
        }
      } else {
        feed = await _client.feed(first ? widget.url : _next!);
      }
      if (!mounted) return;
      setState(() {
        _entries.addAll(feed!.entries);
        _next = feed.next;
      });
    } on SourceException catch (e) {
      logWarning(
        'catalog',
        'Feed failed to load',
        context: {'catalog': widget.catalog.name, 'url': '${widget.url}'},
        error: e.message,
      );
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    final l10n = context.l10n;
    final query = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(l10n.catalogSearch(widget.catalog.name)),
          content: TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (v) => Navigator.pop(context, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.searchButton),
            ),
          ],
        );
      },
    );
    if (query == null || query.isEmpty || !mounted) return;
    await Navigator.of(context).push(
      catalogRoute(
        widget.attachTo,
        (_) => CatalogFeedScreen(
          catalog: widget.catalog,
          url: widget.url,
          title: query,
          query: query,
          attachTo: widget.attachTo,
          fetcher: widget.fetcher,
        ),
      ),
    );
  }

  Future<void> _take(OpdsEntry entry) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final db = DatabaseScope.of(context);
    final storage = LibraryScope.of(context).storage;
    setState(() => _busyTitle = entry.title);
    try {
      final (book, file) = await downloadCatalogBook(entry, _fetcher);
      if (widget.attachTo case final id?) {
        await BookImporter(db, storage).attach(id, book, original: file);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.catalogAttached(entry.title))),
        );
        // Back to the entry the book was attached to.
        navigator.popUntil((r) => r.settings.name != kAttachRoute);
        return;
      }
      if (!mounted) return;
      setState(() => _busyTitle = null);
      final added = await navigator.push<int>(
        MaterialPageRoute(
          builder: (_) => WorkEditScreen(file: (book: book, path: file.path)),
        ),
      );
      if (added != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.importedFile(entry.title))),
        );
      }
    } on Exception catch (e) {
      logWarning(
        'catalog',
        'Book failed to download',
        context: {
          'catalog': widget.catalog.name,
          'url': '${entry.bestFile?.url}',
        },
        error: '$e',
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busyTitle = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.embedded
          ? (_busyTitle == null
                ? null
                : const PreferredSize(
                    preferredSize: Size.fromHeight(4),
                    child: LinearProgressIndicator(),
                  ))
          : AppBar(
              title: Text(widget.title),
              actions: [
                if (widget.query == null)
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: l10n.catalogSearch(widget.catalog.name),
                    onPressed: _search,
                  ),
              ],
              bottom: _busyTitle == null
                  ? null
                  : const PreferredSize(
                      preferredSize: Size.fromHeight(4),
                      child: LinearProgressIndicator(),
                    ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: readablePadding(constraints.maxWidth, top: 8, bottom: 32),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (!_loading && _error == null && _entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.catalogEmpty),
              ),
            for (final e in _entries)
              if (e.isBook)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 40,
                    child: e.coverUrl == null
                        ? const Icon(Icons.menu_book_outlined)
                        : Image.network(
                            '${e.coverUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.menu_book_outlined),
                          ),
                  ),
                  title: Text(e.title),
                  subtitle: Text(
                    [?e.author, ?e.summary].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: e.bestFile == null
                      ? Tooltip(
                          message: l10n.catalogNoFile,
                          child: const Icon(Icons.block),
                        )
                      : IconButton.filledTonal(
                          icon: Icon(
                            widget.attachTo == null
                                ? Icons.library_add
                                : Icons.attach_file,
                          ),
                          tooltip: widget.attachTo == null
                              ? l10n.catalogAdd
                              : l10n.catalogAttach,
                          onPressed: _busyTitle == null ? () => _take(e) : null,
                        ),
                )
              else if (e.navigationUrl case final url?)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(e.title),
                  subtitle: e.summary == null
                      ? null
                      : Text(
                          e.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    catalogRoute(
                      widget.attachTo,
                      (_) => CatalogFeedScreen(
                        catalog: widget.catalog,
                        url: url,
                        title: e.title,
                        attachTo: widget.attachTo,
                        fetcher: widget.fetcher,
                      ),
                    ),
                  ),
                ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_next != null)
              Center(
                child: TextButton(
                  onPressed: _load,
                  child: Text(l10n.catalogMore),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Searches the free catalogs for an entry's title and author, to attach a
/// legal free edition (e.g. of a paper book) or add it.
class FreeEditionsScreen extends StatelessWidget {
  const FreeEditionsScreen({super.key, required this.query, this.attachTo});

  final String query;
  final int? attachTo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: kDefaultCatalogs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.freeEditionsTitle(query)),
          bottom: TabBar(
            tabs: [for (final c in kDefaultCatalogs) Tab(text: c.name)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in kDefaultCatalogs)
              CatalogFeedScreen(
                catalog: c,
                url: c.url,
                title: query,
                query: query,
                attachTo: attachTo,
                embedded: true,
              ),
          ],
        ),
      ),
    );
  }
}
