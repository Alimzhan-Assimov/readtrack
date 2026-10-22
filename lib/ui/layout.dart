import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Breakpoints following the Material 3 window size classes.
abstract final class Breakpoints {
  /// From here on, list and details are shown side by side.
  static const expanded = 840.0;
}

/// Maximum width for text and forms so lines stay readable.
const kReadableWidth = 720.0;

/// Horizontal padding that centers content at [kReadableWidth] in wide
/// windows.
EdgeInsets readablePadding(double width, {double top = 0, double bottom = 0}) {
  final side = math.max(16.0, (width - kReadableWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}
