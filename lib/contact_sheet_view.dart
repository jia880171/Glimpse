import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/film_roll_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import './config.dart' as config;
import 'common/utils/image_utils.dart';

class ContactSheetView extends StatefulWidget {
  final DateTime selectedDate;
  final Function setTargetAlbum;
  final Size widgetSize;

  const ContactSheetView({Key? key,
    required this.selectedDate,
    required this.setTargetAlbum,
    required this.widgetSize})
      : super(key: key);

  @override
  ContactSheetViewState createState() => ContactSheetViewState();
}

double filmWidthRatio = 0.4;

class ContactSheetViewState extends State<ContactSheetView>
    with WidgetsBindingObserver {
  bool lightOn = false;
  bool isNeg = false;
  int thumbnailSize = 135;

  int visibleImageCount = 0;
  String? selectedImageId;

  Color backLight = config.backLightW;

  // 縮略圖快取Map
  final Map<String, ui.Image> _originalThumbnailCache = {};
  final Map<String, ui.Image> _thumbnailCache = {};

  String? targetAlbumName;

  List<String> albumNames = [];
  List<AssetEntity> visibleImages = [];
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
  void didUpdateWidget(ContactSheetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadImagesForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('====== [contact Sheet] building...');

    double fontSizeForText = 20;
    Size widgetSize = widget.widgetSize;

    Color dateColor = const Color(0xFFF9A825);
    double dateSectionHeight = 100;

    return Scaffold(
      // backgroundColor: backLight,
        body: SingleChildScrollView(
          child: Container(
              color: config.backLightB,
              // color: Colors.red,
              width: widgetSize.width,
              height: widgetSize.height,
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Column(
                        children: buildRotatedFilmRollViews(
                          images: visibleImages,
                          widgetSize: widgetSize,
                          thumbnailCache: _thumbnailCache,
                          backLight: config.backLightB,
                          imagesPerBox: 10,
                          isNeg: backLight == config.backLightB,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(11),
                            child: Opacity(
                              opacity: 0.0,
                              child: Image.asset(
                                'assets/images/noise.png',
                                fit: BoxFit.cover,
                                color: Colors.red.withOpacity(0.15),
                                colorBlendMode: BlendMode.multiply,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  // pop-up album list
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
                              _loadImagesForSelectedDate();
                              widget.setTargetAlbum(value);
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
                                  width: widgetSize.width * 0.1,
                                ),
                                Text(
                                  'counts: $visibleImageCount',
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
                          setIsNeg();
                        });

                        await ImageUtils.updateThumbnailsWithLightEffect(
                            originalCache: _originalThumbnailCache,
                            targetCache: _thumbnailCache,
                            lightOn: lightOn);
                        setState(() {}); // 重新繪製畫面
                      },
                    ),
                  )
                ],
              )),
        ));
  }

  List<Widget> buildRotatedFilmRollViews({
    required List<AssetEntity> images,
    required Size widgetSize,
    required Map<String, ui.Image> thumbnailCache,
    required Color backLight,
    required bool isNeg,
    required int imagesPerBox,
  }) {
    int boxCount = (images.length / imagesPerBox).ceil();

    return List.generate(boxCount, (i) {
      final start = i * imagesPerBox;
      final end = (start + imagesPerBox).clamp(0, images.length);
      final imageChunk = images.sublist(start, end);

      final visibleImages =
      ImageUtils.insertBoundaryDummies(List.from(imageChunk));
      final width = _calculateBoxWidth(widgetSize, boxCount);

      return RotatedBox(
        quarterTurns: 1,
        child: Transform.rotate(
            angle: (math.Random().nextInt(2) - 1) * math.pi / 180, // -3~3
            child: FilmRollView(
              viewSize: Size(width, widgetSize.width),
              images: visibleImages,
              thumbnailCache: thumbnailCache,
              backLight: backLight,
              noHeader: i != 0,
              isNeg: isNeg,
              isContactSheet: true, // 第一個有 header，其餘沒有
            )),
      );
    });
  }

  double _calculateBoxWidth(Size widgetSize, int boxCount) {
    final calculatedWidth = widgetSize.height / boxCount;
    return min(calculatedWidth, widgetSize.height / 3);
  }

  void setIsNeg() {
    isNeg = config.backLightB == backLight;
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

  Future<void> _loadImagesForSelectedDate() async {
    // Check if permission is authorized
    if (!await hasPhotoAccess()) {
      print('====== permission is not authed');
      PhotoManager.openSetting();
      return;
    }

    if (_cachedAlbums.isEmpty) {
      await _initAlbumsAndListen();
    }

    if (targetAlbumName == null) {
      return;
    }

    List<AssetEntity> visibleImages = await ImageUtils.getVisibleImagesForDate(
      cachedAlbums: _cachedAlbums,
      targetAlbumName: targetAlbumName!,
      selectedDate: widget.selectedDate,
    );

    await generateAndCacheThumbnails(visibleImages);

    setState(() {
      this.visibleImages = visibleImages;
      visibleImageCount = visibleImages.isEmpty ? 0 : visibleImages.length;
    });
  }

  void setBackLight(bool lightOn) {
    print('====== lightOn? ${lightOn}');
    setState(() {
      backLight = lightOn ? config.backLightB : config.backLightW;
      print('====== backLight: ${backLight}');
    });
  }


  Future<void> generateAndCacheThumbnails(
      List<AssetEntity> visibleImages) async {
    await ImageUtils.generateThumbnails(
        images: visibleImages,
        cache: _originalThumbnailCache,
        thumbnailSize: thumbnailSize);

    await ImageUtils.updateThumbnailsWithLightEffect(
        originalCache: _originalThumbnailCache,
        targetCache: _thumbnailCache,
        lightOn: lightOn);
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
