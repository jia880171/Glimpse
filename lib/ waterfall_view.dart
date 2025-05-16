import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/rotatable_Glimpse_card_view.dart';

import './config.dart' as config;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';

class WaterfallView extends StatefulWidget {
  final DateTime selectedDate;
  final Function setGlimpseCount;

  const WaterfallView(
      {Key? key, required this.selectedDate, required this.setGlimpseCount})
      : super(key: key);

  @override
  WaterfallViewState createState() => WaterfallViewState();
}

double filmWidthRatio = 0.4;

class WaterfallViewState extends State<WaterfallView>
    with WidgetsBindingObserver {
  bool lightOn = false;
  int thumbnailSize = 135;

  int counts = 0;
  String? selectedImageId;

  Color backLight = config.backLightW;

  // 定義一個縮略圖快取Map
  final Map<String, Uint8List?> _thumbnailCache = {};

  String targetAlbumName = "Pictures";

  List<String> albumNames = [];
  List<AssetEntity> images = [];
  List<AssetPathEntity> _cachedAlbums = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAlbumsAndListen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PhotoManager.removeChangeCallback(_onPhotoChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App refreshes when returning to the foreground from the background
    if (state == AppLifecycleState.resumed) {
      _initAlbumsAndListen();
    }
  }

  void _onPhotoChange(MethodCall call) {
    // 系統照片有改變，自動刷新
    _initAlbumsAndListen();
  }

  Future<void> _initAlbumsAndListen() async {
    if (!await hasPhotoAccess()) {
      PhotoManager.openSetting();
      return; //設定回來之後 會回來這裡?????
    }

    // 註冊系統照片庫改變監聽（第一次呼叫時註冊，之後移除重註冊也沒問題）
    PhotoManager.removeChangeCallback(_onPhotoChange);
    PhotoManager.addChangeCallback(_onPhotoChange);

    // 取得相簿列表並緩存
    _cachedAlbums = await PhotoManager.getAssetPathList();

    setState(() {
      albumNames = _cachedAlbums.map((e) => e.name).toList();
    });
  }

  Future<bool> hasPhotoAccess() async {
    final permission = await PhotoManager.requestPermissionExtend();
    return permission.isAuth || permission == PermissionStatus.limited;
  }

  Future<List<String>> _fetchAlbumNames() async {
    if (await hasPhotoAccess()) {
      final albums = await PhotoManager.getAssetPathList();
      return albums.map((album) => album.name).toList();
    } else {
      PhotoManager.openSetting();
      return [];
    }
  }


  Future<List<AssetEntity>> getAssetEntitiesFromCachedAlbums(String targetAlbumName) async {
    final targetAlbum = _cachedAlbums.firstWhereOrNull(
          (album) => album.name == targetAlbumName,
    );

    if (targetAlbum == null) {
      print("目標相簿不存在");
      return [];
    }

    final List<AssetEntity> allImages = await targetAlbum.getAssetListPaged(page: 0, size: 100);
    final selectedImages = filterImagesByDate(allImages);
    return selectedImages;
  }

  Future<void> _fetchImages() async {
    // Check if permission is authorized
    if (!await hasPhotoAccess()) {
      print('====== permission is not authed');
      PhotoManager.openSetting();
      return;
    }

    if (_cachedAlbums.isEmpty) {
      await _initAlbumsAndListen();
    }

    List<AssetEntity> selectedImages =
        await getAssetEntitiesFromCachedAlbums(targetAlbumName);

    if (selectedImages.isNotEmpty) {
      selectedImages.insert(0, selectedImages[0]);
      selectedImages.insert(selectedImages.length, selectedImages[0]);
    }

    setState(() {
      images = selectedImages;
      counts = images.isEmpty ? 0 : images.length - 2;
      widget.setGlimpseCount(counts);
    });

    await loadAndCacheThumbnail(selectedImages);
  }

  Future<void> extractExifDataFromAsset(AssetEntity asset) async {
    final file = await asset.file;

    if (file != null) {
      final imageBytes = await file.readAsBytes();

      final data = await readExifFromBytes(imageBytes);
      if (data != null && data.isNotEmpty) {
        print('Exif data:');
        for (var entry in data.entries) {
          print('${entry.key}: ${entry.value}');
        }

        final cameraModel = data['Image Model'];
        final dateTime = data['EXIF DateTimeOriginal'];

        print('📷 Camera Model: ${cameraModel?.printable}');
        print('🕓 Date Time: ${dateTime?.printable}');
      } else {
        print('No EXIF data found.');
      }
    }
  }


  Future<void> loadAndCacheThumbnail(List<AssetEntity> selectedImages) async {
    for (var image in selectedImages) {
      // Load the thumbnail data
      final thumbnailData = await image.thumbnailDataWithSize(
        ThumbnailSize(thumbnailSize, thumbnailSize),
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
      final DateTime createDate = image.createDateTime;
      return createDate.year == widget.selectedDate.year &&
          createDate.month == widget.selectedDate.month &&
          createDate.day == widget.selectedDate.day;
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

  Future<Uint8List?> _getImageBytes(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      final bytes = await file.readAsBytes();
      return bytes;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeForText = 20;

    double frameHeight = screenHeight * 0.25;
    double frameWidth = screenWidth * 0.5;
    double marginBuffer = 10;

    const rectangleWidth = 15;
    const sizeBoxWidth = 10;
    final rowWidth = rectangleWidth * 2 + sizeBoxWidth * 4 + screenWidth * 0.5;

    Color dateColor = const Color(0xFFF9A825);
    double dateSectionHeight = 100;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
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
                                color: backLight,
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
                                        // setState(() {
                                        //   // 點擊時更新狀態為當前圖片的ID
                                        //   selectedImageId = image.id;
                                        // });
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
                                                      backLight: backLight,
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
                                                        child: Transform.rotate(
                                                          angle: pi,
                                                          child: FilmHead(
                                                            screenWidth:
                                                                screenWidth,
                                                            frameHeight:
                                                                frameHeight,
                                                            backLight:
                                                                backLight,
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Spacer(),
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
                                                                  frameHeight,
                                                              backLight:
                                                                  backLight,
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Container(
                                                              width: screenWidth *
                                                                  filmWidthRatio,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              child: (thumbnail !=
                                                                      null)
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        final imageBytes =
                                                                            await _getImageBytes(image);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                RotatableGlimpseCardView(
                                                                              isNeg: backLight != config.backLightW,
                                                                              image: imageBytes!,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Image
                                                                          .memory(
                                                                        applyNegativeEffect(
                                                                          backLight == config.backLightW
                                                                              ? applyNegativeEffect(thumbnail)
                                                                              : thumbnail,
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
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
                                                                  frameHeight,
                                                              backLight:
                                                                  backLight,
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                          ],
                                                        ),
                                                      ),
                                                      const Spacer()
                                                    ],
                                                  ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),

                  Positioned(
                      top: (screenWidth - (dateSectionHeight / 2)) / 2,
                      left: screenWidth * 0.02,
                      child: Transform.rotate(
                        angle: 90 * pi / 180,
                        child: PopupMenu(
                          items: albumNames,
                          onSelected: (value) {
                            setState(() {
                              targetAlbumName = value;
                              _fetchImages();
                            });
                          },
                        ),
                      )),

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
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'counts: ${counts}',
                                      style: TextStyle(color: dateColor),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),

                  Positioned(
                    top: screenHeight * .6,
                    left: screenWidth * 0.02,
                    child: Switch(
                      value: lightOn,
                      activeColor: Colors.red,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        setState(() {
                          lightOn = value;
                          setBackLight(lightOn);
                        });
                      },
                    ),
                  )
                ],
              )),
        ));
  }

  void setBackLight(bool lightOn) {
    setState(() {
      backLight = lightOn ? config.backLightB : config.backLightW;
    });
  }
}

