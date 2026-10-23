import 'package:flutter/foundation.dart';

import '../data/enums.dart';

/// A combination of library filters, as saved in a shelf.
@immutable
class LibraryFilter {
  const LibraryFilter({
    this.type,
    this.fandomId,
    this.tagId,
    this.pairingId,
    this.status,
    this.minWords,
    this.complete,
    this.sort = WorkSort.updated,
  });

  final WorkType? type;
  final int? fandomId;
  final int? tagId;
  final int? pairingId;
  final ReadingStatus? status;
  final int? minWords;
  final bool? complete;
  final WorkSort sort;

  static T? _byName<T extends Enum>(List<T> values, Object? name) =>
      values.where((v) => v.name == name).firstOrNull;

  factory LibraryFilter.fromJson(Map<String, Object?> json) => LibraryFilter(
    type: _byName(WorkType.values, json['type']),
    fandomId: json['fandomId'] as int?,
    tagId: json['tagId'] as int?,
    pairingId: json['pairingId'] as int?,
    status: _byName(ReadingStatus.values, json['status']),
    minWords: json['minWords'] as int?,
    complete: json['complete'] as bool?,
    sort: _byName(WorkSort.values, json['sort']) ?? WorkSort.updated,
  );

  Map<String, Object?> toJson() => {
    if (type != null) 'type': type!.name,
    if (fandomId != null) 'fandomId': fandomId,
    if (tagId != null) 'tagId': tagId,
    if (pairingId != null) 'pairingId': pairingId,
    if (status != null) 'status': status!.name,
    if (minWords != null) 'minWords': minWords,
    if (complete != null) 'complete': complete,
    'sort': sort.name,
  };
}

/// A named, saved filter ("smart shelf"), e.g. "Long finished romance".
@immutable
class Shelf {
  const Shelf(this.name, this.filter);

  final String name;
  final LibraryFilter filter;

  factory Shelf.fromJson(Map<String, Object?> json) => Shelf(
    json['name'] as String? ?? '',
    LibraryFilter.fromJson(
      (json['filter'] as Map?)?.cast<String, Object?>() ?? const {},
    ),
  );

  Map<String, Object?> toJson() => {'name': name, 'filter': filter.toJson()};
}
