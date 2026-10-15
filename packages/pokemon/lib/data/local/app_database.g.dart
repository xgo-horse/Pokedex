// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PokemonEntriesTable extends PokemonEntries
    with TableInfo<$PokemonEntriesTable, PokemonEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typesJsonMeta = const VerificationMeta(
    'typesJson',
  );
  @override
  late final GeneratedColumn<String> typesJson = GeneratedColumn<String>(
    'types_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    typesJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonEntry> instance, {
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
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('types_json')) {
      context.handle(
        _typesJsonMeta,
        typesJson.isAcceptableOrUnknown(data['types_json']!, _typesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_typesJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      typesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}types_json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $PokemonEntriesTable createAlias(String alias) {
    return $PokemonEntriesTable(attachedDatabase, alias);
  }
}

class PokemonEntry extends DataClass implements Insertable<PokemonEntry> {
  final int id;
  final String name;
  final String imageUrl;
  final String typesJson;
  final int cachedAt;
  const PokemonEntry({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.typesJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['image_url'] = Variable<String>(imageUrl);
    map['types_json'] = Variable<String>(typesJson);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  PokemonEntriesCompanion toCompanion(bool nullToAbsent) {
    return PokemonEntriesCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: Value(imageUrl),
      typesJson: Value(typesJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory PokemonEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      typesJson: serializer.fromJson<String>(json['typesJson']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'typesJson': serializer.toJson<String>(typesJson),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  PokemonEntry copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? typesJson,
    int? cachedAt,
  }) => PokemonEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    typesJson: typesJson ?? this.typesJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  PokemonEntry copyWithCompanion(PokemonEntriesCompanion data) {
    return PokemonEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      typesJson: data.typesJson.present ? data.typesJson.value : this.typesJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('typesJson: $typesJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, imageUrl, typesJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.typesJson == this.typesJson &&
          other.cachedAt == this.cachedAt);
}

class PokemonEntriesCompanion extends UpdateCompanion<PokemonEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> imageUrl;
  final Value<String> typesJson;
  final Value<int> cachedAt;
  const PokemonEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.typesJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  PokemonEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String imageUrl,
    required String typesJson,
    this.cachedAt = const Value.absent(),
  }) : name = Value(name),
       imageUrl = Value(imageUrl),
       typesJson = Value(typesJson);
  static Insertable<PokemonEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? typesJson,
    Expression<int>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (typesJson != null) 'types_json': typesJson,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  PokemonEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? imageUrl,
    Value<String>? typesJson,
    Value<int>? cachedAt,
  }) {
    return PokemonEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      typesJson: typesJson ?? this.typesJson,
      cachedAt: cachedAt ?? this.cachedAt,
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
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (typesJson.present) {
      map['types_json'] = Variable<String>(typesJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('typesJson: $typesJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $PokemonPageEntriesTable extends PokemonPageEntries
    with TableInfo<$PokemonPageEntriesTable, PokemonPageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonPageEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pageLimitMeta = const VerificationMeta(
    'pageLimit',
  );
  @override
  late final GeneratedColumn<int> pageLimit = GeneratedColumn<int>(
    'page_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageOffsetMeta = const VerificationMeta(
    'pageOffset',
  );
  @override
  late final GeneratedColumn<int> pageOffset = GeneratedColumn<int>(
    'page_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeNameMeta = const VerificationMeta(
    'typeName',
  );
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
    'type_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasNextMeta = const VerificationMeta(
    'hasNext',
  );
  @override
  late final GeneratedColumn<bool> hasNext = GeneratedColumn<bool>(
    'has_next',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_next" IN (0, 1))',
    ),
  );
  static const VerificationMeta _pokemonIdsJsonMeta = const VerificationMeta(
    'pokemonIdsJson',
  );
  @override
  late final GeneratedColumn<String> pokemonIdsJson = GeneratedColumn<String>(
    'pokemon_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    pageLimit,
    pageOffset,
    typeName,
    totalCount,
    hasNext,
    pokemonIdsJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_page_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonPageEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('page_limit')) {
      context.handle(
        _pageLimitMeta,
        pageLimit.isAcceptableOrUnknown(data['page_limit']!, _pageLimitMeta),
      );
    } else if (isInserting) {
      context.missing(_pageLimitMeta);
    }
    if (data.containsKey('page_offset')) {
      context.handle(
        _pageOffsetMeta,
        pageOffset.isAcceptableOrUnknown(data['page_offset']!, _pageOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_pageOffsetMeta);
    }
    if (data.containsKey('type_name')) {
      context.handle(
        _typeNameMeta,
        typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta),
      );
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCountMeta);
    }
    if (data.containsKey('has_next')) {
      context.handle(
        _hasNextMeta,
        hasNext.isAcceptableOrUnknown(data['has_next']!, _hasNextMeta),
      );
    } else if (isInserting) {
      context.missing(_hasNextMeta);
    }
    if (data.containsKey('pokemon_ids_json')) {
      context.handle(
        _pokemonIdsJsonMeta,
        pokemonIdsJson.isAcceptableOrUnknown(
          data['pokemon_ids_json']!,
          _pokemonIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdsJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pageLimit, pageOffset, typeName};
  @override
  PokemonPageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonPageEntry(
      pageLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_limit'],
      )!,
      pageOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_offset'],
      )!,
      typeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_name'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      hasNext: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_next'],
      )!,
      pokemonIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pokemon_ids_json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $PokemonPageEntriesTable createAlias(String alias) {
    return $PokemonPageEntriesTable(attachedDatabase, alias);
  }
}

