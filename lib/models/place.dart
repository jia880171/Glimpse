import 'package:isar/isar.dart';
import 'glimpse.dart';

part 'place.g.dart';


@collection
class Place {
  Id id = Isar.autoIncrement;

  String country = ''; // Taiwan Japan
  String admin1 = ''; // Taipei Tokyo
  String admin2 = ''; // 內湖區 Ootaku
  String name = ''; // place name
  DateTime createAt = DateTime.now();

  final glimpse = IsarLinks<Glimpse>();
}