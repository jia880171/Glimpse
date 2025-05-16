// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glimpse.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGlimpseCollection on Isar {
  IsarCollection<Glimpse> get glimpses => this.collection();
}

const GlimpseSchema = CollectionSchema(
  name: r'Glimpse',
  id: 2710175939067173246,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'exifDateTime': PropertySchema(
      id: 1,
      name: r'exifDateTime',
      type: IsarType.dateTime,
    ),
    r'photoPath': PropertySchema(
      id: 2,
      name: r'photoPath',
      type: IsarType.string,
    )
  },
  estimateSize: _glimpseEstimateSize,
  serialize: _glimpseSerialize,
  deserialize: _glimpseDeserialize,
  deserializeProp: _glimpseDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'foods': LinkSchema(
      id: 3797584649319495282,
      name: r'foods',
      target: r'Food',
      single: false,
    ),
    r'places': LinkSchema(
      id: -3758241761208682463,
      name: r'places',
      target: r'Place',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _glimpseGetId,
  getLinks: _glimpseGetLinks,
  attach: _glimpseAttach,
  version: '3.1.0+1',
);

int _glimpseEstimateSize(
  Glimpse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.photoPath.length * 3;
  return bytesCount;
}

void _glimpseSerialize(
  Glimpse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.exifDateTime);
  writer.writeString(offsets[2], object.photoPath);
}

Glimpse _glimpseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Glimpse();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.exifDateTime = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.photoPath = reader.readString(offsets[2]);
  return object;
}

P _glimpseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _glimpseGetId(Glimpse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _glimpseGetLinks(Glimpse object) {
  return [object.foods, object.places];
}

void _glimpseAttach(IsarCollection<dynamic> col, Id id, Glimpse object) {
  object.id = id;
  object.foods.attach(col, col.isar.collection<Food>(), r'foods', id);
  object.places.attach(col, col.isar.collection<Place>(), r'places', id);
}

extension GlimpseQueryWhereSort on QueryBuilder<Glimpse, Glimpse, QWhere> {
  QueryBuilder<Glimpse, Glimpse, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GlimpseQueryWhere on QueryBuilder<Glimpse, Glimpse, QWhereClause> {
  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> idBetween(
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

extension GlimpseQueryFilter
    on QueryBuilder<Glimpse, Glimpse, QFilterCondition> {
  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> exifDateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'exifDateTime',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      exifDateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'exifDateTime',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> exifDateTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exifDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> exifDateTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exifDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> exifDateTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exifDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> exifDateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exifDateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPath',
        value: '',
      ));
    });
  }
}

extension GlimpseQueryObject
    on QueryBuilder<Glimpse, Glimpse, QFilterCondition> {}

extension GlimpseQueryLinks
    on QueryBuilder<Glimpse, Glimpse, QFilterCondition> {
  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foods(
      FilterQuery<Food> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'foods');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foodsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', length, true, length, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', 0, true, 0, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', 0, false, 999999, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', 0, true, length, include);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', length, include, 999999, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> foodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'foods', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> places(
      FilterQuery<Place> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'places');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'places', length, true, length, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'places', 0, true, 0, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'places', 0, false, 999999, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'places', 0, true, length, include);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'places', length, include, 999999, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'places', lower, includeLower, upper, includeUpper);
    });
  }
}

extension GlimpseQuerySortBy on QueryBuilder<Glimpse, Glimpse, QSortBy> {
  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByExifDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exifDateTime', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByExifDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exifDateTime', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }
}

extension GlimpseQuerySortThenBy
    on QueryBuilder<Glimpse, Glimpse, QSortThenBy> {
  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByExifDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exifDateTime', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByExifDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exifDateTime', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }
}

extension GlimpseQueryWhereDistinct
    on QueryBuilder<Glimpse, Glimpse, QDistinct> {
  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByExifDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exifDateTime');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }
}

extension GlimpseQueryProperty
    on QueryBuilder<Glimpse, Glimpse, QQueryProperty> {
  QueryBuilder<Glimpse, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Glimpse, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Glimpse, DateTime?, QQueryOperations> exifDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exifDateTime');
    });
  }

  QueryBuilder<Glimpse, String, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }
}
