// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:exif/exif.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/widgets/calendar/tilted_circle_calendar_widget.dart';
import 'package:glimpse/widgets/dashboard/dashboard.dart';
import 'package:glimpse/widgets/glimpses_book/glimpses_book.dart';
import 'package:glimpse/widgets/light_box/light_box_view.dart';
import 'package:glimpse/widgets/timeline_group/horizontal_date_timeline.dart';
import 'package:glimpse/widgets/timeline_group/timeline_group.dart';
import 'package:glimpse/widgets/trash.dart';
import 'package:photo_manager/photo_manager.dart';

import './config.dart' as config;
import 'Routes.dart';
import 'common/utils/image_utils.dart';
import 'common/utils/rotation_utils.dart';
import 'database_sqlite/attraction.dart';
import 'widgets/contact_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Isar database once using DatabaseService
  await DatabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: Routes.routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Modes {
  chasingAttraction,
  displayTickets,
  displayAttractions,
}

class _MyHomePageState extends State<MyHomePage> {
  bool _canPop = false;
  bool isImagesReset = false;

  List<String> targetAlbumNames = [];

  final List<String> dayOfTheWeekList = [
    "月曜日",
    "火曜日",
    "水曜日",
    "木曜日",
    "金曜日",
    "土曜日",
    "日曜日"
  ];

  final List<String> menuItems = [
    'FILMS',
    'CONTACT SHEET',
    'Glimpses',
    'Trash',
    'Tilted Calendar',
  ];

  final List<String> menuItemsPath = [
    '/filmFinder',
    '/contactSheet',
    '/glimpses',
    '/trash',
    '/receipt',
    '/tiledCalendar'
  ];

  int menuPointer = 0;
  final double _depthMax = 0.5;
  final double _depthMin = 0;
  final double _depthNormal = 0.3;
  List<double> depths = [];
  List<double> prevDepths = [];
  Timer? _timer;

  String shutterSpeed = '0';
  String aperture = '0';
  String iso = '0';

  int targetDatePointer = 0;
  int imageWithDummiesPointer = 1;
  int imagesWithDummiesLength = 0;

  List<DateTime> datesOfSelectedAlbum = [];
  Map<DateTime, int> photosCountPerDay = {};
  DateTime selectedDate = DateTime.now();

  final Duration depthOutDuration = const Duration(milliseconds: 500);
  final Duration depthInDuration = const Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();
    depths = List<double>.filled(menuItems.length, _depthNormal);
    prevDepths = List<double>.filled(menuItems.length, _depthNormal);

    depths[menuPointer] = _depthMax;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double radiusOfMainView = screenWidth * 0.05;

    double mainWidgetWidth = screenWidth * 0.96;
    double screenHeight = MediaQuery.of(context).size.height;

    // header title: screenHeight * 0.1
    double mainWidgetHeight = screenHeight * 0.55;
    double mainWidgetHeightFilm = screenHeight * 0.55;

    double dashboardHeight = screenHeight * 0.3;

    Color radioGlassColor = Colors.white.withOpacity(0.9);
    Color radioBackLightColor = Colors.orange;
    double blur = 0.3;

    double roundRadiusOfMainWidget = screenWidth * 0.0168;

