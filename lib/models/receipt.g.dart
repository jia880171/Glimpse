// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReceiptCollection on Isar {
  IsarCollection<Receipt> get receipts => this.collection();
}

const ReceiptSchema = CollectionSchema(
  name: r'Receipt',
  id: 4668855833497531014,
  properties: {},
  estimateSize: _receiptEstimateSize,
  serialize: _receiptSerialize,
  deserialize: _receiptDeserialize,
  deserializeProp: _receiptDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'glimpses': LinkSchema(
      id: -2824808761896988014,
      name: r'glimpses',
      target: r'Glimpse',
      single: false,
    ),
    r'sakes': LinkSchema(
      id: 540679964089399214,
      name: r'sakes',
      target: r'Sake',
      single: false,
    ),
    r'foods': LinkSchema(
      id: -624767104123254093,
      name: r'foods',
      target: r'Food',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _receiptGetId,
  getLinks: _receiptGetLinks,
  attach: _receiptAttach,
  version: '3.1.0+1',
);

int _receiptEstimateSize(
  Receipt object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _receiptSerialize(
  Receipt object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {}
Receipt _receiptDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Receipt();
  object.id = id;
  return object;
}

P _receiptDeserializeProp<P>(
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

Id _receiptGetId(Receipt object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _receiptGetLinks(Receipt object) {
  return [object.glimpses, object.sakes, object.foods];
}

void _receiptAttach(IsarCollection<dynamic> col, Id id, Receipt object) {
  object.id = id;
  object.glimpses.attach(col, col.isar.collection<Glimpse>(), r'glimpses', id);
  object.sakes.attach(col, col.isar.collection<Sake>(), r'sakes', id);
  object.foods.attach(col, col.isar.collection<Food>(), r'foods', id);
}

extension ReceiptQueryWhereSort on QueryBuilder<Receipt, Receipt, QWhere> {
  QueryBuilder<Receipt, Receipt, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReceiptQueryWhere on QueryBuilder<Receipt, Receipt, QWhereClause> {
  QueryBuilder<Receipt, Receipt, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Receipt, Receipt, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterWhereClause> idBetween(
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

extension ReceiptQueryFilter
    on QueryBuilder<Receipt, Receipt, QFilterCondition> {
  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> idBetween(
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

extension ReceiptQueryObject
    on QueryBuilder<Receipt, Receipt, QFilterCondition> {}

extension ReceiptQueryLinks
    on QueryBuilder<Receipt, Receipt, QFilterCondition> {
  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> glimpses(
      FilterQuery<Glimpse> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'glimpses');
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> glimpsesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', length, true, length, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> glimpsesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', 0, true, 0, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> glimpsesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', 0, false, 999999, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> glimpsesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', 0, true, length, include);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition>
      glimpsesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'glimpses', length, include, 999999, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> glimpsesLengthBetween(
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

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakes(
      FilterQuery<Sake> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'sakes');
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', length, true, length, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', 0, true, 0, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', 0, false, 999999, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', 0, true, length, include);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', length, include, 999999, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> sakesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'sakes', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foods(
      FilterQuery<Food> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'foods');
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foodsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', length, true, length, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', 0, true, 0, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', 0, false, 999999, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', 0, true, length, include);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'foods', length, include, 999999, true);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterFilterCondition> foodsLengthBetween(
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
}

extension ReceiptQuerySortBy on QueryBuilder<Receipt, Receipt, QSortBy> {}

extension ReceiptQuerySortThenBy
    on QueryBuilder<Receipt, Receipt, QSortThenBy> {
  QueryBuilder<Receipt, Receipt, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Receipt, Receipt, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension ReceiptQueryWhereDistinct
    on QueryBuilder<Receipt, Receipt, QDistinct> {}

extension ReceiptQueryProperty
    on QueryBuilder<Receipt, Receipt, QQueryProperty> {
  QueryBuilder<Receipt, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }
}
