import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:exif/exif.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/common/utils/image_utils.dart';
import 'package:glimpse/widgets/dashboard/nikon28_like_dashboard.dart';
import 'package:glimpse/widgets/light_box/popup_memu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../config.dart' as config;
import '../../models/film_profile.dart';
import '../../services/film_profile_service.dart';
import '../film/film_roll_view.dart';
import '../film_canister/film_canister.dart';
import '../rotatable_card/rotatable_Glimpse_card_view.dart';

class LightBoxView extends StatefulWidget {
  final DateTime selectedDate;
  final Function setTargetAlbumNames;
  final Size widgetSize;
  final int imagePointerFromParent;
  final Function(int currentIndex) setImagesWithDummiesPointer;
  final Function(int imagesLength) setImagesWithDummiesLength;
  final Function(Map<String?, IfdTag>) setEXIFOfPointedImg;
  final VoidCallback onImagesResetEnd;
  final String shutterSpeed;
  final String aperture;
  final String iso;
  final bool isImagesReset;
  final List<String> targetAlbumNames;

  const LightBoxView(
      {Key? key,
      required this.shutterSpeed,
      required this.aperture,
      required this.iso,
      required this.selectedDate,
      required this.setTargetAlbumNames,
      required this.widgetSize,
      required this.imagePointerFromParent,
      required this.setImagesWithDummiesPointer,
      required this.setImagesWithDummiesLength,
      required this.setEXIFOfPointedImg,
      required this.onImagesResetEnd,
      required this.isImagesReset,
      required this.targetAlbumNames})
      : super(key: key);

  @override
  LightBoxViewState createState() => LightBoxViewState();
}

