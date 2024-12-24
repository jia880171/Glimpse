import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import './config.dart' as config;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image/image.dart' as img; // Import the image package

class WaterfallView extends StatefulWidget {
  final DateTime selectedDate;
  final Function setGlimpseCount;

  const WaterfallView(
      {Key? key, required this.selectedDate, required this.setGlimpseCount})
      : super(key: key);

  @override
  _WaterfallViewState createState() => _WaterfallViewState();
}

class _WaterfallViewState extends State<WaterfallView> {
  List<AssetEntity> images = [];
  int counts = 0;
  String? selectedImageId;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  // 定義一個縮略圖快取Map
  final Map<String, Uint8List?> _thumbnailCache = {};

  Future<void> _fetchImages() async {
    print('======_fetching Images');
    final PermissionState permission =
    await PhotoManager.requestPermissionExtend();

    // Check if permission is authorized
    if (permission.isAuth || permission == PermissionState.limited) {
      // Fetch albums from the device
      final List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList();

      print('====== albums ${albums}');

      if (albums.isNotEmpty) {
        List<AssetEntity> selectedImages =
        await getAssetEntitiesFormTargetAlbum(albums);

        // insert dummy photos
        selectedImages.insert(0, selectedImages[0]);
        selectedImages.insert(selectedImages.length, selectedImages[0]);

        setState(() {
          images = selectedImages;
          counts = images.length;
          widget.setGlimpseCount(counts);
        });

        // 加載縮略圖並快取
        await loadAndCacheThumbnail(selectedImages);
      } else {
        print('====== albums is empty');
      }
    } else {
      print('====== permission is not authed');
      PhotoManager.openSetting();
    }
  }

  Future<List<AssetEntity>> getAssetEntitiesFormTargetAlbum(
      List<AssetPathEntity> albums) async {
    // 找到目標相簿
    final AssetPathEntity? targetAlbum =
    albums.cast<AssetPathEntity?>().firstWhere(
      // (album) => album?.name == "AdobeLightroom",
          (album) => album?.name == "FUJIFILM X-E4",
      orElse: () => null,
    );

    if (targetAlbum == null) {
      print("目標相簿不存在");
      return [];
    }

    // 從目標相簿中獲取所有圖片
    final List<AssetEntity> allImages =
    await targetAlbum.getAssetListPaged(page: 0, size: 100);

    // Filter images by selected date
    final selectedImages = filterImagesByDate(allImages);
    return selectedImages;
  }

