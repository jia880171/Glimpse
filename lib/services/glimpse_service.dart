import 'dart:io';

import 'package:glimpse/helpers/isar/utils/link_utils.dart';
import 'package:isar/isar.dart';
import '../helpers/isar/links/glimpse_receipt_link_helper.dart';
import '../models/glimpse.dart';
import '../models/receipt.dart';

class GlimpseService {
  final Isar isar;

  GlimpseService(this.isar);

  /// Fetch all Glimpses
  Future<List<Glimpse>> getAllGlimpses() async {
    return await isar.glimpses.where().findAll();
  }

  /// Fetch all Glimpses with their linked data loaded
  Future<List<Glimpse>> getAllGlimpsesWithLinks() async {
    final glimpses = await isar.glimpses.where().findAll();

    for (final glimpse in glimpses) {
      await glimpse.receipt.load();
      final receipt = glimpse.receipt.value;

      if (receipt != null) {
        await receipt.shopType.load();
        await receipt.friends.load();
      }
    }

    return glimpses;
  }

  /// Fetch Glimpses between two dates (inclusive)
  Future<List<Glimpse>> getGlimpsesBetween(
      DateTime startDay, DateTime endDay) async {
    return await isar.glimpses
        .filter()
        .createdAtGreaterThan(startDay.subtract(const Duration(seconds: 1)),
            include: true)
        .and()
        .createdAtLessThan(endDay.add(const Duration(seconds: 1)),
            include: true)
        .findAll();
  }

  /// Fetch Glimpses on a specific day
  Future<List<Glimpse>> getGlimpsesOnDay(DateTime day) async {
    print('=======day: ${day}');
    final start = DateTime(day.year, day.month, day.day);
    print('=======start: ${start}');

    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    print('=======end: ${end}');

    return await isar.glimpses.filter().createdAtBetween(start, end).findAll();
  }

  Future<void> insertGlimpse({
    required Glimpse glimpse,
    Receipt? receipt,
  }) async {
    await isar.writeTxn(() async {
      // 儲存 Glimpse
      final glimpseId = await isar.glimpses.put(glimpse);
      final storedGlimpse = await isar.glimpses.get(glimpseId);

      if (receipt != null && storedGlimpse != null) {
        await isar.receipts.put(receipt);
        await receipt.shopType.save();
        await receipt.friends.save();
        await receipt.glimpses.save();

        // 雙向連結
        await GlimpseReceiptLinkHelper.link(storedGlimpse, receipt);

        // 儲存 Glimpse 的 Link
        await storedGlimpse.receipt.save();
      }
    });
  }

  Future<void> updateGlimpseWithLinks({
    required Glimpse glimpse,
    Receipt? receipt,
  }) async {
    await isar.writeTxn(() async {
      // 1. 更新 Glimpse
      await isar.glimpses.put(glimpse);

      if (receipt != null) {
        Receipt? storedReceipt;

        if (receipt.id > 0) {
          storedReceipt = await isar.receipts.get(receipt.id);
        }

        if (storedReceipt == null) {
          // 👇 新 receipt：直接建立
          await isar.receipts.put(receipt);
          await receipt.shopType.save();
          await receipt.friends.save();
          await receipt.glimpses.save();
          await GlimpseReceiptLinkHelper.link(glimpse, receipt);
          await glimpse.receipt.save();
        } else {
          // 👇 已存在：更新內容與 links
          storedReceipt.shopName = receipt.shopName;
          storedReceipt.totalCost = receipt.totalCost;
          storedReceipt.dateTime = receipt.dateTime;
          storedReceipt.shopType.value = receipt.shopType.value;

          await LinkUtils.replaceIsarLinks(
              storedReceipt.friends, receipt.friends.toList());

          await isar.receipts.put(storedReceipt);

          await storedReceipt.friends.save();
          await storedReceipt.shopType.save();
          await storedReceipt.glimpses.save();

          await GlimpseReceiptLinkHelper.link(glimpse, storedReceipt);
          await glimpse.receipt.save();
        }
      }
    });
  }

  Future<bool> isReceiptLinkedOnlyToThisGlimpse(Glimpse glimpse) async {
    await glimpse.receipt.load();
    final receipt = glimpse.receipt.value;

    if (receipt == null) {
      return false;
    }

    await receipt.glimpses.load();
    return receipt.glimpses.length == 1;
  }

