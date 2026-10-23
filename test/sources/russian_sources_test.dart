// Parser tests for the Russian sites, with small hand-written pages.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/enums.dart';
import 'package:readtrack/sources/charsets.dart';
import 'package:readtrack/sources/fanfics_me.dart';
import 'package:readtrack/sources/litmarket.dart';
import 'package:readtrack/sources/litnet.dart';
import 'package:readtrack/sources/prodaman.dart';
import 'package:readtrack/sources/proza.dart';
import 'package:readtrack/sources/rulate.dart';
import 'package:readtrack/sources/samlib.dart';
import 'package:readtrack/sources/sources.dart';
import 'package:readtrack/sources/zelluloza.dart';

import 'fake_fetcher.dart';

void main() {
  test('decodes KOI8-R and Windows-1251 pages', () {
    // "Привет" in both encodings.
    const koi8 = [0xF0, 0xD2, 0xC9, 0xD7, 0xC5, 0xD4];
    const cp1251 = [0xCF, 0xF0, 0xE8, 0xE2, 0xE5, 0xF2];
    expect(
      decodeBody(koi8, contentType: 'text/html; charset=koi8-r'),
      'Привет',
    );
    expect(
      decodeBody(cp1251, contentType: 'text/html; charset=windows-1251'),
      'Привет',
    );
    final withMeta = [
      ...latin1.encode(
        '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">',
      ),
      ...cp1251,
    ];
    expect(decodeBody(withMeta), endsWith('Привет'));
    expect(decodeBody(utf8.encode('Привет')), 'Привет');
  });

  test('recognizes links of the Russian sites', () {
    final cases = {
      'https://fanfics.me/read.php?id=250919&chapter=3':
          'https://fanfics.me/fic250919',
      'https://litnet.com/ru/reader/zhazhdu-tvoi-vzglyad-b614747?c=1':
          'https://litnet.com/ru/book/zhazhdu-tvoi-vzglyad-b614747',
      'https://litmarket.ru/reader/arktona':
          'https://litmarket.ru/books/arktona',
      'http://samlib.ru/o/ostashew_a_e/puteshest.shtml':
          'http://samlib.ru/o/ostashew_a_e/puteshest.shtml',
      'https://proza.ru/2026/10/22/2136': 'https://proza.ru/2026/10/22/2136',
      'https://tl.rulate.ru/book/234492/34064435/ready_new':
          'https://tl.rulate.ru/book/234492',
      'https://prodaman.ru/JKonstanta/books/Pyataya-nevesta':
          'https://prodaman.ru/JKonstanta/books/Pyataya-nevesta',
      'https://zelluloza.ru/books/673/3047': 'https://zelluloza.ru/books/673/',
    };
    for (final MapEntry(key: link, value: expected) in cases.entries) {
      final url = Uri.parse(link);
      expect(sourceFor(url)?.storyUrl(url).toString(), expected, reason: link);
    }
    expect(
      sourceFor(Uri.parse('http://samlib.ru/o/ostashew_a_e/indexdate.shtml')),
      isNull,
    );
    expect(sourceFor(Uri.parse('https://litmarket.ru/books/genres')), isNull);
  });

  test('Fanfics.me: detail rows, size and chapters', () async {
    final story = Uri.parse('https://fanfics.me/fic5');
    final fetcher = FakeFetcher({
      '$story': '''
        <h1>Резервист <span class="small gen">(джен)</span></h1>
        <div class="tr"><div class="title">Автор:</div><div class="content"><a href="/user1">DeLaKasper</a></div></div>
        <div class="tr"><div class="title">Фандом:</div><div class="content"><a href="/fandom2">Гарри Поттер</a></div></div>
        <div class="tr"><div class="title">Жанр:</div><div class="content">Общий, Драма</div></div>
        <div class="tr"><div class="title">Статус:</div><div class="content">Закончен</div></div>
        <div id="FicSize">Макси | 77 854 слова | 147 страниц</div>
        <div id="summary_5">Летом 1999 года.</div>
        <ul class="FicContents"><li><a href="/read.php?id=5&chapter=0#start_read">Глава 1</a><a href="/user1">x</a></li></ul>''',
      'https://fanfics.me/read.php?id=5&chapter=0': '''
        <h2>Глава 1</h2><div class="chapter" id="c0"><a name="c0p1"></a><p class="fict">Конец июня.</p></div>''',
    });
    const source = FanficsMeSource();
    final info = await source.fetchStory(story, fetcher);
    expect(info.title, 'Резервист');
    expect(
      (info.author, info.fandom, info.isComplete),
      ('DeLaKasper', 'Гарри Поттер', true),
    );
    expect((info.wordCount, info.pageCount), (77854, 147));
    expect(info.tags, ['Общий', 'Драма']);
    expect(info.chapters.single.title, 'Глава 1');
    expect(
      (await source.fetchChapter(info.chapters.single, fetcher)).html,
      '<p>Конец июня.</p>',
    );
  });

  test('Litnet: book state, chapter list and paged chapter text', () async {
    const slug = 'zhazhdu-b614747';
    final state = jsonEncode({
      'a': {
        'b': {
          'alias': slug,
          'title': 'Жажду. Твой. Взгляд',
          'annotation': '<p>Сводная сестра.</p>',
          'pages': 230,
          'is_finished': true,
          'author': {'name': 'Екатерина Юдина '},
        },
      },
    });
    String page(int n, {bool last = false}) => jsonString({
      'status': 1,
      'data': '<p>Страница $n.</p>',
      'totalPages': 2,
      'isLastPage': last,
    });
    final fetcher = _SequencedFetcher(
      {
        'https://litnet.com/ru/book/$slug':
            '<h1>x</h1><a href="/ru/tag/x-t1">жестокий герой</a><script id="ng-state" type="application/json">$state</script>',
        'https://litnet.com/ru/reader/$slug': '<select class="js-chapter-change"><option value="11">Глава 1 Договор</option><option value="12">Глава 2</option></select>',
        'https://litnet.com/ru/reader/$slug?c=11':
            '<meta name="csrf-token" content="tok">',
      },
      responses: [page(1), page(2, last: true)],
    );
    const source = LitnetSource();
    final info = await source.fetchStory(
      Uri.parse('https://litnet.com/ru/book/$slug'),
      fetcher,
    );
    expect(
      (info.title, info.author, info.pageCount, info.isComplete),
      ('Жажду. Твой. Взгляд', 'Екатерина Юдина', 230, true),
    );
    expect(info.summary, 'Сводная сестра.');
    expect(info.tags, ['жестокий герой']);
    expect(info.chapters.map((c) => c.url.toString()), [
      'https://litnet.com/ru/reader/$slug?c=11',
      'https://litnet.com/ru/reader/$slug?c=12',
    ]);
    final chapter = await source.fetchChapter(info.chapters.first, fetcher);
    expect(chapter.html, '<p>Страница 1.</p><p>Страница 2.</p>');
    expect(fetcher.postFields.first, {
      'chapterId': '11',
      'page': '1',
      '_csrf': 'tok',
    });
  });

  test('LitMarket: splits reader blocks into chapters', () async {
    Map<String, Object?> block(String type, String text) => {
      'chunk': {
        'type': type,
        'mods': [
          {'type': 'INLINE', 'text': text},
        ],
      },
    };
    final blocks = jsonString([
      block('chapter', 'Глава 1'),
      block('unstyled', 'Я снова видела сон.'),
      block('atomic', ''),
      block('chapter', 'Глава 2'),
      block('unstyled', 'Утро <настало>.'),
    ]);
    final fetcher = FakeFetcher({
      'https://litmarket.ru/books/arktona':
          '<a href="https://litmarket.ru/books/genres/fantasy">Фэнтези</a>',
      'https://litmarket.ru/reader/arktona':
          '<meta name="csrf-token" content="tok">',
      'https://litmarket.ru/reader/data/arktona': jsonString({
        'book': {
          'bookName': 'Арктона',
          'authorNickname': 'Ядвига',
          'annotation': 'В мире.',
          'ebookStatus': 'В работе',
          'ebookId': 7,
        },
      }),
      'https://litmarket.ru/reader/blocks/7': blocks,
    });
    const source = LitMarketSource();
    final info = await source.fetchStory(
      Uri.parse('https://litmarket.ru/books/arktona'),
      fetcher,
    );
    expect((info.author, info.isComplete), ('Ядвига', false));
    expect(info.tags, ['Фэнтези']);
    expect(info.chapters.map((c) => c.title), ['Глава 1', 'Глава 2']);
    expect(
      (await source.fetchChapter(info.chapters.last, fetcher)).html,
      '<p>Утро &lt;настало&gt;.</p>',
    );
  });

  test('Samlib and Proza.ru: single-page works', () async {
    final fetcher = FakeFetcher({
      'http://samlib.ru/o/a/work.shtml': '''
        <h2><small><a href=/o/a/>Косикава Яэи</a></small><br> Путешествие</h2>
        <ul><li><b>Аннотация:</b><br><i>Редкое издание.</i></li></ul>
        <form>оценка</form>
        <!----------- Собственно произведение ------------->
        <p>Первая глава.</p><p>Вторая.</p>
        <form>оценка внизу</form><hr>''',
      'https://proza.ru/2026/10/22/1': '<h1>ОКНА</h1><div class="titleauthor"><a href="/avtor/g">Галка</a></div><div class="text">Солнце.<br><br>Осень.</div>',
    });
    const samlib = SamlibSource();
    final work = await samlib.fetchStory(
      Uri.parse('http://samlib.ru/o/a/work.shtml'),
      fetcher,
    );
    expect(
      (work.title, work.author, work.summary),
      ('Путешествие', 'Косикава Яэи', 'Редкое издание.'),
    );
    expect(
      (await samlib.fetchChapter(work.chapters.single, fetcher)).html,
      '<p>Первая глава.</p><p>Вторая.</p>',
    );

    const proza = ProzaSource();
    final text = await proza.fetchStory(
      Uri.parse('https://proza.ru/2026/10/22/1'),
      fetcher,
    );
    expect((text.title, text.author), ('ОКНА', 'Галка'));
    expect(
      (await proza.fetchChapter(text.chapters.single, fetcher)).html,
      '<p>Солнце.</p><p>Осень.</p>',
    );
  });

  test('Rulate: paid chapters are locked', () async {
    final fetcher = FakeFetcher({
      'https://tl.rulate.ru/book/9': '''
        <h1><span itemprop="name">Творец миров</span></h1>
        <p><strong>Выпуск:</strong> <em> продолжается </em></p>
        <a href="/search?genres%5B0%5D=37">фэнтези</a>
        <table><tr class="chapter_row"><td></td><td class="t"><a href="/book/9/1/ready_new">Глава 1</a></td></tr>
        <tr class="chapter_row"><td><input type="checkbox" data-price="5"></td><td class="t"><a href="/book/9/2/ready_new">Глава 2</a></td></tr></table>''',
      'https://tl.rulate.ru/book/9/1/ready_new':
          '<div class="content-text"><p>Хаос.</p></div>',
    });
    const source = RulateSource();
    final info = await source.fetchStory(
      Uri.parse('https://tl.rulate.ru/book/9'),
      fetcher,
    );
    expect(info.isComplete, isFalse);
    expect(info.tags, ['фэнтези']);
    expect([for (final c in info.chapters) c.locked], [false, true]);
    expect(
      (await source.fetchChapter(info.chapters.first, fetcher)).html,
      '<p>Хаос.</p>',
    );
    expect(
      () => source.fetchChapter(info.chapters.last, fetcher),
      throwsA(isA<SourceException>()),
    );
  });

  test(
    'ПродаМан: reader pages become chapters named after their chapters',
    () async {
      const book = 'https://prodaman.ru/J/books/Nevesta';
      final fetcher = FakeFetcher({
        book: '''
        <h1 itemprop="name">Пятая невеста</h1><p class="under-title">Автор: <a href="/J">JKonstanta</a></p>
        <div itemprop="description">Принцу драконов не везет.</div><span>В процессе написания</span>''',
        '$book?nav=ok': '''
        <select name="page"><option value="1">Начало текста</option><option value="1">Глава 1</option>
        <option value="1">Глава 2</option><option value="2">Глава 3</option></select>
        <p class="status">Показано 1 из 3 страниц</p>''',
        '$book?page=2': '<div class="blog-text noselect reader-box">Глава 3<br><br>Текст.</div>',
      });
      const source = ProdamanSource();
      final info = await source.fetchStory(Uri.parse(book), fetcher);
      expect((info.author, info.isComplete), ('JKonstanta', false));
      expect(info.chapters.map((c) => c.title), [
        'Глава 1 – Глава 2',
        'Глава 3',
        'Страница 3',
      ]);
      expect(
        (await source.fetchChapter(info.chapters[1], fetcher)).html,
        '<p>Глава 3</p><p>Текст.</p>',
      );
    },
  );

  test('Целлюлоза: details only', () async {
    final fetcher = FakeFetcher({
      'https://zelluloza.ru/books/673/': '''
        <meta property="og:title" content="Константин Муравьев. Неучтенный 3. Угроза клану">
        <li class="bookinfo-top__stats-item"><span class="bookinfo-top__stats-label">Количество глав</span><span class="bookinfo-top__stats-value">12</span></li>
        <li class="bookinfo-top__stats-item"><span class="bookinfo-top__stats-label">Статус произведения</span><span class="bookinfo-top__stats-value">В процессе написания</span></li>''',
    });
    const source = ZellulozaSource();
    final info = await source.fetchStory(
      Uri.parse('https://zelluloza.ru/books/673/'),
      fetcher,
    );
    expect(source.canRead, isFalse);
    expect(
      (info.title, info.author, info.chapterCount, info.isComplete),
      ('Неучтенный 3. Угроза клану', 'Константин Муравьев', 12, false),
    );
    expect(info.type, WorkType.book);
  });
}

/// A [FakeFetcher] whose POST responses come from a queue, for paged APIs.
class _SequencedFetcher extends FakeFetcher {
  _SequencedFetcher(super.pages, {required this.responses});

  /// Responses for the next POST requests, in order.
  final List<String> responses;
  final postFields = <Map<String, String>>[];

  @override
  Future<String> postForm(
    Uri uri,
    Map<String, String> fields, {
    Map<String, String> headers = const {},
  }) async {
    postFields.add(fields);
    return responses.removeAt(0);
  }
}