class PopupMenu extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onSelected;

  PopupMenu({required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return items.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }
}

class SwitchButton extends StatefulWidget {
  final double screenHeight;
  final Function callBackFunction;

  const SwitchButton({
    Key? key,
    required this.screenHeight,
    required this.callBackFunction,
  }) : super(key: key);

  @override
  _SwitchButtonState createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widgetHeight = widget.screenHeight * 0.1;
    double widgetWidth = widget.screenHeight * 0.05;
    return Container(
      color: Colors.grey,
      height: widgetHeight,
      width: widgetWidth,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            // alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                widget.callBackFunction();
              },
              child: Neumorphic(
                margin: EdgeInsets.only(
                    top: widgetHeight * 0.1, bottom: widgetHeight * 0.1),
                style: const NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.rect(),
                  intensity: 0.8,
                  depth: 1.5,
                  lightSource: LightSource.top,
                  color: Colors.yellow, // Use the current state for color
                ),
                child: SizedBox(
                  height: widgetHeight * 0.3,
                  width: widgetWidth * 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        (index) => Container(
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
  final Color backLight;

  Rectangles({
    required this.totalHeight,
    this.rectangleHeight = 10, // Default rectangle height
    this.margin = 10, // Default margin
    required this.backLight,
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
          Color rectangleColor = backLight;

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
  final Color backLight;

  final double cutHeight = 210;

  const FilmHead({
    Key? key,
    required this.screenWidth,
    required this.frameHeight,
    required this.backLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Rectangles(
              totalHeight: frameHeight,
              backLight: backLight,
            ),
            const SizedBox(width: 10),
            Container(
              width: screenWidth * filmWidthRatio,
              decoration: BoxDecoration(
                color: backLight,
              ),
              child: Container(
                color: const Color(0xFF8B4513).withOpacity(0.65),
                height: 200,
              ),
            ),
            const SizedBox(width: 10),
            Rectangles(
              totalHeight: frameHeight,
              backLight: backLight,
            ),
            const SizedBox(width: 10),
          ],
        ),

        // curve
        Row(
          children: [
            Container(
              width: screenWidth * filmWidthRatio * 0.5,
              height: cutHeight,
              decoration: BoxDecoration(
                color: backLight,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(150),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                    width: screenWidth * 0.3,
                    height: cutHeight,
                    color: backLight),
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
