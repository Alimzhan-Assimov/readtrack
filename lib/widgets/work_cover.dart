import 'package:flutter/material.dart';

import '../data/database.dart';
import '../ui/labels.dart';

/// Cover eines Werks im Seitenverhältnis 2:3. Ohne Cover-Bild wird ein
/// Platzhalter in einer aus dem Titel abgeleiteten Farbe gezeigt, damit
/// sich Einträge in der Liste auf einen Blick unterscheiden.
class WorkCover extends StatelessWidget {
  const WorkCover({
    super.key,
    required this.work,
    this.width = 48,
    this.heroTag,
  });

  final Work work;
  final double width;

  /// Gesetzt, wenn das Cover beim Seitenwechsel animiert werden soll.
  /// Muss pro Route eindeutig sein.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(work: work, width: width);
    final url = work.coverUrl;
    Widget cover = ClipRRect(
      borderRadius: BorderRadius.circular(width / 8),
      child: SizedBox(
        width: width,
        height: width * 1.5,
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
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
    // Eigener Hash statt String.hashCode, damit die Farbe stabil bleibt.
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
