// Parser tests for the English sites, with small hand-written pages.
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/enums.dart';
import 'package:readtrack/sources/fanfiction_net.dart';
import 'package:readtrack/sources/honeyfeed.dart';
import 'package:readtrack/sources/inkitt.dart';
import 'package:readtrack/sources/novel_updates.dart';
import 'package:readtrack/sources/quotev.dart';
import 'package:readtrack/sources/sources.dart';
import 'package:readtrack/sources/tapas.dart';
import 'package:readtrack/sources/wattpad.dart';
import 'package:readtrack/sources/wuxiaworld.dart';
import 'package:readtrack/sources/xenforo.dart';

import 'fake_fetcher.dart';

void main() {
  test('recognizes links of the English sites', () {
    final cases = {
      'https://forums.spacebattles.com/threads/vicky.1028636/page-3':
          'SpaceBattles',
      'https://forums.sufficientvelocity.com/threads/melodies.156021/':
          'Sufficient Velocity',
      'https://forum.questionablequesting.com/threads/king.41015/threadmarks':
          'Questionable Questing',
      'https://www.wattpad.com/story/413817060-naruto': 'Wattpad',
      'https://www.wattpad.com/1643728147-naruto-chapter-1': 'Wattpad',
      'https://www.fictionpress.com/s/3380535/2/Hero': 'FictionPress',
      'https://www.quotev.com/story/16427167/KENKA/2': 'Quotev',
      'https://tapas.io/series/children-of-the-holy-emperor-novel/info':
          'Tapas',
      'https://www.inkitt.com/stories/fantasy/1734152': 'Inkitt',
      'https://www.honeyfeed.fm/novels/33435': 'Honeyfeed',
      'https://www.wuxiaworld.com/novel/beyond-the-zenith/bz-chapter-3':
          'Wuxiaworld',
      'https://www.novelupdates.com/series/hiding-tunnels-in-xianxia/':
          'Novel Updates',
    };
    for (final MapEntry(key: link, value: site) in cases.entries) {
      expect(sourceFor(Uri.parse(link))?.name, site, reason: link);
    }
    expect(
      XenForoSource.spaceBattles.storyUrl(
        Uri.parse(
          'https://forums.spacebattles.com/threads/vicky.1028636/page-3',
        ),
      ),
      Uri.parse('https://forums.spacebattles.com/threads/vicky.1028636/'),
    );
  });

  test('XenForo: collects threadmarks over several pages and reads a post', () async {
    final thread = Uri.parse(
      'https://forums.spacebattles.com/threads/vicky.1/',
    );
    String row(int post, String title, String words) =>
        '<div class="structItem structItem--threadmark"><div class="structItem-title">'
        '<a href="/threads/vicky.1/#post-$post">$title</a></div>'
        '<dl class="pairs"><dt>Words</dt><dd>$words</dd></dl></div>';
    final fetcher = FakeFetcher({
      '$thread': '''
        <meta property="og:description" content="Join Victoria.">
        <h1 class="p-title-value">Pokemon Trainer Vicky</h1>
        <a class="tagItem">self insert</a>
        <article class="message" data-author="Seras"></article>''',
      '${thread}threadmarks?per_page=25&page=1':
          '${row(10, 'Chapter 1', '6.9k')}${row(11, 'Chapter 2', '812')}<a class="pageNav-jump--next">Next</a>',
      '${thread}threadmarks?per_page=25&page=2': row(12, 'Chapter 3', '1.2k'),
      'https://forums.spacebattles.com/posts/10/': '''
        <article data-content="post-10"><div class="bbWrapper">Welcome.<br><br>Second
        <div class="bbCodeSpoiler"><button class="bbCodeSpoiler-button">Spoiler</button>
        <div class="bbCodeSpoiler-content">Hidden</div></div>
        <img class="bbImage" src="data:image/gif;base64,x" data-url="https://img.test/a.png"></div></article>''',
    });
    final info = await XenForoSource.spaceBattles.fetchStory(thread, fetcher);
    expect(info.author, 'Seras');
    expect(info.tags, ['self insert']);
    expect(info.wordCount, 6900 + 812 + 1200);
    expect(
      [for (final c in info.chapters) c.url.toString()],
      [
        'https://forums.spacebattles.com/posts/10/',
        'https://forums.spacebattles.com/posts/11/',
        'https://forums.spacebattles.com/posts/12/',
      ],
    );
    final chapter = await XenForoSource.spaceBattles.fetchChapter(
      info.chapters.first,
      fetcher,
    );
    expect(
      chapter.html,
      '<p>Welcome.</p><p>Second</p><p>Hidden</p><img src="https://img.test/a.png">',
    );
  });

  test('Wattpad: story API and paged part text', () async {
    const api =
        'https://www.wattpad.com/api/v3/stories/41?fields=id%2Ctitle%2Cuser%28name%29%2Cdescription%2Ccover%2Ccompleted%2Ctags%2CmainCategory%2Cparts%28id%2Ctitle%2CwordCount%2Curl%2Cdraft%2Cdeleted%29';
    String text(int page) =>
        'https://www.wattpad.com/apiv2/?m=storytext&id=7&page=$page';
    final fetcher = FakeFetcher({
      api: jsonString({
        'title': 'Little Leaf Daycare',
        'user': {'name': 'bluesky'},
        'description': 'Hikari was a teacher.',
        'completed': false,
        'tags': ['naruto', 'fanfiction'],
        'parts': [
          {
            'id': 7,
            'title': 'Chapter 1',
            'wordCount': 1899,
            'url': 'https://www.wattpad.com/7-chapter-1',
          },
          {'id': 8, 'title': 'Draft', 'draft': true},
        ],
      }),
      text(1): '<p data-p-id="a">Hikari loved children.</p>',
      text(2): '<p data-p-id="b">She opened her eyes.</p>',
      text(3): '',
    });
    const source = WattpadSource();
    final info = await source.fetchStory(
      Uri.parse('https://www.wattpad.com/story/41'),
      fetcher,
    );
    expect(info.type, WorkType.fanfiction);
    expect(
      (info.author, info.wordCount, info.isComplete),
      ('bluesky', 1899, false),
    );
    expect(info.chapters.map((c) => c.title), ['Chapter 1']);
    final chapter = await source.fetchChapter(info.chapters.single, fetcher);
    expect(
      chapter.html,
      '<p>Hikari loved children.</p><p>She opened her eyes.</p>',
    );
  });

  test('Tapas: episode pages, free and paid episodes', () async {
    final series = Uri.parse('https://tapas.io/series/holy-emperor/info');
    String episodes(int page) =>
        'https://tapas.io/series/284445/episodes?page=$page&sort=OLDEST&max_limit=20';
    final fetcher = FakeFetcher({
      '$series': '''
        <meta property="og:title" content="Read Children of the Holy Emperor">
        <a href="/CaffeineTree/subscribers?series_id=284445">11,555</a>
        <a class="creator__item">CaffeineTree</a><p class="description__body">The strongest hunter.</p>
        <a class="genre-btn">Action Fantasy</a><a class="genre-btn">Action Fantasy</a>''',
      episodes(1): jsonString({
        'data': {
          'episodes': [
            {'id': 1, 'title': 'Chapter 1', 'free': true},
          ],
          'pagination': {'has_next': true},
        },
      }),
      episodes(2): jsonString({
        'data': {
          'episodes': [
            {'id': 2, 'title': 'Chapter 2', 'free': false, 'unlocked': false},
          ],
          'pagination': {'has_next': false},
        },
      }),
      'https://tapas.io/episode/1': '<article class="js-episode-article"><p>Nate was the heir.</p></article>',
    });
    const source = TapasSource();
    final info = await source.fetchStory(series, fetcher);
    expect(info.title, 'Children of the Holy Emperor');
    expect(info.tags, ['Action Fantasy']);
    expect([for (final c in info.chapters) c.locked], [false, true]);
    expect(
      (await source.fetchChapter(info.chapters.first, fetcher)).html,
      '<p>Nate was the heir.</p>',
    );
    expect(
      () => source.fetchChapter(info.chapters.last, fetcher),
      throwsA(isA<SourceException>()),
    );
  });

  test('Wuxiaworld: builds the chapter list and refuses teasers', () async {
    final novel = Uri.parse('https://www.wuxiaworld.com/novel/zenith');
    final fetcher = FakeFetcher({
      '$novel': '''
        <h1>Beyond the Zenith</h1><div>Ongoing</div>
        <a href="/novel/zenith/bz-chapter-1">Start</a>
        <h4>Synopsis</h4><div><span>A hidden war.</span></div>
        <script>{"authorName":{"value":"Human Arsenal"},"chapterCount":{"value":3}}</script>''',
      'https://www.wuxiaworld.com/novel/zenith/bz-chapter-1': '<script>{"slug":"bz-chapter-1","isTeaser":false}</script><div class="chapter-content"><p>Han Qingyu.</p></div>',
      'https://www.wuxiaworld.com/novel/zenith/bz-chapter-3': '<script>{"slug":"bz-chapter-3","visible":true,"isTeaser":true}</script><div class="chapter-content"><p>Teaser</p></div>',
    });
    const source = WuxiaworldSource();
    final info = await source.fetchStory(novel, fetcher);
    expect(
      (info.author, info.summary, info.isComplete),
      ('Human Arsenal', 'A hidden war.', false),
    );
    expect(info.chapters.map((c) => c.url.pathSegments.last), [
      'bz-chapter-1',
      'bz-chapter-2',
      'bz-chapter-3',
    ]);
    expect(
      (await source.fetchChapter(info.chapters.first, fetcher)).html,
      '<p>Han Qingyu.</p>',
    );
    expect(
      () => source.fetchChapter(info.chapters.last, fetcher),
      throwsA(isA<SourceException>()),
    );
  });

  test('Novel Updates: details and chapter count only', () async {
    final series = Uri.parse(
      'https://www.novelupdates.com/series/hiding-tunnels/',
    );
    final fetcher = FakeFetcher({
      '$series': '''
        <div class="seriestitlenu">Hiding Tunnels in Xianxia</div><a id="authtag">불로수선전</a>
        <div class="seriesimg"><img src="https://cdn.nu/x.jpg"></div>
        <div id="editdescription"><p>Lee Hyun never ages.</p></div>
        <div id="seriesgenre"><a class="genre">Action</a></div><div id="showtags"><a class="genre">Alchemy</a></div>
        <div id="editstatus"> 1,093 Chapters (Ongoing) </div>''',
    });
    const source = NovelUpdatesSource();
    final info = await source.fetchStory(series, fetcher);
    expect(source.canRead, isFalse);
    expect(info.chapters, isEmpty);
    expect((info.chapterCount, info.isComplete), (1093, false));
    expect(info.tags, ['Action', 'Alchemy']);
  });

  test('Quotev, Inkitt, Honeyfeed and FictionPress', () async {
    final fetcher = FakeFetcher({
      'https://www.quotev.com/story/1/KENKA': '''
        <h1>KENKA</h1><div class="quizAuthorList"><a rel="author">Driftwood</a></div>
        <div id="rselectList"><a href="https://www.quotev.com/story/1/KENKA/1">Secret killer</a></div>''',
      'https://www.inkitt.com/stories/2': '''
        <h1 class="story-title">Exile in Flames</h1><div class="story-status-complete"></div>
        <div class="author-block"><a class="author-link" data-cta="Profile Picture"><img alt="CosmicChaos"></a></div>
        <a class="chapter-link" href="/stories/2/chapters/1"><span>1</span><span>Chapter 1</span></a>
        <a class="chapter-link" href="/stories/2/chapters/1"><span>1</span><span>Chapter 1</span></a>''',
      'https://www.honeyfeed.fm/novels/3': '''
        <meta property="og:title" content="Neutral in a Rom-Com | Honeyfeed">
        <a data-gtm-click="link-novelUser-novelsShow" href="/u/1"><img alt="x"></a>
        <a data-gtm-click="link-novelUser-novelsShow" href="/u/1">Fuglunkx</a><span>Ongoing</span>
        <script>{"keywords":["Comedy","Harem"]}</script>
        <ul class="list-chapter"><li><a href="/chapters/9"><div class="text-bold">Chapter 1: Deredere</div></a></li></ul>''',
      'https://www.fictionpress.com/s/4/1': '''
        <div id="pre_story_links"><a>Fiction</a><a>Fantasy</a></div>
        <div id="profile_top"><b class="xcontrast_txt">Hero Book 6</b><a href="/u/5/c">Chicken</a>
        <span class="xgray">Rated: T - English - Fantasy - Chapters: 1 - Words: 711 - Status: Complete</span></div>''',
    });
    final quotev = await const QuotevSource().fetchStory(
      Uri.parse('https://www.quotev.com/story/1/KENKA'),
      fetcher,
    );
    expect(
      (quotev.author, quotev.chapters.single.title),
      ('Driftwood', 'Secret killer'),
    );

    final inkitt = await const InkittSource().fetchStory(
      Uri.parse('https://www.inkitt.com/stories/2'),
      fetcher,
    );
    expect(
      (inkitt.author, inkitt.isComplete, inkitt.chapters.length),
      ('CosmicChaos', true, 1),
    );

    final honeyfeed = await const HoneyfeedSource().fetchStory(
      Uri.parse('https://www.honeyfeed.fm/novels/3'),
      fetcher,
    );
    expect(
      (honeyfeed.title, honeyfeed.author, honeyfeed.isComplete),
      ('Neutral in a Rom-Com', 'Fuglunkx', false),
    );
    expect(honeyfeed.tags, ['Comedy', 'Harem']);
    expect(
      honeyfeed.chapters.single.url.toString(),
      'https://www.honeyfeed.fm/chapters/9',
    );

    final fictionPress = await const FanFictionNetSource.fictionPress()
        .fetchStory(Uri.parse('https://www.fictionpress.com/s/4/1'), fetcher);
    expect(fictionPress.type, WorkType.webnovel);
    expect(fictionPress.fandom, isNull);
    expect(fictionPress.tags, ['Fantasy']);
  });
}
