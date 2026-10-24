/// Whole words that mark adult content; they must stand alone, so
/// "Analysis" is not "anal" and "Lemonade" is not "lemon".
const _adultWords = [
  'anal',
  'smut',
  'lemon',
  'nsfw',
  'pwp',
  'nude',
  'nudity',
  'orgy',
  'lewd',
  'ecchi',
  'yaoi',
  'yuri',
  'mpreg',
  'nc-17',
  'nc-21',
  '18+',
  'юри',
  'яой',
  'лемон',
  'cock',
  'cocks',
  'cum',
  'pussy',
  'dick',
  'tits',
  'boobs',
  'vagina',
  'penis',
];

/// Word beginnings that mark adult content ("sex" also matches "sexual").
const _adultStems = [
  // English
  'sex', 'explicit', 'porn', 'bdsm', 'rape', 'incest', 'underage', 'non-con',
  'noncon', 'dub-con', 'dubcon', 'fetish', 'kink', 'orgasm', 'masturbat',
  'bondage', 'threesome', 'foursome', 'hentai', 'erotic', 'tentacle',
  'lactation', 'blowjob', 'handjob', 'creampie', 'oral sex',
  'blow job', 'hand job', 'vaginal', 'genital', 'cunnilingus', 'fellatio',
  'deepthroat', 'gangbang', 'bukkake', 'voyeur', 'exhibitionis',
  // Russian
  'секс', 'анальн', 'оральн', 'порн', 'изнасил', 'инцест', 'бдсм', 'эрот',
  'оргазм', 'хентай', 'кинк', 'фетиш', 'мастурб', 'групповой секс',
];

final _adultPattern = RegExp(
  '(?:^|[^\\p{L}\\p{N}])'
  '(?:(?:${_adultWords.map(RegExp.escape).join('|')})(?![\\p{L}\\p{N}])'
  '|${_adultStems.map(RegExp.escape).join('|')})',
  caseSensitive: false,
  unicode: true,
);

/// Whether a tag looks like an adult-content tag, e.g. to hide it.
bool looksAdult(String tag) => _adultPattern.hasMatch(tag);
