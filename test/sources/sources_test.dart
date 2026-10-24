// Parser tests with small hand-written pages that mimic each site's markup.
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/enums.dart';
import 'package:readtrack/sources/ao3.dart';
import 'package:readtrack/sources/author_today.dart';
import 'package:readtrack/sources/fanfiction_net.dart';
import 'package:readtrack/sources/ficbook.dart';
import 'package:readtrack/sources/royal_road.dart';
import 'package:readtrack/sources/scribble_hub.dart';
import 'package:readtrack/sources/sources.dart';
import 'package:readtrack/sources/webnovel.dart';

import 'fake_fetcher.dart';

void main() {
  group('finding the source', () {
    test('recognizes story and chapter links of every site', () {
      final cases = {
        'https://www.fanfiction.net/s/123/4/Some-Title':
            'https://www.fanfiction.net/s/123/1',
        'm.fanfiction.net/s/123': 'https://www.fanfiction.net/s/123/1',
        'https://archiveofourown.org/works/55/chapters/9':
            'https://archiveofourown.org/works/55',
        'https://www.royalroad.com/fiction/21220/mother/chapter/1/x':
            'https://www.royalroad.com/fiction/21220',
        'https://www.scribblehub.com/read/117137-the-runesmith/chapter/5/':
            'https://www.scribblehub.com/series/117137/the-runesmith/',
        'https://www.webnovel.com/book/some-title_18427226205628505/chapter-1_49620879314845238':
            'https://www.webnovel.com/book/18427226205628505',
        'https://author.today/reader/667256/6401943':
            'https://author.today/work/667256',
      };
      for (final MapEntry(key: input, value: expected) in cases.entries) {
        final url = parseUserUrl(input)!;
        expect(
          sourceFor(url)?.storyUrl(url).toString(),
          expected,
          reason: input,
        );
      }
    });

    test('unsupported sites and non-story pages give no source', () {
      expect(sourceFor(Uri.parse('https://example.com/book/1')), isNull);
      expect(
        sourceFor(Uri.parse('https://www.royalroad.com/fictions/best-rated')),
        isNull,
      );
      expect(parseUserUrl('   '), isNull);
    });
  });

  test(
    'Royal Road: metadata, chapter list and hidden anti-piracy text',
    () async {
      final story = Uri.parse('https://www.royalroad.com/fiction/1');
      final fetcher = FakeFetcher({
        '$story': '''
        <html><head><meta property="og:image" content="https://cdn.rr/covers/1.jpg">
        <meta property="books:author" content="nobody103">
        <script type="application/ld+json">{"numberOfPages":2932}</script></head>
        <body><div class="fic-header"><h1>Mother of Learning</h1></div>
        <div class="fiction-info"><span class="label">Original</span><span class="label"> COMPLETED </span></div>
        <a class="fiction-tag">Time Loop</a><a class="fiction-tag">Magic</a>
        <div class="description"><p>Zorian is a mage.</p></div>
        <script>window.chapters = [{"title":"1. Good Morning","url":"/fiction/1/x/chapter/10/a","visible":1,"isUnlocked":true},
          {"title":"2. Hidden","url":"/fiction/1/x/chapter/11/b","visible":0},
          {"title":"3. Next","url":"/fiction/1/x/chapter/12/c","visible":1,"isUnlocked":false}];</script>
        </body></html>''',
        'https://www.royalroad.com/fiction/1/x/chapter/10/a': '''
        <html><head><style>.hideme{ display: none; speak: never; }</style></head><body>
        <h1 class="font-white">1. Good Morning</h1>
        <div class="chapter-inner chapter-content"><p>Real text.</p><p class="hideme">Stolen from Royal Road.</p></div>
        </body></html>''',
      });
      const source = RoyalRoadSource();
      final info = await source.fetchStory(story, fetcher);
      expect(info.title, 'Mother of Learning');
      expect(info.author, 'nobody103');
      expect(info.isComplete, isTrue);
      expect(info.pageCount, 2932);
      expect(info.tags, ['Time Loop', 'Magic']);
      expect(info.summary, 'Zorian is a mage.');
      expect(
        [for (final c in info.chapters) (c.number, c.title, c.locked)],
        [(1, '1. Good Morning', false), (2, '3. Next', true)],
      );
      final chapter = await source.fetchChapter(info.chapters.first, fetcher);
      expect(chapter.html, '<p>Real text.</p>');
    },
  );

  test('AO3: tags, word count, completion and chapter text', () async {
    final story = Uri.parse('https://archiveofourown.org/works/7');
    final fetcher = FakeFetcher({
      '$story?view_adult=true': '''
        <h2 class="title heading">Two Strangers</h2>
        <h3 class="byline heading"><a rel="author" href="/users/a">lilac</a></h3>
        <dd class="fandom tags"><a class="tag">Naruto (Anime &amp; Manga)</a></dd>
        <dd class="relationship tags"><a class="tag">Sasuke/Naruto</a></dd>
        <dd class="character tags"><a class="tag">Uzumaki Naruto</a><a class="tag">Uchiha Sasuke</a></dd>
        <dd class="freeform tags"><a class="tag">Marriage</a><a class="tag">Child Care</a></dd>
        <dd class="published">2023-01-05</dd><dd class="status">2024-03-01</dd>
        <dd class="words">4,215</dd><dd class="chapters">2/2</dd>
        <div class="summary module"><blockquote class="userstuff"><p>Naruto is brilliant.</p></blockquote></div>''',
      '$story/navigate': '''
        <ol class="chapter index group"><li><a href="/works/7/chapters/100">1. Start</a></li>
        <li><a href="/works/7/chapters/101">2. End</a></li></ol>''',
      'https://archiveofourown.org/works/7/chapters/100?view_adult=true': '''
        <div id="chapters"><div class="chapter"><h3 class="title">Chapter 1: Start</h3>
        <div class="userstuff" role="article"><h3 class="landmark heading">Chapter Text</h3><p>Hello.</p></div></div></div>''',
    });
    const source = Ao3Source();
    final info = await source.fetchStory(story, fetcher);
    expect(info.fandom, 'Naruto (Anime & Manga)');
    expect(info.characters, ['Uzumaki Naruto', 'Uchiha Sasuke']);
    expect(info.tags, ['Marriage', 'Child Care']);
    expect(info.pairings, ['Sasuke/Naruto']);
    expect(info.wordCount, 4215);
    expect(info.isComplete, isTrue);
    expect(info.chapters.map((c) => c.title), ['Start', 'End']);
    expect(info.updatedOn, DateTime(2024, 3, 1));
    final chapter = await source.fetchChapter(info.chapters.first, fetcher);
    expect(chapter.title, 'Chapter 1: Start');
    expect(chapter.html, '<p>Hello.</p>');
  });

  test('FanFiction.Net: parses the meta line, genres and chapters', () async {
    final story = Uri.parse('https://www.fanfiction.net/s/42/1');
    final fetcher = FakeFetcher({
      '$story': '''
        <div id="pre_story_links"><a href="/anime/">Anime/Manga</a><a href="/anime/Naruto/">Naruto</a></div>
        <div id="profile_top"><img class="cimage" src="/image/9/75/"><b class="xcontrast_txt">Enter, Naruto Hyuga</b>
        By: <a class="xcontrast_txt" href="/u/1/forgetmenot">forgetmenot</a>
        <div class="xcontrast_txt">Naruto is the son of Hizashi.</div>
        <span class="xgray xcontrast_txt">Rated: Fiction T - English - Hurt/Comfort/Adventure - [Naruto U., Hinata H.] Neji H. -
        Chapters: 2 - Words: 3,142 - Status: Complete - id: 42</span></div>
        <select id="chap_select"><option value="1">1. Chapter 1</option><option value="2">2. The Exam</option></select>
        <div id="storytext"><p>If Hizashi could…</p></div>''',
      'https://www.fanfiction.net/s/42/2':
          '<div id="storytext"><p>Second.</p></div>',
    });
    const source = FanFictionNetSource();
    final info = await source.fetchStory(story, fetcher);
    expect(info.title, 'Enter, Naruto Hyuga');
    expect(info.author, 'forgetmenot');
    expect(info.fandom, 'Naruto');
    expect(info.tags, ['Hurt/Comfort', 'Adventure']);
    expect(info.pairings, ['Naruto U./Hinata H.']);
    expect(info.wordCount, 3142);
    expect(info.isComplete, isTrue);
    expect(info.coverUrl.toString(), 'https://www.fanfiction.net/image/9/180/');
    expect(info.chapters.map((c) => c.title), ['Chapter 1', 'The Exam']);
    final chapter = await source.fetchChapter(info.chapters.last, fetcher);
    expect(chapter.html, '<p>Second.</p>');
  });

  test(
    'Scribble Hub: loads the full table of contents in reading order',
    () async {
      final story = Uri.parse('https://www.scribblehub.com/series/5/rune/');
      const ajax = 'https://www.scribblehub.com/wp-admin/admin-ajax.php';
      final fetcher = FakeFetcher({
        '$story': '''
        <div class="fic_title">The Runesmith</div><span class="auth_name_fic">Kuropon</span>
        <div class="fic_image"><img src="https://cdn.sh/5.jpg"></div>
        <div class="wi_fic_desc"><p>A man in a world of magic.</p></div>
        <a class="fic_genre" href="/genre/action/">Action</a><a class="stag">Crafting</a>
        <ul><li><span><i class="fa status"></i></span><span>Ongoing - Updated Oct 21, 2026</span></li></ul>''',
        ajax: '''
        <li class="toc_w" order="2"><a class="toc_a" href="https://www.scribblehub.com/read/5-rune/chapter/20/">Chapter 2</a></li>
        <li class="toc_w" order="1"><a class="toc_a" href="https://www.scribblehub.com/read/5-rune/chapter/10/">Chapter 1</a></li>''',
      });
      const source = ScribbleHubSource();
      final info = await source.fetchStory(story, fetcher);
      expect(fetcher.posts[ajax], {
        'action': 'wi_getreleases_pagination',
        'pagenum': '-1',
        'mypostid': '5',
      });
      expect(info.isComplete, isFalse);
      expect(info.type, WorkType.webnovel);
      expect(info.tags, ['Action', 'Crafting']);
      expect(
        [for (final c in info.chapters) '${c.number} ${c.title}'],
        ['1 Chapter 1', '2 Chapter 2'],
      );
    },
  );

  test('WebNovel: marks paid chapters and removes the teaser', () async {
    final story = Uri.parse('https://www.webnovel.com/book/99999999');
    final fetcher = FakeFetcher({
      '$story': '''
        <meta property="og:image" content="https://book-pic.webnovel.com/99.jpg">
        <h1>Mythical Three Kingdoms</h1><a class="det-hd-tag" href="/stories/fanfic-anime-comics-naruto" title="Naruto">Naruto</a>
        <address><strong>Author: </strong><span>Dilapidated Graveyard</span></address>
        <div class="j_synopsis"><p>Chen Xi looks at the sky.</p></div>
        <div class="m-tags"><a>#KINGDOMBUILDING</a></div>''',
      '$story/catalog': '''
        <ol class="content-list"><li data-cid="1"><a href="/book/x_99999999/ch-1_1" title="Chapter 1">1</a></li>
        <li data-cid="2"><a href="/book/x_99999999/ch-2_2" title="Chapter 2"><svg><use xlink:href="#i-lock"></use></svg></a></li></ol>''',
      'https://www.webnovel.com/book/x_99999999/ch-1_1': '''
        <div class="cha-tit"><h1>Chapter 1: Meteorites</h1></div>
        <div class="cha-content "><div class="cha-words"><div class="cha-paragraph"><p> ... </p><i class="para-comment">2</i></div>
        <div class="cha-paragraph"><p>"Young Master~"</p></div></div></div>''',
    });
    const source = WebnovelSource();
    final info = await source.fetchStory(story, fetcher);
    expect(info.type, WorkType.fanfiction);
    expect(info.fandom, 'Naruto');
    expect(info.author, 'Dilapidated Graveyard');
    expect(info.tags, ['KINGDOMBUILDING']);
    expect([for (final c in info.chapters) c.locked], [false, true]);
    final chapter = await source.fetchChapter(info.chapters.first, fetcher);
    expect(chapter.title, 'Chapter 1: Meteorites');
    expect(chapter.html, '<p>"Young Master~"</p>');
    expect(
      () => source.fetchChapter(info.chapters.last, fetcher),
      throwsA(isA<SourceException>()),
    );
  });

  test('Author.Today: reads the size in characters', () async {
    final story = Uri.parse('https://author.today/work/564935');
    final fetcher = FakeFetcher({
      '$story': '''
        <h1 class="book-title">Книга</h1><div class="book-authors"><a>Автор</a></div>
        <span class="hint-top" data-hint="Размер, кол-во знаков с пробелами">2 110 486 <noindex>зн.</noindex></span>, 52,76 <abbr>а.л.</abbr>
        <ul class="table-of-content"><li><a href="/reader/564935/1">Глава 1</a></li></ul>''',
    });
    final info = await const AuthorTodaySource().fetchStory(story, fetcher);
    expect(info.characterCount, 2110486);
    expect((info.wordCount, info.pageCount), (null, null));
  });

  test(
    'Author.Today: decodes the reader text with the secret header',
    () async {
      const secret = '790b12160285732b0214353fa10f38c0';
      const html = '<p>Ответа на свое «всё куплю» я не дождался.</p>';
      // Encrypting is the same XOR as decrypting.
      final encrypted = AuthorTodaySource.decryptChapter(html, secret);
      expect(encrypted, isNot(html));
      final api = 'https://author.today/reader/667256/chapter?id=6401943';
      final fetcher = FakeFetcher(
        {
          api: jsonString({
            'isSuccessful': true,
            'data': {'text': encrypted},
          }),
        },
        headers: {
          api: {'reader-secret': secret},
        },
      );
      final chapter = await const AuthorTodaySource().fetchChapter(
        ChapterRef(
          number: 1,
          title: 'Глава 1',
          url: Uri.parse('https://author.today/reader/667256/6401943'),
        ),
        fetcher,
      );
      expect(chapter.html, html);
    },
  );

  test('Author.Today: explains the Unadulted age gate', () async {
    final fetcher = FakeFetcher({
      'https://author.today/reader/564935/chapter?id=5359854': jsonString({
        'isSuccessful': false,
        'isWarning': false,
        'messages': ['Unadulted'],
        'data': null,
      }),
    });
    await expectLater(
      const AuthorTodaySource().fetchChapter(
        ChapterRef(
          number: 1,
          title: 'Глава 1: Расклад',
          url: Uri.parse('https://author.today/reader/564935/5359854'),
        ),
        fetcher,
      ),
      throwsA(
        isA<SourceException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('requires age confirmation'),
            contains('ReadTrack browser window'),
            isNot(contains('Unadulted')),
          ),
        ),
      ),
    );
    expect(fetcher.requests, hasLength(1));
  });

  test('Ficbook: details blocks, parts and line-based paragraphs', () async {
    final story = Uri.parse('https://ficbook.net/readfic/0193-abc');
    final fetcher = FakeFetcher({
      '$story': '''
        <h1 class="heading" itemprop="name">Иллюзия любви.</h1>
        <div class="ds-label ds-label-status-finished"> Завершён </div>
        <a href="/authors/1" itemprop="author">Fak_k</a>
        <div class="mb-10"><strong>Фэндом:</strong><div><a href="/fanfiction/anime_and_manga/naruto"> Naruto </a></div></div>
        <div class="mb-10"><strong>Размер:</strong><div> написано 1 124 страницы, 553 964 слова, 2 части </div></div>
        <div class="mb-10"><strong>Метки:</strong><div class="tags"><a class="tag">AU</a><a class="tag">Ангст</a><a class="tag tag-adult">Underage</a></div></div>
        <div class="mb-10"><strong>Пэйринг и персонажи:</strong><div><a class="pairing-link">Какаши Хатаке/Наруто Узумаки</a>, <a class="pairing-link">Ямато</a></div></div>
        <div itemprop="description">Первая строка.
Вторая строка.</div>
        <ul class="list-of-fanfic-parts">
          <li class="part"><a href="/readfic/0193-abc/11#part_content" class="part-link"><div class="part-title"><h3>Первый день.</h3></div></a></li>
          <li class="part"><a href="/readfic/0193-abc/12#part_content" class="part-link"><div class="part-title"><h3>Второй день.</h3></div></a></li>
        </ul>''',
      'https://ficbook.net/readfic/0193-abc/11': '''
        <article id="part_content"><h2>Первый день.</h2>
        <div id="content">- Что за черт?!
<i>Тихо</i> сказал он.

Конец.</div></article>''',
    });
    const source = FicbookSource();
    final info = await source.fetchStory(story, fetcher);
    expect(info.author, 'Fak_k');
    expect(info.fandom, 'Naruto');
    expect(info.type, WorkType.fanfiction);
    expect(info.tags, ['AU', 'Ангст', 'Underage']);
    expect(info.adultTags, {'Underage'});
    expect(info.pairings, ['Какаши Хатаке/Наруто Узумаки']);
    expect(
      (info.pageCount, info.wordCount, info.isComplete),
      (1124, 553964, true),
    );
    expect(info.summary, 'Первая строка.\n\nВторая строка.');
    expect(info.chapters.map((c) => c.url.toString()), [
      'https://ficbook.net/readfic/0193-abc/11',
      'https://ficbook.net/readfic/0193-abc/12',
    ]);
    final chapter = await source.fetchChapter(info.chapters.first, fetcher);
    expect(
      chapter.html,
      '<p>- Что за черт?!</p><p><em>Тихо</em> сказал он.</p><p>Конец.</p>',
    );
  });
}
