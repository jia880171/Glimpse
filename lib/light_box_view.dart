import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:exif/exif.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/film_roll_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import './config.dart' as config;

class LightBoxView extends StatefulWidget {
  final DateTime selectedDate;
  final Function setGlimpseCount;
  final Size widgetSize;

  const LightBoxView(
      {Key? key,
      required this.selectedDate,
      required this.setGlimpseCount,
      required this.widgetSize})
      : super(key: key);

  @override
  LightBoxViewState createState() => LightBoxViewState();
}

double filmWidthRatio = 0.4;

class LightBoxViewState extends State<LightBoxView>
    with WidgetsBindingObserver {
  bool lightOn = false;
  int thumbnailSize = 135;

  int counts = 0;
  String? selectedImageId;

  Color backLight = config.backLightW;

  // 縮略圖快取Map
  final Map<String, ui.Image> _originalThumbnailCache = {};
  final Map<String, ui.Image> _thumbnailCache = {};

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

  @override
  void didUpdateWidget(LightBoxView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSizeForText = 20;
    Size widgetSize = widget.widgetSize;

    Color dateColor = const Color(0xFFF9A825);
    double dateSectionHeight = 100;

    return Scaffold(
        // backgroundColor: backLight,
        body: SingleChildScrollView(
      child: Container(
          // color: backLight,
          width: widgetSize.width,
          height: widgetSize.height,
          child: Stack(
            children: [

              Center(
                  child: FilmRollView(
                viewSize: Size(widgetSize.width, widgetSize.height),
                images: images,
                thumbnailCache: _thumbnailCache,
                backLight: backLight,
              )),

              // menu
              Positioned(
                  top: (widgetSize.width - (dateSectionHeight / 2)) / 2,
                  left: widgetSize.width * 0.02,
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
                top: 0,
                right: 0,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: SizedBox(
                    width: widgetSize.width,
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
                                  fontFamily: 'Ds-Digi',
                                ),
                              ),
                            ),

                            // /
                            Text(
                              '/',
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: dateColor,
                                fontSize: fontSizeForText,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Ds-Digi',
                              ),
                            ),

                            // month
                            SizedBox(
                              width: fontSizeForText * 2,
                              child: Text(
                                widget.selectedDate.month
                                    .toString()
                                    .padLeft(2, '0'),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: dateColor,
                                  fontSize: fontSizeForText,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Ds-Digi',
                                ),
                              ),
                            ),

                            // /
                            Text(
                              '/',
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: dateColor,
                                fontSize: fontSizeForText,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Ds-Digi',
                              ),
                            ),

                            // day
                            SizedBox(
                              width: fontSizeForText * 2,
                              child: Text(
                                widget.selectedDate.day
                                    .toString()
                                    .padLeft(2, '0'),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: dateColor,
                                  fontSize: fontSizeForText,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Ds-Digi',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: widgetSize.width*0.1,
                            ),
                            Text(
                              'counts: $counts',
                              style: TextStyle(color: dateColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // light switch
              Positioned(
                top: widgetSize.height * .6,
                left: widgetSize.width * 0.02,
                child: Switch(
                  value: lightOn,
                  activeColor: Colors.red,
                  onChanged: (bool value) async {
                    setState(() {
                      lightOn = value;
                      setBackLight(lightOn);
                    });

                    await updateThumbnailsForLightState();

                    setState(() {}); // 重新繪製畫面
                  },
                ),
              )
            ],
          )),
    ));
  }

  void _onPhotoChange(MethodCall call) {
    // 系統照片有改變，自動刷新
    _initAlbumsAndListen();
  }

  Future<void> _initAlbumsAndListen() async {
    if (!await hasPhotoAccess()) {
      PhotoManager.openSetting();
      return;
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

  Future<List<AssetEntity>> getAssetEntitiesFromCachedAlbums(
      String targetAlbumName) async {
    final targetAlbum = _cachedAlbums.firstWhereOrNull(
          (album) => album.name == targetAlbumName,
    );

    if (targetAlbum == null) {
      print("目標相簿不存在");
      return [];
    }

    final List<AssetEntity> allImages =
    await targetAlbum.getAssetListPaged(page: 0, size: 100);
    final selectedImages = filterImagesByDate(allImages);

    return selectedImages;
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

    await loadAndCacheThumbnail(selectedImages);

    print('====== _fetchImages done');
    setState(() {
      images = selectedImages;
      counts = images.isEmpty ? 0 : images.length - 2;
      widget.setGlimpseCount(counts);
    });
  }

  void setBackLight(bool lightOn) {
    print('====== lightOn? ${lightOn}');
    setState(() {
      backLight = lightOn ? config.backLightB : config.backLightW;
      print('====== backLight: ${backLight}');
    });
  }

  Future<void> updateThumbnailsForLightState() async {
    for (var entry in _originalThumbnailCache.entries) {
      final original = entry.value;
      if (lightOn) {
        _thumbnailCache[entry.key] = await invertColors(original);
      } else {
        _thumbnailCache[entry.key] = original;
      }
    }
  }

  Future<ui.Image> invertColors(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception("Unable to convert image");

    final rgbaBytes = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    for (int i = 0; i < rgbaBytes.length; i += 4) {
      rgbaBytes[i] = 255 - rgbaBytes[i]; // R
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

  Future<void> loadAndCacheThumbnail(List<AssetEntity> selectedImages) async {
    for (var image in selectedImages) {
      final thumbnailData = await image.thumbnailDataWithSize(
        ThumbnailSize(thumbnailSize, thumbnailSize),
      );

      if (thumbnailData != null) {
        final codec = await ui.instantiateImageCodec(thumbnailData);
        final frame = await codec.getNextFrame();
        final ui.Image rawImage = frame.image;

        // 如果是橫圖，轉 90 度
        if (rawImage.width > rawImage.height) {
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);

          final rotatedWidth = rawImage.height.toDouble();
          final rotatedHeight = rawImage.width.toDouble();

          // 轉 90 度，並將圖繪製在轉換後的位置
          canvas.translate(rotatedWidth, 0);
          canvas.rotate(90 * 3.1415927 / 180);
          final paint = Paint();
          canvas.drawImage(rawImage, Offset.zero, paint);

          final picture = recorder.endRecording();
          final rotatedImage = await picture.toImage(
            rotatedWidth.toInt(),
            rotatedHeight.toInt(),
          );

          _originalThumbnailCache[image.id] = rotatedImage;
        } else {
          _originalThumbnailCache[image.id] = rawImage;
        }
      }
    }

    updateThumbnailsForLightState();
  }

  List<AssetEntity> filterImagesByDate(List<AssetEntity> allImages) {
    return allImages.where((image) {
      final DateTime createDate = image.createDateTime;
      return createDate.year == widget.selectedDate.year &&
          createDate.month == widget.selectedDate.month &&
          createDate.day == widget.selectedDate.day;
    }).toList();
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
