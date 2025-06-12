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
    r'addressCity': PropertySchema(
      id: 0,
      name: r'addressCity',
      type: IsarType.string,
    ),
    r'addressCountry': PropertySchema(
      id: 1,
      name: r'addressCountry',
      type: IsarType.string,
    ),
    r'addressPlaceName': PropertySchema(
      id: 2,
      name: r'addressPlaceName',
      type: IsarType.string,
    ),
    r'addressPrefecture': PropertySchema(
      id: 3,
      name: r'addressPrefecture',
      type: IsarType.string,
    ),
    r'aperture': PropertySchema(
      id: 4,
      name: r'aperture',
      type: IsarType.string,
    ),
    r'cameraModel': PropertySchema(
      id: 5,
      name: r'cameraModel',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'exifDateTime': PropertySchema(
      id: 7,
      name: r'exifDateTime',
      type: IsarType.dateTime,
    ),
    r'imageMake': PropertySchema(
      id: 8,
      name: r'imageMake',
      type: IsarType.string,
    ),
    r'iso': PropertySchema(
      id: 9,
      name: r'iso',
      type: IsarType.string,
    ),
    r'lensModel': PropertySchema(
      id: 10,
      name: r'lensModel',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 11,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'shutterSpeed': PropertySchema(
      id: 12,
      name: r'shutterSpeed',
      type: IsarType.string,
    )
  },
  estimateSize: _glimpseEstimateSize,
  serialize: _glimpseSerialize,
  deserialize: _glimpseDeserialize,
  deserializeProp: _glimpseDeserializeProp,
  idName: r'id',
  indexes: {
    r'photoPath': IndexSchema(
      id: -437682390136811041,
      name: r'photoPath',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'photoPath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'imageMake': IndexSchema(
      id: 638749352550386376,
      name: r'imageMake',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'imageMake',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'cameraModel': IndexSchema(
      id: 4079103721968099864,
      name: r'cameraModel',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cameraModel',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lensModel': IndexSchema(
      id: 8107627808045238697,
      name: r'lensModel',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lensModel',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'shutterSpeed': IndexSchema(
      id: 5103937410283137651,
      name: r'shutterSpeed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'shutterSpeed',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'aperture': IndexSchema(
      id: 2110303652207027588,
      name: r'aperture',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'aperture',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'iso': IndexSchema(
      id: 4614595676463488954,
      name: r'iso',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'iso',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'exifDateTime': IndexSchema(
      id: 4713273560676753964,
      name: r'exifDateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'exifDateTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'addressCountry': IndexSchema(
      id: -8246481092274961015,
      name: r'addressCountry',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addressCountry',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'addressPrefecture': IndexSchema(
      id: -276181977059129264,
      name: r'addressPrefecture',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addressPrefecture',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'addressCity': IndexSchema(
      id: -2294153268076752966,
      name: r'addressCity',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addressCity',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'addressPlaceName': IndexSchema(
      id: 2324194532555771886,
      name: r'addressPlaceName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addressPlaceName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'receipt': LinkSchema(
      id: 169521257082859721,
      name: r'receipt',
      target: r'Receipt',
      single: true,
    ),
    r'places': LinkSchema(
      id: -3758241761208682463,
      name: r'places',
      target: r'Place',
      single: true,
    ),
    r'foods': LinkSchema(
      id: 3797584649319495282,
      name: r'foods',
      target: r'Food',
      single: false,
    ),
    r'sakes': LinkSchema(
      id: -3101650219616807570,
      name: r'sakes',
      target: r'Sake',
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
  {
    final value = object.addressCity;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.addressCountry;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.addressPlaceName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.addressPrefecture;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aperture;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cameraModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageMake;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.iso;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lensModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.photoPath.length * 3;
  {
    final value = object.shutterSpeed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _glimpseSerialize(
  Glimpse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.addressCity);
  writer.writeString(offsets[1], object.addressCountry);
  writer.writeString(offsets[2], object.addressPlaceName);
  writer.writeString(offsets[3], object.addressPrefecture);
  writer.writeString(offsets[4], object.aperture);
  writer.writeString(offsets[5], object.cameraModel);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeDateTime(offsets[7], object.exifDateTime);
  writer.writeString(offsets[8], object.imageMake);
  writer.writeString(offsets[9], object.iso);
  writer.writeString(offsets[10], object.lensModel);
  writer.writeString(offsets[11], object.photoPath);
  writer.writeString(offsets[12], object.shutterSpeed);
}

Glimpse _glimpseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Glimpse();
  object.addressCity = reader.readStringOrNull(offsets[0]);
  object.addressCountry = reader.readStringOrNull(offsets[1]);
  object.addressPlaceName = reader.readStringOrNull(offsets[2]);
  object.addressPrefecture = reader.readStringOrNull(offsets[3]);
  object.aperture = reader.readStringOrNull(offsets[4]);
  object.cameraModel = reader.readStringOrNull(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.exifDateTime = reader.readDateTimeOrNull(offsets[7]);
  object.id = id;
  object.imageMake = reader.readStringOrNull(offsets[8]);
  object.iso = reader.readStringOrNull(offsets[9]);
  object.lensModel = reader.readStringOrNull(offsets[10]);
  object.photoPath = reader.readString(offsets[11]);
  object.shutterSpeed = reader.readStringOrNull(offsets[12]);
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
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _glimpseGetId(Glimpse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _glimpseGetLinks(Glimpse object) {
  return [object.receipt, object.places, object.foods, object.sakes];
}

void _glimpseAttach(IsarCollection<dynamic> col, Id id, Glimpse object) {
  object.id = id;
  object.receipt.attach(col, col.isar.collection<Receipt>(), r'receipt', id);
  object.places.attach(col, col.isar.collection<Place>(), r'places', id);
  object.foods.attach(col, col.isar.collection<Food>(), r'foods', id);
  object.sakes.attach(col, col.isar.collection<Sake>(), r'sakes', id);
}

extension GlimpseQueryWhereSort on QueryBuilder<Glimpse, Glimpse, QWhere> {
  QueryBuilder<Glimpse, Glimpse, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhere> anyExifDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'exifDateTime'),
      );
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

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> photoPathEqualTo(
      String photoPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'photoPath',
        value: [photoPath],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> photoPathNotEqualTo(
      String photoPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'photoPath',
              lower: [],
              upper: [photoPath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'photoPath',
              lower: [photoPath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'photoPath',
              lower: [photoPath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'photoPath',
              lower: [],
              upper: [photoPath],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> imageMakeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'imageMake',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> imageMakeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'imageMake',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> imageMakeEqualTo(
      String? imageMake) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'imageMake',
        value: [imageMake],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> imageMakeNotEqualTo(
      String? imageMake) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'imageMake',
              lower: [],
              upper: [imageMake],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'imageMake',
              lower: [imageMake],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'imageMake',
              lower: [imageMake],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'imageMake',
              lower: [],
              upper: [imageMake],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> cameraModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cameraModel',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> cameraModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'cameraModel',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> cameraModelEqualTo(
      String? cameraModel) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cameraModel',
        value: [cameraModel],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> cameraModelNotEqualTo(
      String? cameraModel) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cameraModel',
              lower: [],
              upper: [cameraModel],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cameraModel',
              lower: [cameraModel],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cameraModel',
              lower: [cameraModel],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cameraModel',
              lower: [],
              upper: [cameraModel],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> lensModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lensModel',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> lensModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lensModel',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> lensModelEqualTo(
      String? lensModel) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lensModel',
        value: [lensModel],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> lensModelNotEqualTo(
      String? lensModel) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lensModel',
              lower: [],
              upper: [lensModel],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lensModel',
              lower: [lensModel],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lensModel',
              lower: [lensModel],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lensModel',
              lower: [],
              upper: [lensModel],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> shutterSpeedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'shutterSpeed',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> shutterSpeedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shutterSpeed',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> shutterSpeedEqualTo(
      String? shutterSpeed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'shutterSpeed',
        value: [shutterSpeed],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> shutterSpeedNotEqualTo(
      String? shutterSpeed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shutterSpeed',
              lower: [],
              upper: [shutterSpeed],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shutterSpeed',
              lower: [shutterSpeed],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shutterSpeed',
              lower: [shutterSpeed],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shutterSpeed',
              lower: [],
              upper: [shutterSpeed],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> apertureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'aperture',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> apertureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'aperture',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> apertureEqualTo(
      String? aperture) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'aperture',
        value: [aperture],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> apertureNotEqualTo(
      String? aperture) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'aperture',
              lower: [],
              upper: [aperture],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'aperture',
              lower: [aperture],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'aperture',
              lower: [aperture],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'aperture',
              lower: [],
              upper: [aperture],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> isoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'iso',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> isoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'iso',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> isoEqualTo(String? iso) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'iso',
        value: [iso],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> isoNotEqualTo(String? iso) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso',
              lower: [],
              upper: [iso],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso',
              lower: [iso],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso',
              lower: [iso],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso',
              lower: [],
              upper: [iso],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exifDateTime',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exifDateTime',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeEqualTo(
      DateTime? exifDateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exifDateTime',
        value: [exifDateTime],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeNotEqualTo(
      DateTime? exifDateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exifDateTime',
              lower: [],
              upper: [exifDateTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exifDateTime',
              lower: [exifDateTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exifDateTime',
              lower: [exifDateTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exifDateTime',
              lower: [],
              upper: [exifDateTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeGreaterThan(
    DateTime? exifDateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exifDateTime',
        lower: [exifDateTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeLessThan(
    DateTime? exifDateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exifDateTime',
        lower: [],
        upper: [exifDateTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> exifDateTimeBetween(
    DateTime? lowerExifDateTime,
    DateTime? upperExifDateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exifDateTime',
        lower: [lowerExifDateTime],
        includeLower: includeLower,
        upper: [upperExifDateTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCountryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressCountry',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCountryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addressCountry',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCountryEqualTo(
      String? addressCountry) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressCountry',
        value: [addressCountry],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCountryNotEqualTo(
      String? addressCountry) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCountry',
              lower: [],
              upper: [addressCountry],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCountry',
              lower: [addressCountry],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCountry',
              lower: [addressCountry],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCountry',
              lower: [],
              upper: [addressCountry],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressPrefectureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressPrefecture',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause>
      addressPrefectureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addressPrefecture',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressPrefectureEqualTo(
      String? addressPrefecture) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressPrefecture',
        value: [addressPrefecture],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressPrefectureNotEqualTo(
      String? addressPrefecture) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPrefecture',
              lower: [],
              upper: [addressPrefecture],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPrefecture',
              lower: [addressPrefecture],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPrefecture',
              lower: [addressPrefecture],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPrefecture',
              lower: [],
              upper: [addressPrefecture],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressCity',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addressCity',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCityEqualTo(
      String? addressCity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressCity',
        value: [addressCity],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressCityNotEqualTo(
      String? addressCity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCity',
              lower: [],
              upper: [addressCity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCity',
              lower: [addressCity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCity',
              lower: [addressCity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressCity',
              lower: [],
              upper: [addressCity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressPlaceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressPlaceName',
        value: [null],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause>
      addressPlaceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addressPlaceName',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressPlaceNameEqualTo(
      String? addressPlaceName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addressPlaceName',
        value: [addressPlaceName],
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterWhereClause> addressPlaceNameNotEqualTo(
      String? addressPlaceName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPlaceName',
              lower: [],
              upper: [addressPlaceName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPlaceName',
              lower: [addressPlaceName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPlaceName',
              lower: [addressPlaceName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addressPlaceName',
              lower: [],
              upper: [addressPlaceName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GlimpseQueryFilter
    on QueryBuilder<Glimpse, Glimpse, QFilterCondition> {
  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addressCity',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addressCity',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressCity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addressCity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addressCity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addressCity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addressCity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addressCity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addressCity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addressCity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressCity',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressCityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addressCity',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addressCountry',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressCountryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addressCountry',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressCountry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressCountryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addressCountry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addressCountry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addressCountry',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressCountryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addressCountry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addressCountry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addressCountry',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressCountryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addressCountry',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressCountryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressCountry',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressCountryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addressCountry',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addressPlaceName',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addressPlaceName',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressPlaceNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressPlaceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addressPlaceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addressPlaceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressPlaceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addressPlaceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addressPlaceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addressPlaceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addressPlaceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> addressPlaceNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addressPlaceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressPlaceName',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPlaceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addressPlaceName',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addressPrefecture',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addressPrefecture',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressPrefecture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addressPrefecture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addressPrefecture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addressPrefecture',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addressPrefecture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addressPrefecture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addressPrefecture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addressPrefecture',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressPrefecture',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      addressPrefectureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addressPrefecture',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aperture',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aperture',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aperture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aperture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aperture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aperture',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aperture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aperture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aperture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aperture',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aperture',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> apertureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aperture',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cameraModel',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cameraModel',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cameraModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cameraModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cameraModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cameraModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cameraModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cameraModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cameraModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cameraModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> cameraModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cameraModel',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      cameraModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cameraModel',
        value: '',
      ));
    });
  }

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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageMake',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageMake',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageMake',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageMake',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageMake',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageMake',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageMake',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageMake',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageMake',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageMake',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageMake',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> imageMakeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageMake',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'iso',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'iso',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoEqualTo(
    String? value, {
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoGreaterThan(
    String? value, {
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoLessThan(
    String? value, {
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoStartsWith(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoEndsWith(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoContains(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoMatches(
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iso',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> isoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iso',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lensModel',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lensModel',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lensModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lensModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lensModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lensModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lensModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lensModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lensModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lensModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lensModel',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> lensModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lensModel',
        value: '',
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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shutterSpeed',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      shutterSpeedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shutterSpeed',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shutterSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shutterSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shutterSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shutterSpeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shutterSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shutterSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shutterSpeed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shutterSpeed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> shutterSpeedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shutterSpeed',
        value: '',
      ));
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition>
      shutterSpeedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shutterSpeed',
        value: '',
      ));
    });
  }
}

extension GlimpseQueryObject
    on QueryBuilder<Glimpse, Glimpse, QFilterCondition> {}

extension GlimpseQueryLinks
    on QueryBuilder<Glimpse, Glimpse, QFilterCondition> {
  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> receipt(
      FilterQuery<Receipt> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'receipt');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> receiptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'receipt', 0, true, 0, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> places(
      FilterQuery<Place> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'places');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> placesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'places', 0, true, 0, true);
    });
  }

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

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakes(
      FilterQuery<Sake> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'sakes');
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', length, true, length, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', 0, true, 0, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', 0, false, 999999, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', 0, true, length, include);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sakes', length, include, 999999, true);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterFilterCondition> sakesLengthBetween(
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
}

extension GlimpseQuerySortBy on QueryBuilder<Glimpse, Glimpse, QSortBy> {
  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCity', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCity', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCountry', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCountry', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressPlaceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPlaceName', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressPlaceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPlaceName', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressPrefecture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPrefecture', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAddressPrefectureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPrefecture', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByAperture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aperture', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByApertureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aperture', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByCameraModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cameraModel', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByCameraModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cameraModel', Sort.desc);
    });
  }

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

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByImageMake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageMake', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByImageMakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageMake', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByLensModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lensModel', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByLensModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lensModel', Sort.desc);
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

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByShutterSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shutterSpeed', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> sortByShutterSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shutterSpeed', Sort.desc);
    });
  }
}

extension GlimpseQuerySortThenBy
    on QueryBuilder<Glimpse, Glimpse, QSortThenBy> {
  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCity', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCity', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCountry', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressCountry', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressPlaceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPlaceName', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressPlaceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPlaceName', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressPrefecture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPrefecture', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAddressPrefectureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressPrefecture', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByAperture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aperture', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByApertureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aperture', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByCameraModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cameraModel', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByCameraModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cameraModel', Sort.desc);
    });
  }

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

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByImageMake() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageMake', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByImageMakeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageMake', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByIso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByIsoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso', Sort.desc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByLensModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lensModel', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByLensModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lensModel', Sort.desc);
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

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByShutterSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shutterSpeed', Sort.asc);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QAfterSortBy> thenByShutterSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shutterSpeed', Sort.desc);
    });
  }
}

extension GlimpseQueryWhereDistinct
    on QueryBuilder<Glimpse, Glimpse, QDistinct> {
  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByAddressCity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addressCity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByAddressCountry(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addressCountry',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByAddressPlaceName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addressPlaceName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByAddressPrefecture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addressPrefecture',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByAperture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aperture', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByCameraModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cameraModel', caseSensitive: caseSensitive);
    });
  }

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

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByImageMake(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageMake', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByIso(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iso', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByLensModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lensModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Glimpse, Glimpse, QDistinct> distinctByShutterSpeed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shutterSpeed', caseSensitive: caseSensitive);
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

  QueryBuilder<Glimpse, String?, QQueryOperations> addressCityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addressCity');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> addressCountryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addressCountry');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> addressPlaceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addressPlaceName');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> addressPrefectureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addressPrefecture');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> apertureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aperture');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> cameraModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cameraModel');
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

  QueryBuilder<Glimpse, String?, QQueryOperations> imageMakeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageMake');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> isoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iso');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> lensModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lensModel');
    });
  }

  QueryBuilder<Glimpse, String, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<Glimpse, String?, QQueryOperations> shutterSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shutterSpeed');
    });
  }
}
