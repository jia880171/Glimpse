// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlbumCollection on Isar {
  IsarCollection<Album> get albums => this.collection();
}

const AlbumSchema = CollectionSchema(
  name: r'Album',
  id: -1355968412107120937,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _albumEstimateSize,
  serialize: _albumSerialize,
  deserialize: _albumDeserialize,
  deserializeProp: _albumDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _albumGetId,
  getLinks: _albumGetLinks,
  attach: _albumAttach,
  version: '3.1.0+1',
);

int _albumEstimateSize(
  Album object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _albumSerialize(
  Album object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
}

Album _albumDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Album();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  return object;
}

P _albumDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _albumGetId(Album object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _albumGetLinks(Album object) {
  return [];
}

void _albumAttach(IsarCollection<dynamic> col, Id id, Album object) {
  object.id = id;
}

extension AlbumQueryWhereSort on QueryBuilder<Album, Album, QWhere> {
  QueryBuilder<Album, Album, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AlbumQueryWhere on QueryBuilder<Album, Album, QWhereClause> {
  QueryBuilder<Album, Album, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AlbumQueryFilter on QueryBuilder<Album, Album, QFilterCondition> {
  QueryBuilder<Album, Album, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Album, Album, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension AlbumQueryObject on QueryBuilder<Album, Album, QFilterCondition> {}

extension AlbumQueryLinks on QueryBuilder<Album, Album, QFilterCondition> {}

extension AlbumQuerySortBy on QueryBuilder<Album, Album, QSortBy> {
  QueryBuilder<Album, Album, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension AlbumQuerySortThenBy on QueryBuilder<Album, Album, QSortThenBy> {
  QueryBuilder<Album, Album, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Album, Album, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension AlbumQueryWhereDistinct on QueryBuilder<Album, Album, QDistinct> {
  QueryBuilder<Album, Album, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension AlbumQueryProperty on QueryBuilder<Album, Album, QQueryProperty> {
  QueryBuilder<Album, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Album, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFilmProfileCollection on Isar {
  IsarCollection<FilmProfile> get filmProfiles => this.collection();
}

const FilmProfileSchema = CollectionSchema(
  name: r'FilmProfile',
  id: -6793361071729483042,
  properties: {
    r'colorHex': PropertySchema(
      id: 0,
      name: r'colorHex',
      type: IsarType.long,
    ),
    r'filmFormat': PropertySchema(
      id: 1,
      name: r'filmFormat',
      type: IsarType.string,
    ),
    r'filmMaker': PropertySchema(
      id: 2,
      name: r'filmMaker',
      type: IsarType.string,
    ),
    r'filmName': PropertySchema(
      id: 3,
      name: r'filmName',
      type: IsarType.string,
    ),
    r'iso': PropertySchema(
      id: 4,
      name: r'iso',
      type: IsarType.string,
    )
  },
  estimateSize: _filmProfileEstimateSize,
  serialize: _filmProfileSerialize,
  deserialize: _filmProfileDeserialize,
  deserializeProp: _filmProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'albums': LinkSchema(
      id: 3592343059771773061,
      name: r'albums',
      target: r'Album',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _filmProfileGetId,
  getLinks: _filmProfileGetLinks,
  attach: _filmProfileAttach,
  version: '3.1.0+1',
);

int _filmProfileEstimateSize(
  FilmProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.filmFormat.length * 3;
  bytesCount += 3 + object.filmMaker.length * 3;
  bytesCount += 3 + object.filmName.length * 3;
  bytesCount += 3 + object.iso.length * 3;
  return bytesCount;
}

void _filmProfileSerialize(
  FilmProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorHex);
  writer.writeString(offsets[1], object.filmFormat);
  writer.writeString(offsets[2], object.filmMaker);
  writer.writeString(offsets[3], object.filmName);
  writer.writeString(offsets[4], object.iso);
}

FilmProfile _filmProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FilmProfile();
  object.colorHex = reader.readLong(offsets[0]);
  object.filmFormat = reader.readString(offsets[1]);
  object.filmMaker = reader.readString(offsets[2]);
  object.filmName = reader.readString(offsets[3]);
  object.id = id;
  object.iso = reader.readString(offsets[4]);
  return object;
}

P _filmProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _filmProfileGetId(FilmProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _filmProfileGetLinks(FilmProfile object) {
  return [object.albums];
}

void _filmProfileAttach(
    IsarCollection<dynamic> col, Id id, FilmProfile object) {
  object.id = id;
  object.albums.attach(col, col.isar.collection<Album>(), r'albums', id);
}

extension FilmProfileQueryWhereSort
    on QueryBuilder<FilmProfile, FilmProfile, QWhere> {
  QueryBuilder<FilmProfile, FilmProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FilmProfileQueryWhere
    on QueryBuilder<FilmProfile, FilmProfile, QWhereClause> {
  QueryBuilder<FilmProfile, FilmProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FilmProfileQueryFilter
    on QueryBuilder<FilmProfile, FilmProfile, QFilterCondition> {
  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> colorHexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: value,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      colorHexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorHex',
        value: value,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      colorHexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorHex',
        value: value,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> colorHexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filmFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filmFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filmFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filmFormat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filmFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filmFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filmFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filmFormat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filmFormat',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmFormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filmFormat',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filmMaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filmMaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filmMaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filmMaker',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filmMaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filmMaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filmMaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filmMaker',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filmMaker',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmMakerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filmMaker',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> filmNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filmName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filmName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filmName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> filmNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filmName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filmName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filmName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filmName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> filmNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filmName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filmName',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      filmNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filmName',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iso',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iso',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iso',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> isoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iso',
        value: '',
      ));
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      isoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iso',
        value: '',
      ));
    });
  }
}

extension FilmProfileQueryObject
    on QueryBuilder<FilmProfile, FilmProfile, QFilterCondition> {}

extension FilmProfileQueryLinks
    on QueryBuilder<FilmProfile, FilmProfile, QFilterCondition> {
  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition> albums(
      FilterQuery<Album> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'albums');
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      albumsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'albums', length, true, length, true);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      albumsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'albums', 0, true, 0, true);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      albumsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'albums', 0, false, 999999, true);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      albumsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'albums', 0, true, length, include);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      albumsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'albums', length, include, 999999, true);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterFilterCondition>
      albumsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'albums', lower, includeLower, upper, includeUpper);
    });
  }
}

