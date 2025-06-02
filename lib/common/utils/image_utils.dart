import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class ImageUtils {
  static Future<Uint8List?> getImageBytes(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      final bytes = await file.readAsBytes();
      return bytes;
    }
    return null;
  }

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

  ///🚫 為何 getSortedAssetsInOneDay 稍微不自然？
  // 語意會被讀者理解為：
  //
  // get [Sorted Assets] [In One Day]
  // 「取得一天內的排序資產」
  //
  // 但這樣就有語義模糊的可能：
  //
  // 是「所有排序過的資產中，一天內的那批」？
  //
  // 還是「一天內的資產，再排序」？
  //
  // 這會讓人不確定 Sorted 是針對哪個子集合來的：是全域？還是 InOneDay 之後的結果？
  static Future<List<AssetEntity>> fetchImagesFromAlbum({
    required List<AssetPathEntity> cachedAlbums,
    required String targetAlbumName,
  }) async {
    final targetAlbum = cachedAlbums.firstWhereOrNull(
      (album) => album.name == targetAlbumName,
    );

    if (targetAlbum == null) {
      print("====== 目標相簿不存在");
      return [];
    }

    final List<AssetEntity> allAssets =
        await targetAlbum.getAssetListPaged(page: 0, size: 100);

    final List<AssetEntity> imageAssets =
        allAssets.where((asset) => asset.type == AssetType.image).toList();

    return imageAssets;
  }

  // Sort images ascending
  static List<AssetEntity> sortByCreationTimeAsc(List<AssetEntity> images) {
    images.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
    return images;
  }

  static List<AssetEntity> filterImagesByExactDay(
      List<AssetEntity> images, DateTime selectedDate) {
    return images.where((image) {
      final DateTime createDate = image.createDateTime;
      return createDate.year == selectedDate.year &&
          createDate.month == selectedDate.month &&
          createDate.day == selectedDate.day;
    }).toList();
  }

  static List<AssetEntity> insertBoundaryDummies(List<AssetEntity> images) {
    if (images.isNotEmpty) {
      images.insert(0, images[0]);
      images.insert(images.length, images[0]);
    }
    return images;
  }

  static Future<List<AssetEntity>> getVisibleImagesForDate({
    required List<AssetPathEntity> cachedAlbums,
    required String targetAlbumName,
    required DateTime selectedDate,
  }) async {
    final images = await fetchImagesFromAlbum(
      cachedAlbums: cachedAlbums,
      targetAlbumName: targetAlbumName,
    );

    final filtered = filterImagesByExactDay(images, selectedDate);
    final sorted = sortByCreationTimeAsc(filtered);

    return sorted;
  }

  static Future<void> generateThumbnails({
    required List<AssetEntity> images,
    required Map<String, ui.Image> cache,
    required int thumbnailSize,
  }) async {
    for (AssetEntity image in images) {
      final thumbnailData = await image.thumbnailDataWithSize(
        ThumbnailSize(thumbnailSize, thumbnailSize)
      );

      if(thumbnailData == null) continue;

      // start to process
      final codec = await ui.instantiateImageCodec(thumbnailData);
      final frame = await codec.getNextFrame();
      final ui.Image rawImage = frame.image;

      final rotatedOrRaw = await _rotateIfNeeded(rawImage);
      cache[image.id] = rotatedOrRaw;
    }
  }

  static Future<ui.Image> _rotateIfNeeded(ui.Image rawImage) async {
    if (rawImage.width <= rawImage.height) return rawImage;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final rotatedWidth = rawImage.height;
    final rotatedHeight = rawImage.width;

    canvas.translate(rotatedWidth.toDouble(), 0);
    canvas.rotate(90 * math.pi / 180);
    canvas.drawImage(rawImage, Offset.zero, Paint());

    final picture = recorder.endRecording();
    return await picture.toImage(rotatedWidth, rotatedHeight);
  }

  static Future<ui.Image> invertColors(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception("Unable to convert image");

    final rgbaBytes = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    for (int i = 0; i < rgbaBytes.length; i += 4) {
      rgbaBytes[i] = 255 - rgbaBytes[i];       // R
      rgbaBytes[i + 1] = 255 - rgbaBytes[i + 1]; // G
      rgbaBytes[i + 2] = 255 - rgbaBytes[i + 2]; // B
      // A (alpha) 保留 rgbaBytes[i + 3]
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgbaBytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
          (ui.Image result) => completer.complete(result),
    );
    return completer.future;
  }

  static Future<void> updateThumbnailsWithLightEffect({
    required Map<String, ui.Image> originalCache,
    required Map<String, ui.Image> targetCache,
    required bool lightOn,
  }) async {
    for (var entry in originalCache.entries) {
      final original = entry.value;
      if (lightOn) {
        targetCache[entry.key] = await invertColors(original);
      } else {
        targetCache[entry.key] = original;
      }
    }
  }
}
