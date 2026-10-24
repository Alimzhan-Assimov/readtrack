import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Turns a chapter image reference into something Flutter can show: online
/// URLs as network images, downloaded ones as files.
typedef ImageResolver = ImageProvider? Function(String src);

/// Renders cleaned chapter HTML (see `cleanHtml`) as a list of widgets, one
/// per block, so long chapters can be built lazily.
List<Widget> buildChapterBlocks(
  String html, {
  required TextStyle style,
  required ImageResolver resolveImage,
  required ColorScheme colors,

  /// Saved quotes to highlight where they appear in the text.
  List<String> highlights = const [],
  TextAlign textAlign = TextAlign.start,
}) {
  final marks = _Marks([
    // A quote across paragraphs is highlighted line by line.
    for (final quote in highlights)
      for (final line in quote.split('\n'))
        if (line.trim().length >= 3) line.trim(),
  ], colors.tertiaryContainer);
  final root = html_parser.parseFragment(html);
  final blocks = <Widget>[];
  final paragraphGap = (style.fontSize ?? 16) * 0.9;

  Widget paragraph(dom.Element element, TextStyle textStyle) => Padding(
    padding: EdgeInsets.only(bottom: paragraphGap),
    child: Text.rich(
      textAlign: textAlign,
      TextSpan(
        children: _inline(element.nodes, textStyle, resolveImage, marks),
      ),
    ),
  );

  void addBlock(dom.Node node, {int quoteDepth = 0}) {
    if (node is dom.Text) {
      if (node.text.trim().isNotEmpty) {
        blocks.add(
          Padding(
            padding: EdgeInsets.only(bottom: paragraphGap),
            child: Text.rich(
              TextSpan(children: marks.spans(node.text.trim(), style)),
            ),
          ),
        );
      }
      return;
    }
    if (node is! dom.Element) return;
    Widget indent(Widget child) => quoteDepth == 0
        ? child
        : Container(
            margin: EdgeInsets.only(left: 12.0 * quoteDepth),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colors.outlineVariant, width: 3),
              ),
            ),
            child: child,
          );
    switch (node.localName) {
      case 'p':
        blocks.add(indent(paragraph(node, style)));
      case 'h2' || 'h3':
        final scale = node.localName == 'h2' ? 1.35 : 1.15;
        blocks.add(
          Padding(
            padding: EdgeInsets.only(top: paragraphGap, bottom: paragraphGap),
            child: Text.rich(
              TextSpan(
                children: _inline(
                  node.nodes,
                  style.copyWith(
                    fontSize: (style.fontSize ?? 16) * scale,
                    fontWeight: FontWeight.w600,
                  ),
                  resolveImage,
                  marks,
                ),
              ),
            ),
          ),
        );
      case 'hr':
        blocks.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: paragraphGap),
            child: Center(
              child: Text(
                '* * *',
                style: style.copyWith(color: colors.outline),
              ),
            ),
          ),
        );
      case 'img':
        if (_image(node, resolveImage) case final image?) {
          blocks.add(
            Padding(
              padding: EdgeInsets.only(bottom: paragraphGap),
              child: image,
            ),
          );
        }
      case 'blockquote':
        for (final child in node.nodes) {
          addBlock(child, quoteDepth: quoteDepth + 1);
        }
      case 'ul' || 'ol':
        var index = 0;
        for (final item in node.children.where((c) => c.localName == 'li')) {
          index++;
          final marker = node.localName == 'ol' ? '$index.' : '•';
          blocks.add(
            indent(
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: paragraphGap / 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 28, child: Text(marker, style: style)),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: _inline(
                            item.nodes,
                            style,
                            resolveImage,
                            marks,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      default:
        for (final child in node.nodes) {
          addBlock(child, quoteDepth: quoteDepth);
        }
    }
  }

  for (final node in root.nodes) {
    addBlock(node);
  }
  return blocks;
}

List<InlineSpan> _inline(
  List<dom.Node> nodes,
  TextStyle style,
  ImageResolver resolveImage,
  _Marks marks,
) {
  final spans = <InlineSpan>[];
  for (final node in nodes) {
    if (node is dom.Text) {
      spans.addAll(marks.spans(node.text, style));
    } else if (node is dom.Element) {
      final tag = node.localName;
      if (tag == 'br') {
        spans.add(TextSpan(text: '\n', style: style));
        continue;
      }
      if (tag == 'img') {
        if (_image(node, resolveImage) case final image?) {
          spans.add(WidgetSpan(child: image));
        }
        continue;
      }
      final childStyle = switch (tag) {
        'strong' => style.copyWith(fontWeight: FontWeight.bold),
        'em' => style.copyWith(fontStyle: FontStyle.italic),
        'u' => style.copyWith(decoration: TextDecoration.underline),
        's' => style.copyWith(decoration: TextDecoration.lineThrough),
        'sup' ||
        'sub' => style.copyWith(fontSize: (style.fontSize ?? 16) * 0.75),
        _ => style,
      };
      spans.addAll(_inline(node.nodes, childStyle, resolveImage, marks));
    }
  }
  return spans;
}

Widget? _image(dom.Element element, ImageResolver resolveImage) {
  final src = element.attributes['src'];
  final provider = src == null ? null : resolveImage(src);
  if (provider == null) return null;
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: provider,
        fit: BoxFit.contain,
        semanticLabel: element.attributes['alt'],
        errorBuilder: (context, _, _) =>
            const Icon(Icons.broken_image_outlined),
      ),
    ),
  );
}

/// Quotes to highlight and their color.
class _Marks {
  _Marks(this.phrases, this.color);

  final List<String> phrases;
  final Color color;

  /// [text] as spans, with every occurrence of a phrase highlighted.
  List<InlineSpan> spans(String text, TextStyle style) {
    if (phrases.isEmpty) return [TextSpan(text: text, style: style)];
    final ranges = <(int, int)>[];
    for (final phrase in phrases) {
      for (
        var i = text.indexOf(phrase);
        i >= 0;
        i = text.indexOf(phrase, i + phrase.length)
      ) {
        ranges.add((i, i + phrase.length));
      }
    }
    if (ranges.isEmpty) return [TextSpan(text: text, style: style)];
    ranges.sort((a, b) => a.$1.compareTo(b.$1));
    final marked = style.copyWith(backgroundColor: color);
    final out = <InlineSpan>[];
    var at = 0;
    for (final (start, end) in ranges) {
      if (end <= at) continue;
      final from = start < at ? at : start;
      if (from > at) {
        out.add(TextSpan(text: text.substring(at, from), style: style));
      }
      out.add(TextSpan(text: text.substring(from, end), style: marked));
      at = end;
    }
    if (at < text.length) {
      out.add(TextSpan(text: text.substring(at), style: style));
    }
    return out;
  }
}
