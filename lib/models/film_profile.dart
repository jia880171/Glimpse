import 'package:isar/isar.dart';

part 'film_profile.g.dart';

@collection
class Album {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;
}

@collection
class FilmProfile {
  Id id = Isar.autoIncrement;

  late String iso;
  late String filmFormat;
  late String filmMaker;
  late String filmName;
  late int colorHex;

  /// 關聯的相簿
  final albums = IsarLinks<Album>();
}