class PokemonPageEntry extends DataClass
    implements Insertable<PokemonPageEntry> {
  final int pageLimit;
  final int pageOffset;
  final String typeName;
  final int totalCount;
  final bool hasNext;
  final String pokemonIdsJson;
  final int cachedAt;
  const PokemonPageEntry({
    required this.pageLimit,
    required this.pageOffset,
    required this.typeName,
    required this.totalCount,
    required this.hasNext,
    required this.pokemonIdsJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['page_limit'] = Variable<int>(pageLimit);
    map['page_offset'] = Variable<int>(pageOffset);
    map['type_name'] = Variable<String>(typeName);
    map['total_count'] = Variable<int>(totalCount);
    map['has_next'] = Variable<bool>(hasNext);
    map['pokemon_ids_json'] = Variable<String>(pokemonIdsJson);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  PokemonPageEntriesCompanion toCompanion(bool nullToAbsent) {
    return PokemonPageEntriesCompanion(
      pageLimit: Value(pageLimit),
      pageOffset: Value(pageOffset),
      typeName: Value(typeName),
      totalCount: Value(totalCount),
      hasNext: Value(hasNext),
      pokemonIdsJson: Value(pokemonIdsJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory PokemonPageEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonPageEntry(
      pageLimit: serializer.fromJson<int>(json['pageLimit']),
      pageOffset: serializer.fromJson<int>(json['pageOffset']),
      typeName: serializer.fromJson<String>(json['typeName']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      hasNext: serializer.fromJson<bool>(json['hasNext']),
      pokemonIdsJson: serializer.fromJson<String>(json['pokemonIdsJson']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pageLimit': serializer.toJson<int>(pageLimit),
      'pageOffset': serializer.toJson<int>(pageOffset),
      'typeName': serializer.toJson<String>(typeName),
      'totalCount': serializer.toJson<int>(totalCount),
      'hasNext': serializer.toJson<bool>(hasNext),
      'pokemonIdsJson': serializer.toJson<String>(pokemonIdsJson),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  PokemonPageEntry copyWith({
    int? pageLimit,
    int? pageOffset,
    String? typeName,
    int? totalCount,
    bool? hasNext,
    String? pokemonIdsJson,
    int? cachedAt,
  }) => PokemonPageEntry(
    pageLimit: pageLimit ?? this.pageLimit,
    pageOffset: pageOffset ?? this.pageOffset,
    typeName: typeName ?? this.typeName,
    totalCount: totalCount ?? this.totalCount,
    hasNext: hasNext ?? this.hasNext,
    pokemonIdsJson: pokemonIdsJson ?? this.pokemonIdsJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  PokemonPageEntry copyWithCompanion(PokemonPageEntriesCompanion data) {
    return PokemonPageEntry(
      pageLimit: data.pageLimit.present ? data.pageLimit.value : this.pageLimit,
      pageOffset: data.pageOffset.present
          ? data.pageOffset.value
          : this.pageOffset,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      hasNext: data.hasNext.present ? data.hasNext.value : this.hasNext,
      pokemonIdsJson: data.pokemonIdsJson.present
          ? data.pokemonIdsJson.value
          : this.pokemonIdsJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonPageEntry(')
          ..write('pageLimit: $pageLimit, ')
          ..write('pageOffset: $pageOffset, ')
          ..write('typeName: $typeName, ')
          ..write('totalCount: $totalCount, ')
          ..write('hasNext: $hasNext, ')
          ..write('pokemonIdsJson: $pokemonIdsJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pageLimit,
    pageOffset,
    typeName,
    totalCount,
    hasNext,
    pokemonIdsJson,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonPageEntry &&
          other.pageLimit == this.pageLimit &&
          other.pageOffset == this.pageOffset &&
          other.typeName == this.typeName &&
          other.totalCount == this.totalCount &&
          other.hasNext == this.hasNext &&
          other.pokemonIdsJson == this.pokemonIdsJson &&
          other.cachedAt == this.cachedAt);
}

class PokemonPageEntriesCompanion extends UpdateCompanion<PokemonPageEntry> {
  final Value<int> pageLimit;
  final Value<int> pageOffset;
  final Value<String> typeName;
  final Value<int> totalCount;
  final Value<bool> hasNext;
  final Value<String> pokemonIdsJson;
  final Value<int> cachedAt;
  final Value<int> rowid;
  const PokemonPageEntriesCompanion({
    this.pageLimit = const Value.absent(),
    this.pageOffset = const Value.absent(),
    this.typeName = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.hasNext = const Value.absent(),
    this.pokemonIdsJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonPageEntriesCompanion.insert({
    required int pageLimit,
    required int pageOffset,
    this.typeName = const Value.absent(),
    required int totalCount,
    required bool hasNext,
    required String pokemonIdsJson,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pageLimit = Value(pageLimit),
       pageOffset = Value(pageOffset),
       totalCount = Value(totalCount),
       hasNext = Value(hasNext),
       pokemonIdsJson = Value(pokemonIdsJson);
  static Insertable<PokemonPageEntry> custom({
    Expression<int>? pageLimit,
    Expression<int>? pageOffset,
    Expression<String>? typeName,
    Expression<int>? totalCount,
    Expression<bool>? hasNext,
    Expression<String>? pokemonIdsJson,
    Expression<int>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pageLimit != null) 'page_limit': pageLimit,
      if (pageOffset != null) 'page_offset': pageOffset,
      if (typeName != null) 'type_name': typeName,
      if (totalCount != null) 'total_count': totalCount,
      if (hasNext != null) 'has_next': hasNext,
      if (pokemonIdsJson != null) 'pokemon_ids_json': pokemonIdsJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonPageEntriesCompanion copyWith({
    Value<int>? pageLimit,
    Value<int>? pageOffset,
    Value<String>? typeName,
    Value<int>? totalCount,
    Value<bool>? hasNext,
    Value<String>? pokemonIdsJson,
    Value<int>? cachedAt,
    Value<int>? rowid,
  }) {
    return PokemonPageEntriesCompanion(
      pageLimit: pageLimit ?? this.pageLimit,
      pageOffset: pageOffset ?? this.pageOffset,
      typeName: typeName ?? this.typeName,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      pokemonIdsJson: pokemonIdsJson ?? this.pokemonIdsJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pageLimit.present) {
      map['page_limit'] = Variable<int>(pageLimit.value);
    }
    if (pageOffset.present) {
      map['page_offset'] = Variable<int>(pageOffset.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (hasNext.present) {
      map['has_next'] = Variable<bool>(hasNext.value);
    }
    if (pokemonIdsJson.present) {
      map['pokemon_ids_json'] = Variable<String>(pokemonIdsJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonPageEntriesCompanion(')
          ..write('pageLimit: $pageLimit, ')
          ..write('pageOffset: $pageOffset, ')
          ..write('typeName: $typeName, ')
          ..write('totalCount: $totalCount, ')
          ..write('hasNext: $hasNext, ')
          ..write('pokemonIdsJson: $pokemonIdsJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonEntriesTable pokemonEntries = $PokemonEntriesTable(this);
  late final $PokemonPageEntriesTable pokemonPageEntries =
      $PokemonPageEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pokemonEntries,
    pokemonPageEntries,
  ];
}

typedef $$PokemonEntriesTableCreateCompanionBuilder =
    PokemonEntriesCompanion Function({
      Value<int> id,
      required String name,
      required String imageUrl,
      required String typesJson,
      Value<int> cachedAt,
    });
typedef $$PokemonEntriesTableUpdateCompanionBuilder =
    PokemonEntriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> imageUrl,
      Value<String> typesJson,
      Value<int> cachedAt,
    });

class $$PokemonEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonEntriesTable> {
  $$PokemonEntriesTableFilterComposer({
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

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typesJson => $composableBuilder(
    column: $table.typesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PokemonEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonEntriesTable> {
  $$PokemonEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typesJson => $composableBuilder(
    column: $table.typesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonEntriesTable> {
  $$PokemonEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get typesJson =>
      $composableBuilder(column: $table.typesJson, builder: (column) => column);

  GeneratedColumn<int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$PokemonEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonEntriesTable,
          PokemonEntry,
          $$PokemonEntriesTableFilterComposer,
          $$PokemonEntriesTableOrderingComposer,
          $$PokemonEntriesTableAnnotationComposer,
          $$PokemonEntriesTableCreateCompanionBuilder,
          $$PokemonEntriesTableUpdateCompanionBuilder,
          (
            PokemonEntry,
            BaseReferences<_$AppDatabase, $PokemonEntriesTable, PokemonEntry>,
          ),
          PokemonEntry,
          PrefetchHooks Function()
        > {
  $$PokemonEntriesTableTableManager(
    _$AppDatabase db,
    $PokemonEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> typesJson = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
              }) => PokemonEntriesCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                typesJson: typesJson,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String imageUrl,
                required String typesJson,
                Value<int> cachedAt = const Value.absent(),
              }) => PokemonEntriesCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                typesJson: typesJson,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokemonEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonEntriesTable,
      PokemonEntry,
      $$PokemonEntriesTableFilterComposer,
      $$PokemonEntriesTableOrderingComposer,
      $$PokemonEntriesTableAnnotationComposer,
      $$PokemonEntriesTableCreateCompanionBuilder,
      $$PokemonEntriesTableUpdateCompanionBuilder,
      (
        PokemonEntry,
        BaseReferences<_$AppDatabase, $PokemonEntriesTable, PokemonEntry>,
      ),
      PokemonEntry,
      PrefetchHooks Function()
    >;
typedef $$PokemonPageEntriesTableCreateCompanionBuilder =
    PokemonPageEntriesCompanion Function({
      required int pageLimit,
      required int pageOffset,
      Value<String> typeName,
      required int totalCount,
      required bool hasNext,
      required String pokemonIdsJson,
      Value<int> cachedAt,
      Value<int> rowid,
    });
typedef $$PokemonPageEntriesTableUpdateCompanionBuilder =
    PokemonPageEntriesCompanion Function({
      Value<int> pageLimit,
      Value<int> pageOffset,
      Value<String> typeName,
      Value<int> totalCount,
      Value<bool> hasNext,
      Value<String> pokemonIdsJson,
      Value<int> cachedAt,
      Value<int> rowid,
    });

class $$PokemonPageEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonPageEntriesTable> {
  $$PokemonPageEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageLimit => $composableBuilder(
    column: $table.pageLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageOffset => $composableBuilder(
    column: $table.pageOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasNext => $composableBuilder(
    column: $table.hasNext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pokemonIdsJson => $composableBuilder(
    column: $table.pokemonIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PokemonPageEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonPageEntriesTable> {
  $$PokemonPageEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageLimit => $composableBuilder(
    column: $table.pageLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageOffset => $composableBuilder(
    column: $table.pageOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasNext => $composableBuilder(
    column: $table.hasNext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pokemonIdsJson => $composableBuilder(
    column: $table.pokemonIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonPageEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonPageEntriesTable> {
  $$PokemonPageEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageLimit =>
      $composableBuilder(column: $table.pageLimit, builder: (column) => column);

  GeneratedColumn<int> get pageOffset => $composableBuilder(
    column: $table.pageOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasNext =>
      $composableBuilder(column: $table.hasNext, builder: (column) => column);

  GeneratedColumn<String> get pokemonIdsJson => $composableBuilder(
    column: $table.pokemonIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$PokemonPageEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonPageEntriesTable,
          PokemonPageEntry,
          $$PokemonPageEntriesTableFilterComposer,
          $$PokemonPageEntriesTableOrderingComposer,
          $$PokemonPageEntriesTableAnnotationComposer,
          $$PokemonPageEntriesTableCreateCompanionBuilder,
          $$PokemonPageEntriesTableUpdateCompanionBuilder,
          (
            PokemonPageEntry,
            BaseReferences<
              _$AppDatabase,
              $PokemonPageEntriesTable,
              PokemonPageEntry
            >,
          ),
          PokemonPageEntry,
          PrefetchHooks Function()
        > {
  $$PokemonPageEntriesTableTableManager(
    _$AppDatabase db,
    $PokemonPageEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonPageEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonPageEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonPageEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> pageLimit = const Value.absent(),
                Value<int> pageOffset = const Value.absent(),
                Value<String> typeName = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<bool> hasNext = const Value.absent(),
                Value<String> pokemonIdsJson = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonPageEntriesCompanion(
                pageLimit: pageLimit,
                pageOffset: pageOffset,
                typeName: typeName,
                totalCount: totalCount,
                hasNext: hasNext,
                pokemonIdsJson: pokemonIdsJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int pageLimit,
                required int pageOffset,
                Value<String> typeName = const Value.absent(),
                required int totalCount,
                required bool hasNext,
                required String pokemonIdsJson,
                Value<int> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokemonPageEntriesCompanion.insert(
                pageLimit: pageLimit,
                pageOffset: pageOffset,
                typeName: typeName,
                totalCount: totalCount,
                hasNext: hasNext,
                pokemonIdsJson: pokemonIdsJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokemonPageEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonPageEntriesTable,
      PokemonPageEntry,
      $$PokemonPageEntriesTableFilterComposer,
      $$PokemonPageEntriesTableOrderingComposer,
      $$PokemonPageEntriesTableAnnotationComposer,
      $$PokemonPageEntriesTableCreateCompanionBuilder,
      $$PokemonPageEntriesTableUpdateCompanionBuilder,
      (
        PokemonPageEntry,
        BaseReferences<
          _$AppDatabase,
          $PokemonPageEntriesTable,
          PokemonPageEntry
        >,
      ),
      PokemonPageEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonEntriesTableTableManager get pokemonEntries =>
      $$PokemonEntriesTableTableManager(_db, _db.pokemonEntries);
  $$PokemonPageEntriesTableTableManager get pokemonPageEntries =>
      $$PokemonPageEntriesTableTableManager(_db, _db.pokemonPageEntries);
}
