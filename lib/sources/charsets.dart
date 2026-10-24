import 'dart:convert';

/// Decoders for the single-byte Cyrillic encodings some older sites still
/// use (Samlib: KOI8-R, Proza.ru: Windows-1251). Dart only ships UTF-8 and
/// Latin-1.
///
/// Each table holds the characters for bytes 0x80–0xFF, generated from
/// Python's codecs.
const _koi8r =
    '\u{2500}\u{2502}\u{250c}\u{2510}\u{2514}\u{2518}\u{251c}\u{2524}\u{252c}\u{2534}\u{253c}\u{2580}\u{2584}\u{2588}\u{258c}\u{2590}\u{2591}\u{2592}\u{2593}\u{2320}\u{25a0}\u{2219}\u{221a}\u{2248}\u{2264}\u{2265}\u{a0}\u{2321}\u{b0}\u{b2}\u{b7}\u{f7}\u{2550}\u{2551}\u{2552}\u{451}\u{2553}\u{2554}\u{2555}\u{2556}\u{2557}\u{2558}\u{2559}\u{255a}\u{255b}\u{255c}\u{255d}\u{255e}\u{255f}\u{2560}\u{2561}\u{401}\u{2562}\u{2563}\u{2564}\u{2565}\u{2566}\u{2567}\u{2568}\u{2569}\u{256a}\u{256b}\u{256c}\u{a9}\u{44e}\u{430}\u{431}\u{446}\u{434}\u{435}\u{444}\u{433}\u{445}\u{438}\u{439}\u{43a}\u{43b}\u{43c}\u{43d}\u{43e}\u{43f}\u{44f}\u{440}\u{441}\u{442}\u{443}\u{436}\u{432}\u{44c}\u{44b}\u{437}\u{448}\u{44d}\u{449}\u{447}\u{44a}\u{42e}\u{410}\u{411}\u{426}\u{414}\u{415}\u{424}\u{413}\u{425}\u{418}\u{419}\u{41a}\u{41b}\u{41c}\u{41d}\u{41e}\u{41f}\u{42f}\u{420}\u{421}\u{422}\u{423}\u{416}\u{412}\u{42c}\u{42b}\u{417}\u{428}\u{42d}\u{429}\u{427}\u{42a}';
const _windows1251 =
    '\u{402}\u{403}\u{201a}\u{453}\u{201e}\u{2026}\u{2020}\u{2021}\u{20ac}\u{2030}\u{409}\u{2039}\u{40a}\u{40c}\u{40b}\u{40f}\u{452}\u{2018}\u{2019}\u{201c}\u{201d}\u{2022}\u{2013}\u{2014}\u{fffd}\u{2122}\u{459}\u{203a}\u{45a}\u{45c}\u{45b}\u{45f}\u{a0}\u{40e}\u{45e}\u{408}\u{a4}\u{490}\u{a6}\u{a7}\u{401}\u{a9}\u{404}\u{ab}\u{ac}\u{ad}\u{ae}\u{407}\u{b0}\u{b1}\u{406}\u{456}\u{491}\u{b5}\u{b6}\u{b7}\u{451}\u{2116}\u{454}\u{bb}\u{458}\u{405}\u{455}\u{457}\u{410}\u{411}\u{412}\u{413}\u{414}\u{415}\u{416}\u{417}\u{418}\u{419}\u{41a}\u{41b}\u{41c}\u{41d}\u{41e}\u{41f}\u{420}\u{421}\u{422}\u{423}\u{424}\u{425}\u{426}\u{427}\u{428}\u{429}\u{42a}\u{42b}\u{42c}\u{42d}\u{42e}\u{42f}\u{430}\u{431}\u{432}\u{433}\u{434}\u{435}\u{436}\u{437}\u{438}\u{439}\u{43a}\u{43b}\u{43c}\u{43d}\u{43e}\u{43f}\u{440}\u{441}\u{442}\u{443}\u{444}\u{445}\u{446}\u{447}\u{448}\u{449}\u{44a}\u{44b}\u{44c}\u{44d}\u{44e}\u{44f}';

String _decodeSingleByte(List<int> bytes, String upperHalf) {
  final out = StringBuffer();
  for (final b in bytes) {
    out.writeCharCode(b < 0x80 ? b : upperHalf.codeUnitAt(b - 0x80));
  }
  return out.toString();
}

/// Decodes [bytes] in the named [charset]; unknown names mean UTF-8.
String decodeCharset(List<int> bytes, String? charset) =>
    switch (charset?.toLowerCase()) {
      'koi8-r' || 'koi8r' => _decodeSingleByte(bytes, _koi8r),
      'windows-1251' ||
      'cp1251' ||
      'win-1251' => _decodeSingleByte(bytes, _windows1251),
      _ => utf8.decode(bytes, allowMalformed: true),
    };

/// Decodes a page body using the charset from the Content-Type header, or
/// from a `<meta charset>` near the top of the page. Falls back to UTF-8.
String decodeBody(List<int> bytes, {String? contentType}) {
  final charset = _charsetFrom(contentType) ?? _sniffMetaCharset(bytes);
  return switch (charset) {
    'koi8-r' || 'koi8r' => _decodeSingleByte(bytes, _koi8r),
    'windows-1251' ||
    'cp1251' ||
    'win-1251' => _decodeSingleByte(bytes, _windows1251),
    _ => utf8.decode(bytes, allowMalformed: true),
  };
}

String? _charsetFrom(String? contentType) => contentType == null
    ? null
    : RegExp(
        r"""charset=["']?([\w-]+)""",
        caseSensitive: false,
      ).firstMatch(contentType)?.group(1)?.toLowerCase();

String? _sniffMetaCharset(List<int> bytes) {
  final head = latin1.decode(bytes.take(2048).toList(), allowInvalid: true);
  return _charsetFrom(
    RegExp(
      r'<meta[^>]+charset=[^>]*>',
      caseSensitive: false,
    ).firstMatch(head)?.group(0),
  );
}