  Future<void> loadAndCacheThumbnail(List<AssetEntity> selectedImages) async {
    for (var image in selectedImages) {
      // Load the thumbnail data
      final thumbnailData = await image.thumbnailDataWithSize(
        const ThumbnailSize(200, 200),
      );

      // Decode the thumbnail to check its orientation
      if (thumbnailData != null) {
        img.Image? decodedImage =
        img.decodeImage(Uint8List.fromList(thumbnailData));

        // Check if the image is landscape (width > height)
        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // Rotate the image by 90 degrees
          decodedImage = img.copyRotate(decodedImage, 90);
        }

        // Save the rotated image back into the cache
        if (decodedImage != null) {
          _thumbnailCache[image.id] =
              Uint8List.fromList(img.encodeJpg(decodedImage));
        }
      }
    }
  }

  List<AssetEntity> filterImagesByDate(List<AssetEntity> allImages) {
    return allImages.where((image) {
      final DateTime? createDate = image.createDateTime;
      return createDate?.year == widget.selectedDate.year &&
          createDate?.month == widget.selectedDate.month &&
          createDate?.day == widget.selectedDate.day;
    }).toList();
  }

  @override
  void didUpdateWidget(WaterfallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      // Only fetch images if selectedDate has changed
      _fetchImages();
    }
  }

  // 將 Uint8List 圖片資料轉為負片效果
  Uint8List applyNegativeEffect(Uint8List imageData) {
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

  @override
  Widget build(BuildContext context) {
    print('====== building');
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double fontSizeForText = 20;

    double frameHeight = screenHeight * 0.3;
    double frameWidth = screenWidth * 0.5;
    double marginBuffer = 10;

    const rectangleWidth = 15;
    const sizeBoxWidth = 10;
    final rowWidth = rectangleWidth * 2 + sizeBoxWidth * 4 + screenWidth * 0.5;

    Color dateColor = const Color(0xFFF9A825);
    double dateSectionHeight = 100;

    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
              width: screenWidth,
              height: screenHeight,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: images.isEmpty
                          ? const Center(
                          child: Text("No images found for this date"))
                          : Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          color: Colors.black,
                          width: screenWidth,
                          height: screenHeight,
                          child: MasonryGridView.count(
                            crossAxisCount: 1,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final image = images[index];
                              final thumbnail = _thumbnailCache[image.id];
                              final isFirst = index == 0;
                              final isLast = index == images.length - 1;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // 點擊時更新狀態為當前圖片的ID
                                    selectedImageId = image.id;
                                  });
                                },
                                child: Container(
                                  child: isFirst
                                      ? Row(
                                    children: [
                                      const Spacer(),
                                      Container(
                                        color:
                                        const Color(0xFF8B4513)
                                            .withOpacity(0.65),
                                        child: FilmHead(
                                          screenWidth: screenWidth,
                                          frameHeight: frameHeight,
                                        ),
                                      ),
                                      const Spacer()
                                    ],
                                  )
                                      : isLast
                                      ? Row(
                                    children: [
                                      const Spacer(),
                                      Container(
                                        color: const Color(
                                            0xFF8B4513)
                                            .withOpacity(0.65),
                                        child: FilmTail(
                                            screenWidth:
                                            screenWidth,
                                            frameHeight:
                                            frameHeight),
                                      ),
                                      const Spacer(),
                                    ],
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      Spacer(),
                                      Container(
                                        color: const Color(
                                            0xFF8B4513)
                                            .withOpacity(0.65),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                                width: 10),
                                            Rectangles(
                                                totalHeight:
                                                frameHeight),
                                            const SizedBox(
                                                width: 10),
                                            Container(
                                              width:
                                              screenWidth *
                                                  0.5,
                                              decoration:
                                              const BoxDecoration(
                                                color: Colors
                                                    .black,
                                              ),
                                              child: (thumbnail !=
                                                  null)
                                                  ? Image
                                                  .memory(
                                                applyNegativeEffect(
                                                  selectedImageId ==
                                                      image.id
                                                      ? applyNegativeEffect(
                                                      thumbnail)
                                                      : thumbnail,
                                                ),
                                                fit: BoxFit
                                                    .cover,
                                              )
                                                  : Container(
                                                color: Colors
                                                    .grey[
                                                200],
                                                height:
                                                100,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 10),
                                            Rectangles(
                                                totalHeight:
                                                frameHeight),
                                            const SizedBox(
                                                width: 10),
                                          ],
                                        ),
                                      ),
                                      Spacer()
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          ,
                        ),
                      ),
                    ),
                  ),

                  // date section
                  Positioned(
                      top: (screenWidth - (dateSectionHeight / 2)) / 2,
                      left: screenWidth / 2 - 60,
                      child: Transform.rotate(
                        angle: 90 * pi / 180,
                        child: SizedBox(
                          width: screenWidth,
                          height: dateSectionHeight,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // year
                                  SizedBox(
                                    width: fontSizeForText * 4,
                                    child: Text(
                                      widget.selectedDate.year.toString(),
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: dateColor,
                                        fontSize: fontSizeForText,
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                      ),
                                    ),
                                  ),

                                  // /
                                  SizedBox(
                                    child: Text(
                                      '/',
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: dateColor,
                                        fontSize: fontSizeForText,
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                      ),
                                    ),
                                  ),

                                  // month
                                  SizedBox(
                                    width: fontSizeForText * 2,
                                    child: Text(
                                      widget.selectedDate.month < 10
                                          ? '0${widget.selectedDate.month}'
                                          : widget.selectedDate.month
                                          .toString(),
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: dateColor,
                                        fontSize: fontSizeForText,
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                      ),
                                    ),
                                  ),

                                  // /
                                  SizedBox(
                                    child: Text(
                                      '/',
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: dateColor,
                                        fontSize: fontSizeForText,
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                      ),
                                    ),
                                  ),

                                  // date
                                  SizedBox(
                                      width: fontSizeForText * 2,
                                      child: Text(
                                        widget.selectedDate.day < 10
                                            ? '0${widget.selectedDate.day}'
                                            : widget.selectedDate.day
                                            .toString(),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: dateColor,
                                          fontSize: fontSizeForText,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                          'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                        ),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'counts: ${counts}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              )),
        ));
  }
}