  Future<void> deleteFileIfExists(String? path) async {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
          print('🗑️ Deleted file: $path');
        } catch (e) {
          print('⚠️ Failed to delete file at $path: $e');
        }
      }
    }
  }

  Future<void> deleteGlimpse(Glimpse glimpse) async {
    await isar.writeTxn(() async {
      await glimpse.receipt.load();
      final receipt = glimpse.receipt.value;

      // 從 receipt 的 glimpses 移除該 Glimpse
      if (receipt != null) {
        await receipt.glimpses.load();
        receipt.glimpses.removeWhere((g) => g.id == glimpse.id);
        await receipt.glimpses.save();
      }

      // 刪除掃描圖片
      await deleteFileIfExists(glimpse.scannedImagePath);

      // 刪除 Glimpse
      await isar.glimpses.delete(glimpse.id);
    });
  }

  Future<void> deleteGlimpseAndReceipt(Glimpse glimpse) async {
    await isar.writeTxn(() async {
      await glimpse.receipt.load();
      final receipt = glimpse.receipt.value;

      if (receipt != null) {
        final detachedGlimpses =
            await GlimpseReceiptLinkHelper.unlinkAllGlimpsesFromReceiptInMemory(
                receipt);

        for (final g in detachedGlimpses) {
          await g.receipt.save();
        }

        await receipt.glimpses.save();

        // 刪除 Receipt
        await isar.receipts.delete(receipt.id);
      }

      // 刪除掃描圖片
      await deleteFileIfExists(glimpse.scannedImagePath);

      // 刪除 Glimpse
      await isar.glimpses.delete(glimpse.id);
    });
  }

  Future<Glimpse?> getGlimpseWithLinks(int id) async {
    final glimpse = await isar.glimpses.get(id);
    if (glimpse == null) {
      return null;
    }

    // Receipt link
    await glimpse.receipt.load();
    final receipt = glimpse.receipt.value;
    if (receipt != null) {
      await receipt.shopType.load();
      await receipt.friends.load();
    }

    // Journal link
    await glimpse.journal.load();
    final journal = glimpse.journal.value;
    if (journal != null) {
      await journal.friends.load();
    }

    return glimpse;
  }

  Future<Glimpse?> getGlimpseByPhotoPath(String photoPath) async {
    final glimpse =
        await isar.glimpses.filter().photoPathEqualTo(photoPath).findFirst();

    if (glimpse == null) {
      return null;
    }

    // 載入 receipt 與其關聯資料
    await glimpse.receipt.load();
    final receipt = glimpse.receipt.value;

    if (receipt != null) {
      await receipt.shopType.load();
      await receipt.friends.load();
    }

    return glimpse;
  }

  /// Query all glimpses whose EXIF timestamp falls in [startLocal, endLocalExclusive).
  /// - Uses a half-open interval to avoid boundary loss.
  /// - Converts local boundaries to UTC to match Isar DateTime comparison.
  /// - Requires an index on `exifDateTime` (you have `@Index()` already).
  Future<List<Glimpse>> getGlimpsesByExifTimeBetween(
    DateTime startLocal,
    DateTime endLocalExclusive,
  ) async {
    // Guard invalid range.
    if (endLocalExclusive.isAfter(startLocal) == false) {
      return <Glimpse>[];
    } else {
      // proceed
    }

    // Convert to UTC before querying.
    final DateTime startUtc = startLocal.toUtc();
    final DateTime endUtcExclusive = endLocalExclusive.toUtc();

    // Use the index for a fast range scan. Upper bound is exclusive.
    final List<Glimpse> result = await isar.glimpses
        .where()
        .exifDateTimeBetween(
          startUtc,
          endUtcExclusive,
          includeLower: true,
          includeUpper: false,
        )
        .findAll();

    return result;
  }

  /// Query all glimpses on a specific local day using EXIF time.
  /// Range = [startOfDayLocal, nextDayStartLocal).
  Future<List<Glimpse>> getGlimpsesByExifTimeOnDay(DateTime dayLocal) async {
    final DateTime startOfDayLocal =
        DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
    final DateTime nextDayStartLocal =
        startOfDayLocal.add(const Duration(days: 1));
    return await getGlimpsesByExifTimeBetween(
        startOfDayLocal, nextDayStartLocal);
  }

  /// Query all glimpses in a specific local month using EXIF time.
  /// Range = [monthStartLocal, nextMonthStartLocal).
  Future<List<Glimpse>> getGlimpsesByExifTimeInMonth(
      int year, int month) async {
    final DateTime monthStartLocal = DateTime(year, month, 1);
    final DateTime nextMonthStartLocal = DateTime(
      month == 12 ? year + 1 : year,
      month == 12 ? 1 : month + 1,
      1,
    );
    return await getGlimpsesByExifTimeBetween(
        monthStartLocal, nextMonthStartLocal);
  }

  /// Query all glimpses whose CREATED-AT timestamp falls in [startLocal, endLocalExclusive).
  /// - Uses a half-open interval to avoid boundary loss at the end of the range.
  /// - Converts local boundaries to UTC to match Isar DateTime comparison.
  /// - Works without an index (uses filter); if you add @Index() on `createdAt`, you can switch to a `where()` range for speed.
  Future<List<Glimpse>> getGlimpsesByCreatedAtBetween(
    DateTime startLocal,
    DateTime endLocalExclusive,
  ) async {
    // Guard invalid range.
    if (endLocalExclusive.isAfter(startLocal) == false) {
      return <Glimpse>[];
    } else {
      // proceed
    }

    // Convert to UTC before querying to match Isar storage/comparison.
    final DateTime startUtc = startLocal.toUtc();
    final DateTime endUtcExclusive = endLocalExclusive.toUtc();

    // Half-open range: lower inclusive, upper exclusive.
    final List<Glimpse> result = await isar.glimpses
        .filter()
        .createdAtGreaterThan(startUtc, include: true)
        .and()
        .createdAtLessThan(endUtcExclusive, include: false)
        .findAll();

    return result;
  }

  /// Query all glimpses on a specific local day by CREATED-AT.
  /// Range = [startOfDayLocal, nextDayStartLocal).
  Future<List<Glimpse>> getGlimpsesByCreatedAtOnDay(DateTime dayLocal) async {
    final DateTime startOfDayLocal =
        DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
    final DateTime nextDayStartLocal =
        startOfDayLocal.add(const Duration(days: 1));
    return await getGlimpsesByCreatedAtBetween(
        startOfDayLocal, nextDayStartLocal);
  }
}
