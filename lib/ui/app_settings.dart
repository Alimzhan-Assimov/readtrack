import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../library/shelves.dart';
import '../opds/opds.dart';

/// Reading modes for image chapters.
enum MangaMode {
  /// Page by page, left to right.
  pages,

  /// Page by page, right to left (Japanese manga).
  pagesRtl,

  /// One long strip (webtoons).
  scroll,
}

enum ReaderFont {
  system(null),
  serif('serif'),
  sans('sans-serif'),
  mono('monospace');

  const ReaderFont(this.family);

  /// Generic family name resolved by the platform (fontconfig on Linux).
  final String? family;
}

enum ReaderTheme {
  /// Follows the app's light or dark theme.
  app(null, null),
  light(Color(0xFFFFFFFF), Color(0xFF1C1B1F)),
  sepia(Color(0xFFF4ECD8), Color(0xFF433422)),
  dark(Color(0xFF1E1E1E), Color(0xFFE0E0E0)),
  black(Color(0xFF000000), Color(0xFFBDBDBD));

  const ReaderTheme(this.background, this.text);
  final Color? background;
  final Color? text;
}

/// How chapter text looks in the reader.
@immutable
class ReaderPrefs {
  const ReaderPrefs({
    this.fontSize = 18,
    this.font = ReaderFont.serif,
    this.lineHeight = 1.6,
    this.theme = ReaderTheme.app,
    this.justify = false,
  });

  final double fontSize;
  final ReaderFont font;
  final double lineHeight;
  final ReaderTheme theme;
  final bool justify;

  ReaderPrefs copyWith({
    double? fontSize,
    ReaderFont? font,
    double? lineHeight,
    ReaderTheme? theme,
    bool? justify,
  }) => ReaderPrefs(
    fontSize: fontSize ?? this.fontSize,
    font: font ?? this.font,
    lineHeight: lineHeight ?? this.lineHeight,
    theme: theme ?? this.theme,
    justify: justify ?? this.justify,
  );
}

/// App-wide settings, stored in the database. Screens rebuild when they
/// change.
class AppSettings extends ChangeNotifier {
  AppSettings(this._db);

  final AppDatabase _db;

  static const _hideAdultTagsKey = 'hideAdultTags';

  bool _hideAdultTags = false;
  ReaderPrefs _reader = const ReaderPrefs();
  bool _gridView = false;
  List<Shelf> _shelves = const [];
  List<OpdsCatalog> _catalogs = const [];

  bool _checkOnStart = true;

  static const _gridViewKey = 'library.grid';
  static const _checkOnStartKey = 'updates.onStart';

  /// Whether online stories are checked for new chapters when the app starts.
  bool get checkOnStart => _checkOnStart;

  Future<void> setCheckOnStart(bool check) async {
    _checkOnStart = check;
    notifyListeners();
    await _db.setSetting(_checkOnStartKey, '$check');
  }

  static const _autoDownloadKey = 'updates.autoDownload';
  bool _autoDownload = false;

  /// Whether new chapters found by a check extend existing downloads.
  bool get autoDownload => _autoDownload;

  Future<void> setAutoDownload(bool value) async {
    _autoDownload = value;
    notifyListeners();
    await _db.setSetting(_autoDownloadKey, '$value');
  }

  static const _shelvesKey = 'library.shelves';

  /// Whether the library shows covers in a grid instead of a list.
  bool get gridView => _gridView;

  Future<void> setGridView(bool grid) async {
    _gridView = grid;
    notifyListeners();
    await _db.setSetting(_gridViewKey, '$grid');
  }

  static const _mangaModeKey = 'manga.mode', _doublePageKey = 'manga.double';
  MangaMode _mangaMode = MangaMode.pages;
  bool _doublePage = false;

  /// How chapters made only of images (manga, comics) are shown.
  MangaMode get mangaMode => _mangaMode;

  /// Two pages side by side in wide windows.
  bool get doublePage => _doublePage;

  Future<void> setMangaMode(MangaMode mode) async {
    _mangaMode = mode;
    notifyListeners();
    await _db.setSetting(_mangaModeKey, mode.name);
  }

  Future<void> setDoublePage(bool double) async {
    _doublePage = double;
    notifyListeners();
    await _db.setSetting(_doublePageKey, '$double');
  }

  List<Shelf> get shelves => _shelves;

  /// Saves [shelf], replacing one with the same name.
  Future<void> saveShelf(Shelf shelf) => _storeShelves([
    for (final s in _shelves)
      if (s.name != shelf.name) s,
    shelf,
  ]);

  Future<void> deleteShelf(String name) => _storeShelves([
    for (final s in _shelves)
      if (s.name != name) s,
  ]);

