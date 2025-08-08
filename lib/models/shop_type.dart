import 'package:isar/isar.dart';

import 'package:isar/isar.dart';

part 'shop_type.g.dart';

@collection
class ShopType {
  Id id = Isar.autoIncrement;

  late String name; // 例如：居酒屋、喫茶店、Bar
}