import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsFormat on AppLocalizations {
  /// 45300 -> "45,300" (separator depends on the locale).
  String formatNumber(int n) =>
      NumberFormat.decimalPattern(localeName).format(n);
}
