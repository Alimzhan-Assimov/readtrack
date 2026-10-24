import 'package:flutter/material.dart';

/// The image sources of a chapter that is nothing but images (a manga or
/// comic chapter), or null if it has text.
List<String>? imageOnlyPages(String html) {
  final sources = [
    for (final m in RegExp(r'<img[^>]+src="([^"]+)"').allMatches(html))
      m.group(1)!.replaceAll('&amp;', '&'),
  ];
  if (sources.isEmpty) return null;
  final text = html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'&nbsp;|\s'), '');
  return text.isEmpty ? sources : null;
}

/// A chapter's pages one (or two) at a time, swiped or turned with the
/// arrow keys and by tapping the left or right edge. Right to left for
/// Japanese manga. Turning past the last page asks for the next chapter.
class MangaPages extends StatefulWidget {
  const MangaPages({
    super.key,
    required this.pages,
    required this.rightToLeft,
    required this.doublePage,
    required this.onPageChanged,
    required this.onPastEnd,
    required this.onBeforeStart,
    this.initialPage = 0,
  });

  final List<ImageProvider?> pages;
  final bool rightToLeft;

  /// Two pages side by side; the first page (the cover) stays alone.
  final bool doublePage;
  final int initialPage;

  /// The (first) page now shown, and the number of pages.
  final void Function(int page, int count) onPageChanged;
  final VoidCallback onPastEnd;
  final VoidCallback onBeforeStart;

  @override
  State<MangaPages> createState() => MangaPagesState();
}

class MangaPagesState extends State<MangaPages> {
  late List<List<int>> _spreads = _layout();
  late final PageController _controller = PageController(
    initialPage: _spreadOf(widget.initialPage),
  );

  List<List<int>> _layout() {
    final n = widget.pages.length;
    if (!widget.doublePage) {
      return [
        for (var i = 0; i < n; i++) [i],
      ];
    }
    return [
      if (n > 0) [0],
      for (var i = 1; i < n; i += 2) [i, if (i + 1 < n) i + 1],
    ];
  }

  int _spreadOf(int page) {
    final i = _spreads.indexWhere((s) => s.contains(page));
    return i < 0 ? 0 : i;
  }

  @override
  void didUpdateWidget(MangaPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doublePage != widget.doublePage ||
        oldWidget.pages.length != widget.pages.length) {
      final page = _spreads[_current].first;
      _spreads = _layout();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpToPage(_spreadOf(page));
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _current =>
      (_controller.hasClients ? _controller.page?.round() : null) ??
      _controller.initialPage;

  /// Turns to the next page, or asks for the next chapter after the last.
  void next() {
    if (_current >= _spreads.length - 1) {
      widget.onPastEnd();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void previous() {
    if (_current <= 0) {
      widget.onBeforeStart();
    } else {
      _controller.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  /// The arrow key or screen edge pointing [left].
  void turn({required bool left}) =>
      left == widget.rightToLeft ? next() : previous();

  Widget _page(int i) {
    final image = widget.pages[i];
    return image == null
        ? const Center(child: Icon(Icons.broken_image_outlined, size: 48))
        : Image(
            image: image,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image_outlined, size: 48),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTapUp: (d) {
          final x = d.localPosition.dx / constraints.maxWidth;
          if (x < 1 / 3) turn(left: true);
          if (x > 2 / 3) turn(left: false);
        },
        child: PageView.builder(
          controller: _controller,
          reverse: widget.rightToLeft,
          itemCount: _spreads.length,
          onPageChanged: (i) =>
              widget.onPageChanged(_spreads[i].first, widget.pages.length),
          itemBuilder: (context, i) {
            final spread = _spreads[i];
            // In a right-to-left spread the first page is on the right.
            final shown = widget.rightToLeft ? spread.reversed : spread;
            return InteractiveViewer(
              maxScale: 4,
              child: Row(
                children: [for (final p in shown) Expanded(child: _page(p))],
              ),
            );
          },
        ),
      ),
    );
  }
}
