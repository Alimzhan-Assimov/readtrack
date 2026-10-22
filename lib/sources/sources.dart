import 'ao3.dart';
import 'author_today.dart';
import 'fanfiction_net.dart';
import 'ficbook.dart';
import 'royal_road.dart';
import 'scribble_hub.dart';
import 'source.dart';
import 'webnovel.dart';

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
];

/// The source that can read [url], or null if the site isn't supported.
StorySource? sourceFor(Uri url) {
  for (final source in kSources) {
    if (source.matches(url) && source.storyUrl(url) != null) return source;
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
