import 'package:isar/isar.dart';
import 'package:glimpse/models/receipt.dart';
import 'package:glimpse/models/glimpse.dart';

part 'food.g.dart';


@collection
class Food {
  Id id = Isar.autoIncrement;

  final glimpses = IsarLinks<Glimpse>();
  final receipts = IsarLinks<Receipt>();
}