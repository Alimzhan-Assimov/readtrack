import 'package:flutter/material.dart';

import '../data/database.dart';

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
