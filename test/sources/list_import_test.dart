import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/sources/ao3.dart';
import 'package:readtrack/sources/fanfiction_net.dart';
import 'package:readtrack/sources/royal_road.dart';
import 'package:readtrack/sources/scribble_hub.dart';
import 'package:readtrack/sources/wattpad.dart';

import 'fake_fetcher.dart';

void main() {
  test(
    'AO3: bookmarks over several pages, without sidebars or repeats',
    () async {
      const base = 'https://archiveofourown.org/users/someone/bookmarks';
      final fetcher = FakeFetcher({
        base: '''
        <div id="dashboard"><a href="/works/999">Featured work</a></div>
        <ol class="bookmark index group">
          <li id="bookmark_1" class="bookmark blurb group">
            <h4 class="heading"><a href="/works/111">First Story</a> by <a rel="author" href="/users/a">a</a></h4>
            <dl><dd class="chapters"><a href="/works/111/chapters/5">2</a>/5</dd></dl>
          </li>
          <li id="bookmark_2" class="bookmark blurb group">
            <h4 class="heading"><a href="/series/7">A Series</a></h4>
          </li>
          <li id="bookmark_3" class="bookmark blurb group">
            <h4 class="heading"><a href="/works/222">Second Story</a></h4>
          </li>
        </ol>
        <ol class="pagination actions"><li class="next" title="next"><a rel="next" href="/users/someone/bookmarks?page=2">Next →</a></li></ol>''',
        '$base?page=2': '''
        <li class="bookmark blurb group"><h4 class="heading"><a href="/works/222">Second Story</a></h4></li>
        <li class="work blurb group"><h4 class="heading"><a href="/works/333">Third Story</a></h4></li>
        <ol class="pagination actions"><li class="next" title="next"><span class="disabled">Next →</span></li></ol>''',
      });
      final list = await const Ao3Source().fetchList(Uri.parse(base), fetcher);
      expect(
        [for (final s in list) '${s.url} ${s.title}'],
        [
          'https://archiveofourown.org/works/111 First Story',
          'https://archiveofourown.org/works/222 Second Story',
          'https://archiveofourown.org/works/333 Third Story',
        ],
      );
    },
  );

  test('Royal Road: favorites', () async {
    const url = 'https://www.royalroad.com/profile/1/favorites';
    final fetcher = FakeFetcher({
      url: '''
        <div class="fiction-list-item row"><h2 class="fiction-title"><a href="/fiction/21220/mother-of-learning">Mother of Learning</a></h2></div>
        <div class="sidebar"><a href="/fiction/1/popular">Popular</a></div>''',
    });
    final list = await const RoyalRoadSource().fetchList(
      Uri.parse(url),
      fetcher,
    );
    expect(
      list.single.url.toString(),
      'https://www.royalroad.com/fiction/21220',
    );
  });

  test(
    'FanFiction.net: a profile gives its favorites, not own stories',
    () async {
      const url = 'https://www.fanfiction.net/u/123/Someone';
      final fetcher = FakeFetcher({
        url: '''
        <div class="z-list mystories"><a class="stitle" href="/s/1/1/Mine">Mine</a></div>
        <div class="z-list favstories"><a class="stitle" href="/s/2/1/Fav">Fav</a></div>''',
      });
      final list = await const FanFictionNetSource().fetchList(
        Uri.parse(url),
        fetcher,
      );
      expect([for (final s in list) s.title], ['Fav']);
    },
  );

  test('other sites take every story link on the page', () async {
    const url = 'https://www.scribblehub.com/series-ranking/';
    final fetcher = FakeFetcher({
      url: '''
        <a href="https://www.scribblehub.com/series/123/a-story/">A Story</a>
        <a href="https://www.scribblehub.com/profile/5/x/">Profile</a>''',
    });
    final list = await const ScribbleHubSource().fetchList(
      Uri.parse(url),
      fetcher,
    );
    expect([for (final s in list) s.title], ['A Story']);
  });

  test('Wattpad: reading lists come from the API, page by page', () async {
    final fetcher = FakeFetcher({
      'https://www.wattpad.com/api/v3/lists/42/stories?limit=100&fields=stories%28id%2Ctitle%29%2CnextUrl': '{"stories":[{"id":"1","title":"One"}],"nextUrl":"https://www.wattpad.com/api/v3/lists/42/stories?offset=1"}',
      'https://www.wattpad.com/api/v3/lists/42/stories?offset=1':
          '{"stories":[{"id":"2","title":"Two"}]}',
    });
    final list = await const WattpadSource().fetchList(
      Uri.parse('https://www.wattpad.com/list/42-favorites'),
      fetcher,
    );
    expect(
      [for (final s in list) '${s.url} ${s.title}'],
      [
        'https://www.wattpad.com/story/1 One',
        'https://www.wattpad.com/story/2 Two',
      ],
    );
  });
}
