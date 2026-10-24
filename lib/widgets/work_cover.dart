import 'dart:io';

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../ui/labels.dart';

/// A work's cover at a 2:3 aspect ratio. Without a cover image it shows a
/// placeholder colored from the title, so list entries are easy to tell apart.
class WorkCover extends StatelessWidget {
  const WorkCover({
    super.key,
    required this.work,
    this.width = 48,
    this.heroTag,
  });

  final Work work;
  final double width;

  /// Set to animate the cover between pages. Must be unique per route.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(work: work, width: width);
    // A downloaded cover works offline; the online one is the fallback.
    final path = work.coverPath;
    final url = work.coverUrl;
    final Widget image;
    if (path != null && File(path).existsSync()) {
      image = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else if (url != null) {
      image = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else {
      image = placeholder;
    }
    Widget cover = ClipRRect(
      borderRadius: BorderRadius.circular(width / 8),
      child: SizedBox(width: width, height: width * 1.5, child: image),
    );
    if (heroTag != null) cover = Hero(tag: heroTag!, child: cover);
    return cover;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.work, required this.width});

  final Work work;
  final double width;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Own hash instead of String.hashCode so the color stays stable.
    final hash = work.title.codeUnits.fold(
      0,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    final base = HSLColor.fromAHSL(
      1,
      (hash % 360).toDouble(),
      0.45,
      dark ? 0.30 : 0.82,
    );
    return ColoredBox(
      color: base.toColor(),
      child: Center(
        child: Icon(
          work.type.icon,
          size: width * 0.45,
          color: base.withLightness(dark ? 0.85 : 0.25).toColor(),
        ),
      ),
    );
  }
}
