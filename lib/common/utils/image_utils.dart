import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'package:image/image.dart' as img;


class ImageUtils {
  static Future<Uint8List?> getImageBytes(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      final bytes = await file.readAsBytes();
      return bytes;
    }
    return null;
  }

  // 將 Uint8List 圖片資料轉為負片效果
  static Uint8List applyNegativeEffect(Uint8List imageData) {
    // 解碼圖片
    final originalImage = img.decodeImage(imageData);
    if (originalImage == null) {
      throw Exception("無法解碼圖片");
    }

    // 套用負片效果
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final pixel = originalImage.getPixel(x, y);

        // 取出 RGB 值
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // 取反 RGB 值
        final invertedColor = img.getColor(255 - r, 255 - g, 255 - b);
        originalImage.setPixel(x, y, invertedColor);
      }
    }

    // 將處理後的圖片編碼回 Uint8List
    return Uint8List.fromList(img.encodeJpg(originalImage));
  }
}