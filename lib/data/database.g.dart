// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FandomsTable extends Fandoms with TableInfo<$FandomsTable, Fandom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FandomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fandoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fandom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fandom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fandom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $FandomsTable createAlias(String alias) {
    return $FandomsTable(attachedDatabase, alias);
  }
}

class Fandom extends DataClass implements Insertable<Fandom> {
  final int id;
  final String name;
  const Fandom({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  FandomsCompanion toCompanion(bool nullToAbsent) {
    return FandomsCompanion(id: Value(id), name: Value(name));
  }

  factory Fandom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fandom(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Fandom copyWith({int? id, String? name}) =>
      Fandom(id: id ?? this.id, name: name ?? this.name);
  Fandom copyWithCompanion(FandomsCompanion data) {
    return Fandom(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fandom(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fandom && other.id == this.id && other.name == this.name);
}

class FandomsCompanion extends UpdateCompanion<Fandom> {
  final Value<int> id;
  final Value<String> name;
  const FandomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  FandomsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Fandom> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  FandomsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return FandomsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FandomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, Character> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fandomIdMeta = const VerificationMeta(
    'fandomId',
  );
  @override
  late final GeneratedColumn<int> fandomId = GeneratedColumn<int>(
    'fandom_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fandoms (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _anilistIdMeta = const VerificationMeta(
    'anilistId',
  );
  @override
  late final GeneratedColumn<int> anilistId = GeneratedColumn<int>(
    'anilist_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, fandomId, anilistId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Character> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fandom_id')) {
      context.handle(
        _fandomIdMeta,
        fandomId.isAcceptableOrUnknown(data['fandom_id']!, _fandomIdMeta),
      );
    }
    if (data.containsKey('anilist_id')) {
      context.handle(
        _anilistIdMeta,
        anilistId.isAcceptableOrUnknown(data['anilist_id']!, _anilistIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Character map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Character(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fandomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fandom_id'],
      ),
      anilistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anilist_id'],
      ),
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class Character extends DataClass implements Insertable<Character> {
  final int id;
  final String name;
  final int? fandomId;

  /// The character's AniList id, once looked up there.
  final int? anilistId;
  const Character({
    required this.id,
    required this.name,
    this.fandomId,
    this.anilistId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fandomId != null) {
      map['fandom_id'] = Variable<int>(fandomId);
    }
    if (!nullToAbsent || anilistId != null) {
      map['anilist_id'] = Variable<int>(anilistId);
    }
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      name: Value(name),
      fandomId: fandomId == null && nullToAbsent
          ? const Value.absent()
          : Value(fandomId),
      anilistId: anilistId == null && nullToAbsent
          ? const Value.absent()
          : Value(anilistId),
    );
  }

  factory Character.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Character(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fandomId: serializer.fromJson<int?>(json['fandomId']),
      anilistId: serializer.fromJson<int?>(json['anilistId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fandomId': serializer.toJson<int?>(fandomId),
      'anilistId': serializer.toJson<int?>(anilistId),
    };
  }

  Character copyWith({
    int? id,
    String? name,
    Value<int?> fandomId = const Value.absent(),
    Value<int?> anilistId = const Value.absent(),
  }) => Character(
    id: id ?? this.id,
    name: name ?? this.name,
    fandomId: fandomId.present ? fandomId.value : this.fandomId,
    anilistId: anilistId.present ? anilistId.value : this.anilistId,
  );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fandomId: data.fandomId.present ? data.fandomId.value : this.fandomId,
      anilistId: data.anilistId.present ? data.anilistId.value : this.anilistId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Character(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fandomId: $fandomId, ')
          ..write('anilistId: $anilistId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, fandomId, anilistId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Character &&
          other.id == this.id &&
          other.name == this.name &&
          other.fandomId == this.fandomId &&
          other.anilistId == this.anilistId);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> fandomId;
  final Value<int?> anilistId;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fandomId = const Value.absent(),
    this.anilistId = const Value.absent(),
  });
  CharactersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.fandomId = const Value.absent(),
    this.anilistId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Character> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? fandomId,
    Expression<int>? anilistId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fandomId != null) 'fandom_id': fandomId,
      if (anilistId != null) 'anilist_id': anilistId,
    });
  }

  CharactersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? fandomId,
    Value<int?>? anilistId,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fandomId: fandomId ?? this.fandomId,
      anilistId: anilistId ?? this.anilistId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fandomId.present) {
      map['fandom_id'] = Variable<int>(fandomId.value);
    }
    if (anilistId.present) {
      map['anilist_id'] = Variable<int>(anilistId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fandomId: $fandomId, ')
          ..write('anilistId: $anilistId')
          ..write(')'))
        .toString();
  }
}

class $CharacterAliasesTable extends CharacterAliases
    with TableInfo<$CharacterAliasesTable, CharacterAliase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [characterId, alias];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterAliase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {characterId, alias};
  @override
  CharacterAliase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterAliase(
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
    );
  }

  @override
  $CharacterAliasesTable createAlias(String alias) {
    return $CharacterAliasesTable(attachedDatabase, alias);
  }
}

