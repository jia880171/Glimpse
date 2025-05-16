import 'package:isar/isar.dart';
import 'glimpse.dart';

part 'food.g.dart';


@collection
class Food {
  Id id = Isar.autoIncrement;

  String name = '';
  double price = 0;

  final glimpse = IsarLink<Glimpse>();
  // one to one
}