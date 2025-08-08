import 'package:isar/isar.dart';

part 'friend.g.dart';

@collection
class Friend {
  Id id = Isar.autoIncrement;

  late String name;
}