class LightBoxViewState extends State<LightBoxView>
    with WidgetsBindingObserver {
  late Map<String, FilmProfile> dbAlbumMap = {};

  int selectedFilmIndex = 0;
  int visibleImagesGroupsCount = 0;
  List<List<AssetEntity>> visibleImagesGroups = [];

  bool isCardMode = false;
  bool isLoading = false;
  bool lightOn = false;
  bool isNeg = false;
  int thumbnailSize = 100;

  int visibleImageCount = 0;
  String? selectedImageId;

  Color backLight = config.backLightW;

  // 縮略圖快取Map
  final Map<String, ui.Image> _originalThumbnailCache = {};
  final Map<String, ui.Image> _thumbnailCache = {};

  List<String> dbAlbumNames = [];
  List<String> systemAlbumNames = [];

  List<AssetEntity> imagesWithDummies = [];
  List<AssetPathEntity> _cachedAlbums = [];

  // card mode
  late int cardIndex;
  late Uint8List processedImage;
  late Map<String?, IfdTag> exifData;
  late String imagePath;

  int scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _initAlbumsAndListen();

    _loadImagesForSelectedDate();
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
      _loadImagesForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSizeForText = 20;
    Size widgetSize = widget.widgetSize;
    Color dateColor = const Color(0xFFF9A825);
    double dateSectionHeight = 100;

    double filmRoll3DWidth = widgetSize.width * 0.08;
    double filmRoll3DHeight = filmRoll3DWidth * 1.7;

    return Container(
        width: widgetSize.width,
        height: widgetSize.height,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: widgetSize.height, // 確保至少跟螢幕一樣高
          ),
          child: Column(
            children: [
              Container(
                  height: widgetSize.height * 0.3,
                  width: widgetSize.width,
                  child: Row(
                    children: [
                      const Spacer(),
                      Nikon28TiDashboard(
                          widgetSize: Size(widgetSize.height * 0.5,
                              widgetSize.height * 0.25),
                          imagesWithDummiesPointer:
                              widget.imagePointerFromParent,
                          imagesLength: 43,
                          backgroundColor: config.backGroundWhite,
                          shutterSpeed: widget.shutterSpeed,
                          aperture: widget.aperture,
                          iso: widget.iso,
                          isReset: widget.isImagesReset,
                          onImagesResetEnd: widget.onImagesResetEnd),
                      const Spacer(),
                    ],
                  )),
              Neumorphic(
                  style: NeumorphicStyle(
                      color: config.backGroundMainTheme,
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(widgetSize.width * 0.0168)),
                      intensity: 1,
                      depth: -1),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        // film
                        RotatedBox(
                          quarterTurns: 1,
                          child: SizedBox(
                            width: widgetSize.height * 0.7,
                            height: widgetSize.width,
                            child: FilmRollView(
                                viewSize:
                                    Size(widgetSize.width, widgetSize.width),
                                imagesWithDummies: imagesWithDummies,
                                thumbnailCache: _thumbnailCache,
                                backLight: backLight,
                                noHeader: false,
                                isNeg: isNeg,
                                isContactSheet: false,
                                targetAlbumNames: widget.targetAlbumNames,
                                selectedDate: widget.selectedDate,
                                onTapPic: onTapPic,
                                setImagesWithDummiesPointer:
                                    widget.setImagesWithDummiesPointer,
                                imagePointerFromParent:
                                    widget.imagePointerFromParent,
                                setEXIFOfPointedImg:
                                    widget.setEXIFOfPointedImg),
                          ),
                        ),

                        // menu
                        Positioned(
                            top: widgetSize.height * 0.1,
                            left: widgetSize.width * 0.02,
                            child: Transform.rotate(
                              angle: 90 * pi / 180,
                              child: PopupMenu(
                                systemAlbumsNames: systemAlbumNames,
                                onSelected: (value) async {
                                  List<String> targetAlbumNamesTemp = [];

                                  if (dbAlbumMap.containsKey(value)) {
                                    final profile = dbAlbumMap[value]!;

                                    if (!profile.albums.isLoaded) {
                                      await profile.albums.load();
                                    }

                                    for (final album in profile.albums) {
                                      debugPrint('✔ 相簿名: ${album.name}');
                                      targetAlbumNamesTemp.add(album.name);
                                    }
                                  } else {
                                    targetAlbumNamesTemp = [value];
                                  }

                                  // 先更新 album name
                                  widget.setTargetAlbumNames(
                                      targetAlbumNamesTemp);

                                  setState(() {
                                    selectedFilmIndex = 0;
                                    visibleImagesGroupsCount = 0;
                                    visibleImagesGroups = [];
                                    imagesWithDummies = [];
                                    visibleImageCount = 0;
                                    isLoading = true;
                                  });

                                  // 再載入新的資料
                                  await _loadImagesForSelectedDate();
                                },
                                screenWidth: widgetSize.width,
                                dbAlbumMap: dbAlbumMap,
                                updateAlbums: _initAlbumsAndListen,
                              ),
                            )),

                        // films
                        Positioned(
                          bottom: widgetSize.height * 0.01,
                          left: 0,
                          child: SizedBox(
                            height: filmRoll3DHeight,
                            width: widgetSize.width,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: visibleImagesGroupsCount,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedFilmIndex = index;
                                      });

                                      _setImageGroupAt(index);
                                    },
                                    child: Transform.scale(
                                      scale: index == selectedFilmIndex
                                          ? 1.0168
                                          : 0.8,
                                      child: FilmCanisterWidget(
                                        width: filmRoll3DWidth,
                                        bodyColor: Colors.green,
                                        iso: '200',
                                        filmFormat: '35mm',
                                        filmMaker: 'Kodak',
                                        filmName: 'Gold',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

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
                          top: widgetSize.height * .5,
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
                        ),

                        if (isLoading || isCardMode)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.01),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (isCardMode)
                          RotatableGlimpseCardView(
                            index: cardIndex,
                            image: processedImage,
                            exifData: exifData,
                            imagePath: imagePath,
                            backLight: config.backLightB,
                            isNeg: isNeg,
                            cardSize: Size(widgetSize.width * 0.6,
                                widgetSize.height * 0.6),
                            leaveCardMode: leaveCardMode,
                            rotationAlignment: Alignment.center,
                            widgetSize: widgetSize,
                            interactive: true,
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }

  void leaveCardMode() {
    setState(() {
      isCardMode = false;
    });
  }

  void onTapPic(AssetEntity image, int index, bool isNeg) async {
    final imageBytes = await ImageUtils.getImageBytes(image);
    exifData = (await readExifFromBytes(imageBytes!))!;
    final file = await image.file;
    imagePath = file!.path;
    cardIndex = index;
    processedImage =
        isNeg ? ImageUtils.applyNegativeEffect(imageBytes) : imageBytes;

    setState(() {
      isCardMode = true;
    });
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
    // 系統相簿名稱
    final systemAlbumNames = _cachedAlbums.map((e) => e.name).toList();

    // 從db取得自定義列表
    final filmService = FilmProfileService();
    final albumsFromDB = await filmService.getAllFilmProfiles();

    // 存儲 map 供後續反查
    dbAlbumMap = filmService.formatLabelMap(albumsFromDB);
    final dbAlbumNames = dbAlbumMap.keys.toList();

    setState(() {
      this.dbAlbumNames = dbAlbumNames;
      this.systemAlbumNames = systemAlbumNames;
    });
  }

  Future<bool> hasPhotoAccess() async {
    final permission = await PhotoManager.requestPermissionExtend();
    return permission.isAuth || permission == PermissionStatus.limited;
  }

  Future<void> _setImageGroupAt(int groupIndex) async {
    if (groupIndex < 0 || groupIndex >= visibleImagesGroups.length) return;

    setState(() {
      isLoading = true;
    });

    final List<AssetEntity> selectedGroup = visibleImagesGroups[groupIndex];
    final List<AssetEntity> withDummies =
        ImageUtils.insertBoundaryDummies(selectedGroup);

    await generateAndCacheThumbnails(withDummies);

    setState(() {
      imagesWithDummies = withDummies;
      visibleImageCount = withDummies.length - 2;
      widget.setImagesWithDummiesLength(withDummies.length);
      isLoading = false;
    });
  }

  Future<void> _loadImagesForSelectedDate() async {
    // Check if permission is authorized
    if (!await hasPhotoAccess()) {
      print('====== permission is not authed');
      PhotoManager.openSetting();
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (_cachedAlbums.isEmpty) {
      await _initAlbumsAndListen();
    }

    if (widget.targetAlbumNames.isEmpty) {
      isLoading = false;
      return;
    }

    visibleImagesGroups = await ImageUtils.getVisibleImagesForDate(
      cachedAlbums: _cachedAlbums,
      targetAlbumNames: widget.targetAlbumNames,
      selectedDate: widget.selectedDate,
    );

    await _setImageGroupAt(0);

    setState(() {
      visibleImagesGroupsCount = visibleImagesGroups.length;
      isLoading = false;
    });
  }

  void setBackLight(bool lightOn) {
    setState(() {
      backLight = lightOn ? config.backLightB : config.backLightW;
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
