import 'package:xml/xml.dart';

import '../sources/fetcher.dart';

/// An OPDS catalog the user can browse, e.g. Project Gutenberg or their own
/// Calibre library.
class OpdsCatalog {
  const OpdsCatalog(this.name, this.url, {this.searchUrl});

  final String name;
  final Uri url;

  /// A search address with `{searchTerms}`, for catalogs whose feeds don't
  /// announce one.
  final String? searchUrl;

  factory OpdsCatalog.fromJson(Map<String, Object?> json) => OpdsCatalog(
    json['name'] as String? ?? '',
    Uri.parse(json['url'] as String? ?? ''),
    searchUrl: json['searchUrl'] as String?,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'url': '$url',
    if (searchUrl != null) 'searchUrl': searchUrl,
  };
}

/// Catalogs of free, legal books that every user gets.
final kDefaultCatalogs = [
  OpdsCatalog(
    'Project Gutenberg',
    Uri.parse('https://www.gutenberg.org/ebooks.opds/'),
    searchUrl:
        'https://www.gutenberg.org/ebooks/search.opds/?query={searchTerms}',
  ),
  OpdsCatalog(
    'Standard Ebooks',
    // Browsing the OPDS feeds needs a membership; new releases and search
    // are open.
    Uri.parse('https://standardebooks.org/feeds/atom/new-releases'),
    searchUrl: 'https://standardebooks.org/feeds/opds/all?query={searchTerms}',
  ),
];

/// A file to download for an entry.
typedef OpdsAcquisition = ({Uri url, String type});

class OpdsEntry {
  const OpdsEntry({
    required this.title,
    this.author,
    this.summary,
    this.coverUrl,
    this.pageUrl,
    this.navigationUrl,
    this.acquisitions = const [],
  });

  final String title;
  final String? author;
  final String? summary;
  final Uri? coverUrl;

  /// The book's web page, kept as the entry's source link.
  final Uri? pageUrl;

  /// For a section of the catalog (a subfeed) instead of a book.
  final Uri? navigationUrl;
  final List<OpdsAcquisition> acquisitions;

  bool get isBook => acquisitions.isNotEmpty;

  OpdsEntry withPage(Uri page) => OpdsEntry(
    title: title,
    author: author,
    summary: summary,
    coverUrl: coverUrl,
    pageUrl: page,
    navigationUrl: navigationUrl,
    acquisitions: acquisitions,
  );

  /// The best file ReadTrack can import: EPUB, then FB2, then plain text.
  OpdsAcquisition? get bestFile {
    for (final wanted in [
      RegExp(r'^application/epub\+zip'),
      RegExp('fb2|fictionbook'),
      RegExp('^text/plain'),
    ]) {
      for (final a in acquisitions) {
        if (wanted.hasMatch(a.type)) return a;
      }
    }
    return null;
  }
}

class OpdsFeed {
  const OpdsFeed({
    required this.title,
    required this.entries,
    this.next,
    this.searchUrl,
    this.searchDescription,
  });

  final String title;
  final List<OpdsEntry> entries;
  final Uri? next;

  /// A search address with `{searchTerms}`.
  final String? searchUrl;

  /// An OpenSearch description to read the search address from.
  final Uri? searchDescription;
}

