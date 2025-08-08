


import '../../../models/glimpse.dart';
import '../../../models/receipt.dart';

class GlimpseReceiptLinkHelper {
  static Future<void> link(Glimpse glimpse, Receipt receipt) async {
    receipt.glimpses.add(glimpse);
    glimpse.receipt.value = receipt;
  }

  // bidirectional
  static Future<void> unlink(Glimpse glimpse) async {
    await glimpse.receipt.load();
    final receipt = glimpse.receipt.value;

    if (receipt != null) {
      await receipt.glimpses.load();
      receipt.glimpses.removeWhere((g) => g.id == glimpse.id);
    }

    glimpse.receipt.value = null;
  }

  static Future<List<Glimpse>> unlinkAllGlimpsesFromReceiptInMemory(Receipt receipt) async {
    await receipt.glimpses.load();
    final detachedGlimpses = <Glimpse>[];

    for (final glimpse in receipt.glimpses) {
      await glimpse.receipt.load();
      glimpse.receipt.value = null;
      detachedGlimpses.add(glimpse);
    }

    receipt.glimpses.clear();

    return detachedGlimpses;
  }
}