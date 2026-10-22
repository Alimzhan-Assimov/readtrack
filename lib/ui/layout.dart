import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Breakpoints nach den Material-3-Fenstergrößenklassen.
abstract final class Breakpoints {
  /// Ab hier Liste und Details nebeneinander.
  static const expanded = 840.0;
}

/// Maximale Breite für Text und Formulare, damit Zeilen lesbar bleiben.
const kReadableWidth = 720.0;

/// Seitenabstand, der Inhalte in breiten Fenstern auf [kReadableWidth]
/// zentriert.
EdgeInsets readablePadding(double width, {double top = 0, double bottom = 0}) {
  final side = math.max(16.0, (width - kReadableWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}