extension FilmProfileQuerySortBy
    on QueryBuilder<FilmProfile, FilmProfile, QSortBy> {
  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByFilmFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmFormat', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByFilmFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmFormat', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByFilmMaker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmMaker', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByFilmMakerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmMaker', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByFilmName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmName', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByFilmNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmName', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> sortByIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.desc);
    });
  }
}

extension FilmProfileQuerySortThenBy
    on QueryBuilder<FilmProfile, FilmProfile, QSortThenBy> {
  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByFilmFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmFormat', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByFilmFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmFormat', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByFilmMaker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmMaker', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByFilmMakerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmMaker', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByFilmName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmName', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByFilmNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filmName', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.asc);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QAfterSortBy> thenByIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.desc);
    });
  }
}

extension FilmProfileQueryWhereDistinct
    on QueryBuilder<FilmProfile, FilmProfile, QDistinct> {
  QueryBuilder<FilmProfile, FilmProfile, QDistinct> distinctByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorHex');
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QDistinct> distinctByFilmFormat(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filmFormat', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QDistinct> distinctByFilmMaker(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filmMaker', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QDistinct> distinctByFilmName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filmName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FilmProfile, FilmProfile, QDistinct> distinctByIso(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iso', caseSensitive: caseSensitive);
    });
  }
}

extension FilmProfileQueryProperty
    on QueryBuilder<FilmProfile, FilmProfile, QQueryProperty> {
  QueryBuilder<FilmProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FilmProfile, int, QQueryOperations> colorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorHex');
    });
  }

  QueryBuilder<FilmProfile, String, QQueryOperations> filmFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filmFormat');
    });
  }

  QueryBuilder<FilmProfile, String, QQueryOperations> filmMakerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filmMaker');
    });
  }

  QueryBuilder<FilmProfile, String, QQueryOperations> filmNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filmName');
    });
  }

  QueryBuilder<FilmProfile, String, QQueryOperations> isoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iso');
    });
  }
}