// 白點生成
class Dots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        8, // 點的數量
            (index) =>
            Container(
              width: 5,
              height: 5,
              margin: EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
      ),
    );
  }
}

class Rectangles extends StatelessWidget {
  final double
  totalHeight; // Total height (including spacing) passed as a parameter
  final double rectangleHeight; // The height of each rectangle
  final double margin; // The margin between the rectangles

  Rectangles({
    required this.totalHeight,
    this.rectangleHeight = 10, // Default rectangle height
    this.margin = 10, // Default margin
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the number of rectangles that can fit within the total height
    final numberOfRectangles =
        (totalHeight / (rectangleHeight + margin)).floor() - 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        numberOfRectangles, // Number of rectangles calculated dynamically
            (index) {
          // Determine color for the first and last rectangle
          Color rectangleColor = Colors.black;

          return Container(
            width: 15, // Rectangle width
            height: rectangleHeight, // Rectangle height
            margin: EdgeInsets.symmetric(vertical: margin), // Rectangle margin
            decoration: BoxDecoration(
              color: rectangleColor, // Set the color of the rectangle
              borderRadius: BorderRadius.circular(3), // Rounded corners
            ),
          );
        },
      ),
    );
  }
}

class FilmHead extends StatelessWidget {
  final double screenWidth;
  final double frameHeight;

  final double cutHeight = 210;

  const FilmHead({
    Key? key,
    required this.screenWidth,
    required this.frameHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Rectangles(totalHeight: frameHeight),
            const SizedBox(width: 10),
            Container(
              width: screenWidth * 0.5,
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Container(
                color: Color(0xFF8B4513).withOpacity(0.65),
                height: 200,
              ),
            ),
            const SizedBox(width: 10),
            Rectangles(totalHeight: frameHeight),
            const SizedBox(width: 10),
          ],
        ),
        Row(
          children: [
            Container(
              width: screenWidth * 0.3,
              height: cutHeight,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(150),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: cutHeight,
                  color: Colors.black,
                ),
                Container(
                  width: screenWidth * 0.3,
                  height: cutHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.65),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class FilmTail extends StatelessWidget {
  final double screenWidth;
  final double frameHeight;

  const FilmTail({
    Key? key,
    required this.screenWidth,
    required this.frameHeight,
  }) : super(key: key);

  final double rectangleWidth = 15;
  final double sizeBoxWidth = 10;

  @override
  Widget build(BuildContext context) {
    final double rowWidth =
        rectangleWidth * 2 + sizeBoxWidth * 4 + screenWidth * 0.5;
    return SizedBox(
      height: frameHeight,
      child: Stack(
        children: [
          // null item
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              SizedBox(
                width: rectangleWidth,
                height: frameHeight,
                child: ClipRect(
                  clipBehavior: Clip.hardEdge, // 使內容超過邊界時會被裁剪
                  child: OverflowBox(
                    maxHeight: double.infinity, // 允許內部元素的高度超過容器的限制
                    child: Rectangles(totalHeight: frameHeight),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: screenWidth * 0.5,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Container(
                  color: const Color(0xFF8B4513).withOpacity(0.65),
                  height: frameHeight,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: rectangleWidth,
                height: frameHeight,
                child: ClipRect(
                  clipBehavior: Clip.hardEdge, // 使內容超過邊界時會被裁剪
                  child: OverflowBox(
                    maxHeight: double.infinity, // 允許內部元素的高度超過容器的限制
                    child: Rectangles(totalHeight: frameHeight),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),

          Row(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        // color: Colors.green,
                        width: sizeBoxWidth + rectangleWidth,
                        height: frameHeight,
                      ),
                      Stack(
                        children: [
                          Container(
                            width: rowWidth -
                                screenWidth * 0.3 -
                                (sizeBoxWidth + rectangleWidth),
                            height: frameHeight,
                            color: Colors.black,
                          ),
                          Container(
                            width: rowWidth -
                                screenWidth * 0.3 -
                                (sizeBoxWidth + rectangleWidth),
                            height: frameHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B4513).withOpacity(0.65),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: 20,
                    height: frameHeight - 150,
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(150),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