    return PopScope(
        canPop: _canPop,
        onPopInvoked: (canPop) {
          if (!_canPop) {
            _showPopWarningDialog();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Brightness.dark, // Dark status bar icons (like time, battery)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(roundRadiusOfMainWidget), // 👈 底部圓角
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Stack(
                      children: [
                        Container(
                          height: screenHeight,
                          width: screenWidth,
                          color: config.backGroundMainTheme,
                        ),
                        Positioned(
                          top: screenHeight * 0.05,
                          left: 0,
                          right: 0,
                          child: Center(
                            // alignment: Alignment.center,
                            child: Container(
                                color: config.backGroundMainTheme,
                                width: screenWidth,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.05,
                                      child: Column(
                                        children: [
                                          const Spacer(),
                                          Text(
                                            menuItems[menuPointer],
                                            style: TextStyle(
                                                fontFamily: 'Jura',
                                                fontSize:
                                                    screenHeight * 0.05 * 0.3,
                                                color: Colors.black),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                    ),
                                    buildMainView(
                                      screenWidth,
                                      mainWidgetWidth,
                                      mainWidgetHeightFilm,
                                      mainWidgetHeight,
                                    ),
                                  ],
                                )),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight,
                          width: screenWidth,
                          child: Stack(
                            children: [
                              Positioned(
                                  bottom: 0,
                                  child: Dashboard(
                                    widgetSize: Size(
                                      screenWidth,
                                      dashboardHeight,
                                    ),
                                    items: menuItems,
                                    onItemSelected: onMenuItemSelected,
                                    datesOfSelectedAlbum: datesOfSelectedAlbum,
                                    setSelectedDateByOffset:
                                        setSelectedDateByOffset,
                                    imageWithDummiesPointer:
                                        imageWithDummiesPointer,
                                    setImagesWithDummiesPointer:
                                        setImagesWithDummiesPointer,
                                    imagesWithDummiesLength:
                                        imagesWithDummiesLength,
                                    shutterSpeed: shutterSpeed,
                                    aperture: aperture,
                                    iso: iso,
                                    selectedDate: selectedDate,
                                    photosCountPerDay: photosCountPerDay,
                                    onImagesReset: onImagesReset,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  Widget buildMainView(double screenWidth, double mainWidgetWidth,
      double mainWidgetHeightFilm, double mainWidgetHeight) {
    final currentMenu = menuItems[menuPointer];

    switch (currentMenu) {
      case 'FILMS':
        return LightBoxView(
          widgetSize: Size(mainWidgetWidth, mainWidgetHeightFilm),
          selectedDate: selectedDate,
          setTargetAlbumNames: setTargetAlbumNames,
          setImagesWithDummiesPointer: setImagesWithDummiesPointer,
          setImagesWithDummiesLength: setImagesWithDummiesLength,
          imagePointerFromParent: imageWithDummiesPointer,
          setEXIFOfPointedImg: setEXIFOfPointedImg,
          shutterSpeed: shutterSpeed,
          aperture: aperture,
          iso: iso,
          onImagesResetEnd: onImagesResetEnd,
          isImagesReset: isImagesReset,
          targetAlbumNames: targetAlbumNames,
        );

      case 'Trash':
        return _buildNeumorphicWrapper(
          height: mainWidgetHeight,
          width: mainWidgetWidth,
          child: TrashView(
            widgetSize: Size(mainWidgetWidth, mainWidgetHeight),
          ),
        );

      case 'CONTACT SHEET':
        return _buildNeumorphicWrapper(
          height: mainWidgetHeight,
          width: mainWidgetWidth,
          child: ContactSheetView(
            widgetSize: Size(mainWidgetWidth, mainWidgetHeight),
            selectedDate: selectedDate,
            setTargetAlbumNames: setTargetAlbumNames,
            setImagesWithDummiesPointer: setImagesWithDummiesPointer,
          ),
        );

      case 'Glimpses':
        return _buildNeumorphicWrapper(
            child: GlimpseBookView(widgetSize: Size(mainWidgetWidth, mainWidgetHeight)),
            height: mainWidgetHeight,
            width: mainWidgetWidth);
      // return _buildNeumorphicWrapper(
      //   height: mainWidgetHeight,
      //   width: mainWidgetWidth,
      //   child: SingleChildScrollView(
      //     child: Column(
      //       children: List.generate(
      //         66,
      //             (i) => GlimpseRowCard(
      //           date: DateTime.now()
      //               .subtract(Duration(days: math.Random().nextInt(90))),
      //           rowWidth: screenWidth * 0.8,
      //           dayOfTheWeekList: dayOfTheWeekList,
      //         ),
      //       ),
      //     ),
      //   ),
      // );

      case 'Tilted Calendar':
        return _buildNeumorphicWrapper(
            child: TiltedCircleCalendar(widgetSize: Size(mainWidgetWidth, mainWidgetHeight), rotationSpeed: 5.0,),
            height: mainWidgetHeight,
            width: mainWidgetWidth);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNeumorphicWrapper({
    required Widget child,
    required double height,
    required double width,
    double borderRadius = 8,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        color: config.mainBackGroundWhite,
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(borderRadius),
        ),
        intensity: 1,
        depth: -0.8,
      ),
      child: Container(
        height: height,
        width: width,
        child: child,
      ),
    );
  }

  void onImagesResetEnd() {
    setState(() {
      isImagesReset = false;
    });
  }

  void onImagesReset() {
    setState(() {
      isImagesReset = true;
    });
  }

  Widget timelineUnderGlassPanel(double glassPanelWidth, double screenHeight,
      double blur, Color radioBackLightColor, Color radioGlassColor) {
    return Stack(
      children: [
        timelineSection(glassPanelWidth, screenHeight),

        // glass with orange light
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Stack(
                  children: [
                    // inner light
                    Container(
                      decoration: BoxDecoration(
                        color: radioBackLightColor.withOpacity(0.1),
                        gradient: LinearGradient(
                          colors: [
                            // Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.3)
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),

                    // subtle orange
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return RadialGradient(
                          center: const Alignment(0, 1),
                          radius: 2,
                          colors: [
                            radioBackLightColor.withOpacity(0.3),
                            radioBackLightColor.withOpacity(0.15),
                            radioBackLightColor.withOpacity(0.05),
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.softLight,
                      child: Container(
                        color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                      ),
                    ),

                    // red light
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return RadialGradient(
                          center: const Alignment(0, -1),
                          radius: 2,
                          colors: [
                            Colors.red.withOpacity(0.08),
                            Colors.red.withOpacity(0.02),
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.softLight,
                      child: Container(
                        color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                      ),
                    ),

                    // white light
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return RadialGradient(
                          center: const Alignment(0, 1),
                          radius: 3,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.01),
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.softLight,
                      child: Container(
                        color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                      ),
                    ),

                    // black shadow
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return RadialGradient(
                            center: const Alignment(0, 0),
                            radius: 1.68,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.068),
                              Colors.black.withOpacity(0.268),
                            ],
                            stops: const [
                              0,
                              0.5,
                              0.9
                            ]).createShader(bounds);
                      },
                      blendMode: BlendMode.softLight,
                      child: Container(
                        color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                      ),
                    ),

                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Opacity(
                          opacity: 0.068,
                          child: Image.asset(
                            'assets/images/glass2.png',
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.screen,
                            color: Colors.white.withOpacity(0),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Widget timelineSection(double widgetWidth, double screenHeight) {
    double paddingW = widgetWidth * 0.0168;
    return Neumorphic(
      style: NeumorphicStyle(
          // lightSource: neumorphicLightSource,
          color: config.mainBackGroundWhite,
          shape: NeumorphicShape.convex,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(6)),
          intensity: 1,
          depth: -1),
      child: Padding(
          padding: EdgeInsets.all(paddingW),
          child: Column(
            children: [
              Neumorphic(
                style: NeumorphicStyle(
                    // lightSource: neumorphicLightSource,
                    color: config.mainBackGroundWhite,
                    shape: NeumorphicShape.convex,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(2)),
                    intensity: 1,
                    depth: -2.68),
                child: HorizontalDateTimeline(
                  size: Size(
                    widgetWidth - paddingW * 2,
                    screenHeight * 0.05,
                  ),
                  selectedDate: selectedDate,
                  photosCountPerDay: photosCountPerDay,
                  modeType: modeDate,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Neumorphic(
                style: NeumorphicStyle(
                    // lightSource: neumorphicLightSource,
                    color: config.mainBackGroundWhite,
                    shape: NeumorphicShape.convex,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(2)),
                    intensity: 1,
                    depth: -2.68),
                child: HorizontalDateTimeline(
                  size: Size(
                    widgetWidth - paddingW * 2,
                    screenHeight * 0.025,
                  ),
                  selectedDate: selectedDate,
                  photosCountPerDay: photosCountPerDay,
                  modeType: modeMonth,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Neumorphic(
                style: NeumorphicStyle(
                    // lightSource: neumorphicLightSource,
                    color: config.mainBackGroundWhite,
                    shape: NeumorphicShape.convex,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(2)),
                    intensity: 1,
                    depth: -2.68),
                child: HorizontalDateTimeline(
                  size: Size(
                    widgetWidth - paddingW * 2,
                    screenHeight * 0.025,
                  ),
                  selectedDate: selectedDate,
                  photosCountPerDay: photosCountPerDay,
                  modeType: modeYear,
                ),
              ),
            ],
          )),
    );
  }

  Future<void> setTargetAlbumNames(List<String> targetAlbumNames) async {
    this.targetAlbumNames = targetAlbumNames;

    print(
        '====== [main] setTargetAlbumNames,this.targetAlbumNames ${this.targetAlbumNames} ');
    await updateDateRangeFromAlbums(targetAlbumNames);
  }

  Future<void> updateDateRangeFromAlbums(List<String> targetAlbums) async {
    await setDatesOfSelectedAlbums(targetAlbums);
    setState(() {
      selectedDate = datesOfSelectedAlbum[0];
    });
  }

  Future<void> setDatesOfSelectedAlbums(List<String> targetAlbums) async {
    datesOfSelectedAlbum.clear();
    photosCountPerDay.clear();

    // 1. 取得所有相簿
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    // 2. 遍歷所有目標相簿名稱
    for (final target in targetAlbums) {
      final album = albums.firstWhereOrNull((a) => a.name == target);

      if (album == null) {
        debugPrint('⚠️ 相簿未找到: $target');
        continue;
      }

      // 3. 取得相簿內所有照片
      final count = await album.assetCountAsync;
      final assets = await album.getAssetListPaged(page: 0, size: count);

      for (final asset in assets) {
        final dt = asset.createDateTime;
        final dateOnly = DateTime(dt.year, dt.month, dt.day);

        if (!photosCountPerDay.containsKey(dateOnly)) {
          datesOfSelectedAlbum.add(dateOnly);
          photosCountPerDay[dateOnly] = 1;
        } else {
          photosCountPerDay[dateOnly] = photosCountPerDay[dateOnly]! + 1;
        }
      }
    }

    // 4. 日期排序（從新到舊）
    datesOfSelectedAlbum.sort((a, b) => b.compareTo(a));

    print('====== sorted? : $datesOfSelectedAlbum');
    print('====== photosCountPerDay? : $photosCountPerDay');
  }

  void setSelectedDateByOffset(int x) {
    if (datesOfSelectedAlbum.isEmpty) {
      return;
    }

    targetDatePointer = (targetDatePointer + x) < 0
        ? datesOfSelectedAlbum.length - 1
        : (targetDatePointer + x) >= datesOfSelectedAlbum.length
            ? 0
            : targetDatePointer + x;
    setState(() {
      selectedDate = datesOfSelectedAlbum[targetDatePointer];
      // scrollOffset = 0;
    });
  }

  void setImagesWithDummiesPointer(int indexWithDummies) {
    setState(() {
      imageWithDummiesPointer = indexWithDummies;
    });
  }

  void setImagesWithDummiesLength(int imagesWithDummiesLength) {
    setState(() {
      this.imagesWithDummiesLength = imagesWithDummiesLength;
    });
  }

  void setEXIFOfPointedImg(Map<String?, IfdTag> data) {
    setState(() {
      shutterSpeed = data['EXIF ShutterSpeedValue']?.printable != null
          ? ImageUtils.formatShutterSpeed(
              data['EXIF ShutterSpeedValue']!.printable!)
          : '0';
      aperture = data['EXIF ApertureValue']?.printable != null
          ? ImageUtils.formatAperture(data['EXIF ApertureValue']!.printable!)
          : '0';
      iso = data['EXIF ISOSpeedRatings']?.printable ?? '未知';
    });
  }

  void onMenuItemSelected(int newIndex) {
    print('====== newIndex $newIndex');
    if (newIndex == menuPointer) return;

    // 👉 取消先前設定的延遲動畫，避免動畫疊加。
    _timer?.cancel();

    final oldIndex = menuPointer;

    // 👉 在動畫前，先記錄下每個項目的目前 depth 狀態，供動畫補間用。
    for (int i = 0; i < depths.length; i++) {
      prevDepths[i] = depths[i];
    }

    // 👉 讓舊的選中項目先變凹陷（浮起 ➝ 凹陷），動畫開始。
    // setState(() {
    //   depths[oldIndex] = _depthMin;
    // });

    // 👉 延遲結束後，做兩件事：
    //
    // 舊的選中項目變成靜止狀態（浮起 ➝ 0.3）。
    //
    // 新選中項目進入凹陷過渡狀態（0.3 ➝ 0.0）。
    //
    // 更新 menuPointer。
    _timer = Timer(Duration(milliseconds: 500), () {
      // 👉 設定一個延遲 1000ms 的 Timer，等動畫執行完再做下一步。
      setState(() {
        for (int i = 0; i < depths.length; i++) {
          prevDepths[i] = depths[i]; // 儲存當前狀態
        }

        depths[oldIndex] = _depthNormal;
        depths[newIndex] = _depthMax;
        menuPointer = newIndex;
      });

      // Timer(Duration(milliseconds: 500), () { // 👉 再設定下一段延遲動畫（1000ms），做最後一段動畫。
      //   setState(() {
      //     for (int i = 0; i < depths.length; i++) {
      //       prevDepths[i] = depths[i]; // 再次更新
      //     }
      //
      //     depths[newIndex] = _depthMax; // 👉 把新選中項目從凹陷 ➝ 浮起，讓動畫從 0.0 ➝ 0.8。
      //   });
      // });
    });
  }

  void _showPopWarningDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('正在離開...'),
        content: const Text(''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            // Close the app
            child: const Text('關閉app'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      setState(() {
        _canPop = true;
      });
      Navigator.of(context)
          .maybePop(); // Close the app after setting canPop to true
    }
  }
}

class VisitingText extends StatefulWidget {
  final Attraction visitingAttraction;
  final Function(BuildContext context, double screenHeight, double screenWidth)
      clickAddNewTicketButton;

  const VisitingText(this.visitingAttraction, this.clickAddNewTicketButton,
      {Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VisitingTextState createState() => _VisitingTextState();
}

class _VisitingTextState extends State<VisitingText> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth,
      height: screenHeight * 0.1,
      // color: Colors.red,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align text to top
          children: <Widget>[
            const Spacer(),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.visitingAttraction.name,
                        style: const TextStyle(
                            fontSize: 25,
                            fontFamily: 'Open-Sans',
                            fontWeight: FontWeight.w300)),
                  ],
                )),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class ChasingView extends StatefulWidget {
  final double chasingViewHeight;
  final double screenWidth;
  final double screenHeight;
  final double sensorDegree;
  final double heading;

  final Attraction home;
  final Attraction visitingAttraction;
  final VoidCallback toggleChasingMode;

  const ChasingView(
      this.toggleChasingMode,
      this.screenHeight,
      this.screenWidth,
      this.chasingViewHeight,
      this.sensorDegree,
      this.heading,
      this.home,
      this.visitingAttraction,
      {Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChasingViewState createState() => _ChasingViewState();
}

class _ChasingViewState extends State<ChasingView> {
  late Timer _timer;
  final int fetchLocationIntervalSeconds = 10;

  double userLatitude = 0.0;
  double userLongitude = 0.0;

  double _currentHeading = 0.0;
  late StreamSubscription<CompassEvent> _compassStreamSubscription;

  List<DisplayBottle> bottles = [];

  @override
  void initState() {
    super.initState();

    // For N E W
    bottles = [
      DisplayBottle('E', 0, 150, 24.397630, 121.264331), // taiwan
      DisplayBottle('N', 90, 100, 35.622522, 139.720624), // zis
      DisplayBottle('W', 180, 150, 24.397630, 121.264331),
    ];

    _getUserLocation(widget.home);
    _initCompass();

    // Set up a periodic timer to call _getUserLocation every 5 seconds
    _timer = Timer.periodic(Duration(seconds: fetchLocationIntervalSeconds),
        (timer) {
      _getUserLocation(widget.home);
    });

    print('====== endof init');
  }

  Future<void> _getUserLocation(Attraction targetAttraction) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          // Handle location permission denied
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
        var distanceInMeters = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            targetAttraction.latitude,
            targetAttraction.longitude);
        targetAttraction.distance = distanceInMeters / 1000;
      });
    } catch (e) {
      // Handle location fetch errors
      print('Error getting user location: $e');
    }
  }

  void _initCompass() {
    Stream<CompassEvent> emptyStream = Stream<CompassEvent>.empty();
    _compassStreamSubscription = FlutterCompass.events?.listen((event) {
          setState(() {
            _currentHeading = event.heading ?? 0.0;
          });
        }) ??
        emptyStream.listen((event) {});
  }

  @override
  void dispose() {
    _compassStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LightSource neumorphicLightSource = LightSource.topLeft;

    double sensorRadius = widget.chasingViewHeight * 0.3;
    double smallSensorRadius = widget.chasingViewHeight * 0.05;
    double dentRadius = sensorRadius + smallSensorRadius * 3.2;
    double backgroundRadius = sensorRadius + smallSensorRadius * 3.6;
    double rotatedNRadius = sensorRadius - smallSensorRadius * 0.5;

    final double targetRadiusToCenter = sensorRadius + smallSensorRadius * 2;
    final double centerX = ((widget.screenWidth / 2) - smallSensorRadius);
    final double centerY = ((widget.chasingViewHeight / 2) - smallSensorRadius);

    List<Widget> targets = [];

    // display subsequent two items.
    for (int i = 0; i < bottles.length; i++) {
      double leftX = centerX +
          RotationUtils.radiusProjector(
                  bottles[i].bearingAngle + _currentHeading,
                  targetRadiusToCenter)
              .dx;
      double topY = centerY -
          RotationUtils.radiusProjector(
                  bottles[i].bearingAngle + _currentHeading,
                  targetRadiusToCenter)
              .dy;
      targets.add(Positioned(
        left: leftX,
        top: topY,
        child: Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              // surfaceIntensity: 0.5,
              boxShape: const NeumorphicBoxShape.circle(),
              intensity: 0.9,
              depth: 1.5,
              lightSource: neumorphicLightSource,
            ),
            child: Container(
                color: config.backGroundWhite,
                width: smallSensorRadius * 2,
                height: smallSensorRadius * 2,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(bottles[i].name,
                      style: TextStyle(
                          fontSize: 0.36 * smallSensorRadius,
                          fontWeight: FontWeight.bold)),
                ))),
      ));
    }

    return SizedBox(
      height: widget.chasingViewHeight,
      child: Stack(
        children: [
          // rim
          Align(
            alignment: Alignment.center,
            child: Neumorphic(
                style: const NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  intensity: 1,
                  depth: 1.5,
                ),
                child: Container(
                  color: config.backGroundWhite,
                  width: (backgroundRadius * 2),
                  height: (backgroundRadius * 2),
                )),
          ),

          // dent
          Align(
            alignment: Alignment.center,
            child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: const NeumorphicBoxShape.circle(),
                  intensity: 0.8,
                  lightSource: neumorphicLightSource,
                  color: config.backGroundWhite,
                  depth: -5,
                ),
                child: Container(
                  color: config.backGroundWhite,
                  width: (dentRadius * 2),
                  height: (dentRadius * 2),
                )),
          ),

          // hint
          Align(
            alignment: Alignment.center,
            child: NeumorphicButton(
                style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: const NeumorphicBoxShape.circle(),
                    intensity: 0.8,
                    depth: 1,
                    lightSource: neumorphicLightSource,
                    color: config.backGroundWhite,
                    border: const NeumorphicBorder(
                      color: config.border,
                      width: 0.3,
                    )),
                onPressed: () {
                  widget.toggleChasingMode();
                },
                child: SizedBox(
                  // color: Colors.red,
                  height: (sensorRadius) * 2,
                  width: (sensorRadius) * 2,

                  child: Center(
                      child: SizedBox(
                    height: (sensorRadius) * 2,
                    width: (sensorRadius) * 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // monitor background
                        Center(
                          child: Container(
                            width: sensorRadius * 2,
                            height: sensorRadius * 2,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/monitor.png'),
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                        Center(
                            child: SizedBox(
                                width: sensorRadius * 2,
                                height: sensorRadius * 2,
                                child: Column(
                                  children: [
                                    const Spacer(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Spacer(),
                                        SizedBox(
                                          child: Text(
                                            'Next 新幹線 leaves in : ',
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize:
                                                  widget.screenWidth * 0.03,
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Spacer(),
                                        SizedBox(
                                          child: Text(
                                            '1 H : 30 M',
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize:
                                                  widget.screenWidth * 0.06,
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Spacer(),
                                        SizedBox(
                                          child: Text(
                                            'Home: ',
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize:
                                                  widget.screenWidth * 0.035,
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            child: Text(
                                          (widget.home.distance != null)
                                              ? widget.home.distance!
                                                  .toStringAsFixed(3)
                                              : 'calc...',
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                widget.screenWidth * 0.035,
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                          ),
                                        )),
                                        SizedBox(
                                            width: widget.screenWidth * 0.01),
                                        Text(
                                          'KM',
                                          style: TextStyle(
                                            fontSize: widget.screenWidth * 0.02,
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'Open-Sans', // Replace 'SecondFontFamily' with your desired font family
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    const Spacer(),
                                  ],
                                ))),
                      ],
                    ),
                  )),
                )),
          ),

          Stack(children: targets),
        ],
      ),
    );
  }
}

class DisplayBottle {
  String name;
  double bearingAngle;
  double distance;
  double latitude;
  double longitude;

  DisplayBottle(this.name, this.bearingAngle, this.distance, this.latitude,
      this.longitude);
}