/// Parses an OPDS 1.x (Atom) feed; links are resolved against [base].
OpdsFeed parseOpdsFeed(String text, Uri base) {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(text);
  } on XmlException {
    throw SourceException('This is not an OPDS catalog feed.');
  }
  final feed = doc.rootElement;
  if (feed.localName != 'feed') {
    throw SourceException('This is not an OPDS catalog feed.');
  }

  String? text0(XmlElement e, String name) {
    final v = e.findElements(name, namespaceUri: '*').firstOrNull?.innerText;
    final t = v?.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t == null || t.isEmpty ? null : t;
  }

  Uri? resolve(String? href) => href == null ? null : base.resolve(href);

  final links = feed.findElements('link', namespaceUri: '*').toList();
  String? searchUrl;
  Uri? searchDescription;
  for (final l in links.where((l) => l.getAttribute('rel') == 'search')) {
    final href = l.getAttribute('href');
    if (href == null) continue;
    if (href.contains('{searchTerms}')) {
      searchUrl ??=
          base.resolve(href.split('{').first).toString() +
          href.substring(href.indexOf('{'));
    } else if ((l.getAttribute('type') ?? '').contains('opensearch')) {
      searchDescription ??= base.resolve(href);
    }
  }

  final entries = <OpdsEntry>[];
  for (final e in feed.findElements('entry', namespaceUri: '*')) {
    final title = text0(e, 'title');
    if (title == null) continue;
    final authors = [
      for (final a in e.findElements('author', namespaceUri: '*'))
        ?text0(a, 'name'),
    ];
    final acquisitions = <OpdsAcquisition>[];
    Uri? cover, page, navigation;
    for (final l in e.findElements('link', namespaceUri: '*')) {
      final rel = l.getAttribute('rel') ?? '';
      final type = l.getAttribute('type') ?? '';
      final href = resolve(l.getAttribute('href'));
      if (href == null || href.scheme == 'data') continue;
      if (rel.startsWith('http://opds-spec.org/acquisition') ||
          rel == 'enclosure') {
        acquisitions.add((url: href, type: type));
      } else if (rel == 'http://opds-spec.org/image') {
        cover = href;
      } else if (rel == 'http://opds-spec.org/image/thumbnail') {
        cover ??= href;
      } else if (rel == 'alternate' && type.contains('html')) {
        page ??= href;
      } else if (type.contains('profile=opds-catalog') ||
          type.contains('application/atom+xml')) {
        navigation ??= href;
      }
    }
    entries.add(
      OpdsEntry(
        title: title,
        author: authors.isEmpty ? null : authors.join(', '),
        summary: text0(e, 'summary') ?? text0(e, 'content'),
        coverUrl: cover,
        pageUrl: page,
        navigationUrl: acquisitions.isEmpty ? navigation : null,
        acquisitions: acquisitions,
      ),
    );
  }

  // A book's own feed (Gutenberg: one entry per edition) links its web page
  // from the feed.
  final books = entries.where((e) => e.isBook).toList();
  final feedPage = links
      .where(
        (l) =>
            l.getAttribute('rel') == 'alternate' &&
            (l.getAttribute('type') ?? '').contains('html'),
      )
      .map((l) => resolve(l.getAttribute('href')))
      .firstOrNull;
  if (feedPage != null &&
      books.isNotEmpty &&
      books.every((b) => b.title == books.first.title)) {
    for (final (i, e) in entries.indexed) {
      if (e.isBook && e.pageUrl == null) entries[i] = e.withPage(feedPage);
    }
  }

  final next = links
      .where((l) => l.getAttribute('rel') == 'next')
      .map((l) => resolve(l.getAttribute('href')))
      .firstOrNull;
  return OpdsFeed(
    title: text0(feed, 'title') ?? '',
    entries: entries,
    next: next,
    searchUrl: searchUrl,
    searchDescription: searchDescription,
  );
}

/// Reads the search address from an OpenSearch description.
String? parseOpenSearchTemplate(String text, Uri base) {
  try {
    final doc = XmlDocument.parse(text);
    final urls = doc.findAllElements('Url', namespaceUri: '*').toList();
    final url =
        urls
            .where((u) => (u.getAttribute('type') ?? '').contains('atom'))
            .firstOrNull ??
        urls.firstOrNull;
    final template = url?.getAttribute('template');
    if (template == null || !template.contains('{searchTerms}')) return null;
    final head = template.split('{').first;
    return base.resolve(head).toString() + template.substring(head.length);
  } on XmlException {
    return null;
  }
}

/// [template] with the search words filled in (other parameters dropped).
Uri searchUri(String template, String query) => Uri.parse(
  template
      .replaceAll('{searchTerms}', Uri.encodeQueryComponent(query))
      .replaceAll(RegExp(r'\{[^}]*\?\}'), '')
      .replaceAll(RegExp(r'\{[^}]*\}'), ''),
);

/// Loads OPDS feeds and searches catalogs.
class OpdsClient {
  OpdsClient(this.fetcher);

  final PageFetcher fetcher;

  Future<OpdsFeed> feed(Uri url) async =>
      parseOpdsFeed(await fetcher.getText(url), url);

  /// Searches [catalog]; null if it can't be searched.
  Future<OpdsFeed?> search(OpdsCatalog catalog, String query) async {
    var template = catalog.searchUrl;
    if (template == null) {
      final root = await feed(catalog.url);
      template = root.searchUrl;
      if (template == null && root.searchDescription != null) {
        template = parseOpenSearchTemplate(
          await fetcher.getText(root.searchDescription!),
          root.searchDescription!,
        );
      }
    }
    if (template == null) return null;
    return feed(searchUri(template, query));
  }
}
