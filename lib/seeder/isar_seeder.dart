import 'package:isar/isar.dart';
import 'package:glimpse/models/receipt.dart';
import 'package:glimpse/models/shop_type.dart';
import 'package:glimpse/models/friend.dart';

Future<void> seedIsarData(Isar isar) async {
  // 避免重複塞資料
  final existingShopTypes = await isar.shopTypes.count();
  if (existingShopTypes > 0) return;

  // 建立 ShopType
  final shopTypes = [
    ShopType()..name = '居酒屋',
    ShopType()..name = '喫茶店',
    ShopType()..name = 'バー',
  ];

  // 建立 Friend
  final friends = [
    Friend()..name = 'Henry',
    Friend()..name = '大林',
    Friend()..name = 'Tai',
    Friend()..name = '堂',
    Friend()..name = '包Ｄ',
    Friend()..name = '廖桑',
    Friend()..name = '黛',
    Friend()..name = '憶文',
    Friend()..name = 'PJ',
  ];

  // 寫入資料
  await isar.writeTxn(() async {
    await isar.shopTypes.putAll(shopTypes);
    await isar.friends.putAll(friends);
  });

  // 建立 Receipt 範例
  // final receipt = Receipt()
  //   ..dateTime = DateTime.now()
  //   ..shopName = '新宿の月'
  //   ..totalCost = 3260
  //   ..shopType.value = shopTypes.first // 居酒屋
  //   ..friends.addAll(friends.take(2)); // Henry, Alice

  // await isar.writeTxn(() async {
  //   await isar.receipts.put(receipt);
  //   await receipt.shopType.save();
  //   await receipt.friends.save();
  // });

  print('✅ Seeder complete');
}