class CharacterAliase extends DataClass implements Insertable<CharacterAliase> {
  final int characterId;
  final String alias;
  const CharacterAliase({required this.characterId, required this.alias});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character_id'] = Variable<int>(characterId);
    map['alias'] = Variable<String>(alias);
    return map;
  }

  CharacterAliasesCompanion toCompanion(bool nullToAbsent) {
    return CharacterAliasesCompanion(
      characterId: Value(characterId),
      alias: Value(alias),
    );
  }

  factory CharacterAliase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterAliase(
      characterId: serializer.fromJson<int>(json['characterId']),
      alias: serializer.fromJson<String>(json['alias']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'characterId': serializer.toJson<int>(characterId),
      'alias': serializer.toJson<String>(alias),
    };
  }

  CharacterAliase copyWith({int? characterId, String? alias}) =>
      CharacterAliase(
        characterId: characterId ?? this.characterId,
        alias: alias ?? this.alias,
      );
  CharacterAliase copyWithCompanion(CharacterAliasesCompanion data) {
    return CharacterAliase(
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      alias: data.alias.present ? data.alias.value : this.alias,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterAliase(')
          ..write('characterId: $characterId, ')
          ..write('alias: $alias')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(characterId, alias);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterAliase &&
          other.characterId == this.characterId &&
          other.alias == this.alias);
}

class CharacterAliasesCompanion extends UpdateCompanion<CharacterAliase> {
  final Value<int> characterId;
  final Value<String> alias;
  final Value<int> rowid;
  const CharacterAliasesCompanion({
    this.characterId = const Value.absent(),
    this.alias = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterAliasesCompanion.insert({
    required int characterId,
    required String alias,
    this.rowid = const Value.absent(),
  }) : characterId = Value(characterId),
       alias = Value(alias);
  static Insertable<CharacterAliase> custom({
    Expression<int>? characterId,
    Expression<String>? alias,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (characterId != null) 'character_id': characterId,
      if (alias != null) 'alias': alias,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterAliasesCompanion copyWith({
    Value<int>? characterId,
    Value<String>? alias,
    Value<int>? rowid,
  }) {
    return CharacterAliasesCompanion(
      characterId: characterId ?? this.characterId,
      alias: alias ?? this.alias,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterAliasesCompanion(')
          ..write('characterId: $characterId, ')
          ..write('alias: $alias, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesTable extends Series with TableInfo<$SeriesTable, SeriesItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SeriesTable createAlias(String alias) {
    return $SeriesTable(attachedDatabase, alias);
  }
}

class SeriesItem extends DataClass implements Insertable<SeriesItem> {
  final int id;
  final String name;
  const SeriesItem({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  SeriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCompanion(id: Value(id), name: Value(name));
  }

  factory SeriesItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  SeriesItem copyWith({int? id, String? name}) =>
      SeriesItem(id: id ?? this.id, name: name ?? this.name);
  SeriesItem copyWithCompanion(SeriesCompanion data) {
    return SeriesItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesItem(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesItem && other.id == this.id && other.name == this.name);
}

class SeriesCompanion extends UpdateCompanion<SeriesItem> {
  final Value<int> id;
  final Value<String> name;
  const SeriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  SeriesCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<SeriesItem> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  SeriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return SeriesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WorksTable extends Works with TableInfo<$WorksTable, Work> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorkType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WorkType>($WorksTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<WorkFormat, String> format =
      GeneratedColumn<String>(
        'format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WorkFormat>($WorksTable.$converterformat);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fandomIdMeta = const VerificationMeta(
    'fandomId',
  );
  @override
  late final GeneratedColumn<int> fandomId = GeneratedColumn<int>(
    'fandom_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fandoms (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReadingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ReadingStatus.planned.name),
      ).withConverter<ReadingStatus>($WorksTable.$converterstatus);
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _chapterCountMeta = const VerificationMeta(
    'chapterCount',
  );
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
    'chapter_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentChapterMeta = const VerificationMeta(
    'currentChapter',
  );
  @override
  late final GeneratedColumn<int> currentChapter = GeneratedColumn<int>(
    'current_chapter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readOffsetMeta = const VerificationMeta(
    'readOffset',
  );
  @override
  late final GeneratedColumn<double> readOffset = GeneratedColumn<double>(
    'read_offset',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastChapterAtMeta = const VerificationMeta(
    'lastChapterAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastChapterAt =
      GeneratedColumn<DateTime>(
        'last_chapter_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _newChaptersMeta = const VerificationMeta(
    'newChapters',
  );
  @override
  late final GeneratedColumn<int> newChapters = GeneratedColumn<int>(
    'new_chapters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES series (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _seriesIndexMeta = const VerificationMeta(
    'seriesIndex',
  );
  @override
  late final GeneratedColumn<double> seriesIndex = GeneratedColumn<double>(
    'series_index',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordsEstimatedMeta = const VerificationMeta(
    'wordsEstimated',
  );
  @override
  late final GeneratedColumn<bool> wordsEstimated = GeneratedColumn<bool>(
    'words_estimated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("words_estimated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pagesEstimatedMeta = const VerificationMeta(
    'pagesEstimated',
  );
  @override
  late final GeneratedColumn<bool> pagesEstimated = GeneratedColumn<bool>(
    'pages_estimated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pages_estimated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _characterCountMeta = const VerificationMeta(
    'characterCount',
  );
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
    'character_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    format,
    title,
    author,
    summary,
    isbn,
    sourceUrl,
    coverUrl,
    coverPath,
    fandomId,
    status,
    isComplete,
    chapterCount,
    currentChapter,
    readOffset,
    wordCount,
    pageCount,
    rating,
    notes,
    addedAt,
    updatedAt,
    checkedAt,
    lastChapterAt,
    newChapters,
    deletedAt,
    finishedAt,
    seriesId,
    seriesIndex,
    wordsEstimated,
    pagesEstimated,
    characterCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'works';
  @override
  VerificationContext validateIntegrity(
    Insertable<Work> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('fandom_id')) {
      context.handle(
        _fandomIdMeta,
        fandomId.isAcceptableOrUnknown(data['fandom_id']!, _fandomIdMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
        _chapterCountMeta,
        chapterCount.isAcceptableOrUnknown(
          data['chapter_count']!,
          _chapterCountMeta,
        ),
      );
    }
    if (data.containsKey('current_chapter')) {
      context.handle(
        _currentChapterMeta,
        currentChapter.isAcceptableOrUnknown(
          data['current_chapter']!,
          _currentChapterMeta,
        ),
      );
    }
    if (data.containsKey('read_offset')) {
      context.handle(
        _readOffsetMeta,
        readOffset.isAcceptableOrUnknown(data['read_offset']!, _readOffsetMeta),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    }
    if (data.containsKey('last_chapter_at')) {
      context.handle(
        _lastChapterAtMeta,
        lastChapterAt.isAcceptableOrUnknown(
          data['last_chapter_at']!,
          _lastChapterAtMeta,
        ),
      );
    }
    if (data.containsKey('new_chapters')) {
      context.handle(
        _newChaptersMeta,
        newChapters.isAcceptableOrUnknown(
          data['new_chapters']!,
          _newChaptersMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('series_index')) {
      context.handle(
        _seriesIndexMeta,
        seriesIndex.isAcceptableOrUnknown(
          data['series_index']!,
          _seriesIndexMeta,
        ),
      );
    }
    if (data.containsKey('words_estimated')) {
      context.handle(
        _wordsEstimatedMeta,
        wordsEstimated.isAcceptableOrUnknown(
          data['words_estimated']!,
          _wordsEstimatedMeta,
        ),
      );
    }
    if (data.containsKey('pages_estimated')) {
      context.handle(
        _pagesEstimatedMeta,
        pagesEstimated.isAcceptableOrUnknown(
          data['pages_estimated']!,
          _pagesEstimatedMeta,
        ),
      );
    }
    if (data.containsKey('character_count')) {
      context.handle(
        _characterCountMeta,
        characterCount.isAcceptableOrUnknown(
          data['character_count']!,
          _characterCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Work map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Work(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $WorksTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      format: $WorksTable.$converterformat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}format'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      fandomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fandom_id'],
      ),
      status: $WorksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      chapterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_count'],
      ),
      currentChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_chapter'],
      ),
      readOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}read_offset'],
      ),
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      ),
      lastChapterAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_chapter_at'],
      ),
      newChapters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_chapters'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      ),
      seriesIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}series_index'],
      ),
      wordsEstimated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}words_estimated'],
      )!,
      pagesEstimated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pages_estimated'],
      )!,
      characterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_count'],
      ),
    );
  }

  @override
  $WorksTable createAlias(String alias) {
    return $WorksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WorkType, String, String> $convertertype =
      const EnumNameConverter<WorkType>(WorkType.values);
  static JsonTypeConverter2<WorkFormat, String, String> $converterformat =
      const EnumNameConverter<WorkFormat>(WorkFormat.values);
  static JsonTypeConverter2<ReadingStatus, String, String> $converterstatus =
      const EnumNameConverter<ReadingStatus>(ReadingStatus.values);
}

class Work extends DataClass implements Insertable<Work> {
  final int id;
  final WorkType type;
  final WorkFormat format;
  final String title;
  final String? author;
  final String? summary;
  final String? isbn;
  final String? sourceUrl;
  final String? coverUrl;

  /// Downloaded cover, so it shows offline.
  final String? coverPath;
  final int? fandomId;
  final ReadingStatus status;

  /// Whether the author has finished the story.
  final bool isComplete;
  final int? chapterCount;
  final int? currentChapter;

  /// Scroll position within [currentChapter], from 0 (top) to 1 (end).
  final double? readOffset;
  final int? wordCount;
  final int? pageCount;

  /// 1 to 5 stars.
  final int? rating;
  final String? notes;
  final DateTime addedAt;
  final DateTime updatedAt;

  /// When the site was last checked for new chapters.
  final DateTime? checkedAt;

  /// When the latest chapter came out: the site's date if it shows one,
  /// otherwise when ReadTrack first saw it.
  final DateTime? lastChapterAt;

  /// Chapters found by update checks that the user hasn't looked at yet.
  final int newChapters;

  /// Set while the work is in the trash.
  final DateTime? deletedAt;

  /// When the status last became "finished" (kept by a trigger).
  final DateTime? finishedAt;
  final int? seriesId;

  /// Position in the series; may be fractional (2.5 for a side story).
  final double? seriesIndex;

  /// Whether [wordCount] / [pageCount] were worked out by the app because
  /// the site didn't give them; such values are updated as more is known.
  final bool wordsEstimated;
  final bool pagesEstimated;

  /// Size in characters (with spaces), for sites that give only that.
  final int? characterCount;
  const Work({
    required this.id,
    required this.type,
    required this.format,
    required this.title,
    this.author,
    this.summary,
    this.isbn,
    this.sourceUrl,
    this.coverUrl,
    this.coverPath,
    this.fandomId,
    required this.status,
    required this.isComplete,
    this.chapterCount,
    this.currentChapter,
    this.readOffset,
    this.wordCount,
    this.pageCount,
    this.rating,
    this.notes,
    required this.addedAt,
    required this.updatedAt,
    this.checkedAt,
    this.lastChapterAt,
    required this.newChapters,
    this.deletedAt,
    this.finishedAt,
    this.seriesId,
    this.seriesIndex,
    required this.wordsEstimated,
    required this.pagesEstimated,
    this.characterCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>($WorksTable.$convertertype.toSql(type));
    }
    {
      map['format'] = Variable<String>(
        $WorksTable.$converterformat.toSql(format),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || fandomId != null) {
      map['fandom_id'] = Variable<int>(fandomId);
    }
    {
      map['status'] = Variable<String>(
        $WorksTable.$converterstatus.toSql(status),
      );
    }
    map['is_complete'] = Variable<bool>(isComplete);
    if (!nullToAbsent || chapterCount != null) {
      map['chapter_count'] = Variable<int>(chapterCount);
    }
    if (!nullToAbsent || currentChapter != null) {
      map['current_chapter'] = Variable<int>(currentChapter);
    }
    if (!nullToAbsent || readOffset != null) {
      map['read_offset'] = Variable<double>(readOffset);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<int>(wordCount);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<DateTime>(checkedAt);
    }
    if (!nullToAbsent || lastChapterAt != null) {
      map['last_chapter_at'] = Variable<DateTime>(lastChapterAt);
    }
    map['new_chapters'] = Variable<int>(newChapters);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    if (!nullToAbsent || seriesIndex != null) {
      map['series_index'] = Variable<double>(seriesIndex);
    }
    map['words_estimated'] = Variable<bool>(wordsEstimated);
    map['pages_estimated'] = Variable<bool>(pagesEstimated);
    if (!nullToAbsent || characterCount != null) {
      map['character_count'] = Variable<int>(characterCount);
    }
    return map;
  }

  WorksCompanion toCompanion(bool nullToAbsent) {
    return WorksCompanion(
      id: Value(id),
      type: Value(type),
      format: Value(format),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      fandomId: fandomId == null && nullToAbsent
          ? const Value.absent()
          : Value(fandomId),
      status: Value(status),
      isComplete: Value(isComplete),
      chapterCount: chapterCount == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterCount),
      currentChapter: currentChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(currentChapter),
      readOffset: readOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(readOffset),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      addedAt: Value(addedAt),
      updatedAt: Value(updatedAt),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
      lastChapterAt: lastChapterAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapterAt),
      newChapters: Value(newChapters),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      seriesIndex: seriesIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesIndex),
      wordsEstimated: Value(wordsEstimated),
      pagesEstimated: Value(pagesEstimated),
      characterCount: characterCount == null && nullToAbsent
          ? const Value.absent()
          : Value(characterCount),
    );
  }

  factory Work.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Work(
      id: serializer.fromJson<int>(json['id']),
      type: $WorksTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      format: $WorksTable.$converterformat.fromJson(
        serializer.fromJson<String>(json['format']),
      ),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      summary: serializer.fromJson<String?>(json['summary']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      fandomId: serializer.fromJson<int?>(json['fandomId']),
      status: $WorksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      chapterCount: serializer.fromJson<int?>(json['chapterCount']),
      currentChapter: serializer.fromJson<int?>(json['currentChapter']),
      readOffset: serializer.fromJson<double?>(json['readOffset']),
      wordCount: serializer.fromJson<int?>(json['wordCount']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      rating: serializer.fromJson<int?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      checkedAt: serializer.fromJson<DateTime?>(json['checkedAt']),
      lastChapterAt: serializer.fromJson<DateTime?>(json['lastChapterAt']),
      newChapters: serializer.fromJson<int>(json['newChapters']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      seriesId: serializer.fromJson<int?>(json['seriesId']),
      seriesIndex: serializer.fromJson<double?>(json['seriesIndex']),
      wordsEstimated: serializer.fromJson<bool>(json['wordsEstimated']),
      pagesEstimated: serializer.fromJson<bool>(json['pagesEstimated']),
      characterCount: serializer.fromJson<int?>(json['characterCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        $WorksTable.$convertertype.toJson(type),
      ),
      'format': serializer.toJson<String>(
        $WorksTable.$converterformat.toJson(format),
      ),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'summary': serializer.toJson<String?>(summary),
      'isbn': serializer.toJson<String?>(isbn),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'coverPath': serializer.toJson<String?>(coverPath),
      'fandomId': serializer.toJson<int?>(fandomId),
      'status': serializer.toJson<String>(
        $WorksTable.$converterstatus.toJson(status),
      ),
      'isComplete': serializer.toJson<bool>(isComplete),
      'chapterCount': serializer.toJson<int?>(chapterCount),
      'currentChapter': serializer.toJson<int?>(currentChapter),
      'readOffset': serializer.toJson<double?>(readOffset),
      'wordCount': serializer.toJson<int?>(wordCount),
      'pageCount': serializer.toJson<int?>(pageCount),
      'rating': serializer.toJson<int?>(rating),
      'notes': serializer.toJson<String?>(notes),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'checkedAt': serializer.toJson<DateTime?>(checkedAt),
      'lastChapterAt': serializer.toJson<DateTime?>(lastChapterAt),
      'newChapters': serializer.toJson<int>(newChapters),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'seriesId': serializer.toJson<int?>(seriesId),
      'seriesIndex': serializer.toJson<double?>(seriesIndex),
      'wordsEstimated': serializer.toJson<bool>(wordsEstimated),
      'pagesEstimated': serializer.toJson<bool>(pagesEstimated),
      'characterCount': serializer.toJson<int?>(characterCount),
    };
  }

  Work copyWith({
    int? id,
    WorkType? type,
    WorkFormat? format,
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> isbn = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    Value<int?> fandomId = const Value.absent(),
    ReadingStatus? status,
    bool? isComplete,
    Value<int?> chapterCount = const Value.absent(),
    Value<int?> currentChapter = const Value.absent(),
    Value<double?> readOffset = const Value.absent(),
    Value<int?> wordCount = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? addedAt,
    DateTime? updatedAt,
    Value<DateTime?> checkedAt = const Value.absent(),
    Value<DateTime?> lastChapterAt = const Value.absent(),
    int? newChapters,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<int?> seriesId = const Value.absent(),
    Value<double?> seriesIndex = const Value.absent(),
    bool? wordsEstimated,
    bool? pagesEstimated,
    Value<int?> characterCount = const Value.absent(),
  }) => Work(
    id: id ?? this.id,
    type: type ?? this.type,
    format: format ?? this.format,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    summary: summary.present ? summary.value : this.summary,
    isbn: isbn.present ? isbn.value : this.isbn,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    fandomId: fandomId.present ? fandomId.value : this.fandomId,
    status: status ?? this.status,
    isComplete: isComplete ?? this.isComplete,
    chapterCount: chapterCount.present ? chapterCount.value : this.chapterCount,
    currentChapter: currentChapter.present
        ? currentChapter.value
        : this.currentChapter,
    readOffset: readOffset.present ? readOffset.value : this.readOffset,
    wordCount: wordCount.present ? wordCount.value : this.wordCount,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    rating: rating.present ? rating.value : this.rating,
    notes: notes.present ? notes.value : this.notes,
    addedAt: addedAt ?? this.addedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
    lastChapterAt: lastChapterAt.present
        ? lastChapterAt.value
        : this.lastChapterAt,
    newChapters: newChapters ?? this.newChapters,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    seriesIndex: seriesIndex.present ? seriesIndex.value : this.seriesIndex,
    wordsEstimated: wordsEstimated ?? this.wordsEstimated,
    pagesEstimated: pagesEstimated ?? this.pagesEstimated,
    characterCount: characterCount.present
        ? characterCount.value
        : this.characterCount,
  );
  Work copyWithCompanion(WorksCompanion data) {
    return Work(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      format: data.format.present ? data.format.value : this.format,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      summary: data.summary.present ? data.summary.value : this.summary,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      fandomId: data.fandomId.present ? data.fandomId.value : this.fandomId,
      status: data.status.present ? data.status.value : this.status,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
      currentChapter: data.currentChapter.present
          ? data.currentChapter.value
          : this.currentChapter,
      readOffset: data.readOffset.present
          ? data.readOffset.value
          : this.readOffset,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      lastChapterAt: data.lastChapterAt.present
          ? data.lastChapterAt.value
          : this.lastChapterAt,
      newChapters: data.newChapters.present
          ? data.newChapters.value
          : this.newChapters,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      seriesIndex: data.seriesIndex.present
          ? data.seriesIndex.value
          : this.seriesIndex,
      wordsEstimated: data.wordsEstimated.present
          ? data.wordsEstimated.value
          : this.wordsEstimated,
      pagesEstimated: data.pagesEstimated.present
          ? data.pagesEstimated.value
          : this.pagesEstimated,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Work(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('isbn: $isbn, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverPath: $coverPath, ')
          ..write('fandomId: $fandomId, ')
          ..write('status: $status, ')
          ..write('isComplete: $isComplete, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('currentChapter: $currentChapter, ')
          ..write('readOffset: $readOffset, ')
          ..write('wordCount: $wordCount, ')
          ..write('pageCount: $pageCount, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('lastChapterAt: $lastChapterAt, ')
          ..write('newChapters: $newChapters, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesIndex: $seriesIndex, ')
          ..write('wordsEstimated: $wordsEstimated, ')
          ..write('pagesEstimated: $pagesEstimated, ')
          ..write('characterCount: $characterCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    type,
    format,
    title,
    author,
    summary,
    isbn,
    sourceUrl,
    coverUrl,
    coverPath,
    fandomId,
    status,
    isComplete,
    chapterCount,
    currentChapter,
    readOffset,
    wordCount,
    pageCount,
    rating,
    notes,
    addedAt,
    updatedAt,
    checkedAt,
    lastChapterAt,
    newChapters,
    deletedAt,
    finishedAt,
    seriesId,
    seriesIndex,
    wordsEstimated,
    pagesEstimated,
    characterCount,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Work &&
          other.id == this.id &&
          other.type == this.type &&
          other.format == this.format &&
          other.title == this.title &&
          other.author == this.author &&
          other.summary == this.summary &&
          other.isbn == this.isbn &&
          other.sourceUrl == this.sourceUrl &&
          other.coverUrl == this.coverUrl &&
          other.coverPath == this.coverPath &&
          other.fandomId == this.fandomId &&
          other.status == this.status &&
          other.isComplete == this.isComplete &&
          other.chapterCount == this.chapterCount &&
          other.currentChapter == this.currentChapter &&
          other.readOffset == this.readOffset &&
          other.wordCount == this.wordCount &&
          other.pageCount == this.pageCount &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.addedAt == this.addedAt &&
          other.updatedAt == this.updatedAt &&
          other.checkedAt == this.checkedAt &&
          other.lastChapterAt == this.lastChapterAt &&
          other.newChapters == this.newChapters &&
          other.deletedAt == this.deletedAt &&
          other.finishedAt == this.finishedAt &&
          other.seriesId == this.seriesId &&
          other.seriesIndex == this.seriesIndex &&
          other.wordsEstimated == this.wordsEstimated &&
          other.pagesEstimated == this.pagesEstimated &&
          other.characterCount == this.characterCount);
}

class WorksCompanion extends UpdateCompanion<Work> {
  final Value<int> id;
  final Value<WorkType> type;
  final Value<WorkFormat> format;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> summary;
  final Value<String?> isbn;
  final Value<String?> sourceUrl;
  final Value<String?> coverUrl;
  final Value<String?> coverPath;
  final Value<int?> fandomId;
  final Value<ReadingStatus> status;
  final Value<bool> isComplete;
  final Value<int?> chapterCount;
  final Value<int?> currentChapter;
  final Value<double?> readOffset;
  final Value<int?> wordCount;
  final Value<int?> pageCount;
  final Value<int?> rating;
  final Value<String?> notes;
  final Value<DateTime> addedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> checkedAt;
  final Value<DateTime?> lastChapterAt;
  final Value<int> newChapters;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> seriesId;
  final Value<double?> seriesIndex;
  final Value<bool> wordsEstimated;
  final Value<bool> pagesEstimated;
  final Value<int?> characterCount;
  const WorksCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.format = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.isbn = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.fandomId = const Value.absent(),
    this.status = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.currentChapter = const Value.absent(),
    this.readOffset = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.lastChapterAt = const Value.absent(),
    this.newChapters = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesIndex = const Value.absent(),
    this.wordsEstimated = const Value.absent(),
    this.pagesEstimated = const Value.absent(),
    this.characterCount = const Value.absent(),
  });
  WorksCompanion.insert({
    this.id = const Value.absent(),
    required WorkType type,
    required WorkFormat format,
    required String title,
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.isbn = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.fandomId = const Value.absent(),
    this.status = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.currentChapter = const Value.absent(),
    this.readOffset = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.lastChapterAt = const Value.absent(),
    this.newChapters = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesIndex = const Value.absent(),
    this.wordsEstimated = const Value.absent(),
    this.pagesEstimated = const Value.absent(),
    this.characterCount = const Value.absent(),
  }) : type = Value(type),
       format = Value(format),
       title = Value(title);
  static Insertable<Work> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? format,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? summary,
    Expression<String>? isbn,
    Expression<String>? sourceUrl,
    Expression<String>? coverUrl,
    Expression<String>? coverPath,
    Expression<int>? fandomId,
    Expression<String>? status,
    Expression<bool>? isComplete,
    Expression<int>? chapterCount,
    Expression<int>? currentChapter,
    Expression<double>? readOffset,
    Expression<int>? wordCount,
    Expression<int>? pageCount,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? checkedAt,
    Expression<DateTime>? lastChapterAt,
    Expression<int>? newChapters,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? seriesId,
    Expression<double>? seriesIndex,
    Expression<bool>? wordsEstimated,
    Expression<bool>? pagesEstimated,
    Expression<int>? characterCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (format != null) 'format': format,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (summary != null) 'summary': summary,
      if (isbn != null) 'isbn': isbn,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (coverPath != null) 'cover_path': coverPath,
      if (fandomId != null) 'fandom_id': fandomId,
      if (status != null) 'status': status,
      if (isComplete != null) 'is_complete': isComplete,
      if (chapterCount != null) 'chapter_count': chapterCount,
      if (currentChapter != null) 'current_chapter': currentChapter,
      if (readOffset != null) 'read_offset': readOffset,
      if (wordCount != null) 'word_count': wordCount,
      if (pageCount != null) 'page_count': pageCount,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (lastChapterAt != null) 'last_chapter_at': lastChapterAt,
      if (newChapters != null) 'new_chapters': newChapters,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (seriesId != null) 'series_id': seriesId,
      if (seriesIndex != null) 'series_index': seriesIndex,
      if (wordsEstimated != null) 'words_estimated': wordsEstimated,
      if (pagesEstimated != null) 'pages_estimated': pagesEstimated,
      if (characterCount != null) 'character_count': characterCount,
    });
  }

  WorksCompanion copyWith({
    Value<int>? id,
    Value<WorkType>? type,
    Value<WorkFormat>? format,
    Value<String>? title,
    Value<String?>? author,
    Value<String?>? summary,
    Value<String?>? isbn,
    Value<String?>? sourceUrl,
    Value<String?>? coverUrl,
    Value<String?>? coverPath,
    Value<int?>? fandomId,
    Value<ReadingStatus>? status,
    Value<bool>? isComplete,
    Value<int?>? chapterCount,
    Value<int?>? currentChapter,
    Value<double?>? readOffset,
    Value<int?>? wordCount,
    Value<int?>? pageCount,
    Value<int?>? rating,
    Value<String?>? notes,
    Value<DateTime>? addedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? checkedAt,
    Value<DateTime?>? lastChapterAt,
    Value<int>? newChapters,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? finishedAt,
    Value<int?>? seriesId,
    Value<double?>? seriesIndex,
    Value<bool>? wordsEstimated,
    Value<bool>? pagesEstimated,
    Value<int?>? characterCount,
  }) {
    return WorksCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      format: format ?? this.format,
      title: title ?? this.title,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      isbn: isbn ?? this.isbn,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      coverPath: coverPath ?? this.coverPath,
      fandomId: fandomId ?? this.fandomId,
      status: status ?? this.status,
      isComplete: isComplete ?? this.isComplete,
      chapterCount: chapterCount ?? this.chapterCount,
      currentChapter: currentChapter ?? this.currentChapter,
      readOffset: readOffset ?? this.readOffset,
      wordCount: wordCount ?? this.wordCount,
      pageCount: pageCount ?? this.pageCount,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      checkedAt: checkedAt ?? this.checkedAt,
      lastChapterAt: lastChapterAt ?? this.lastChapterAt,
      newChapters: newChapters ?? this.newChapters,
      deletedAt: deletedAt ?? this.deletedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      seriesId: seriesId ?? this.seriesId,
      seriesIndex: seriesIndex ?? this.seriesIndex,
      wordsEstimated: wordsEstimated ?? this.wordsEstimated,
      pagesEstimated: pagesEstimated ?? this.pagesEstimated,
      characterCount: characterCount ?? this.characterCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $WorksTable.$convertertype.toSql(type.value),
      );
    }
    if (format.present) {
      map['format'] = Variable<String>(
        $WorksTable.$converterformat.toSql(format.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (fandomId.present) {
      map['fandom_id'] = Variable<int>(fandomId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $WorksTable.$converterstatus.toSql(status.value),
      );
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    if (currentChapter.present) {
      map['current_chapter'] = Variable<int>(currentChapter.value);
    }
    if (readOffset.present) {
      map['read_offset'] = Variable<double>(readOffset.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (lastChapterAt.present) {
      map['last_chapter_at'] = Variable<DateTime>(lastChapterAt.value);
    }
    if (newChapters.present) {
      map['new_chapters'] = Variable<int>(newChapters.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (seriesIndex.present) {
      map['series_index'] = Variable<double>(seriesIndex.value);
    }
    if (wordsEstimated.present) {
      map['words_estimated'] = Variable<bool>(wordsEstimated.value);
    }
    if (pagesEstimated.present) {
      map['pages_estimated'] = Variable<bool>(pagesEstimated.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorksCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('isbn: $isbn, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverPath: $coverPath, ')
          ..write('fandomId: $fandomId, ')
          ..write('status: $status, ')
          ..write('isComplete: $isComplete, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('currentChapter: $currentChapter, ')
          ..write('readOffset: $readOffset, ')
          ..write('wordCount: $wordCount, ')
          ..write('pageCount: $pageCount, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('lastChapterAt: $lastChapterAt, ')
          ..write('newChapters: $newChapters, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesIndex: $seriesIndex, ')
          ..write('wordsEstimated: $wordsEstimated, ')
          ..write('pagesEstimated: $pagesEstimated, ')
          ..write('characterCount: $characterCount')
          ..write(')'))
        .toString();
  }
}

class $WorkCharactersTable extends WorkCharacters
    with TableInfo<$WorkCharactersTable, WorkCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkCharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [workId, characterId, confidence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, characterId};
  @override
  WorkCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkCharacter(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $WorkCharactersTable createAlias(String alias) {
    return $WorkCharactersTable(attachedDatabase, alias);
  }
}

class WorkCharacter extends DataClass implements Insertable<WorkCharacter> {
  final int workId;
  final int characterId;

  /// 1 when the site or the user names the character; lower when guessed.
  final double confidence;
  const WorkCharacter({
    required this.workId,
    required this.characterId,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<int>(workId);
    map['character_id'] = Variable<int>(characterId);
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  WorkCharactersCompanion toCompanion(bool nullToAbsent) {
    return WorkCharactersCompanion(
      workId: Value(workId),
      characterId: Value(characterId),
      confidence: Value(confidence),
    );
  }

  factory WorkCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkCharacter(
      workId: serializer.fromJson<int>(json['workId']),
      characterId: serializer.fromJson<int>(json['characterId']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<int>(workId),
      'characterId': serializer.toJson<int>(characterId),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  WorkCharacter copyWith({int? workId, int? characterId, double? confidence}) =>
      WorkCharacter(
        workId: workId ?? this.workId,
        characterId: characterId ?? this.characterId,
        confidence: confidence ?? this.confidence,
      );
  WorkCharacter copyWithCompanion(WorkCharactersCompanion data) {
    return WorkCharacter(
      workId: data.workId.present ? data.workId.value : this.workId,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkCharacter(')
          ..write('workId: $workId, ')
          ..write('characterId: $characterId, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, characterId, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkCharacter &&
          other.workId == this.workId &&
          other.characterId == this.characterId &&
          other.confidence == this.confidence);
}

class WorkCharactersCompanion extends UpdateCompanion<WorkCharacter> {
  final Value<int> workId;
  final Value<int> characterId;
  final Value<double> confidence;
  final Value<int> rowid;
  const WorkCharactersCompanion({
    this.workId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkCharactersCompanion.insert({
    required int workId,
    required int characterId,
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       characterId = Value(characterId);
  static Insertable<WorkCharacter> custom({
    Expression<int>? workId,
    Expression<int>? characterId,
    Expression<double>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (characterId != null) 'character_id': characterId,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkCharactersCompanion copyWith({
    Value<int>? workId,
    Value<int>? characterId,
    Value<double>? confidence,
    Value<int>? rowid,
  }) {
    return WorkCharactersCompanion(
      workId: workId ?? this.workId,
      characterId: characterId ?? this.characterId,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkCharactersCompanion(')
          ..write('workId: $workId, ')
          ..write('characterId: $characterId, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkFandomsTable extends WorkFandoms
    with TableInfo<$WorkFandomsTable, WorkFandom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkFandomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fandomIdMeta = const VerificationMeta(
    'fandomId',
  );
  @override
  late final GeneratedColumn<int> fandomId = GeneratedColumn<int>(
    'fandom_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fandoms (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FandomRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('crossover'),
      ).withConverter<FandomRole>($WorkFandomsTable.$converterrole);
  @override
  List<GeneratedColumn> get $columns => [workId, fandomId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_fandoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkFandom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('fandom_id')) {
      context.handle(
        _fandomIdMeta,
        fandomId.isAcceptableOrUnknown(data['fandom_id']!, _fandomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fandomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, fandomId};
  @override
  WorkFandom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkFandom(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      fandomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fandom_id'],
      )!,
      role: $WorkFandomsTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
    );
  }

  @override
  $WorkFandomsTable createAlias(String alias) {
    return $WorkFandomsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FandomRole, String, String> $converterrole =
      const EnumNameConverter<FandomRole>(FandomRole.values);
}

class WorkFandom extends DataClass implements Insertable<WorkFandom> {
  final int workId;
  final int fandomId;
  final FandomRole role;
  const WorkFandom({
    required this.workId,
    required this.fandomId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<int>(workId);
    map['fandom_id'] = Variable<int>(fandomId);
    {
      map['role'] = Variable<String>(
        $WorkFandomsTable.$converterrole.toSql(role),
      );
    }
    return map;
  }

  WorkFandomsCompanion toCompanion(bool nullToAbsent) {
    return WorkFandomsCompanion(
      workId: Value(workId),
      fandomId: Value(fandomId),
      role: Value(role),
    );
  }

  factory WorkFandom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkFandom(
      workId: serializer.fromJson<int>(json['workId']),
      fandomId: serializer.fromJson<int>(json['fandomId']),
      role: $WorkFandomsTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<int>(workId),
      'fandomId': serializer.toJson<int>(fandomId),
      'role': serializer.toJson<String>(
        $WorkFandomsTable.$converterrole.toJson(role),
      ),
    };
  }

  WorkFandom copyWith({int? workId, int? fandomId, FandomRole? role}) =>
      WorkFandom(
        workId: workId ?? this.workId,
        fandomId: fandomId ?? this.fandomId,
        role: role ?? this.role,
      );
  WorkFandom copyWithCompanion(WorkFandomsCompanion data) {
    return WorkFandom(
      workId: data.workId.present ? data.workId.value : this.workId,
      fandomId: data.fandomId.present ? data.fandomId.value : this.fandomId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkFandom(')
          ..write('workId: $workId, ')
          ..write('fandomId: $fandomId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, fandomId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkFandom &&
          other.workId == this.workId &&
          other.fandomId == this.fandomId &&
          other.role == this.role);
}

class WorkFandomsCompanion extends UpdateCompanion<WorkFandom> {
  final Value<int> workId;
  final Value<int> fandomId;
  final Value<FandomRole> role;
  final Value<int> rowid;
  const WorkFandomsCompanion({
    this.workId = const Value.absent(),
    this.fandomId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkFandomsCompanion.insert({
    required int workId,
    required int fandomId,
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       fandomId = Value(fandomId);
  static Insertable<WorkFandom> custom({
    Expression<int>? workId,
    Expression<int>? fandomId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (fandomId != null) 'fandom_id': fandomId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkFandomsCompanion copyWith({
    Value<int>? workId,
    Value<int>? fandomId,
    Value<FandomRole>? role,
    Value<int>? rowid,
  }) {
    return WorkFandomsCompanion(
      workId: workId ?? this.workId,
      fandomId: fandomId ?? this.fandomId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (fandomId.present) {
      map['fandom_id'] = Variable<int>(fandomId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $WorkFandomsTable.$converterrole.toSql(role.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkFandomsCompanion(')
          ..write('workId: $workId, ')
          ..write('fandomId: $fandomId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkRelationsTable extends WorkRelations
    with TableInfo<$WorkRelationsTable, WorkRelation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkRelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fromWorkIdMeta = const VerificationMeta(
    'fromWorkId',
  );
  @override
  late final GeneratedColumn<int> fromWorkId = GeneratedColumn<int>(
    'from_work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toWorkIdMeta = const VerificationMeta(
    'toWorkId',
  );
  @override
  late final GeneratedColumn<int> toWorkId = GeneratedColumn<int>(
    'to_work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RelationType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RelationType>($WorkRelationsTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [fromWorkId, toWorkId, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_relations';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkRelation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('from_work_id')) {
      context.handle(
        _fromWorkIdMeta,
        fromWorkId.isAcceptableOrUnknown(
          data['from_work_id']!,
          _fromWorkIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromWorkIdMeta);
    }
    if (data.containsKey('to_work_id')) {
      context.handle(
        _toWorkIdMeta,
        toWorkId.isAcceptableOrUnknown(data['to_work_id']!, _toWorkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toWorkIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fromWorkId, toWorkId, type};
  @override
  WorkRelation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkRelation(
      fromWorkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_work_id'],
      )!,
      toWorkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_work_id'],
      )!,
      type: $WorkRelationsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
    );
  }

  @override
  $WorkRelationsTable createAlias(String alias) {
    return $WorkRelationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RelationType, String, String> $convertertype =
      const EnumNameConverter<RelationType>(RelationType.values);
}

class WorkRelation extends DataClass implements Insertable<WorkRelation> {
  final int fromWorkId;
  final int toWorkId;
  final RelationType type;
  const WorkRelation({
    required this.fromWorkId,
    required this.toWorkId,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['from_work_id'] = Variable<int>(fromWorkId);
    map['to_work_id'] = Variable<int>(toWorkId);
    {
      map['type'] = Variable<String>(
        $WorkRelationsTable.$convertertype.toSql(type),
      );
    }
    return map;
  }

  WorkRelationsCompanion toCompanion(bool nullToAbsent) {
    return WorkRelationsCompanion(
      fromWorkId: Value(fromWorkId),
      toWorkId: Value(toWorkId),
      type: Value(type),
    );
  }

  factory WorkRelation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkRelation(
      fromWorkId: serializer.fromJson<int>(json['fromWorkId']),
      toWorkId: serializer.fromJson<int>(json['toWorkId']),
      type: $WorkRelationsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fromWorkId': serializer.toJson<int>(fromWorkId),
      'toWorkId': serializer.toJson<int>(toWorkId),
      'type': serializer.toJson<String>(
        $WorkRelationsTable.$convertertype.toJson(type),
      ),
    };
  }

  WorkRelation copyWith({int? fromWorkId, int? toWorkId, RelationType? type}) =>
      WorkRelation(
        fromWorkId: fromWorkId ?? this.fromWorkId,
        toWorkId: toWorkId ?? this.toWorkId,
        type: type ?? this.type,
      );
  WorkRelation copyWithCompanion(WorkRelationsCompanion data) {
    return WorkRelation(
      fromWorkId: data.fromWorkId.present
          ? data.fromWorkId.value
          : this.fromWorkId,
      toWorkId: data.toWorkId.present ? data.toWorkId.value : this.toWorkId,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkRelation(')
          ..write('fromWorkId: $fromWorkId, ')
          ..write('toWorkId: $toWorkId, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fromWorkId, toWorkId, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkRelation &&
          other.fromWorkId == this.fromWorkId &&
          other.toWorkId == this.toWorkId &&
          other.type == this.type);
}

class WorkRelationsCompanion extends UpdateCompanion<WorkRelation> {
  final Value<int> fromWorkId;
  final Value<int> toWorkId;
  final Value<RelationType> type;
  final Value<int> rowid;
  const WorkRelationsCompanion({
    this.fromWorkId = const Value.absent(),
    this.toWorkId = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkRelationsCompanion.insert({
    required int fromWorkId,
    required int toWorkId,
    required RelationType type,
    this.rowid = const Value.absent(),
  }) : fromWorkId = Value(fromWorkId),
       toWorkId = Value(toWorkId),
       type = Value(type);
  static Insertable<WorkRelation> custom({
    Expression<int>? fromWorkId,
    Expression<int>? toWorkId,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fromWorkId != null) 'from_work_id': fromWorkId,
      if (toWorkId != null) 'to_work_id': toWorkId,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkRelationsCompanion copyWith({
    Value<int>? fromWorkId,
    Value<int>? toWorkId,
    Value<RelationType>? type,
    Value<int>? rowid,
  }) {
    return WorkRelationsCompanion(
      fromWorkId: fromWorkId ?? this.fromWorkId,
      toWorkId: toWorkId ?? this.toWorkId,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fromWorkId.present) {
      map['from_work_id'] = Variable<int>(fromWorkId.value);
    }
    if (toWorkId.present) {
      map['to_work_id'] = Variable<int>(toWorkId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $WorkRelationsTable.$convertertype.toSql(type.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkRelationsCompanion(')
          ..write('fromWorkId: $fromWorkId, ')
          ..write('toWorkId: $toWorkId, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingDaysTable extends ReadingDays
    with TableInfo<$ReadingDaysTable, ReadingDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wordsMeta = const VerificationMeta('words');
  @override
  late final GeneratedColumn<int> words = GeneratedColumn<int>(
    'words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chaptersMeta = const VerificationMeta(
    'chapters',
  );
  @override
  late final GeneratedColumn<int> chapters = GeneratedColumn<int>(
    'chapters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [workId, day, seconds, words, chapters];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    }
    if (data.containsKey('words')) {
      context.handle(
        _wordsMeta,
        words.isAcceptableOrUnknown(data['words']!, _wordsMeta),
      );
    }
    if (data.containsKey('chapters')) {
      context.handle(
        _chaptersMeta,
        chapters.isAcceptableOrUnknown(data['chapters']!, _chaptersMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, day};
  @override
  ReadingDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingDay(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
      words: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words'],
      )!,
      chapters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapters'],
      )!,
    );
  }

  @override
  $ReadingDaysTable createAlias(String alias) {
    return $ReadingDaysTable(attachedDatabase, alias);
  }
}

class ReadingDay extends DataClass implements Insertable<ReadingDay> {
  final int workId;

  /// Local date as "YYYY-MM-DD".
  final String day;
  final int seconds;
  final int words;
  final int chapters;
  const ReadingDay({
    required this.workId,
    required this.day,
    required this.seconds,
    required this.words,
    required this.chapters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<int>(workId);
    map['day'] = Variable<String>(day);
    map['seconds'] = Variable<int>(seconds);
    map['words'] = Variable<int>(words);
    map['chapters'] = Variable<int>(chapters);
    return map;
  }

  ReadingDaysCompanion toCompanion(bool nullToAbsent) {
    return ReadingDaysCompanion(
      workId: Value(workId),
      day: Value(day),
      seconds: Value(seconds),
      words: Value(words),
      chapters: Value(chapters),
    );
  }

  factory ReadingDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingDay(
      workId: serializer.fromJson<int>(json['workId']),
      day: serializer.fromJson<String>(json['day']),
      seconds: serializer.fromJson<int>(json['seconds']),
      words: serializer.fromJson<int>(json['words']),
      chapters: serializer.fromJson<int>(json['chapters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<int>(workId),
      'day': serializer.toJson<String>(day),
      'seconds': serializer.toJson<int>(seconds),
      'words': serializer.toJson<int>(words),
      'chapters': serializer.toJson<int>(chapters),
    };
  }

  ReadingDay copyWith({
    int? workId,
    String? day,
    int? seconds,
    int? words,
    int? chapters,
  }) => ReadingDay(
    workId: workId ?? this.workId,
    day: day ?? this.day,
    seconds: seconds ?? this.seconds,
    words: words ?? this.words,
    chapters: chapters ?? this.chapters,
  );
  ReadingDay copyWithCompanion(ReadingDaysCompanion data) {
    return ReadingDay(
      workId: data.workId.present ? data.workId.value : this.workId,
      day: data.day.present ? data.day.value : this.day,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      words: data.words.present ? data.words.value : this.words,
      chapters: data.chapters.present ? data.chapters.value : this.chapters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingDay(')
          ..write('workId: $workId, ')
          ..write('day: $day, ')
          ..write('seconds: $seconds, ')
          ..write('words: $words, ')
          ..write('chapters: $chapters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, day, seconds, words, chapters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingDay &&
          other.workId == this.workId &&
          other.day == this.day &&
          other.seconds == this.seconds &&
          other.words == this.words &&
          other.chapters == this.chapters);
}

class ReadingDaysCompanion extends UpdateCompanion<ReadingDay> {
  final Value<int> workId;
  final Value<String> day;
  final Value<int> seconds;
  final Value<int> words;
  final Value<int> chapters;
  final Value<int> rowid;
  const ReadingDaysCompanion({
    this.workId = const Value.absent(),
    this.day = const Value.absent(),
    this.seconds = const Value.absent(),
    this.words = const Value.absent(),
    this.chapters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingDaysCompanion.insert({
    required int workId,
    required String day,
    this.seconds = const Value.absent(),
    this.words = const Value.absent(),
    this.chapters = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       day = Value(day);
  static Insertable<ReadingDay> custom({
    Expression<int>? workId,
    Expression<String>? day,
    Expression<int>? seconds,
    Expression<int>? words,
    Expression<int>? chapters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (day != null) 'day': day,
      if (seconds != null) 'seconds': seconds,
      if (words != null) 'words': words,
      if (chapters != null) 'chapters': chapters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingDaysCompanion copyWith({
    Value<int>? workId,
    Value<String>? day,
    Value<int>? seconds,
    Value<int>? words,
    Value<int>? chapters,
    Value<int>? rowid,
  }) {
    return ReadingDaysCompanion(
      workId: workId ?? this.workId,
      day: day ?? this.day,
      seconds: seconds ?? this.seconds,
      words: words ?? this.words,
      chapters: chapters ?? this.chapters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (words.present) {
      map['words'] = Variable<int>(words.value);
    }
    if (chapters.present) {
      map['chapters'] = Variable<int>(chapters.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingDaysCompanion(')
          ..write('workId: $workId, ')
          ..write('day: $day, ')
          ..write('seconds: $seconds, ')
          ..write('words: $words, ')
          ..write('chapters: $chapters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isAdultMeta = const VerificationMeta(
    'isAdult',
  );
  @override
  late final GeneratedColumn<bool> isAdult = GeneratedColumn<bool>(
    'is_adult',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_adult" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isAdult];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_adult')) {
      context.handle(
        _isAdultMeta,
        isAdult.isAcceptableOrUnknown(data['is_adult']!, _isAdultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isAdult: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_adult'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;

  /// Adult content; hidden when the "hide 18+ tags" setting is on.
  final bool isAdult;
  const Tag({required this.id, required this.name, required this.isAdult});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_adult'] = Variable<bool>(isAdult);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      isAdult: Value(isAdult),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isAdult: serializer.fromJson<bool>(json['isAdult']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isAdult': serializer.toJson<bool>(isAdult),
    };
  }

  Tag copyWith({int? id, String? name, bool? isAdult}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    isAdult: isAdult ?? this.isAdult,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isAdult: data.isAdult.present ? data.isAdult.value : this.isAdult,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isAdult: $isAdult')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isAdult);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.isAdult == this.isAdult);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isAdult;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isAdult = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isAdult = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isAdult,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isAdult != null) 'is_adult': isAdult,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isAdult,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isAdult: isAdult ?? this.isAdult,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isAdult.present) {
      map['is_adult'] = Variable<bool>(isAdult.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isAdult: $isAdult')
          ..write(')'))
        .toString();
  }
}

class $WorkTagsTable extends WorkTags with TableInfo<$WorkTagsTable, WorkTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [workId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, tagId};
  @override
  WorkTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkTag(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $WorkTagsTable createAlias(String alias) {
    return $WorkTagsTable(attachedDatabase, alias);
  }
}

class WorkTag extends DataClass implements Insertable<WorkTag> {
  final int workId;
  final int tagId;
  const WorkTag({required this.workId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<int>(workId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  WorkTagsCompanion toCompanion(bool nullToAbsent) {
    return WorkTagsCompanion(workId: Value(workId), tagId: Value(tagId));
  }

  factory WorkTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkTag(
      workId: serializer.fromJson<int>(json['workId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<int>(workId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  WorkTag copyWith({int? workId, int? tagId}) =>
      WorkTag(workId: workId ?? this.workId, tagId: tagId ?? this.tagId);
  WorkTag copyWithCompanion(WorkTagsCompanion data) {
    return WorkTag(
      workId: data.workId.present ? data.workId.value : this.workId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkTag(')
          ..write('workId: $workId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkTag &&
          other.workId == this.workId &&
          other.tagId == this.tagId);
}

class WorkTagsCompanion extends UpdateCompanion<WorkTag> {
  final Value<int> workId;
  final Value<int> tagId;
  final Value<int> rowid;
  const WorkTagsCompanion({
    this.workId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkTagsCompanion.insert({
    required int workId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       tagId = Value(tagId);
  static Insertable<WorkTag> custom({
    Expression<int>? workId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkTagsCompanion copyWith({
    Value<int>? workId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return WorkTagsCompanion(
      workId: workId ?? this.workId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkTagsCompanion(')
          ..write('workId: $workId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workId,
    number,
    title,
    url,
    content,
    wordCount,
    downloadedAt,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workId, number},
  ];
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
  final int workId;
  final int number;
  final String? title;
  final String? url;
  final String? content;
  final int? wordCount;
  final DateTime? downloadedAt;

  /// Paid or otherwise unavailable on the site.
  final bool isLocked;
  const Chapter({
    required this.id,
    required this.workId,
    required this.number,
    this.title,
    this.url,
    this.content,
    this.wordCount,
    this.downloadedAt,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_id'] = Variable<int>(workId);
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<int>(wordCount);
    }
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      workId: Value(workId),
      number: Value(number),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
      isLocked: Value(isLocked),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      workId: serializer.fromJson<int>(json['workId']),
      number: serializer.fromJson<int>(json['number']),
      title: serializer.fromJson<String?>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
      content: serializer.fromJson<String?>(json['content']),
      wordCount: serializer.fromJson<int?>(json['wordCount']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workId': serializer.toJson<int>(workId),
      'number': serializer.toJson<int>(number),
      'title': serializer.toJson<String?>(title),
      'url': serializer.toJson<String?>(url),
      'content': serializer.toJson<String?>(content),
      'wordCount': serializer.toJson<int?>(wordCount),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  Chapter copyWith({
    int? id,
    int? workId,
    int? number,
    Value<String?> title = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> content = const Value.absent(),
    Value<int?> wordCount = const Value.absent(),
    Value<DateTime?> downloadedAt = const Value.absent(),
    bool? isLocked,
  }) => Chapter(
    id: id ?? this.id,
    workId: workId ?? this.workId,
    number: number ?? this.number,
    title: title.present ? title.value : this.title,
    url: url.present ? url.value : this.url,
    content: content.present ? content.value : this.content,
    wordCount: wordCount.present ? wordCount.value : this.wordCount,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
    isLocked: isLocked ?? this.isLocked,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      workId: data.workId.present ? data.workId.value : this.workId,
      number: data.number.present ? data.number.value : this.number,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      content: data.content.present ? data.content.value : this.content,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('content: $content, ')
          ..write('wordCount: $wordCount, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workId,
    number,
    title,
    url,
    content,
    wordCount,
    downloadedAt,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.workId == this.workId &&
          other.number == this.number &&
          other.title == this.title &&
          other.url == this.url &&
          other.content == this.content &&
          other.wordCount == this.wordCount &&
          other.downloadedAt == this.downloadedAt &&
          other.isLocked == this.isLocked);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> workId;
  final Value<int> number;
  final Value<String?> title;
  final Value<String?> url;
  final Value<String?> content;
  final Value<int?> wordCount;
  final Value<DateTime?> downloadedAt;
  final Value<bool> isLocked;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.workId = const Value.absent(),
    this.number = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.content = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int workId,
    required int number,
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.content = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
  }) : workId = Value(workId),
       number = Value(number);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? workId,
    Expression<int>? number,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? content,
    Expression<int>? wordCount,
    Expression<DateTime>? downloadedAt,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workId != null) 'work_id': workId,
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (content != null) 'content': content,
      if (wordCount != null) 'word_count': wordCount,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? workId,
    Value<int>? number,
    Value<String?>? title,
    Value<String?>? url,
    Value<String?>? content,
    Value<int?>? wordCount,
    Value<DateTime?>? downloadedAt,
    Value<bool>? isLocked,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      number: number ?? this.number,
      title: title ?? this.title,
      url: url ?? this.url,
      content: content ?? this.content,
      wordCount: wordCount ?? this.wordCount,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('content: $content, ')
          ..write('wordCount: $wordCount, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fromChapterMeta = const VerificationMeta(
    'fromChapter',
  );
  @override
  late final GeneratedColumn<int> fromChapter = GeneratedColumn<int>(
    'from_chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toChapterMeta = const VerificationMeta(
    'toChapter',
  );
  @override
  late final GeneratedColumn<int> toChapter = GeneratedColumn<int>(
    'to_chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('txt'),
  );
  static const VerificationMeta _withImagesMeta = const VerificationMeta(
    'withImages',
  );
  @override
  late final GeneratedColumn<bool> withImages = GeneratedColumn<bool>(
    'with_images',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("with_images" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workId,
    fromChapter,
    toChapter,
    format,
    withImages,
    filePath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('from_chapter')) {
      context.handle(
        _fromChapterMeta,
        fromChapter.isAcceptableOrUnknown(
          data['from_chapter']!,
          _fromChapterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromChapterMeta);
    }
    if (data.containsKey('to_chapter')) {
      context.handle(
        _toChapterMeta,
        toChapter.isAcceptableOrUnknown(data['to_chapter']!, _toChapterMeta),
      );
    } else if (isInserting) {
      context.missing(_toChapterMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('with_images')) {
      context.handle(
        _withImagesMeta,
        withImages.isAcceptableOrUnknown(data['with_images']!, _withImagesMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      fromChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_chapter'],
      )!,
      toChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_chapter'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      withImages: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}with_images'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class Download extends DataClass implements Insertable<Download> {
  final int id;
  final int workId;
  final int fromChapter;
  final int toChapter;
  final String format;

  /// False when chapter images were left out to save space.
  final bool withImages;
  final String? filePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Download({
    required this.id,
    required this.workId,
    required this.fromChapter,
    required this.toChapter,
    required this.format,
    required this.withImages,
    this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_id'] = Variable<int>(workId);
    map['from_chapter'] = Variable<int>(fromChapter);
    map['to_chapter'] = Variable<int>(toChapter);
    map['format'] = Variable<String>(format);
    map['with_images'] = Variable<bool>(withImages);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      workId: Value(workId),
      fromChapter: Value(fromChapter),
      toChapter: Value(toChapter),
      format: Value(format),
      withImages: Value(withImages),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<int>(json['id']),
      workId: serializer.fromJson<int>(json['workId']),
      fromChapter: serializer.fromJson<int>(json['fromChapter']),
      toChapter: serializer.fromJson<int>(json['toChapter']),
      format: serializer.fromJson<String>(json['format']),
      withImages: serializer.fromJson<bool>(json['withImages']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workId': serializer.toJson<int>(workId),
      'fromChapter': serializer.toJson<int>(fromChapter),
      'toChapter': serializer.toJson<int>(toChapter),
      'format': serializer.toJson<String>(format),
      'withImages': serializer.toJson<bool>(withImages),
      'filePath': serializer.toJson<String?>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Download copyWith({
    int? id,
    int? workId,
    int? fromChapter,
    int? toChapter,
    String? format,
    bool? withImages,
    Value<String?> filePath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Download(
    id: id ?? this.id,
    workId: workId ?? this.workId,
    fromChapter: fromChapter ?? this.fromChapter,
    toChapter: toChapter ?? this.toChapter,
    format: format ?? this.format,
    withImages: withImages ?? this.withImages,
    filePath: filePath.present ? filePath.value : this.filePath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      id: data.id.present ? data.id.value : this.id,
      workId: data.workId.present ? data.workId.value : this.workId,
      fromChapter: data.fromChapter.present
          ? data.fromChapter.value
          : this.fromChapter,
      toChapter: data.toChapter.present ? data.toChapter.value : this.toChapter,
      format: data.format.present ? data.format.value : this.format,
      withImages: data.withImages.present
          ? data.withImages.value
          : this.withImages,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('fromChapter: $fromChapter, ')
          ..write('toChapter: $toChapter, ')
          ..write('format: $format, ')
          ..write('withImages: $withImages, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workId,
    fromChapter,
    toChapter,
    format,
    withImages,
    filePath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.workId == this.workId &&
          other.fromChapter == this.fromChapter &&
          other.toChapter == this.toChapter &&
          other.format == this.format &&
          other.withImages == this.withImages &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<int> id;
  final Value<int> workId;
  final Value<int> fromChapter;
  final Value<int> toChapter;
  final Value<String> format;
  final Value<bool> withImages;
  final Value<String?> filePath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.workId = const Value.absent(),
    this.fromChapter = const Value.absent(),
    this.toChapter = const Value.absent(),
    this.format = const Value.absent(),
    this.withImages = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.id = const Value.absent(),
    required int workId,
    required int fromChapter,
    required int toChapter,
    this.format = const Value.absent(),
    this.withImages = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : workId = Value(workId),
       fromChapter = Value(fromChapter),
       toChapter = Value(toChapter);
  static Insertable<Download> custom({
    Expression<int>? id,
    Expression<int>? workId,
    Expression<int>? fromChapter,
    Expression<int>? toChapter,
    Expression<String>? format,
    Expression<bool>? withImages,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workId != null) 'work_id': workId,
      if (fromChapter != null) 'from_chapter': fromChapter,
      if (toChapter != null) 'to_chapter': toChapter,
      if (format != null) 'format': format,
      if (withImages != null) 'with_images': withImages,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadsCompanion copyWith({
    Value<int>? id,
    Value<int>? workId,
    Value<int>? fromChapter,
    Value<int>? toChapter,
    Value<String>? format,
    Value<bool>? withImages,
    Value<String?>? filePath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DownloadsCompanion(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      fromChapter: fromChapter ?? this.fromChapter,
      toChapter: toChapter ?? this.toChapter,
      format: format ?? this.format,
      withImages: withImages ?? this.withImages,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (fromChapter.present) {
      map['from_chapter'] = Variable<int>(fromChapter.value);
    }
    if (toChapter.present) {
      map['to_chapter'] = Variable<int>(toChapter.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (withImages.present) {
      map['with_images'] = Variable<bool>(withImages.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('fromChapter: $fromChapter, ')
          ..write('toChapter: $toChapter, ')
          ..write('format: $format, ')
          ..write('withImages: $withImages, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PairingsTable extends Pairings with TableInfo<$PairingsTable, Pairing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pairings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pairing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pairing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pairing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PairingsTable createAlias(String alias) {
    return $PairingsTable(attachedDatabase, alias);
  }
}

class Pairing extends DataClass implements Insertable<Pairing> {
  final int id;
  final String name;
  const Pairing({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PairingsCompanion toCompanion(bool nullToAbsent) {
    return PairingsCompanion(id: Value(id), name: Value(name));
  }

  factory Pairing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pairing(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Pairing copyWith({int? id, String? name}) =>
      Pairing(id: id ?? this.id, name: name ?? this.name);
  Pairing copyWithCompanion(PairingsCompanion data) {
    return Pairing(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pairing(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pairing && other.id == this.id && other.name == this.name);
}

class PairingsCompanion extends UpdateCompanion<Pairing> {
  final Value<int> id;
  final Value<String> name;
  const PairingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  PairingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Pairing> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  PairingsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return PairingsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WorkPairingsTable extends WorkPairings
    with TableInfo<$WorkPairingsTable, WorkPairing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkPairingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pairingIdMeta = const VerificationMeta(
    'pairingId',
  );
  @override
  late final GeneratedColumn<int> pairingId = GeneratedColumn<int>(
    'pairing_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pairings (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [workId, pairingId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_pairings';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkPairing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('pairing_id')) {
      context.handle(
        _pairingIdMeta,
        pairingId.isAcceptableOrUnknown(data['pairing_id']!, _pairingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pairingIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workId, pairingId};
  @override
  WorkPairing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkPairing(
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      pairingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pairing_id'],
      )!,
    );
  }

  @override
  $WorkPairingsTable createAlias(String alias) {
    return $WorkPairingsTable(attachedDatabase, alias);
  }
}

class WorkPairing extends DataClass implements Insertable<WorkPairing> {
  final int workId;
  final int pairingId;
  const WorkPairing({required this.workId, required this.pairingId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['work_id'] = Variable<int>(workId);
    map['pairing_id'] = Variable<int>(pairingId);
    return map;
  }

  WorkPairingsCompanion toCompanion(bool nullToAbsent) {
    return WorkPairingsCompanion(
      workId: Value(workId),
      pairingId: Value(pairingId),
    );
  }

  factory WorkPairing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkPairing(
      workId: serializer.fromJson<int>(json['workId']),
      pairingId: serializer.fromJson<int>(json['pairingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workId': serializer.toJson<int>(workId),
      'pairingId': serializer.toJson<int>(pairingId),
    };
  }

  WorkPairing copyWith({int? workId, int? pairingId}) => WorkPairing(
    workId: workId ?? this.workId,
    pairingId: pairingId ?? this.pairingId,
  );
  WorkPairing copyWithCompanion(WorkPairingsCompanion data) {
    return WorkPairing(
      workId: data.workId.present ? data.workId.value : this.workId,
      pairingId: data.pairingId.present ? data.pairingId.value : this.pairingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkPairing(')
          ..write('workId: $workId, ')
          ..write('pairingId: $pairingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workId, pairingId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkPairing &&
          other.workId == this.workId &&
          other.pairingId == this.pairingId);
}

class WorkPairingsCompanion extends UpdateCompanion<WorkPairing> {
  final Value<int> workId;
  final Value<int> pairingId;
  final Value<int> rowid;
  const WorkPairingsCompanion({
    this.workId = const Value.absent(),
    this.pairingId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkPairingsCompanion.insert({
    required int workId,
    required int pairingId,
    this.rowid = const Value.absent(),
  }) : workId = Value(workId),
       pairingId = Value(pairingId);
  static Insertable<WorkPairing> custom({
    Expression<int>? workId,
    Expression<int>? pairingId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workId != null) 'work_id': workId,
      if (pairingId != null) 'pairing_id': pairingId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkPairingsCompanion copyWith({
    Value<int>? workId,
    Value<int>? pairingId,
    Value<int>? rowid,
  }) {
    return WorkPairingsCompanion(
      workId: workId ?? this.workId,
      pairingId: pairingId ?? this.pairingId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (pairingId.present) {
      map['pairing_id'] = Variable<int>(pairingId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkPairingsCompanion(')
          ..write('workId: $workId, ')
          ..write('pairingId: $pairingId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnotationsTable extends Annotations
    with TableInfo<$AnnotationsTable, Annotation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workIdMeta = const VerificationMeta('workId');
  @override
  late final GeneratedColumn<int> workId = GeneratedColumn<int>(
    'work_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES works (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AnnotationKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AnnotationKind>($AnnotationsTable.$converterkind);
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
    'quote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offsetMeta = const VerificationMeta('offset');
  @override
  late final GeneratedColumn<double> offset = GeneratedColumn<double>(
    'offset',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workId,
    chapterNumber,
    kind,
    quote,
    note,
    offset,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Annotation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_id')) {
      context.handle(
        _workIdMeta,
        workId.isAcceptableOrUnknown(data['work_id']!, _workIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
        _quoteMeta,
        quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('offset')) {
      context.handle(
        _offsetMeta,
        offset.isAcceptableOrUnknown(data['offset']!, _offsetMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Annotation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Annotation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      kind: $AnnotationsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      quote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      offset: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offset'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AnnotationsTable createAlias(String alias) {
    return $AnnotationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AnnotationKind, String, String> $converterkind =
      const EnumNameConverter<AnnotationKind>(AnnotationKind.values);
}

class Annotation extends DataClass implements Insertable<Annotation> {
  final int id;
  final int workId;
  final int chapterNumber;
  final AnnotationKind kind;

  /// The quoted text (quotes, and notes made on a selection).
  final String? quote;

  /// The user's own words (notes).
  final String? note;

  /// Scroll position in the chapter, from 0 to 1.
  final double offset;
  final DateTime createdAt;
  const Annotation({
    required this.id,
    required this.workId,
    required this.chapterNumber,
    required this.kind,
    this.quote,
    this.note,
    required this.offset,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_id'] = Variable<int>(workId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    {
      map['kind'] = Variable<String>(
        $AnnotationsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || quote != null) {
      map['quote'] = Variable<String>(quote);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['offset'] = Variable<double>(offset);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AnnotationsCompanion toCompanion(bool nullToAbsent) {
    return AnnotationsCompanion(
      id: Value(id),
      workId: Value(workId),
      chapterNumber: Value(chapterNumber),
      kind: Value(kind),
      quote: quote == null && nullToAbsent
          ? const Value.absent()
          : Value(quote),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      offset: Value(offset),
      createdAt: Value(createdAt),
    );
  }

  factory Annotation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Annotation(
      id: serializer.fromJson<int>(json['id']),
      workId: serializer.fromJson<int>(json['workId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      kind: $AnnotationsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      quote: serializer.fromJson<String?>(json['quote']),
      note: serializer.fromJson<String?>(json['note']),
      offset: serializer.fromJson<double>(json['offset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workId': serializer.toJson<int>(workId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'kind': serializer.toJson<String>(
        $AnnotationsTable.$converterkind.toJson(kind),
      ),
      'quote': serializer.toJson<String?>(quote),
      'note': serializer.toJson<String?>(note),
      'offset': serializer.toJson<double>(offset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Annotation copyWith({
    int? id,
    int? workId,
    int? chapterNumber,
    AnnotationKind? kind,
    Value<String?> quote = const Value.absent(),
    Value<String?> note = const Value.absent(),
    double? offset,
    DateTime? createdAt,
  }) => Annotation(
    id: id ?? this.id,
    workId: workId ?? this.workId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    kind: kind ?? this.kind,
    quote: quote.present ? quote.value : this.quote,
    note: note.present ? note.value : this.note,
    offset: offset ?? this.offset,
    createdAt: createdAt ?? this.createdAt,
  );
  Annotation copyWithCompanion(AnnotationsCompanion data) {
    return Annotation(
      id: data.id.present ? data.id.value : this.id,
      workId: data.workId.present ? data.workId.value : this.workId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      kind: data.kind.present ? data.kind.value : this.kind,
      quote: data.quote.present ? data.quote.value : this.quote,
      note: data.note.present ? data.note.value : this.note,
      offset: data.offset.present ? data.offset.value : this.offset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Annotation(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('kind: $kind, ')
          ..write('quote: $quote, ')
          ..write('note: $note, ')
          ..write('offset: $offset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workId,
    chapterNumber,
    kind,
    quote,
    note,
    offset,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Annotation &&
          other.id == this.id &&
          other.workId == this.workId &&
          other.chapterNumber == this.chapterNumber &&
          other.kind == this.kind &&
          other.quote == this.quote &&
          other.note == this.note &&
          other.offset == this.offset &&
          other.createdAt == this.createdAt);
}

class AnnotationsCompanion extends UpdateCompanion<Annotation> {
  final Value<int> id;
  final Value<int> workId;
  final Value<int> chapterNumber;
  final Value<AnnotationKind> kind;
  final Value<String?> quote;
  final Value<String?> note;
  final Value<double> offset;
  final Value<DateTime> createdAt;
  const AnnotationsCompanion({
    this.id = const Value.absent(),
    this.workId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.kind = const Value.absent(),
    this.quote = const Value.absent(),
    this.note = const Value.absent(),
    this.offset = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AnnotationsCompanion.insert({
    this.id = const Value.absent(),
    required int workId,
    required int chapterNumber,
    required AnnotationKind kind,
    this.quote = const Value.absent(),
    this.note = const Value.absent(),
    this.offset = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : workId = Value(workId),
       chapterNumber = Value(chapterNumber),
       kind = Value(kind);
  static Insertable<Annotation> custom({
    Expression<int>? id,
    Expression<int>? workId,
    Expression<int>? chapterNumber,
    Expression<String>? kind,
    Expression<String>? quote,
    Expression<String>? note,
    Expression<double>? offset,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workId != null) 'work_id': workId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (kind != null) 'kind': kind,
      if (quote != null) 'quote': quote,
      if (note != null) 'note': note,
      if (offset != null) 'offset': offset,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AnnotationsCompanion copyWith({
    Value<int>? id,
    Value<int>? workId,
    Value<int>? chapterNumber,
    Value<AnnotationKind>? kind,
    Value<String?>? quote,
    Value<String?>? note,
    Value<double>? offset,
    Value<DateTime>? createdAt,
  }) {
    return AnnotationsCompanion(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      kind: kind ?? this.kind,
      quote: quote ?? this.quote,
      note: note ?? this.note,
      offset: offset ?? this.offset,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workId.present) {
      map['work_id'] = Variable<int>(workId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $AnnotationsTable.$converterkind.toSql(kind.value),
      );
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (offset.present) {
      map['offset'] = Variable<double>(offset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('workId: $workId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('kind: $kind, ')
          ..write('quote: $quote, ')
          ..write('note: $note, ')
          ..write('offset: $offset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FandomsTable fandoms = $FandomsTable(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $CharacterAliasesTable characterAliases = $CharacterAliasesTable(
    this,
  );
  late final $SeriesTable series = $SeriesTable(this);
  late final $WorksTable works = $WorksTable(this);
  late final $WorkCharactersTable workCharacters = $WorkCharactersTable(this);
  late final $WorkFandomsTable workFandoms = $WorkFandomsTable(this);
  late final $WorkRelationsTable workRelations = $WorkRelationsTable(this);
  late final $ReadingDaysTable readingDays = $ReadingDaysTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $WorkTagsTable workTags = $WorkTagsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $PairingsTable pairings = $PairingsTable(this);
  late final $WorkPairingsTable workPairings = $WorkPairingsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AnnotationsTable annotations = $AnnotationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    fandoms,
    characters,
    characterAliases,
    series,
    works,
    workCharacters,
    workFandoms,
    workRelations,
    readingDays,
    tags,
    workTags,
    chapters,
    downloads,
    pairings,
    workPairings,
    settings,
    annotations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fandoms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('characters', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('character_aliases', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fandoms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('works', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'series',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('works', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_characters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_characters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_fandoms', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fandoms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_fandoms', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_relations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_relations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chapters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('downloads', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_pairings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pairings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_pairings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'works',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('annotations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FandomsTableCreateCompanionBuilder = FandomsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$FandomsTableUpdateCompanionBuilder = FandomsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$FandomsTableReferences
    extends BaseReferences<_$AppDatabase, $FandomsTable, Fandom> {
  $$FandomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CharactersTable, List<Character>>
  _charactersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characters,
    aliasName: 'fandoms__id__characters__fandom_id',
  );

  $$CharactersTableProcessedTableManager get charactersRefs {
    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.fandomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_charactersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorksTable, List<Work>> _worksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.works,
    aliasName: 'fandoms__id__works__fandom_id',
  );

  $$WorksTableProcessedTableManager get worksRefs {
    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.fandomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_worksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkFandomsTable, List<WorkFandom>>
  _workFandomsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workFandoms,
    aliasName: 'fandoms__id__work_fandoms__fandom_id',
  );

  $$WorkFandomsTableProcessedTableManager get workFandomsRefs {
    final manager = $$WorkFandomsTableTableManager(
      $_db,
      $_db.workFandoms,
    ).filter((f) => f.fandomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workFandomsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FandomsTableFilterComposer
    extends Composer<_$AppDatabase, $FandomsTable> {
  $$FandomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> charactersRefs(
    Expression<bool> Function($$CharactersTableFilterComposer f) f,
  ) {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.fandomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> worksRefs(
    Expression<bool> Function($$WorksTableFilterComposer f) f,
  ) {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.fandomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workFandomsRefs(
    Expression<bool> Function($$WorkFandomsTableFilterComposer f) f,
  ) {
    final $$WorkFandomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workFandoms,
      getReferencedColumn: (t) => t.fandomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkFandomsTableFilterComposer(
            $db: $db,
            $table: $db.workFandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FandomsTableOrderingComposer
    extends Composer<_$AppDatabase, $FandomsTable> {
  $$FandomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FandomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FandomsTable> {
  $$FandomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> charactersRefs<T extends Object>(
    Expression<T> Function($$CharactersTableAnnotationComposer a) f,
  ) {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.fandomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> worksRefs<T extends Object>(
    Expression<T> Function($$WorksTableAnnotationComposer a) f,
  ) {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.fandomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workFandomsRefs<T extends Object>(
    Expression<T> Function($$WorkFandomsTableAnnotationComposer a) f,
  ) {
    final $$WorkFandomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workFandoms,
      getReferencedColumn: (t) => t.fandomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkFandomsTableAnnotationComposer(
            $db: $db,
            $table: $db.workFandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FandomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FandomsTable,
          Fandom,
          $$FandomsTableFilterComposer,
          $$FandomsTableOrderingComposer,
          $$FandomsTableAnnotationComposer,
          $$FandomsTableCreateCompanionBuilder,
          $$FandomsTableUpdateCompanionBuilder,
          (Fandom, $$FandomsTableReferences),
          Fandom,
          PrefetchHooks Function({
            bool charactersRefs,
            bool worksRefs,
            bool workFandomsRefs,
          })
        > {
  $$FandomsTableTableManager(_$AppDatabase db, $FandomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FandomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FandomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FandomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => FandomsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => FandomsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FandomsTable, Fandom>(table),
                  $$FandomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                charactersRefs = false,
                worksRefs = false,
                workFandomsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (charactersRefs) db.characters,
                    if (worksRefs) db.works,
                    if (workFandomsRefs) db.workFandoms,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (charactersRefs)
                        await $_getPrefetchedData<
                          Fandom,
                          $FandomsTable,
                          Character
                        >(
                          currentTable: table,
                          referencedTable: $$FandomsTableReferences
                              ._charactersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FandomsTableReferences(
                                db,
                                table,
                                p0,
                              ).charactersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fandomId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (worksRefs)
                        await $_getPrefetchedData<Fandom, $FandomsTable, Work>(
                          currentTable: table,
                          referencedTable: $$FandomsTableReferences
                              ._worksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FandomsTableReferences(db, table, p0).worksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fandomId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workFandomsRefs)
                        await $_getPrefetchedData<
                          Fandom,
                          $FandomsTable,
                          WorkFandom
                        >(
                          currentTable: table,
                          referencedTable: $$FandomsTableReferences
                              ._workFandomsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FandomsTableReferences(
                                db,
                                table,
                                p0,
                              ).workFandomsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fandomId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FandomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FandomsTable,
      Fandom,
      $$FandomsTableFilterComposer,
      $$FandomsTableOrderingComposer,
      $$FandomsTableAnnotationComposer,
      $$FandomsTableCreateCompanionBuilder,
      $$FandomsTableUpdateCompanionBuilder,
      (Fandom, $$FandomsTableReferences),
      Fandom,
      PrefetchHooks Function({
        bool charactersRefs,
        bool worksRefs,
        bool workFandomsRefs,
      })
    >;
typedef $$CharactersTableCreateCompanionBuilder = CharactersCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> fandomId,
  Value<int?> anilistId,
});
typedef $$CharactersTableUpdateCompanionBuilder = CharactersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> fandomId,
  Value<int?> anilistId,
});

final class $$CharactersTableReferences
    extends BaseReferences<_$AppDatabase, $CharactersTable, Character> {
  $$CharactersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FandomsTable _fandomIdTable(_$AppDatabase db) =>
      db.fandoms.createAlias('characters__fandom_id__fandoms__id');

  $$FandomsTableProcessedTableManager? get fandomId {
    final $_column = $_itemColumn<int>('fandom_id');
    if ($_column == null) return null;
    final manager = $$FandomsTableTableManager(
      $_db,
      $_db.fandoms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fandomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CharacterAliasesTable, List<CharacterAliase>>
  _characterAliasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characterAliases,
    aliasName: 'characters__id__character_aliases__character_id',
  );

  $$CharacterAliasesTableProcessedTableManager get characterAliasesRefs {
    final manager = $$CharacterAliasesTableTableManager(
      $_db,
      $_db.characterAliases,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characterAliasesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkCharactersTable, List<WorkCharacter>>
  _workCharactersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workCharacters,
    aliasName: 'characters__id__work_characters__character_id',
  );

  $$WorkCharactersTableProcessedTableManager get workCharactersRefs {
    final manager = $$WorkCharactersTableTableManager(
      $_db,
      $_db.workCharacters,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workCharactersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anilistId => $composableBuilder(
    column: $table.anilistId,
    builder: (column) => ColumnFilters(column),
  );

  $$FandomsTableFilterComposer get fandomId {
    final $$FandomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableFilterComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> characterAliasesRefs(
    Expression<bool> Function($$CharacterAliasesTableFilterComposer f) f,
  ) {
    final $$CharacterAliasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterAliases,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterAliasesTableFilterComposer(
            $db: $db,
            $table: $db.characterAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workCharactersRefs(
    Expression<bool> Function($$WorkCharactersTableFilterComposer f) f,
  ) {
    final $$WorkCharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workCharacters,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkCharactersTableFilterComposer(
            $db: $db,
            $table: $db.workCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anilistId => $composableBuilder(
    column: $table.anilistId,
    builder: (column) => ColumnOrderings(column),
  );

  $$FandomsTableOrderingComposer get fandomId {
    final $$FandomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableOrderingComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get anilistId =>
      $composableBuilder(column: $table.anilistId, builder: (column) => column);

  $$FandomsTableAnnotationComposer get fandomId {
    final $$FandomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableAnnotationComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> characterAliasesRefs<T extends Object>(
    Expression<T> Function($$CharacterAliasesTableAnnotationComposer a) f,
  ) {
    final $$CharacterAliasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characterAliases,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacterAliasesTableAnnotationComposer(
            $db: $db,
            $table: $db.characterAliases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workCharactersRefs<T extends Object>(
    Expression<T> Function($$WorkCharactersTableAnnotationComposer a) f,
  ) {
    final $$WorkCharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workCharacters,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkCharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.workCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          Character,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (Character, $$CharactersTableReferences),
          Character,
          PrefetchHooks Function({
            bool fandomId,
            bool characterAliasesRefs,
            bool workCharactersRefs,
          })
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> fandomId = const Value.absent(),
                Value<int?> anilistId = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                name: name,
                fandomId: fandomId,
                anilistId: anilistId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> fandomId = const Value.absent(),
                Value<int?> anilistId = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                name: name,
                fandomId: fandomId,
                anilistId: anilistId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CharactersTable, Character>(table),
                  $$CharactersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fandomId = false,
                characterAliasesRefs = false,
                workCharactersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (characterAliasesRefs) db.characterAliases,
                    if (workCharactersRefs) db.workCharacters,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fandomId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fandomId,
                            referencedTable: $$CharactersTableReferences
                                ._fandomIdTable(db),
                            referencedColumn: $$CharactersTableReferences
                                ._fandomIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (characterAliasesRefs)
                        await $_getPrefetchedData<
                          Character,
                          $CharactersTable,
                          CharacterAliase
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._characterAliasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).characterAliasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workCharactersRefs)
                        await $_getPrefetchedData<
                          Character,
                          $CharactersTable,
                          WorkCharacter
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._workCharactersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).workCharactersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      Character,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (Character, $$CharactersTableReferences),
      Character,
      PrefetchHooks Function({
        bool fandomId,
        bool characterAliasesRefs,
        bool workCharactersRefs,
      })
    >;
typedef $$CharacterAliasesTableCreateCompanionBuilder =
    CharacterAliasesCompanion Function({
      required int characterId,
      required String alias,
      Value<int> rowid,
    });
typedef $$CharacterAliasesTableUpdateCompanionBuilder =
    CharacterAliasesCompanion Function({
      Value<int> characterId,
      Value<String> alias,
      Value<int> rowid,
    });

final class $$CharacterAliasesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CharacterAliasesTable, CharacterAliase> {
  $$CharacterAliasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharactersTable _characterIdTable(_$AppDatabase db) => db.characters
      .createAlias('character_aliases__character_id__characters__id');

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<int>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CharacterAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterAliasesTable> {
  $$CharacterAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterAliasesTable> {
  $$CharacterAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterAliasesTable> {
  $$CharacterAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacterAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterAliasesTable,
          CharacterAliase,
          $$CharacterAliasesTableFilterComposer,
          $$CharacterAliasesTableOrderingComposer,
          $$CharacterAliasesTableAnnotationComposer,
          $$CharacterAliasesTableCreateCompanionBuilder,
          $$CharacterAliasesTableUpdateCompanionBuilder,
          (CharacterAliase, $$CharacterAliasesTableReferences),
          CharacterAliase,
          PrefetchHooks Function({bool characterId})
        > {
  $$CharacterAliasesTableTableManager(
    _$AppDatabase db,
    $CharacterAliasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> characterId = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterAliasesCompanion(
                characterId: characterId,
                alias: alias,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int characterId,
                required String alias,
                Value<int> rowid = const Value.absent(),
              }) => CharacterAliasesCompanion.insert(
                characterId: characterId,
                alias: alias,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CharacterAliasesTable, CharacterAliase>(table),
                  $$CharacterAliasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (characterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.characterId,
                        referencedTable: $$CharacterAliasesTableReferences
                            ._characterIdTable(db),
                        referencedColumn: $$CharacterAliasesTableReferences
                            ._characterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CharacterAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterAliasesTable,
      CharacterAliase,
      $$CharacterAliasesTableFilterComposer,
      $$CharacterAliasesTableOrderingComposer,
      $$CharacterAliasesTableAnnotationComposer,
      $$CharacterAliasesTableCreateCompanionBuilder,
      $$CharacterAliasesTableUpdateCompanionBuilder,
      (CharacterAliase, $$CharacterAliasesTableReferences),
      CharacterAliase,
      PrefetchHooks Function({bool characterId})
    >;
typedef $$SeriesTableCreateCompanionBuilder = SeriesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$SeriesTableUpdateCompanionBuilder = SeriesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$SeriesTableReferences
    extends BaseReferences<_$AppDatabase, $SeriesTable, SeriesItem> {
  $$SeriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorksTable, List<Work>> _worksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.works,
    aliasName: 'series__id__works__series_id',
  );

  $$WorksTableProcessedTableManager get worksRefs {
    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_worksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeriesTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTable> {
  $$SeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> worksRefs(
    Expression<bool> Function($$WorksTableFilterComposer f) f,
  ) {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTable> {
  $$SeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTable> {
  $$SeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> worksRefs<T extends Object>(
    Expression<T> Function($$WorksTableAnnotationComposer a) f,
  ) {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesTable,
          SeriesItem,
          $$SeriesTableFilterComposer,
          $$SeriesTableOrderingComposer,
          $$SeriesTableAnnotationComposer,
          $$SeriesTableCreateCompanionBuilder,
          $$SeriesTableUpdateCompanionBuilder,
          (SeriesItem, $$SeriesTableReferences),
          SeriesItem,
          PrefetchHooks Function({bool worksRefs})
        > {
  $$SeriesTableTableManager(_$AppDatabase db, $SeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => SeriesCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => SeriesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesTable, SeriesItem>(table),
                  $$SeriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({worksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (worksRefs) db.works],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (worksRefs)
                    await $_getPrefetchedData<SeriesItem, $SeriesTable, Work>(
                      currentTable: table,
                      referencedTable: $$SeriesTableReferences._worksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SeriesTableReferences(db, table, p0).worksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.seriesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesTable,
      SeriesItem,
      $$SeriesTableFilterComposer,
      $$SeriesTableOrderingComposer,
      $$SeriesTableAnnotationComposer,
      $$SeriesTableCreateCompanionBuilder,
      $$SeriesTableUpdateCompanionBuilder,
      (SeriesItem, $$SeriesTableReferences),
      SeriesItem,
      PrefetchHooks Function({bool worksRefs})
    >;
typedef $$WorksTableCreateCompanionBuilder = WorksCompanion Function({
  Value<int> id,
  required WorkType type,
  required WorkFormat format,
  required String title,
  Value<String?> author,
  Value<String?> summary,
  Value<String?> isbn,
  Value<String?> sourceUrl,
  Value<String?> coverUrl,
  Value<String?> coverPath,
  Value<int?> fandomId,
  Value<ReadingStatus> status,
  Value<bool> isComplete,
  Value<int?> chapterCount,
  Value<int?> currentChapter,
  Value<double?> readOffset,
  Value<int?> wordCount,
  Value<int?> pageCount,
  Value<int?> rating,
  Value<String?> notes,
  Value<DateTime> addedAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> checkedAt,
  Value<DateTime?> lastChapterAt,
  Value<int> newChapters,
  Value<DateTime?> deletedAt,
  Value<DateTime?> finishedAt,
  Value<int?> seriesId,
  Value<double?> seriesIndex,
  Value<bool> wordsEstimated,
  Value<bool> pagesEstimated,
  Value<int?> characterCount,
});
typedef $$WorksTableUpdateCompanionBuilder = WorksCompanion Function({
  Value<int> id,
  Value<WorkType> type,
  Value<WorkFormat> format,
  Value<String> title,
  Value<String?> author,
  Value<String?> summary,
  Value<String?> isbn,
  Value<String?> sourceUrl,
  Value<String?> coverUrl,
  Value<String?> coverPath,
  Value<int?> fandomId,
  Value<ReadingStatus> status,
  Value<bool> isComplete,
  Value<int?> chapterCount,
  Value<int?> currentChapter,
  Value<double?> readOffset,
  Value<int?> wordCount,
  Value<int?> pageCount,
  Value<int?> rating,
  Value<String?> notes,
  Value<DateTime> addedAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> checkedAt,
  Value<DateTime?> lastChapterAt,
  Value<int> newChapters,
  Value<DateTime?> deletedAt,
  Value<DateTime?> finishedAt,
  Value<int?> seriesId,
  Value<double?> seriesIndex,
  Value<bool> wordsEstimated,
  Value<bool> pagesEstimated,
  Value<int?> characterCount,
});

final class $$WorksTableReferences
    extends BaseReferences<_$AppDatabase, $WorksTable, Work> {
  $$WorksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FandomsTable _fandomIdTable(_$AppDatabase db) =>
      db.fandoms.createAlias('works__fandom_id__fandoms__id');

  $$FandomsTableProcessedTableManager? get fandomId {
    final $_column = $_itemColumn<int>('fandom_id');
    if ($_column == null) return null;
    final manager = $$FandomsTableTableManager(
      $_db,
      $_db.fandoms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fandomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SeriesTable _seriesIdTable(_$AppDatabase db) =>
      db.series.createAlias('works__series_id__series__id');

  $$SeriesTableProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<int>('series_id');
    if ($_column == null) return null;
    final manager = $$SeriesTableTableManager(
      $_db,
      $_db.series,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkCharactersTable, List<WorkCharacter>>
  _workCharactersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workCharacters,
    aliasName: 'works__id__work_characters__work_id',
  );

  $$WorkCharactersTableProcessedTableManager get workCharactersRefs {
    final manager = $$WorkCharactersTableTableManager(
      $_db,
      $_db.workCharacters,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workCharactersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkFandomsTable, List<WorkFandom>>
  _workFandomsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workFandoms,
    aliasName: 'works__id__work_fandoms__work_id',
  );

  $$WorkFandomsTableProcessedTableManager get workFandomsRefs {
    final manager = $$WorkFandomsTableTableManager(
      $_db,
      $_db.workFandoms,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workFandomsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingDaysTable, List<ReadingDay>>
  _readingDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingDays,
    aliasName: 'works__id__reading_days__work_id',
  );

  $$ReadingDaysTableProcessedTableManager get readingDaysRefs {
    final manager = $$ReadingDaysTableTableManager(
      $_db,
      $_db.readingDays,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkTagsTable, List<WorkTag>> _workTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workTags,
    aliasName: 'works__id__work_tags__work_id',
  );

  $$WorkTagsTableProcessedTableManager get workTagsRefs {
    final manager = $$WorkTagsTableTableManager(
      $_db,
      $_db.workTags,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: 'works__id__chapters__work_id',
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadsTable, List<Download>>
  _downloadsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloads,
    aliasName: 'works__id__downloads__work_id',
  );

  $$DownloadsTableProcessedTableManager get downloadsRefs {
    final manager = $$DownloadsTableTableManager(
      $_db,
      $_db.downloads,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkPairingsTable, List<WorkPairing>>
  _workPairingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workPairings,
    aliasName: 'works__id__work_pairings__work_id',
  );

  $$WorkPairingsTableProcessedTableManager get workPairingsRefs {
    final manager = $$WorkPairingsTableTableManager(
      $_db,
      $_db.workPairings,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workPairingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnnotationsTable, List<Annotation>>
  _annotationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.annotations,
    aliasName: 'works__id__annotations__work_id',
  );

  $$AnnotationsTableProcessedTableManager get annotationsRefs {
    final manager = $$AnnotationsTableTableManager(
      $_db,
      $_db.annotations,
    ).filter((f) => f.workId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_annotationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorksTableFilterComposer extends Composer<_$AppDatabase, $WorksTable> {
  $$WorksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WorkType, WorkType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<WorkFormat, WorkFormat, String> get format =>
      $composableBuilder(
        column: $table.format,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReadingStatus, ReadingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentChapter => $composableBuilder(
    column: $table.currentChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get readOffset => $composableBuilder(
    column: $table.readOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastChapterAt => $composableBuilder(
    column: $table.lastChapterAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newChapters => $composableBuilder(
    column: $table.newChapters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get seriesIndex => $composableBuilder(
    column: $table.seriesIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wordsEstimated => $composableBuilder(
    column: $table.wordsEstimated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pagesEstimated => $composableBuilder(
    column: $table.pagesEstimated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnFilters(column),
  );

  $$FandomsTableFilterComposer get fandomId {
    final $$FandomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableFilterComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeriesTableFilterComposer get seriesId {
    final $$SeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableFilterComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workCharactersRefs(
    Expression<bool> Function($$WorkCharactersTableFilterComposer f) f,
  ) {
    final $$WorkCharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workCharacters,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkCharactersTableFilterComposer(
            $db: $db,
            $table: $db.workCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workFandomsRefs(
    Expression<bool> Function($$WorkFandomsTableFilterComposer f) f,
  ) {
    final $$WorkFandomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workFandoms,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkFandomsTableFilterComposer(
            $db: $db,
            $table: $db.workFandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingDaysRefs(
    Expression<bool> Function($$ReadingDaysTableFilterComposer f) f,
  ) {
    final $$ReadingDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingDays,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingDaysTableFilterComposer(
            $db: $db,
            $table: $db.readingDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workTagsRefs(
    Expression<bool> Function($$WorkTagsTableFilterComposer f) f,
  ) {
    final $$WorkTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workTags,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkTagsTableFilterComposer(
            $db: $db,
            $table: $db.workTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadsRefs(
    Expression<bool> Function($$DownloadsTableFilterComposer f) f,
  ) {
    final $$DownloadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloads,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableFilterComposer(
            $db: $db,
            $table: $db.downloads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workPairingsRefs(
    Expression<bool> Function($$WorkPairingsTableFilterComposer f) f,
  ) {
    final $$WorkPairingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workPairings,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkPairingsTableFilterComposer(
            $db: $db,
            $table: $db.workPairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> annotationsRefs(
    Expression<bool> Function($$AnnotationsTableFilterComposer f) f,
  ) {
    final $$AnnotationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.annotations,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnnotationsTableFilterComposer(
            $db: $db,
            $table: $db.annotations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorksTableOrderingComposer
    extends Composer<_$AppDatabase, $WorksTable> {
  $$WorksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentChapter => $composableBuilder(
    column: $table.currentChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get readOffset => $composableBuilder(
    column: $table.readOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastChapterAt => $composableBuilder(
    column: $table.lastChapterAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newChapters => $composableBuilder(
    column: $table.newChapters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get seriesIndex => $composableBuilder(
    column: $table.seriesIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wordsEstimated => $composableBuilder(
    column: $table.wordsEstimated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pagesEstimated => $composableBuilder(
    column: $table.pagesEstimated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$FandomsTableOrderingComposer get fandomId {
    final $$FandomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableOrderingComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeriesTableOrderingComposer get seriesId {
    final $$SeriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableOrderingComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorksTable> {
  $$WorksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorkType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorkFormat, String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReadingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentChapter => $composableBuilder(
    column: $table.currentChapter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get readOffset => $composableBuilder(
    column: $table.readOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastChapterAt => $composableBuilder(
    column: $table.lastChapterAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newChapters => $composableBuilder(
    column: $table.newChapters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get seriesIndex => $composableBuilder(
    column: $table.seriesIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wordsEstimated => $composableBuilder(
    column: $table.wordsEstimated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pagesEstimated => $composableBuilder(
    column: $table.pagesEstimated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get characterCount => $composableBuilder(
    column: $table.characterCount,
    builder: (column) => column,
  );

  $$FandomsTableAnnotationComposer get fandomId {
    final $$FandomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableAnnotationComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SeriesTableAnnotationComposer get seriesId {
    final $$SeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workCharactersRefs<T extends Object>(
    Expression<T> Function($$WorkCharactersTableAnnotationComposer a) f,
  ) {
    final $$WorkCharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workCharacters,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkCharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.workCharacters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workFandomsRefs<T extends Object>(
    Expression<T> Function($$WorkFandomsTableAnnotationComposer a) f,
  ) {
    final $$WorkFandomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workFandoms,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkFandomsTableAnnotationComposer(
            $db: $db,
            $table: $db.workFandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingDaysRefs<T extends Object>(
    Expression<T> Function($$ReadingDaysTableAnnotationComposer a) f,
  ) {
    final $$ReadingDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingDays,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.readingDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workTagsRefs<T extends Object>(
    Expression<T> Function($$WorkTagsTableAnnotationComposer a) f,
  ) {
    final $$WorkTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workTags,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.workTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> downloadsRefs<T extends Object>(
    Expression<T> Function($$DownloadsTableAnnotationComposer a) f,
  ) {
    final $$DownloadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloads,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workPairingsRefs<T extends Object>(
    Expression<T> Function($$WorkPairingsTableAnnotationComposer a) f,
  ) {
    final $$WorkPairingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workPairings,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkPairingsTableAnnotationComposer(
            $db: $db,
            $table: $db.workPairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> annotationsRefs<T extends Object>(
    Expression<T> Function($$AnnotationsTableAnnotationComposer a) f,
  ) {
    final $$AnnotationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.annotations,
      getReferencedColumn: (t) => t.workId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnnotationsTableAnnotationComposer(
            $db: $db,
            $table: $db.annotations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorksTable,
          Work,
          $$WorksTableFilterComposer,
          $$WorksTableOrderingComposer,
          $$WorksTableAnnotationComposer,
          $$WorksTableCreateCompanionBuilder,
          $$WorksTableUpdateCompanionBuilder,
          (Work, $$WorksTableReferences),
          Work,
          PrefetchHooks Function({
            bool fandomId,
            bool seriesId,
            bool workCharactersRefs,
            bool workFandomsRefs,
            bool readingDaysRefs,
            bool workTagsRefs,
            bool chaptersRefs,
            bool downloadsRefs,
            bool workPairingsRefs,
            bool annotationsRefs,
          })
        > {
  $$WorksTableTableManager(_$AppDatabase db, $WorksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<WorkType> type = const Value.absent(),
                Value<WorkFormat> format = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int?> fandomId = const Value.absent(),
                Value<ReadingStatus> status = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<int?> chapterCount = const Value.absent(),
                Value<int?> currentChapter = const Value.absent(),
                Value<double?> readOffset = const Value.absent(),
                Value<int?> wordCount = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<DateTime?> lastChapterAt = const Value.absent(),
                Value<int> newChapters = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                Value<double?> seriesIndex = const Value.absent(),
                Value<bool> wordsEstimated = const Value.absent(),
                Value<bool> pagesEstimated = const Value.absent(),
                Value<int?> characterCount = const Value.absent(),
              }) => WorksCompanion(
                id: id,
                type: type,
                format: format,
                title: title,
                author: author,
                summary: summary,
                isbn: isbn,
                sourceUrl: sourceUrl,
                coverUrl: coverUrl,
                coverPath: coverPath,
                fandomId: fandomId,
                status: status,
                isComplete: isComplete,
                chapterCount: chapterCount,
                currentChapter: currentChapter,
                readOffset: readOffset,
                wordCount: wordCount,
                pageCount: pageCount,
                rating: rating,
                notes: notes,
                addedAt: addedAt,
                updatedAt: updatedAt,
                checkedAt: checkedAt,
                lastChapterAt: lastChapterAt,
                newChapters: newChapters,
                deletedAt: deletedAt,
                finishedAt: finishedAt,
                seriesId: seriesId,
                seriesIndex: seriesIndex,
                wordsEstimated: wordsEstimated,
                pagesEstimated: pagesEstimated,
                characterCount: characterCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required WorkType type,
                required WorkFormat format,
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int?> fandomId = const Value.absent(),
                Value<ReadingStatus> status = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<int?> chapterCount = const Value.absent(),
                Value<int?> currentChapter = const Value.absent(),
                Value<double?> readOffset = const Value.absent(),
                Value<int?> wordCount = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<DateTime?> lastChapterAt = const Value.absent(),
                Value<int> newChapters = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                Value<double?> seriesIndex = const Value.absent(),
                Value<bool> wordsEstimated = const Value.absent(),
                Value<bool> pagesEstimated = const Value.absent(),
                Value<int?> characterCount = const Value.absent(),
              }) => WorksCompanion.insert(
                id: id,
                type: type,
                format: format,
                title: title,
                author: author,
                summary: summary,
                isbn: isbn,
                sourceUrl: sourceUrl,
                coverUrl: coverUrl,
                coverPath: coverPath,
                fandomId: fandomId,
                status: status,
                isComplete: isComplete,
                chapterCount: chapterCount,
                currentChapter: currentChapter,
                readOffset: readOffset,
                wordCount: wordCount,
                pageCount: pageCount,
                rating: rating,
                notes: notes,
                addedAt: addedAt,
                updatedAt: updatedAt,
                checkedAt: checkedAt,
                lastChapterAt: lastChapterAt,
                newChapters: newChapters,
                deletedAt: deletedAt,
                finishedAt: finishedAt,
                seriesId: seriesId,
                seriesIndex: seriesIndex,
                wordsEstimated: wordsEstimated,
                pagesEstimated: pagesEstimated,
                characterCount: characterCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorksTable, Work>(table),
                  $$WorksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fandomId = false,
                seriesId = false,
                workCharactersRefs = false,
                workFandomsRefs = false,
                readingDaysRefs = false,
                workTagsRefs = false,
                chaptersRefs = false,
                downloadsRefs = false,
                workPairingsRefs = false,
                annotationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workCharactersRefs) db.workCharacters,
                    if (workFandomsRefs) db.workFandoms,
                    if (readingDaysRefs) db.readingDays,
                    if (workTagsRefs) db.workTags,
                    if (chaptersRefs) db.chapters,
                    if (downloadsRefs) db.downloads,
                    if (workPairingsRefs) db.workPairings,
                    if (annotationsRefs) db.annotations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fandomId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fandomId,
                            referencedTable: $$WorksTableReferences
                                ._fandomIdTable(db),
                            referencedColumn: $$WorksTableReferences
                                ._fandomIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (seriesId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.seriesId,
                            referencedTable: $$WorksTableReferences
                                ._seriesIdTable(db),
                            referencedColumn: $$WorksTableReferences
                                ._seriesIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workCharactersRefs)
                        await $_getPrefetchedData<
                          Work,
                          $WorksTable,
                          WorkCharacter
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._workCharactersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).workCharactersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workFandomsRefs)
                        await $_getPrefetchedData<
                          Work,
                          $WorksTable,
                          WorkFandom
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._workFandomsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).workFandomsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingDaysRefs)
                        await $_getPrefetchedData<
                          Work,
                          $WorksTable,
                          ReadingDay
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._readingDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workTagsRefs)
                        await $_getPrefetchedData<Work, $WorksTable, WorkTag>(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._workTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).workTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chaptersRefs)
                        await $_getPrefetchedData<Work, $WorksTable, Chapter>(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._chaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).chaptersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (downloadsRefs)
                        await $_getPrefetchedData<Work, $WorksTable, Download>(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._downloadsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workPairingsRefs)
                        await $_getPrefetchedData<
                          Work,
                          $WorksTable,
                          WorkPairing
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._workPairingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).workPairingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (annotationsRefs)
                        await $_getPrefetchedData<
                          Work,
                          $WorksTable,
                          Annotation
                        >(
                          currentTable: table,
                          referencedTable: $$WorksTableReferences
                              ._annotationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorksTableReferences(
                                db,
                                table,
                                p0,
                              ).annotationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorksTable,
      Work,
      $$WorksTableFilterComposer,
      $$WorksTableOrderingComposer,
      $$WorksTableAnnotationComposer,
      $$WorksTableCreateCompanionBuilder,
      $$WorksTableUpdateCompanionBuilder,
      (Work, $$WorksTableReferences),
      Work,
      PrefetchHooks Function({
        bool fandomId,
        bool seriesId,
        bool workCharactersRefs,
        bool workFandomsRefs,
        bool readingDaysRefs,
        bool workTagsRefs,
        bool chaptersRefs,
        bool downloadsRefs,
        bool workPairingsRefs,
        bool annotationsRefs,
      })
    >;
typedef $$WorkCharactersTableCreateCompanionBuilder =
    WorkCharactersCompanion Function({
      required int workId,
      required int characterId,
      Value<double> confidence,
      Value<int> rowid,
    });
typedef $$WorkCharactersTableUpdateCompanionBuilder =
    WorkCharactersCompanion Function({
      Value<int> workId,
      Value<int> characterId,
      Value<double> confidence,
      Value<int> rowid,
    });

final class $$WorkCharactersTableReferences
    extends BaseReferences<_$AppDatabase, $WorkCharactersTable, WorkCharacter> {
  $$WorkCharactersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_characters__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CharactersTable _characterIdTable(_$AppDatabase db) => db.characters
      .createAlias('work_characters__character_id__characters__id');

  $$CharactersTableProcessedTableManager get characterId {
    final $_column = $_itemColumn<int>('character_id')!;

    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkCharactersTableFilterComposer
    extends Composer<_$AppDatabase, $WorkCharactersTable> {
  $$WorkCharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkCharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkCharactersTable> {
  $$WorkCharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkCharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkCharactersTable> {
  $$WorkCharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkCharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkCharactersTable,
          WorkCharacter,
          $$WorkCharactersTableFilterComposer,
          $$WorkCharactersTableOrderingComposer,
          $$WorkCharactersTableAnnotationComposer,
          $$WorkCharactersTableCreateCompanionBuilder,
          $$WorkCharactersTableUpdateCompanionBuilder,
          (WorkCharacter, $$WorkCharactersTableReferences),
          WorkCharacter,
          PrefetchHooks Function({bool workId, bool characterId})
        > {
  $$WorkCharactersTableTableManager(
    _$AppDatabase db,
    $WorkCharactersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkCharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkCharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkCharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> workId = const Value.absent(),
                Value<int> characterId = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkCharactersCompanion(
                workId: workId,
                characterId: characterId,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int workId,
                required int characterId,
                Value<double> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkCharactersCompanion.insert(
                workId: workId,
                characterId: characterId,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkCharactersTable, WorkCharacter>(table),
                  $$WorkCharactersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false, characterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$WorkCharactersTableReferences
                            ._workIdTable(db),
                        referencedColumn: $$WorkCharactersTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (characterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.characterId,
                        referencedTable: $$WorkCharactersTableReferences
                            ._characterIdTable(db),
                        referencedColumn: $$WorkCharactersTableReferences
                            ._characterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkCharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkCharactersTable,
      WorkCharacter,
      $$WorkCharactersTableFilterComposer,
      $$WorkCharactersTableOrderingComposer,
      $$WorkCharactersTableAnnotationComposer,
      $$WorkCharactersTableCreateCompanionBuilder,
      $$WorkCharactersTableUpdateCompanionBuilder,
      (WorkCharacter, $$WorkCharactersTableReferences),
      WorkCharacter,
      PrefetchHooks Function({bool workId, bool characterId})
    >;
typedef $$WorkFandomsTableCreateCompanionBuilder =
    WorkFandomsCompanion Function({
      required int workId,
      required int fandomId,
      Value<FandomRole> role,
      Value<int> rowid,
    });
typedef $$WorkFandomsTableUpdateCompanionBuilder =
    WorkFandomsCompanion Function({
      Value<int> workId,
      Value<int> fandomId,
      Value<FandomRole> role,
      Value<int> rowid,
    });

final class $$WorkFandomsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkFandomsTable, WorkFandom> {
  $$WorkFandomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_fandoms__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FandomsTable _fandomIdTable(_$AppDatabase db) =>
      db.fandoms.createAlias('work_fandoms__fandom_id__fandoms__id');

  $$FandomsTableProcessedTableManager get fandomId {
    final $_column = $_itemColumn<int>('fandom_id')!;

    final manager = $$FandomsTableTableManager(
      $_db,
      $_db.fandoms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fandomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkFandomsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkFandomsTable> {
  $$WorkFandomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<FandomRole, FandomRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FandomsTableFilterComposer get fandomId {
    final $$FandomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableFilterComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkFandomsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkFandomsTable> {
  $$WorkFandomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FandomsTableOrderingComposer get fandomId {
    final $$FandomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableOrderingComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkFandomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkFandomsTable> {
  $$WorkFandomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<FandomRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FandomsTableAnnotationComposer get fandomId {
    final $$FandomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fandomId,
      referencedTable: $db.fandoms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FandomsTableAnnotationComposer(
            $db: $db,
            $table: $db.fandoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkFandomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkFandomsTable,
          WorkFandom,
          $$WorkFandomsTableFilterComposer,
          $$WorkFandomsTableOrderingComposer,
          $$WorkFandomsTableAnnotationComposer,
          $$WorkFandomsTableCreateCompanionBuilder,
          $$WorkFandomsTableUpdateCompanionBuilder,
          (WorkFandom, $$WorkFandomsTableReferences),
          WorkFandom,
          PrefetchHooks Function({bool workId, bool fandomId})
        > {
  $$WorkFandomsTableTableManager(_$AppDatabase db, $WorkFandomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkFandomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkFandomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkFandomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> workId = const Value.absent(),
                Value<int> fandomId = const Value.absent(),
                Value<FandomRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkFandomsCompanion(
                workId: workId,
                fandomId: fandomId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int workId,
                required int fandomId,
                Value<FandomRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkFandomsCompanion.insert(
                workId: workId,
                fandomId: fandomId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkFandomsTable, WorkFandom>(table),
                  $$WorkFandomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false, fandomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$WorkFandomsTableReferences
                            ._workIdTable(db),
                        referencedColumn: $$WorkFandomsTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (fandomId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fandomId,
                        referencedTable: $$WorkFandomsTableReferences
                            ._fandomIdTable(db),
                        referencedColumn: $$WorkFandomsTableReferences
                            ._fandomIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkFandomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkFandomsTable,
      WorkFandom,
      $$WorkFandomsTableFilterComposer,
      $$WorkFandomsTableOrderingComposer,
      $$WorkFandomsTableAnnotationComposer,
      $$WorkFandomsTableCreateCompanionBuilder,
      $$WorkFandomsTableUpdateCompanionBuilder,
      (WorkFandom, $$WorkFandomsTableReferences),
      WorkFandom,
      PrefetchHooks Function({bool workId, bool fandomId})
    >;
typedef $$WorkRelationsTableCreateCompanionBuilder =
    WorkRelationsCompanion Function({
      required int fromWorkId,
      required int toWorkId,
      required RelationType type,
      Value<int> rowid,
    });
typedef $$WorkRelationsTableUpdateCompanionBuilder =
    WorkRelationsCompanion Function({
      Value<int> fromWorkId,
      Value<int> toWorkId,
      Value<RelationType> type,
      Value<int> rowid,
    });

final class $$WorkRelationsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkRelationsTable, WorkRelation> {
  $$WorkRelationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorksTable _fromWorkIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_relations__from_work_id__works__id');

  $$WorksTableProcessedTableManager get fromWorkId {
    final $_column = $_itemColumn<int>('from_work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromWorkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorksTable _toWorkIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_relations__to_work_id__works__id');

  $$WorksTableProcessedTableManager get toWorkId {
    final $_column = $_itemColumn<int>('to_work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toWorkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkRelationsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkRelationsTable> {
  $$WorkRelationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<RelationType, RelationType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$WorksTableFilterComposer get fromWorkId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromWorkId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableFilterComposer get toWorkId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toWorkId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkRelationsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkRelationsTable> {
  $$WorkRelationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get fromWorkId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromWorkId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableOrderingComposer get toWorkId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toWorkId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkRelationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkRelationsTable> {
  $$WorkRelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<RelationType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$WorksTableAnnotationComposer get fromWorkId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromWorkId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorksTableAnnotationComposer get toWorkId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toWorkId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkRelationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkRelationsTable,
          WorkRelation,
          $$WorkRelationsTableFilterComposer,
          $$WorkRelationsTableOrderingComposer,
          $$WorkRelationsTableAnnotationComposer,
          $$WorkRelationsTableCreateCompanionBuilder,
          $$WorkRelationsTableUpdateCompanionBuilder,
          (WorkRelation, $$WorkRelationsTableReferences),
          WorkRelation,
          PrefetchHooks Function({bool fromWorkId, bool toWorkId})
        > {
  $$WorkRelationsTableTableManager(_$AppDatabase db, $WorkRelationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkRelationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkRelationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkRelationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> fromWorkId = const Value.absent(),
                Value<int> toWorkId = const Value.absent(),
                Value<RelationType> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkRelationsCompanion(
                fromWorkId: fromWorkId,
                toWorkId: toWorkId,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int fromWorkId,
                required int toWorkId,
                required RelationType type,
                Value<int> rowid = const Value.absent(),
              }) => WorkRelationsCompanion.insert(
                fromWorkId: fromWorkId,
                toWorkId: toWorkId,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkRelationsTable, WorkRelation>(table),
                  $$WorkRelationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromWorkId = false, toWorkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fromWorkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fromWorkId,
                        referencedTable: $$WorkRelationsTableReferences
                            ._fromWorkIdTable(db),
                        referencedColumn: $$WorkRelationsTableReferences
                            ._fromWorkIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (toWorkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.toWorkId,
                        referencedTable: $$WorkRelationsTableReferences
                            ._toWorkIdTable(db),
                        referencedColumn: $$WorkRelationsTableReferences
                            ._toWorkIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkRelationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkRelationsTable,
      WorkRelation,
      $$WorkRelationsTableFilterComposer,
      $$WorkRelationsTableOrderingComposer,
      $$WorkRelationsTableAnnotationComposer,
      $$WorkRelationsTableCreateCompanionBuilder,
      $$WorkRelationsTableUpdateCompanionBuilder,
      (WorkRelation, $$WorkRelationsTableReferences),
      WorkRelation,
      PrefetchHooks Function({bool fromWorkId, bool toWorkId})
    >;
typedef $$ReadingDaysTableCreateCompanionBuilder =
    ReadingDaysCompanion Function({
      required int workId,
      required String day,
      Value<int> seconds,
      Value<int> words,
      Value<int> chapters,
      Value<int> rowid,
    });
typedef $$ReadingDaysTableUpdateCompanionBuilder =
    ReadingDaysCompanion Function({
      Value<int> workId,
      Value<String> day,
      Value<int> seconds,
      Value<int> words,
      Value<int> chapters,
      Value<int> rowid,
    });

final class $$ReadingDaysTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingDaysTable, ReadingDay> {
  $$ReadingDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('reading_days__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingDaysTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingDaysTable> {
  $$ReadingDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get words => $composableBuilder(
    column: $table.words,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapters => $composableBuilder(
    column: $table.chapters,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingDaysTable> {
  $$ReadingDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get words => $composableBuilder(
    column: $table.words,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapters => $composableBuilder(
    column: $table.chapters,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingDaysTable> {
  $$ReadingDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<int> get words =>
      $composableBuilder(column: $table.words, builder: (column) => column);

  GeneratedColumn<int> get chapters =>
      $composableBuilder(column: $table.chapters, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingDaysTable,
          ReadingDay,
          $$ReadingDaysTableFilterComposer,
          $$ReadingDaysTableOrderingComposer,
          $$ReadingDaysTableAnnotationComposer,
          $$ReadingDaysTableCreateCompanionBuilder,
          $$ReadingDaysTableUpdateCompanionBuilder,
          (ReadingDay, $$ReadingDaysTableReferences),
          ReadingDay,
          PrefetchHooks Function({bool workId})
        > {
  $$ReadingDaysTableTableManager(_$AppDatabase db, $ReadingDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> workId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<int> words = const Value.absent(),
                Value<int> chapters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingDaysCompanion(
                workId: workId,
                day: day,
                seconds: seconds,
                words: words,
                chapters: chapters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int workId,
                required String day,
                Value<int> seconds = const Value.absent(),
                Value<int> words = const Value.absent(),
                Value<int> chapters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingDaysCompanion.insert(
                workId: workId,
                day: day,
                seconds: seconds,
                words: words,
                chapters: chapters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingDaysTable, ReadingDay>(table),
                  $$ReadingDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$ReadingDaysTableReferences
                            ._workIdTable(db),
                        referencedColumn: $$ReadingDaysTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingDaysTable,
      ReadingDay,
      $$ReadingDaysTableFilterComposer,
      $$ReadingDaysTableOrderingComposer,
      $$ReadingDaysTableAnnotationComposer,
      $$ReadingDaysTableCreateCompanionBuilder,
      $$ReadingDaysTableUpdateCompanionBuilder,
      (ReadingDay, $$ReadingDaysTableReferences),
      ReadingDay,
      PrefetchHooks Function({bool workId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> isAdult,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> isAdult,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkTagsTable, List<WorkTag>> _workTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workTags,
    aliasName: 'tags__id__work_tags__tag_id',
  );

  $$WorkTagsTableProcessedTableManager get workTagsRefs {
    final manager = $$WorkTagsTableTableManager(
      $_db,
      $_db.workTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdult => $composableBuilder(
    column: $table.isAdult,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workTagsRefs(
    Expression<bool> Function($$WorkTagsTableFilterComposer f) f,
  ) {
    final $$WorkTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkTagsTableFilterComposer(
            $db: $db,
            $table: $db.workTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdult => $composableBuilder(
    column: $table.isAdult,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isAdult =>
      $composableBuilder(column: $table.isAdult, builder: (column) => column);

  Expression<T> workTagsRefs<T extends Object>(
    Expression<T> Function($$WorkTagsTableAnnotationComposer a) f,
  ) {
    final $$WorkTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.workTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool workTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isAdult = const Value.absent(),
          }) => TagsCompanion(id: id, name: name, isAdult: isAdult),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> isAdult = const Value.absent(),
          }) => TagsCompanion.insert(id: id, name: name, isAdult: isAdult),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workTagsRefs) db.workTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, WorkTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._workTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).workTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool workTagsRefs})
    >;
typedef $$WorkTagsTableCreateCompanionBuilder = WorkTagsCompanion Function({
  required int workId,
  required int tagId,
  Value<int> rowid,
});
typedef $$WorkTagsTableUpdateCompanionBuilder = WorkTagsCompanion Function({
  Value<int> workId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$WorkTagsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkTagsTable, WorkTag> {
  $$WorkTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_tags__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('work_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkTagsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkTagsTable> {
  $$WorkTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkTagsTable> {
  $$WorkTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkTagsTable> {
  $$WorkTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkTagsTable,
          WorkTag,
          $$WorkTagsTableFilterComposer,
          $$WorkTagsTableOrderingComposer,
          $$WorkTagsTableAnnotationComposer,
          $$WorkTagsTableCreateCompanionBuilder,
          $$WorkTagsTableUpdateCompanionBuilder,
          (WorkTag, $$WorkTagsTableReferences),
          WorkTag,
          PrefetchHooks Function({bool workId, bool tagId})
        > {
  $$WorkTagsTableTableManager(_$AppDatabase db, $WorkTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> workId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => WorkTagsCompanion(workId: workId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int workId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => WorkTagsCompanion.insert(
                workId: workId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkTagsTable, WorkTag>(table),
                  $$WorkTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$WorkTagsTableReferences._workIdTable(
                          db,
                        ),
                        referencedColumn: $$WorkTagsTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$WorkTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$WorkTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkTagsTable,
      WorkTag,
      $$WorkTagsTableFilterComposer,
      $$WorkTagsTableOrderingComposer,
      $$WorkTagsTableAnnotationComposer,
      $$WorkTagsTableCreateCompanionBuilder,
      $$WorkTagsTableUpdateCompanionBuilder,
      (WorkTag, $$WorkTagsTableReferences),
      WorkTag,
      PrefetchHooks Function({bool workId, bool tagId})
    >;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  Value<int> id,
  required int workId,
  required int number,
  Value<String?> title,
  Value<String?> url,
  Value<String?> content,
  Value<int?> wordCount,
  Value<DateTime?> downloadedAt,
  Value<bool> isLocked,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<int> id,
  Value<int> workId,
  Value<int> number,
  Value<String?> title,
  Value<String?> url,
  Value<String?> content,
  Value<int?> wordCount,
  Value<DateTime?> downloadedAt,
  Value<bool> isLocked,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('chapters__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, $$ChaptersTableReferences),
          Chapter,
          PrefetchHooks Function({bool workId})
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int?> wordCount = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                workId: workId,
                number: number,
                title: title,
                url: url,
                content: content,
                wordCount: wordCount,
                downloadedAt: downloadedAt,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workId,
                required int number,
                Value<String?> title = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int?> wordCount = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                workId: workId,
                number: number,
                title: title,
                url: url,
                content: content,
                wordCount: wordCount,
                downloadedAt: downloadedAt,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChaptersTable, Chapter>(table),
                  $$ChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$ChaptersTableReferences._workIdTable(
                          db,
                        ),
                        referencedColumn: $$ChaptersTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, $$ChaptersTableReferences),
      Chapter,
      PrefetchHooks Function({bool workId})
    >;
typedef $$DownloadsTableCreateCompanionBuilder = DownloadsCompanion Function({
  Value<int> id,
  required int workId,
  required int fromChapter,
  required int toChapter,
  Value<String> format,
  Value<bool> withImages,
  Value<String?> filePath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DownloadsTableUpdateCompanionBuilder = DownloadsCompanion Function({
  Value<int> id,
  Value<int> workId,
  Value<int> fromChapter,
  Value<int> toChapter,
  Value<String> format,
  Value<bool> withImages,
  Value<String?> filePath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$DownloadsTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadsTable, Download> {
  $$DownloadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('downloads__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromChapter => $composableBuilder(
    column: $table.fromChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toChapter => $composableBuilder(
    column: $table.toChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get withImages => $composableBuilder(
    column: $table.withImages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromChapter => $composableBuilder(
    column: $table.fromChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toChapter => $composableBuilder(
    column: $table.toChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get withImages => $composableBuilder(
    column: $table.withImages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fromChapter => $composableBuilder(
    column: $table.fromChapter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toChapter =>
      $composableBuilder(column: $table.toChapter, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<bool> get withImages => $composableBuilder(
    column: $table.withImages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (Download, $$DownloadsTableReferences),
          Download,
          PrefetchHooks Function({bool workId})
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workId = const Value.absent(),
                Value<int> fromChapter = const Value.absent(),
                Value<int> toChapter = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<bool> withImages = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadsCompanion(
                id: id,
                workId: workId,
                fromChapter: fromChapter,
                toChapter: toChapter,
                format: format,
                withImages: withImages,
                filePath: filePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workId,
                required int fromChapter,
                required int toChapter,
                Value<String> format = const Value.absent(),
                Value<bool> withImages = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadsCompanion.insert(
                id: id,
                workId: workId,
                fromChapter: fromChapter,
                toChapter: toChapter,
                format: format,
                withImages: withImages,
                filePath: filePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadsTable, Download>(table),
                  $$DownloadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$DownloadsTableReferences
                            ._workIdTable(db),
                        referencedColumn: $$DownloadsTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (Download, $$DownloadsTableReferences),
      Download,
      PrefetchHooks Function({bool workId})
    >;
typedef $$PairingsTableCreateCompanionBuilder = PairingsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$PairingsTableUpdateCompanionBuilder = PairingsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$PairingsTableReferences
    extends BaseReferences<_$AppDatabase, $PairingsTable, Pairing> {
  $$PairingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkPairingsTable, List<WorkPairing>>
  _workPairingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workPairings,
    aliasName: 'pairings__id__work_pairings__pairing_id',
  );

  $$WorkPairingsTableProcessedTableManager get workPairingsRefs {
    final manager = $$WorkPairingsTableTableManager(
      $_db,
      $_db.workPairings,
    ).filter((f) => f.pairingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workPairingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PairingsTableFilterComposer
    extends Composer<_$AppDatabase, $PairingsTable> {
  $$PairingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workPairingsRefs(
    Expression<bool> Function($$WorkPairingsTableFilterComposer f) f,
  ) {
    final $$WorkPairingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workPairings,
      getReferencedColumn: (t) => t.pairingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkPairingsTableFilterComposer(
            $db: $db,
            $table: $db.workPairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PairingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PairingsTable> {
  $$PairingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PairingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairingsTable> {
  $$PairingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> workPairingsRefs<T extends Object>(
    Expression<T> Function($$WorkPairingsTableAnnotationComposer a) f,
  ) {
    final $$WorkPairingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workPairings,
      getReferencedColumn: (t) => t.pairingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkPairingsTableAnnotationComposer(
            $db: $db,
            $table: $db.workPairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PairingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairingsTable,
          Pairing,
          $$PairingsTableFilterComposer,
          $$PairingsTableOrderingComposer,
          $$PairingsTableAnnotationComposer,
          $$PairingsTableCreateCompanionBuilder,
          $$PairingsTableUpdateCompanionBuilder,
          (Pairing, $$PairingsTableReferences),
          Pairing,
          PrefetchHooks Function({bool workPairingsRefs})
        > {
  $$PairingsTableTableManager(_$AppDatabase db, $PairingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => PairingsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => PairingsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PairingsTable, Pairing>(table),
                  $$PairingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workPairingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workPairingsRefs) db.workPairings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workPairingsRefs)
                    await $_getPrefetchedData<
                      Pairing,
                      $PairingsTable,
                      WorkPairing
                    >(
                      currentTable: table,
                      referencedTable: $$PairingsTableReferences
                          ._workPairingsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PairingsTableReferences(
                        db,
                        table,
                        p0,
                      ).workPairingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.pairingId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PairingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairingsTable,
      Pairing,
      $$PairingsTableFilterComposer,
      $$PairingsTableOrderingComposer,
      $$PairingsTableAnnotationComposer,
      $$PairingsTableCreateCompanionBuilder,
      $$PairingsTableUpdateCompanionBuilder,
      (Pairing, $$PairingsTableReferences),
      Pairing,
      PrefetchHooks Function({bool workPairingsRefs})
    >;
typedef $$WorkPairingsTableCreateCompanionBuilder =
    WorkPairingsCompanion Function({
      required int workId,
      required int pairingId,
      Value<int> rowid,
    });
typedef $$WorkPairingsTableUpdateCompanionBuilder =
    WorkPairingsCompanion Function({
      Value<int> workId,
      Value<int> pairingId,
      Value<int> rowid,
    });

final class $$WorkPairingsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkPairingsTable, WorkPairing> {
  $$WorkPairingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('work_pairings__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PairingsTable _pairingIdTable(_$AppDatabase db) =>
      db.pairings.createAlias('work_pairings__pairing_id__pairings__id');

  $$PairingsTableProcessedTableManager get pairingId {
    final $_column = $_itemColumn<int>('pairing_id')!;

    final manager = $$PairingsTableTableManager(
      $_db,
      $_db.pairings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pairingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkPairingsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkPairingsTable> {
  $$WorkPairingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PairingsTableFilterComposer get pairingId {
    final $$PairingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairingId,
      referencedTable: $db.pairings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairingsTableFilterComposer(
            $db: $db,
            $table: $db.pairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkPairingsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkPairingsTable> {
  $$WorkPairingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PairingsTableOrderingComposer get pairingId {
    final $$PairingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairingId,
      referencedTable: $db.pairings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairingsTableOrderingComposer(
            $db: $db,
            $table: $db.pairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkPairingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkPairingsTable> {
  $$WorkPairingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PairingsTableAnnotationComposer get pairingId {
    final $$PairingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairingId,
      referencedTable: $db.pairings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairingsTableAnnotationComposer(
            $db: $db,
            $table: $db.pairings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkPairingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkPairingsTable,
          WorkPairing,
          $$WorkPairingsTableFilterComposer,
          $$WorkPairingsTableOrderingComposer,
          $$WorkPairingsTableAnnotationComposer,
          $$WorkPairingsTableCreateCompanionBuilder,
          $$WorkPairingsTableUpdateCompanionBuilder,
          (WorkPairing, $$WorkPairingsTableReferences),
          WorkPairing,
          PrefetchHooks Function({bool workId, bool pairingId})
        > {
  $$WorkPairingsTableTableManager(_$AppDatabase db, $WorkPairingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkPairingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkPairingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkPairingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> workId = const Value.absent(),
                Value<int> pairingId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkPairingsCompanion(
                workId: workId,
                pairingId: pairingId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int workId,
                required int pairingId,
                Value<int> rowid = const Value.absent(),
              }) => WorkPairingsCompanion.insert(
                workId: workId,
                pairingId: pairingId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkPairingsTable, WorkPairing>(table),
                  $$WorkPairingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false, pairingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$WorkPairingsTableReferences
                            ._workIdTable(db),
                        referencedColumn: $$WorkPairingsTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (pairingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pairingId,
                        referencedTable: $$WorkPairingsTableReferences
                            ._pairingIdTable(db),
                        referencedColumn: $$WorkPairingsTableReferences
                            ._pairingIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkPairingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkPairingsTable,
      WorkPairing,
      $$WorkPairingsTableFilterComposer,
      $$WorkPairingsTableOrderingComposer,
      $$WorkPairingsTableAnnotationComposer,
      $$WorkPairingsTableCreateCompanionBuilder,
      $$WorkPairingsTableUpdateCompanionBuilder,
      (WorkPairing, $$WorkPairingsTableReferences),
      WorkPairing,
      PrefetchHooks Function({bool workId, bool pairingId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$AnnotationsTableCreateCompanionBuilder =
    AnnotationsCompanion Function({
      Value<int> id,
      required int workId,
      required int chapterNumber,
      required AnnotationKind kind,
      Value<String?> quote,
      Value<String?> note,
      Value<double> offset,
      Value<DateTime> createdAt,
    });
typedef $$AnnotationsTableUpdateCompanionBuilder =
    AnnotationsCompanion Function({
      Value<int> id,
      Value<int> workId,
      Value<int> chapterNumber,
      Value<AnnotationKind> kind,
      Value<String?> quote,
      Value<String?> note,
      Value<double> offset,
      Value<DateTime> createdAt,
    });

final class $$AnnotationsTableReferences
    extends BaseReferences<_$AppDatabase, $AnnotationsTable, Annotation> {
  $$AnnotationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorksTable _workIdTable(_$AppDatabase db) =>
      db.works.createAlias('annotations__work_id__works__id');

  $$WorksTableProcessedTableManager get workId {
    final $_column = $_itemColumn<int>('work_id')!;

    final manager = $$WorksTableTableManager(
      $_db,
      $_db.works,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AnnotationKind, AnnotationKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offset => $composableBuilder(
    column: $table.offset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorksTableFilterComposer get workId {
    final $$WorksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableFilterComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offset => $composableBuilder(
    column: $table.offset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorksTableOrderingComposer get workId {
    final $$WorksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableOrderingComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AnnotationKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get offset =>
      $composableBuilder(column: $table.offset, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorksTableAnnotationComposer get workId {
    final $$WorksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workId,
      referencedTable: $db.works,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorksTableAnnotationComposer(
            $db: $db,
            $table: $db.works,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnnotationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnnotationsTable,
          Annotation,
          $$AnnotationsTableFilterComposer,
          $$AnnotationsTableOrderingComposer,
          $$AnnotationsTableAnnotationComposer,
          $$AnnotationsTableCreateCompanionBuilder,
          $$AnnotationsTableUpdateCompanionBuilder,
          (Annotation, $$AnnotationsTableReferences),
          Annotation,
          PrefetchHooks Function({bool workId})
        > {
  $$AnnotationsTableTableManager(_$AppDatabase db, $AnnotationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<AnnotationKind> kind = const Value.absent(),
                Value<String?> quote = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<double> offset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AnnotationsCompanion(
                id: id,
                workId: workId,
                chapterNumber: chapterNumber,
                kind: kind,
                quote: quote,
                note: note,
                offset: offset,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workId,
                required int chapterNumber,
                required AnnotationKind kind,
                Value<String?> quote = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<double> offset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AnnotationsCompanion.insert(
                id: id,
                workId: workId,
                chapterNumber: chapterNumber,
                kind: kind,
                quote: quote,
                note: note,
                offset: offset,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnnotationsTable, Annotation>(table),
                  $$AnnotationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workId,
                        referencedTable: $$AnnotationsTableReferences
                            ._workIdTable(db),
                        referencedColumn: $$AnnotationsTableReferences
                            ._workIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnnotationsTable,
      Annotation,
      $$AnnotationsTableFilterComposer,
      $$AnnotationsTableOrderingComposer,
      $$AnnotationsTableAnnotationComposer,
      $$AnnotationsTableCreateCompanionBuilder,
      $$AnnotationsTableUpdateCompanionBuilder,
      (Annotation, $$AnnotationsTableReferences),
      Annotation,
      PrefetchHooks Function({bool workId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FandomsTableTableManager get fandoms =>
      $$FandomsTableTableManager(_db, _db.fandoms);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$CharacterAliasesTableTableManager get characterAliases =>
      $$CharacterAliasesTableTableManager(_db, _db.characterAliases);
  $$SeriesTableTableManager get series =>
      $$SeriesTableTableManager(_db, _db.series);
  $$WorksTableTableManager get works =>
      $$WorksTableTableManager(_db, _db.works);
  $$WorkCharactersTableTableManager get workCharacters =>
      $$WorkCharactersTableTableManager(_db, _db.workCharacters);
  $$WorkFandomsTableTableManager get workFandoms =>
      $$WorkFandomsTableTableManager(_db, _db.workFandoms);
  $$WorkRelationsTableTableManager get workRelations =>
      $$WorkRelationsTableTableManager(_db, _db.workRelations);
  $$ReadingDaysTableTableManager get readingDays =>
      $$ReadingDaysTableTableManager(_db, _db.readingDays);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$WorkTagsTableTableManager get workTags =>
      $$WorkTagsTableTableManager(_db, _db.workTags);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$PairingsTableTableManager get pairings =>
      $$PairingsTableTableManager(_db, _db.pairings);
  $$WorkPairingsTableTableManager get workPairings =>
      $$WorkPairingsTableTableManager(_db, _db.workPairings);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$AnnotationsTableTableManager get annotations =>
      $$AnnotationsTableTableManager(_db, _db.annotations);
}
