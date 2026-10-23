import 'package:flutter/widgets.dart';

import '../data/database.dart';

/// App-wide settings, stored in the database. Screens rebuild when they
/// change.
class AppSettings extends ChangeNotifier {
  AppSettings(this._db);

  final AppDatabase _db;

  static const _hideAdultTagsKey = 'hideAdultTags';

  bool _hideAdultTags = false;

  /// Whether tags marked as 18+ are hidden everywhere in the app.
  bool get hideAdultTags => _hideAdultTags;

  Future<void> load() async {
    _hideAdultTags = await _db.setting(_hideAdultTagsKey) == 'true';
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
