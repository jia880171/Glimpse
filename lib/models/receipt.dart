import 'package:isar/isar.dart';
import 'package:glimpse/models/sake.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/models/food.dart';

part 'receipt.g.dart';


@collection
class Receipt {
  Id id = Isar.autoIncrement;

  final glimpses = IsarLinks<Glimpse>(); // 雙向一對多
  final sakes = IsarLinks<Sake>();       // 多對多
  final foods = IsarLinks<Food>();       // 多對多
}