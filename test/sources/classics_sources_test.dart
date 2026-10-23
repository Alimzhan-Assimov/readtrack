// Parser tests for the public-domain libraries, with small hand-written pages.
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/enums.dart';
import 'package:readtrack/sources/gutenberg.dart';
import 'package:readtrack/sources/sources.dart';
import 'package:readtrack/sources/standard_ebooks.dart';
import 'package:readtrack/sources/wikisource.dart';

import 'fake_fetcher.dart';

void main() {
  test('recognizes links of the libraries', () {
    final cases = {
      'https://www.gutenberg.org/cache/epub/1342/pg1342-images.html':
          'https://www.gutenberg.org/ebooks/1342',
      'https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice/text/single-page':
          'https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice',
      'https://ru.wikisource.org/wiki/Война_и_мир_(Толстой)/Том_1': 'https://ru.wikisource.org/wiki/%D0%92%D0%BE%D0%B9%D0%BD%D0%B0_%D0%B8_%D0%BC%D0%B8%D1%80_(%D0%A2%D0%BE%D0%BB%D1%81%D1%82%D0%BE%D0%B9)/%D0%A2%D0%BE%D0%BC_1',
    };
    for (final MapEntry(key: link, value: expected) in cases.entries) {
      final url = Uri.parse(link);
      expect(sourceFor(url)?.storyUrl(url).toString(), expected, reason: link);
    }
    expect(
      sourceFor(Uri.parse('https://ru.wikisource.org/wiki/Автор:Лев_Толстой')),
      isNull,
    );
  });

  test('Project Gutenberg: splits the book file at headings', () async {
    final fetcher = FakeFetcher({
      'https://www.gutenberg.org/ebooks/77': '''
        <table><tr><td itemprop="headline">Pride and Prejudice</td></tr>
        <tr><th>Author</th><td><a itemprop="creator">Austen, Jane, 1775-1817</a></td></tr>
        <tr><th>Summary</th><td>A novel. (This is an automatically generated summary.)</td></tr></table>
        <a href="/ebooks/subject/1">Love stories</a><img class="cover-art" src="/cache/epub/77/cover.jpg">''',
      'https://www.gutenberg.org/cache/epub/77/pg77-images.html':
          '''
        <body><section id="pg-header"><h2>The Project Gutenberg eBook</h2><p>License.</p></section>
        <h2>{ix}</h2><p>${'Preface word. ' * 120}</p>
        <div class="chapter"><h2>Chapter I.</h2><p>It is a truth.</p><h2>{3}</h2><p>Still chapter one.</p></div>
        <div class="chapter"><h2>Chapter II.</h2><p>Mr. Bennet.</p></div>
        <section id="pg-footer"><p>End of the Project Gutenberg eBook.</p></section></body>''',
    });
    const source = GutenbergSource();
    final info = await source.fetchStory(
      Uri.parse('https://www.gutenberg.org/ebooks/77'),
      fetcher,
    );
    expect(
      (info.author, info.summary, info.type),
      ('Jane Austen', 'A novel.', WorkType.book),
    );
    expect(info.tags, ['Love stories']);
    expect(info.chapters.map((c) => c.title), [
      'Front matter',
      'Chapter I.',
      'Chapter II.',
    ]);
    final first = await source.fetchChapter(info.chapters[1], fetcher);
    expect(first.html, '<p>It is a truth.</p><p>Still chapter one.</p>');
    final last = await source.fetchChapter(info.chapters[2], fetcher);
    expect(last.html, '<p>Mr. Bennet.</p>');
    // The big book file was fetched once for all chapters.
    expect(
      fetcher.requests.where((r) => r.endsWith('-images.html')),
      hasLength(1),
    );
  });

  test(
    'Standard Ebooks: chapter sections of the single-page edition',
    () async {
      const book = 'https://standardebooks.org/ebooks/jane-austen/emma';
      final fetcher = FakeFetcher({
        book: '''
        <h1>Emma</h1><a property="schema:author"><span property="schema:name">Jane Austen</span></a>
        <section id="description"><div property="schema:description"><p>Emma Woodhouse.</p></div></section>
        <ul class="tags"><li><a>Fiction</a></li></ul>''',
        '$book/text/single-page': '''
        <section id="titlepage" epub:type="frontmatter titlepage"><h1>Emma</h1></section>
        <section id="chapter-1" epub:type="bodymatter chapter"><h2>I</h2><p>Emma Woodhouse, handsome.</p></section>
        <section id="chapter-2" epub:type="bodymatter chapter"><h2>II</h2><p>Mr. Weston.</p></section>''',
      });
      const source = StandardEbooksSource();
      final info = await source.fetchStory(Uri.parse(book), fetcher);
      expect(
        (info.author, info.summary, info.isComplete),
        ('Jane Austen', 'Emma Woodhouse.', true),
      );
      expect(info.chapters.map((c) => c.title), ['I', 'II']);
      expect(
        (await source.fetchChapter(info.chapters.last, fetcher)).html,
        '<p>Mr. Weston.</p>',
      );
    },
  );

  test('Wikisource: direct subpages become chapters', () async {
    String api(String page) => Uri.https('ru.wikisource.org', '/w/api.php', {
      'action': 'parse',
      'page': page,
      'prop': 'text',
      'format': 'json',
      'formatversion': '2',
      'disabletoc': '1',
      'redirects': '1',
    }).toString();
    final fetcher = FakeFetcher({
      api('Война и мир (Толстой)'): jsonString({
        'parse': {
          'text': '''
            <span id="ws-author">автор <a href="/wiki/Автор:Толстой">Лев Николаевич Толстой</a></span>
            <a href="/wiki/Война_и_мир_(Толстой)/Том_1">Том 1</a>
            <a href="/wiki/Война_и_мир_(Толстой)/Том_1/Часть_1">deeper</a>
            <a href="/wiki/Война_и_мир_(Толстой)/Том_2">Том 2</a>''',
        },
      }),
      api('Война и мир (Толстой)/Том 1'): jsonString({
        'parse': {
          'text': '''
            <div id="headertemplate">Навигация</div>
            <p><span class="noprint ws-noexport pagenumber">[3]</span>— Eh bien, mon prince.<sup class="reference">1</sup></p>''',
        },
      }),
    });
    const source = WikisourceSource();
    final info = await source.fetchStory(
      Uri.parse('https://ru.wikisource.org/wiki/Война_и_мир_(Толстой)'),
      fetcher,
    );
    expect(
      (info.title, info.author),
      ('Война и мир', 'Лев Николаевич Толстой'),
    );
    expect(info.chapters.map((c) => c.title), ['Том 1', 'Том 2']);
    expect(
      (await source.fetchChapter(info.chapters.first, fetcher)).html,
      '<p>— Eh bien, mon prince.</p>',
    );
  });
}
