import 'package:isar/isar.dart';
import 'friend.dart';
part 'journal.g.dart';

@collection
class Journal {
  Id id = Isar.autoIncrement;

  /// 標題
  String? title;

  /// 長文內容
  String? content;

  /// 關聯的朋友，多對多
  final friends = IsarLinks<Friend>();

  /// 建立時間（可選，方便排序）
  DateTime createdAt = DateTime.now();
}
