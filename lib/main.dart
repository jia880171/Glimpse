// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:geolocator/geolocator.dart';
import 'package:glimpse/perpetual_view.dart';
import 'package:photo_manager/photo_manager.dart';
import ' waterfall_view.dart';
import './config.dart' as config;
import 'attractions_view.dart';
import 'bottom_tourist_list_view.dart';
import 'tickets_view.dart';
import 'database/ticket.dart';
import 'database/attraction.dart';
import 'database/ticket_db.dart';
import 'database/attraction_db.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import './add_attraction_view.dart';
import './add_ticket_view.dart';

import 'Routes.dart';

void main() {
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
        // primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: Routes.getRoutes(),
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
  bool isChasingMode = true;
  bool isDisplayAttractionsView = false;
  bool hideUsedTickets = false;
  bool isShowFilms = true;

  double panelScale = 1;
  bool isPanelBig = true;
  Timer? _timer;

  int year = 2024;
  int month = 1;
  int day = 1;
  int glimpseCount = 0;

  late DateTime selectedDate;

  // var mode = Modes.chasingAttraction;

  void startCountdown() {
    print('====== start timer');

    // 如果已有倒计时，先取消
    _timer?.cancel();

    // 启动一个新的倒计时
    _timer = Timer(const Duration(milliseconds: 3500), () {
      print('======== times up');
      setState(() {
        isPanelBig = false;
        panelScale = 0.3; // 可根据需要调整
      });
    });
  }

  // Taiwan
  Attraction home = Attraction(
      sequenceNumber: 0,
      name: 'Taiwan',
      memo: 'Default',
      date: '19930312',
      longitude: 121.597366,
      latitude: 25.105497,
      arrivalTime: '199303121',
      departureTime: '19931312',
      arrivalStation: 'tokyo',
      departureStation: 'tokyo',
      isVisited: false,
      isNavigating: false,
      isVisiting: false);

  late Attraction clickedAttraction;

  late Attraction visitingAttraction;

  void makePanelSmall() {
    setState(() {
      if (isPanelBig) {
        isPanelBig = false;
        panelScale = 0.3;
      }
    });
  }

  void _togglePanel() {
    print('====== _togglePanel is triggered');
    startCountdown();

    setState(() {
      if (!isPanelBig) {
        isPanelBig = true;
        panelScale = 1;
      }
    });
  }

  void updateHome(Attraction attraction) {
    setState(() {
      home = attraction;
    });
  }

  void updateVisitingAttraction(Attraction attraction) {
    setState(() {
      visitingAttraction = attraction;
    });
  }

  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Ticket> tickets = []; // Store fetched tickets

  final AttractionDatabaseHelper attractionDatabaseHelper =
      AttractionDatabaseHelper();
  List<Attraction> attractions = [];

  @override
  void initState() {
    super.initState();
    print('====== main init');
    fetchTickets();
    fetchAttractions();
    selectedDate = DateTime(year, month, day);
    visitingAttraction = home;
    startCountdown();
  }

  Future<void> fetchTickets() async {
    print('====== fetching Tickets... ');

    List<Ticket> fetchedTickets = await databaseHelper.getTickets();
    setState(() {
      tickets = fetchedTickets;
      print('====== fetched tickets: $tickets');
    });
  }

  Future<void> fetchAttractions() async {
    print('====== fetching Attractions... ');

    List<Attraction> fetchedAttractions =
        await attractionDatabaseHelper.getAttractions();

    setState(() {
      attractions = fetchedAttractions;

      // Find the last visited attraction and use it to refresh visiting attraction.
      var lastVisitedAttraction = home;

      for (Attraction attraction in attractions) {
        if (attraction.isVisited == true) {
          lastVisitedAttraction = attraction;
        }
      }

      updateVisitingAttraction(lastVisitedAttraction);
    });
  }

  void toggleDisplayAttractionsView(Attraction? attraction) {
    setState(() {
      if (attraction != null) {
        clickedAttraction = attraction;
      }
      isDisplayAttractionsView = !isDisplayAttractionsView;
    });
  }

  void toggleChasingMode() {
    setState(() {
      isChasingMode = !isChasingMode;
    });
  }

  void showAddAttractionDialog(double screenHeight, double screenWidth) {
    AddAttractionView floatAttractionCardView = AddAttractionView(
      widgetHeight: screenHeight * 0.5,
      screenWidth: screenWidth,
      cardWidth: screenWidth * 0.7,
    );

    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0.8),
      builder: (BuildContext context) {
        return Theme(
            data: ThemeData(
              useMaterial3: false,
            ),
            child: AlertDialog(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.0),
              // title: const Text('New Attraction'),
              content: floatAttractionCardView,
              actions: <Widget>[
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close',
                      style: TextStyle(color: Colors.black)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    double? latitude;
                    double? longitude;
                    final locationText =
                        floatAttractionCardView.locationController.text;
                    final locationValues = locationText.split(',');
                    if (locationValues.length == 2) {
                      latitude = double.tryParse(locationValues[0].trim());
                      longitude = double.tryParse(locationValues[1].trim());
                    }

                    final newAttraction = Attraction.withAutoIncrement(
                      name: floatAttractionCardView.nameController.text,
                      memo: floatAttractionCardView.memoController.text,
                      date: floatAttractionCardView.dateController.text,
                      latitude: latitude ?? 0.0,
                      longitude: longitude ?? 0.0,
                      departureTime:
                          floatAttractionCardView.departureTimeController.text,
                      arrivalTime:
                          floatAttractionCardView.arrivalTimeController.text,
                      departureStation: floatAttractionCardView
                          .departureStationController.text,
                      arrivalStation:
                          floatAttractionCardView.arrivalStationController.text,
                      isVisited: false,
                      isNavigating: false,
                      isVisiting: false,
                    );

                    await attractionDatabaseHelper
                        .insertAttraction(newAttraction);

                    fetchAttractions();

                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Spacer(),
                const Spacer(),
              ],
            ));
      },
    );
  }

  void showAddTicketDialog(double screenHeight, double screenWidth) {
    AddTicketView floatCardView = AddTicketView(
      widgetHeight: screenHeight * 0.5,
      screenWidth: screenWidth,
      cardWidth: screenWidth * 0.7,
    );

    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0.96),
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          backgroundColor: Colors.white.withOpacity(0.0),
          // title: const Text('New Ticket'),
          content: floatCardView,
          actions: <Widget>[
            const Spacer(),
            // close button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const Spacer(),

            // create button
            TextButton(
              onPressed: () async {
                final newTicket = Ticket(
                  memo: floatCardView.memoController.text,
                  date: floatCardView.dateController.text,
                  departureTime: floatCardView.departureTimeController.text,
                  arrivalTime: floatCardView.arrivalTimeController.text,
                  trainName: floatCardView.trainNameController.text,
                  trainNumber: floatCardView.trainNumberController.text,
                  carNumber: floatCardView.carNumberController.text,
                  row: floatCardView.rowNumberController.text,
                  seat: floatCardView.seatNumberController.text,
                  departureStation:
                      floatCardView.departureStationController.text,
                  arrivalStation: floatCardView.arrivalStationController.text,
                  isUsed: false,
                );

                await databaseHelper.insertTicket(newTicket);

                fetchTickets();

                Navigator.of(context).pop();
              },
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const Spacer(),
            const Spacer(),
          ],
        );
      },
    );
  }

  // add new ticket or tourist
  void clickAddButton(
      BuildContext context, double screenHeight, double screenWidth) async {
    if (isChasingMode) {
      showAddAttractionDialog(screenHeight, screenWidth);
    } else {
      showAddTicketDialog(screenHeight, screenWidth);
    }
  }

  void _showWarningDialog() async {
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

  void setDate(int year, int month, int day) {
    setState(() {
      this.year = year;
      this.month = month;
      this.day = day;
      selectedDate = DateTime(year, month, day);
    });
  }

  void setGlimpseCount(int count) {
    setState(() {
      glimpseCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TicketsView ticketsView = TicketsView(hideUsedTickets, screenHeight * 0.6,
        screenWidth, screenWidth * 0.8, tickets);

    return PopScope(
      canPop: _canPop,
      onPopInvoked: (canPop) {
        if (!_canPop) {
          _showWarningDialog();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.dark, // Dark status bar icons (like time, battery)
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: screenWidth,
              height: screenHeight,
              // color: config.backGroundWhite,
              child: Stack(

                  children: [
                // Container(
                //   color: Colors.red,
                //   height: screenHeight,
                //   width: screenWidth,
                // ),

                Opacity(
                  opacity: (isShowFilms == true) ? 1.0 : 0.0,
                  // opacity: 1.0,
                  child: Transform.rotate(
                    angle: 0 * 3.1415926535897932 / 180,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight,
                      child: WaterfallView(
                        selectedDate: selectedDate,
                        setGlimpseCount: setGlimpseCount,
                      ),
                    ),
                  ),
                ),

                // panel
                Positioned(
                  bottom: screenHeight * 0.02,
                  left: 0,
                  child: GestureDetector(
                    onTap: _togglePanel,
                    child: AnimatedScale(
                      scale: panelScale,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Transform.rotate(
                        angle: 0 * 3.1415926535897932 / 180,
                        child: PerpetualView(
                            screenHeight * 0.38,
                            screenWidth,
                            home,
                            setDate,
                            glimpseCount,
                            isPanelBig,
                            makePanelSmall,
                            startCountdown),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
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
          AngleCalculator()
              .radiusProjector(bottles[i].bearingAngle + _currentHeading,
                  targetRadiusToCenter)
              .dx;
      double topY = centerY -
          AngleCalculator()
              .radiusProjector(bottles[i].bearingAngle + _currentHeading,
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
                  // lightSource: neumorphiclightSource,
                  // color: config.themeColor,
                  depth: 1.5,
                  // border: NeumorphicBorder(
                  //   color: config.backGroundWhite10,
                  //   width: 2,
                  // )
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

          // rotated N
          // IgnorePointer(
          //   ignoring: true,
          //   child: Align(
          //       alignment: Alignment.center,
          //       child: Transform.rotate(
          //         angle: _currentHeading * (3.14159 / 180) * -1,
          //         child: Container(
          //           height: rotatedNRadius * 2,
          //           width: rotatedNRadius * 2,
          //           decoration: const BoxDecoration(
          //             shape: BoxShape.circle,
          //           ),
          //           child: Stack(
          //             children: [
          //               Align(
          //                 alignment: Alignment.topCenter,
          //                 child: Text('N',
          //                     style: TextStyle(
          //                         color: Colors.black,
          //                         fontSize: widget.screenHeight * 0.025)),
          //               ),
          //               Align(
          //                 alignment: Alignment.center,
          //                 child: Row(
          //                   children: [
          //                     Text('－',
          //                         style: TextStyle(
          //                             color: Colors.black,
          //                             fontSize: widget.screenHeight * 0.02)),
          //                     const Spacer(),
          //                     Text('－',
          //                         style: TextStyle(
          //                             color: Colors.black,
          //                             fontSize: widget.screenHeight * 0.02)),
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       )),
          // ),

          Stack(children: targets),
        ],
      ),
    );
  }
}

class AngleCalculator {
  Offset radiusProjector(double degree, double radius) {
    degree = 2 * math.pi * (degree / 360);
    double x = radius * math.cos(degree);
    double y = radius * math.sin(degree);

    return Offset(x, y);
  }

  double calculateRotateAngleForContainer(double degree) {
    return -(2 * math.pi * ((degree) / 360));
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
