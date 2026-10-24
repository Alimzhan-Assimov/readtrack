import 'dart:convert';

import 'package:http/http.dart' as http;

import 'fetcher.dart';
import 'html_clean.dart';
import 'source.dart' show parseHtml;

/// A character as AniList knows it.
typedef AniListCharacter = ({int id, String name, List<String> otherNames});

/// A manga, light novel or anime on AniList.
class AniListMedia {
  const AniListMedia({
    required this.id,
    required this.title,
    this.titles = const [],
    this.type,
    this.format,
    this.year,
    this.description,
    this.coverUrl,
    this.genres = const [],
    this.tags = const [],
    this.isAdult = false,
    this.characters = const [],
    this.relations = const [],
  });

  final int id;

  /// English if there is one, else romaji.
  final String title;

  /// All other titles and synonyms.
  final List<String> titles;

  /// "MANGA" or "ANIME".
  final String? type;

  /// e.g. "MANGA", "NOVEL", "ONE_SHOT", "TV".
  final String? format;
  final int? year;
  final String? description;
  final Uri? coverUrl;
  final List<String> genres;

  /// Tags AniList rates as fitting well (rank 60 and up).
  final List<String> tags;
  final bool isAdult;
  final List<AniListCharacter> characters;

  /// AniList relation type ("SEQUEL", "PREQUEL", "SIDE_STORY", "SPIN_OFF"
  /// …) and the other media's id.
  final List<({String type, int mediaId})> relations;

  factory AniListMedia.fromJson(Map<String, Object?> j) {
    final t = (j['title'] as Map?) ?? const {};
    final english = t['english'] as String?;
    final romaji = t['romaji'] as String?;
    final description = j['description'] as String?;
    return AniListMedia(
      id: j['id'] as int,
      title: english ?? romaji ?? '?',
      titles: {
        ?romaji,
        ?english,
        ?(t['native'] as String?),
        for (final s in j['synonyms'] as List? ?? const []) '$s',
      }.toList(),
      type: j['type'] as String?,
      format: j['format'] as String?,
      year: (j['startDate'] as Map?)?['year'] as int?,
      description: description == null
          ? null
          : htmlToPlainText(parseHtml(description).body!.innerHtml).trim(),
      coverUrl: switch ((j['coverImage'] as Map?)?['large']) {
        final String url => Uri.parse(url),
        _ => null,
      },
      genres: [for (final g in j['genres'] as List? ?? const []) '$g'],
      tags: [
        for (final tag in j['tags'] as List? ?? const [])
          if (((tag as Map)['rank'] as int? ?? 0) >= 60 &&
              tag['isMediaSpoiler'] != true)
            '${tag['name']}',
      ],
      isAdult: j['isAdult'] == true,
      characters: [
        for (final c
            in ((j['characters'] as Map?)?['nodes'] as List?) ?? const [])
          if (((c as Map)['name'] as Map?)?['full'] case final String full)
            (
              id: c['id'] as int,
              name: full,
              otherNames: {
                ?((c['name'] as Map)['native'] as String?),
                for (final a
                    in (c['name'] as Map)['alternative'] as List? ?? const [])
                  if ('$a'.trim().isNotEmpty) '$a',
              }.toList(),
            ),
      ],
      relations: [
        for (final e
            in ((j['relations'] as Map?)?['edges'] as List?) ?? const [])
          if ((e as Map)['node'] case {'id': final int id})
            (type: '${e['relationType']}', mediaId: id),
      ],
    );
  }
}

/// AniList's public GraphQL API (no key needed; about 90 requests a minute).
class AniListClient {
  AniListClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static final _endpoint = Uri.https('graphql.anilist.co', '/');

  static const _fields = '''
    id type format isAdult synonyms genres description(asHtml: false)
    title { romaji english native }
    startDate { year }
    coverImage { large }
    tags { name rank isMediaSpoiler }
    characters(perPage: 25, sort: [ROLE, RELEVANCE]) {
      nodes { id name { full native alternative } }
    }
    relations { edges { relationType node { id } } }
  ''';

  /// The best matches for [query]; [type] "MANGA" or "ANIME", or both.
  Future<List<AniListMedia>> search(String query, {String? type}) async {
    final data = await _post(
      'query (\$q: String, \$t: MediaType) { Page(perPage: 8) { '
      'media(search: \$q, type: \$t, sort: [SEARCH_MATCH, POPULARITY_DESC]) '
      '{ $_fields } } }',
      {'q': query, 't': ?type},
    );
    return [
      for (final m in ((data['Page'] as Map)['media'] as List))
        AniListMedia.fromJson((m as Map).cast<String, Object?>()),
    ];
  }

  Future<Map<String, Object?>> _post(
    String query,
    Map<String, Object?> variables,
  ) async {
    final http.Response response;
    try {
      response = await _client.post(
        _endpoint,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': HttpFetcher.userAgent,
        },
        body: jsonEncode({'query': query, 'variables': variables}),
      );
    } on Exception catch (e) {
      throw SourceException('AniList could not be reached: $e');
    }
    if (response.statusCode == 429) {
      throw SourceException(
        'AniList asks to slow down. Try again in a minute.',
      );
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (json['errors'] case [final first, ...]) {
      throw SourceException('AniList: ${(first as Map)['message']}');
    }
    if (response.statusCode != 200) {
      throw SourceException('AniList answered HTTP ${response.statusCode}.');
    }
    return (json['data'] as Map).cast<String, Object?>();
  }

  void close() => _client.close();
}
