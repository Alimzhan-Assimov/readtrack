import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Tags kept as they are; everything else is unwrapped (its children stay).
const _inlineTags = {
  'em',
  'i',
  'strong',
  'b',
  'u',
  's',
  'del',
  'strike',
  'sup',
  'sub',
};
const _dropTags = {
  'script',
  'style',
  'noscript',
  'iframe',
  'form',
  'button',
  'input',
  'select',
  'svg',
  'template',
};

/// Reduces a chapter's markup to a small, safe subset that the reader and the
/// exporters understand: paragraphs, headings, quotes, lists, rules, line
/// breaks, basic emphasis and images with absolute URLs. Tables become one
/// paragraph per row.
String cleanHtml(dom.Element root, {required Uri base}) {
  final out = StringBuffer();
  _Cleaner(out, base)
    ..children(root)
    .._closeParagraph();
  return out.toString().replaceAll(RegExp(r'<p>(?:\s|<br>)*</p>'), '').trim();
}

class _Cleaner {
  _Cleaner(this.out, this.base);

  final StringBuffer out;
  final Uri base;

  /// Whether we opened a `<p>` ourselves for loose text.
  var _implicitOpen = false;

  /// How deep we are inside explicit text blocks (`p`, `li`, headings).
  var _textDepth = 0;

  bool get _inText => _textDepth > 0 || _implicitOpen;

  void children(dom.Node node) {
    for (final child in node.nodes) {
      visit(child);
    }
  }

  void _openParagraph() {
    if (_textDepth == 0 && !_implicitOpen) {
      out.write('<p>');
      _implicitOpen = true;
    }
  }

  void _closeParagraph() {
    if (_implicitOpen) {
      out.write('</p>');
      _implicitOpen = false;
    }
  }

  void visit(dom.Node node) {
    if (node is dom.Text) {
      final text = node.text.replaceAll(RegExp(r'\s+'), ' ');
      if (text.trim().isEmpty) {
        if (_inText && text.isNotEmpty) out.write(' ');
        return;
      }
      _openParagraph();
      out.write(_escapeText(text));
      return;
    }
    if (node is! dom.Element) return;
    final tag = node.localName ?? '';
    if (_dropTags.contains(tag)) return;

    switch (tag) {
      case 'br':
        if (_inText) out.write('<br>');
      case 'hr':
        if (_textDepth > 0) {
          out.write('<br>');
        } else {
          _closeParagraph();
          out.write('<hr>');
        }
      case 'img':
        _image(node);
      case _ when _inlineTags.contains(tag):
        final name = switch (tag) {
          'b' => 'strong',
          'i' => 'em',
          'del' || 'strike' => 's',
          _ => tag,
        };
        _openParagraph();
        out.write('<$name>');
        children(node);
        out.write('</$name>');
      case _ when _textDepth > 0:
        // Blocks nested in a paragraph (invalid, but common): keep the text.
        children(node);
      case 'tr':
        final cells = node.children
            .where((c) => c.localName == 'td' || c.localName == 'th')
            .map((c) => c.text.replaceAll(RegExp(r'\s+'), ' ').trim())
            .where((t) => t.isNotEmpty);
        if (cells.isEmpty) return;
        _closeParagraph();
        out.write('<p>${_escapeText(cells.join(' | '))}</p>');
      case 'p' || 'li' || 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        final name = switch (tag) {
          'h1' || 'h2' => 'h2',
          'h3' || 'h4' || 'h5' || 'h6' => 'h3',
          _ => tag,
        };
        _closeParagraph();
        out.write('<$name>');
        _textDepth++;
        children(node);
        _textDepth--;
        out.write('</$name>');
      case 'blockquote' || 'ul' || 'ol':
        _closeParagraph();
        out.write('<$tag>');
        children(node);
        _closeParagraph();
        out.write('</$tag>');
      case 'div' ||
          'section' ||
          'article' ||
          'center' ||
          'table' ||
          'tbody' ||
          'thead':
        _closeParagraph();
        children(node);
        _closeParagraph();
      default:
        // span, a, font, ...: keep only the content.
        children(node);
    }
  }

  void _image(dom.Element node) {
    final src =
        node.attributes['data-src'] ??
        node.attributes['data-original'] ??
        node.attributes['src'];
    final url = src == null ? null : _resolve(src);
    if (url == null) return;
    if (_textDepth == 0) _closeParagraph();
    out.write('<img src="${_escape(url)}"');
    final alt = node.attributes['alt']?.trim();
    if (alt != null && alt.isNotEmpty) out.write(' alt="${_escape(alt)}"');
    out.write('>');
  }

  String? _resolve(String src) {
    final trimmed = src.trim();
    if (trimmed.isEmpty || trimmed.startsWith('data:')) return null;
    final resolved = base.resolve(
      trimmed.startsWith('//') ? 'https:$trimmed' : trimmed,
    );
    return resolved.hasScheme && resolved.scheme.startsWith('http')
        ? resolved.toString()
        : null;
  }
}

String _escapeText(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

/// For attribute values, which are written in double quotes.
String _escape(String text) => _escapeText(text).replaceAll('"', '&quot;');

/// Plain text for TXT export and word counts.
String htmlToPlainText(String cleanedHtml) {
  final root = html_parser.parseFragment(cleanedHtml);
  final out = StringBuffer();
  void walk(dom.Node node) {
    for (final child in node.nodes) {
      if (child is dom.Text) {
        out.write(child.text);
      } else if (child is dom.Element) {
        switch (child.localName) {
          case 'br':
            out.write('\n');
          case 'hr':
            out.write('\n* * *\n\n');
          case 'img':
            final alt = child.attributes['alt'];
            out.write(alt == null ? '[Image]\n\n' : '[Image: $alt]\n\n');
          case 'li':
            out.write('• ');
            walk(child);
            out.write('\n');
          case 'p' || 'h2' || 'h3' || 'blockquote' || 'ul' || 'ol':
            walk(child);
            out.write('\n\n');
          default:
            walk(child);
        }
      }
    }
  }

  walk(root);
  return out
      .toString()
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

int countWords(String plainText) => RegExp(
  r"[\p{L}\p{N}][\p{L}\p{N}'’-]*",
  unicode: true,
).allMatches(plainText).length;
