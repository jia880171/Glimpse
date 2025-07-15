import 'package:isar/isar.dart';

import '../models/glimpse.dart';

class GlimpseService {
  final Isar isar;

  GlimpseService(this.isar);

  /// Fetch all Glimpses
  Future<List<Glimpse>> getAllGlimpses() async {
    return await isar.glimpses.where().findAll();
  }

  /// Fetch Glimpses between two dates (inclusive)
  Future<List<Glimpse>> getGlimpsesBetween(DateTime startDay, DateTime endDay) async {
    return await isar.glimpses
        .filter()
        .createdAtGreaterThan(startDay.subtract(const Duration(seconds: 1)), include: true)
        .and()
        .createdAtLessThan(endDay.add(const Duration(seconds: 1)), include: true)
        .findAll();
  }

  /// Fetch Glimpses on a specific day
  Future<List<Glimpse>> getGlimpsesOnDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    return await isar.glimpses
        .filter()
        .createdAtBetween(start, end)
        .findAll();
  }


}