  Future<void> _storeShelves(List<Shelf> shelves) async {
    _shelves = shelves;
    notifyListeners();
    await _db.setSetting(
      _shelvesKey,
      jsonEncode([for (final s in shelves) s.toJson()]),
    );
  }

  static const _catalogsKey = 'opds.catalogs';

  /// The user's own OPDS catalogs (the free ones in [kDefaultCatalogs]
  /// are always offered too).
  List<OpdsCatalog> get catalogs => _catalogs;

  Future<void> addCatalog(OpdsCatalog catalog) => _storeCatalogs([
    for (final c in _catalogs)
      if (c.url != catalog.url) c,
    catalog,
  ]);

  Future<void> removeCatalog(Uri url) => _storeCatalogs([
    for (final c in _catalogs)
      if (c.url != url) c,
  ]);

  Future<void> _storeCatalogs(List<OpdsCatalog> catalogs) async {
    _catalogs = catalogs;
    notifyListeners();
    await _db.setSetting(
      _catalogsKey,
      jsonEncode([for (final c in catalogs) c.toJson()]),
    );
  }

  static const _readerKeys = (
    fontSize: 'reader.fontSize',
    font: 'reader.font',
    lineHeight: 'reader.lineHeight',
    theme: 'reader.theme',
    justify: 'reader.justify',
  );

  ReaderPrefs get reader => _reader;

  Future<void> setReader(ReaderPrefs prefs) async {
    _reader = prefs;
    notifyListeners();
    await _db.setSetting(_readerKeys.fontSize, '${prefs.fontSize}');
    await _db.setSetting(_readerKeys.font, prefs.font.name);
    await _db.setSetting(_readerKeys.lineHeight, '${prefs.lineHeight}');
    await _db.setSetting(_readerKeys.theme, prefs.theme.name);
    await _db.setSetting(_readerKeys.justify, '${prefs.justify}');
  }

  /// Whether tags marked as 18+ are hidden everywhere in the app.
  bool get hideAdultTags => _hideAdultTags;

  Future<void> load() async {
    _hideAdultTags = await _db.setting(_hideAdultTagsKey) == 'true';
    _gridView = await _db.setting(_gridViewKey) == 'true';
    _mangaMode =
        MangaMode.values.asNameMap()[await _db.setting(_mangaModeKey)] ??
        MangaMode.pages;
    _doublePage = await _db.setting(_doublePageKey) == 'true';
    _checkOnStart = await _db.setting(_checkOnStartKey) != 'false';
    _autoDownload = await _db.setting(_autoDownloadKey) == 'true';
    final shelves = await _db.setting(_shelvesKey);
    if (shelves != null) {
      try {
        _shelves = [
          for (final s in jsonDecode(shelves) as List)
            Shelf.fromJson((s as Map).cast<String, Object?>()),
        ];
      } on FormatException {
        _shelves = const [];
      }
    }
    final catalogs = await _db.setting(_catalogsKey);
    if (catalogs != null) {
      try {
        _catalogs = [
          for (final c in jsonDecode(catalogs) as List)
            OpdsCatalog.fromJson((c as Map).cast<String, Object?>()),
        ];
      } on FormatException {
        _catalogs = const [];
      }
    }
    const defaults = ReaderPrefs();
    T byName<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    _reader = ReaderPrefs(
      fontSize:
          double.tryParse(await _db.setting(_readerKeys.fontSize) ?? '') ??
          defaults.fontSize,
      font: byName(
        ReaderFont.values,
        await _db.setting(_readerKeys.font),
        defaults.font,
      ),
      lineHeight:
          double.tryParse(await _db.setting(_readerKeys.lineHeight) ?? '') ??
          defaults.lineHeight,
      theme: byName(
        ReaderTheme.values,
        await _db.setting(_readerKeys.theme),
        defaults.theme,
      ),
      justify: await _db.setting(_readerKeys.justify) == 'true',
    );
    notifyListeners();
  }

  Future<void> setHideAdultTags(bool hide) async {
    _hideAdultTags = hide;
    notifyListeners();
    await _db.setSetting(_hideAdultTagsKey, '$hide');
  }

  /// [tags] without the adult ones while they are hidden.
  List<Tag> visibleTags(List<Tag> tags) => _hideAdultTags
      ? [
          for (final t in tags)
            if (!t.isAdult) t,
        ]
      : tags;
}

class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// The settings, or null outside a [SettingsScope] (e.g. in tests).
  static AppSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()?.notifier;

  /// Tags to show for the current settings.
  static List<Tag> visibleTags(BuildContext context, List<Tag> tags) =>
      maybeOf(context)?.visibleTags(tags) ?? tags;
}
