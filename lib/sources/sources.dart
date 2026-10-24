import 'ao3.dart';
import 'author_today.dart';
import 'fanfiction_net.dart';
import 'fanfics_me.dart';
import 'ficbook.dart';
import 'gutenberg.dart';
import 'honeyfeed.dart';
import 'inkitt.dart';
import 'litmarket.dart';
import 'litnet.dart';
import 'novel_updates.dart';
import 'prodaman.dart';
import 'proza.dart';
import 'quotev.dart';
import 'royal_road.dart';
import 'rulate.dart';
import 'samlib.dart';
import 'scribble_hub.dart';
import 'source.dart';
import 'standard_ebooks.dart';
import 'tapas.dart';
import 'wattpad.dart';
import 'webnovel.dart';
import 'wikisource.dart';
import 'wuxiaworld.dart';
import 'xenforo.dart';
import 'zelluloza.dart';

export 'fetcher.dart' show PageFetcher, SourceException;
export 'source.dart';

const kSources = <StorySource>[
  FanFictionNetSource(),
  Ao3Source(),
  WebnovelSource(),
  RoyalRoadSource(),
  ScribbleHubSource(),
  AuthorTodaySource(),
  FicbookSource(),
  XenForoSource.spaceBattles,
  XenForoSource.sufficientVelocity,
  XenForoSource.questionableQuesting,
  WattpadSource(),
  FanFictionNetSource.fictionPress(),
  QuotevSource(),
  TapasSource(),
  InkittSource(),
  HoneyfeedSource(),
  WuxiaworldSource(),
  NovelUpdatesSource(),
  FanficsMeSource(),
  LitnetSource(),
  LitMarketSource(),
  SamlibSource(),
  ProzaSource(),
  RulateSource(),
  ProdamanSource(),
  ZellulozaSource(),
  GutenbergSource(),
  StandardEbooksSource(),
  WikisourceSource(),
];

/// The source that can read [url], or null if the site isn't supported.
StorySource? sourceFor(Uri url) {
  for (final source in kSources) {
    if (source.matches(url) && source.storyUrl(url) != null) return source;
  }
  return null;
}

/// The source for any page on a supported site, e.g. a list of stories.
StorySource? siteFor(Uri url) {
  for (final source in kSources) {
    if (source.matches(url)) return source;
  }
  return null;
}

/// Parses user input such as "fanfiction.net/s/123" into a URL.
Uri? parseUserUrl(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
  return uri == null || uri.host.isEmpty ? null : uri;
}
