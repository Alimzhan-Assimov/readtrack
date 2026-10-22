import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:readtrack/sources/html_clean.dart';

String clean(String html) => cleanHtml(
  html_parser.parseFragment('<div>$html</div>').children.first,
  base: Uri.parse('https://example.com/story/1'),
);

void main() {
  test('keeps paragraphs and emphasis, drops scripts and wrappers', () {
    expect(
      clean(
        '<p>Hello <b>bold</b> <span style="x">and <i>italic</i></span></p>'
        '<script>alert(1)</script><div class="ad"><p>Second</p></div>',
      ),
      '<p>Hello <strong>bold</strong> and <em>italic</em></p><p>Second</p>',
    );
  });

  test('wraps loose text and line breaks into paragraphs', () {
    expect(
      clean('First line<br>second line'),
      '<p>First line<br>second line</p>',
    );
  });

  test('handles paragraphs nested in list items and quotes', () {
    expect(
      clean(
        '<ul><li><p>One</p></li><li>Two</li></ul><blockquote>Quoted</blockquote>',
      ),
      '<ul><li>One</li><li>Two</li></ul><blockquote><p>Quoted</p></blockquote>',
    );
  });

  test('resolves images and drops empty paragraphs', () {
    expect(
      clean(
        '<p>&nbsp;</p><img src="/img/a.png" alt="Map"><p><br></p><img src="data:x">',
      ),
      '<img src="https://example.com/img/a.png" alt="Map">',
    );
  });

  test('turns table rows into paragraphs', () {
    expect(
      clean(
        '<table><tr><th>Name</th><th>Type</th></tr><tr><td>Debugger</td><td>Skill</td></tr></table>',
      ),
      '<p>Name | Type</p><p>Debugger | Skill</p>',
    );
  });

  test('escapes text', () {
    expect(clean('<p>a &lt;b&gt; &amp; c</p>'), '<p>a &lt;b&gt; &amp; c</p>');
  });

  test('plain text keeps paragraph breaks and marks images', () {
    final text = htmlToPlainText(
      '<h2>Title</h2><p>One<br>two</p><hr><img src="x" alt="Map"><ul><li>A</li></ul>',
    );
    expect(text, 'Title\n\nOne\ntwo\n\n* * *\n\n[Image: Map]\n\n• A');
  });

  test('counts words in several scripts', () {
    expect(countWords('Hello, world! It’s 2026.'), 4);
    expect(countWords('Ответа на свое «всё куплю»'), 5);
  });
}
