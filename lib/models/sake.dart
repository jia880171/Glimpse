import 'package:isar/isar.dart';
import 'package:glimpse/models/receipt.dart';
import 'package:glimpse/models/glimpse.dart';

part 'sake.g.dart';


@collection
class Sake {
  Id id = Isar.autoIncrement;

  final glimpses = IsarLinks<Glimpse>(); // one to many
  final receipts = IsarLinks<Receipt>();
}