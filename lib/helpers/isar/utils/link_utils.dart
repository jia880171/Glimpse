import 'package:isar/isar.dart';

class LinkUtils {
  static Future<void> clearIsarLinks<T>(IsarLinks<T> links) async {
    await links.load();

    final oldItems = links.toList();
    links.removeAll(oldItems);

    await links.save();
  }

  static Future<void> replaceIsarLinks<T>(
    IsarLinks<T> links,
    List<T> newItems,
  ) async {
    if (!links.isLoaded) {
      await links.load();
    }

    await clearIsarLinks(links);

    links.addAll(newItems);
    await links.save();
  }
}
