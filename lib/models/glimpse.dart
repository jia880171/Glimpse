import 'package:glimpse/models/food.dart';
import 'package:glimpse/models/place.dart';
import 'package:glimpse/models/receipt.dart';
import 'package:glimpse/models/sake.dart';
import 'package:isar/isar.dart';

part 'glimpse.g.dart';

@collection
class Glimpse {
  Id id = Isar.autoIncrement;

  @Index()
  late String photoPath;

  @Index()
  late String? imageMake; // 品牌

  @Index()
  late String? cameraModel; // 機型

  @Index()
  late String? lensModel;

  @Index()
  late String? shutterSpeed;

  @Index()
  late String? aperture;

  @Index()
  late String? iso;

  @Index()
  late DateTime? exifDateTime;

  @Index()
  late String? scannedImagePath;

  @Index()
  late String? addressCountry;

  @Index()
  late String? addressPrefecture; // 東京都

  @Index()
  late String? addressCity; // 大田区

  @Index()
  late String? addressPlaceName;

  DateTime createdAt = DateTime.now();

  final receipt = IsarLink<Receipt>(); // to one
  final places = IsarLink<Place>(); // to one

  final foods = IsarLinks<Food>(); // to many
  final sakes = IsarLinks<Sake>();
}
