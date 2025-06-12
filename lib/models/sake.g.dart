// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sake.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSakeCollection on Isar {
  IsarCollection<Sake> get sakes => this.collection();
}

const SakeSchema = CollectionSchema(
  name: r'Sake',
  id: 4353577288400262808,
  properties: {},
  estimateSize: _sakeEstimateSize,
  serialize: _sakeSerialize,
  deserialize: _sakeDeserialize,
  deserializeProp: _sakeDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'glimpses': LinkSchema(
      id: 3452739023382877882,
      name: r'glimpses',
      target: r'Glimpse',
      single: false,
    ),
    r'receipts': LinkSchema(
      id: 8107819638996915773,
      name: r'receipts',
      target: r'Receipt',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _sakeGetId,
  getLinks: _sakeGetLinks,
  attach: _sakeAttach,
  version: '3.1.0+1',
);

int _sakeEstimateSize(
  Sake object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _sakeSerialize(
  Sake object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {}
Sake _sakeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Sake();
  object.id = id;
  return object;
}

P _sakeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sakeGetId(Sake object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sakeGetLinks(Sake object) {
  return [object.glimpses, object.receipts];
}

void _sakeAttach(IsarCollection<dynamic> col, Id id, Sake object) {
  object.id = id;
  object.glimpses.attach(col, col.isar.collection<Glimpse>(), r'glimpses', id);
  object.receipts.attach(col, col.isar.collection<Receipt>(), r'receipts', id);
}

extension SakeQueryWhereSort on QueryBuilder<Sake, Sake, QWhere> {
  QueryBuilder<Sake, Sake, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SakeQueryWhere on QueryBuilder<Sake, Sake, QWhereClause> {
  QueryBuilder<Sake, Sake, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Sake, Sake, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Sake, Sake, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Sake, Sake, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Sake, Sake, QAfterWhereClause> idBetween(
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

extension SakeQueryFilter on QueryBuilder<Sake, Sake, QFilterCondition> {
  QueryBuilder<Sake, Sake, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Sake, Sake, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Sake, Sake, QAfterFilterCondition> idBetween(
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
}

extension SakeQueryObject on QueryBuilder<Sake, Sake, QFilterCondition> {}

extension SakeQueryLinks on QueryBuilder<Sake, Sake, QFilterCondition> {
  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpses(
      FilterQuery<Glimpse> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'glimpses');
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpsesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', length, true, length, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpsesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', 0, true, 0, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpsesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', 0, false, 999999, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpsesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', 0, true, length, include);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpsesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', length, include, 999999, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> glimpsesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'glimpses', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receipts(
      FilterQuery<Receipt> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'receipts');
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receiptsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'receipts', length, true, length, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receiptsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'receipts', 0, true, 0, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receiptsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'receipts', 0, false, 999999, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receiptsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'receipts', 0, true, length, include);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receiptsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'receipts', length, include, 999999, true);
    });
  }

  QueryBuilder<Sake, Sake, QAfterFilterCondition> receiptsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'receipts', lower, includeLower, upper, includeUpper);
    });
  }
}

extension SakeQuerySortBy on QueryBuilder<Sake, Sake, QSortBy> {}

extension SakeQuerySortThenBy on QueryBuilder<Sake, Sake, QSortThenBy> {
  QueryBuilder<Sake, Sake, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Sake, Sake, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension SakeQueryWhereDistinct on QueryBuilder<Sake, Sake, QDistinct> {}

extension SakeQueryProperty on QueryBuilder<Sake, Sake, QQueryProperty> {
  QueryBuilder<Sake, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }
}
