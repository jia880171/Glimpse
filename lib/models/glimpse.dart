import 'package:isar/isar.dart';
import 'food.dart';
import 'place.dart';

part 'glimpse.g.dart';

@collection
class Glimpse {
  Id id = Isar.autoIncrement;

  late String photoPath;
  DateTime? exifDateTime;
  DateTime createdAt = DateTime.now();

  final foods = IsarLinks<Food>();
  final places = IsarLinks<Place>();
// final sakes = IsarLinks<Sake>();

}