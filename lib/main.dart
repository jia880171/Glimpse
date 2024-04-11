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

// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:geolocator/geolocator.dart';
import './config.dart' as config;
import './ticket.dart';
import './attraction.dart';
import './ticket_db.dart';
import './attraction_db.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

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
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".fds

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isChasingMode = true;
  bool hideUsedTickets = false;

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

  late Attraction visitingAttraction = home;

  void updateHome(Attraction attraction) {
    setState(() {
      print('====== updating home');
      home = attraction;
    });
  }

  void updateVisitingAttraction(Attraction attraction) {
    setState(() {
      print('====== updating visiting target');
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
    fetchTickets();
    fetchAttractions();
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
      print('====== fetched attractions: $attractions');

      // refresh visiting attraction
      for (Attraction attraction in attractions) {
        print('====== attraction: ${attraction.name}');
        print('====== attraction: ${attraction.isVisiting}');

        if (attraction.isVisiting == true) {
          print('====== update visiting attraction');
          updateVisitingAttraction(attraction);
        }
      }
      print('====== visiting refreshed');
    });
  }

  void toggleChasingMode() {
    print('======Chasing mode toggled');
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
      builder: (BuildContext context) {
        return Theme(
            data: ThemeData(
              useMaterial3: false,
            ),
            child: AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('New Attraction'),
              content: floatAttractionCardView,
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close',
                      style: TextStyle(color: Colors.black)),
                ),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Ticket'),
          content: floatCardView,
          actions: <Widget>[
            // close button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
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
              child: const Text('Create'),
            ),
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TicketsView ticketsView = TicketsView(hideUsedTickets, screenHeight * 0.6,
        screenWidth, screenWidth * 0.8, tickets);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Dark status bar icons (like time, battery)
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            color: config.backGroundWhite,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: screenHeight,
                    ),
                    Positioned(
                      top: screenHeight * 0.1,
                      left: 0,
                      right: 0,
                      child: Stack(
                        children: [
                          ChasingView(
                              toggleChasingMode,
                              screenHeight,
                              screenWidth,
                              screenHeight * 0.38,
                              20.0,
                              10.0,
                              home,
                              visitingAttraction),
                        ],
                      ),
                    ),
                    if (isChasingMode)
                      Positioned(
                        top: screenHeight * 0.5,
                        left: 0,
                        right: 0,
                        height: screenHeight,
                        child: Column(
                          children: [
                            VisitingText(visitingAttraction, clickAddButton),
                            BottomTouristList(
                                screenHeight,
                                screenWidth,
                                attractions,
                                attractionDatabaseHelper,
                                home,
                                updateVisitingAttraction)
                          ],
                        ),
                      ),
                    if (!isChasingMode)
                      Positioned(
                        // top: screenHeight * 0.25,
                        left: 0,
                        right: 0,
                        child: Container(
                            height: screenHeight,
                            color: const Color.fromARGB(239, 255, 255, 255),
                            child: Stack(
                              children: [
                                Positioned(
                                    top: screenHeight * 0.05,
                                    child: BackButton(
                                      onPressed: () => {toggleChasingMode()},
                                    )),
                                Column(
                                  children: [
                                    // SizedBox(height: screenHeight * 0.1),
                                    const Spacer(),
                                    ticketsView,
                                    const Spacer(),

                                    // SizedBox(height: screenHeight * 0.05)
                                  ],
                                ),
                              ],
                            )),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: NeumorphicButton(
              style: const NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.circle(),
                  intensity: 0.8,
                  depth: 1,
                  lightSource: LightSource.topLeft,
                  color: config.backGroundWhite,
                  border: NeumorphicBorder(
                    color: config.border,
                    width: 0.3,
                  )),
              onPressed: () {
                clickAddButton(context, screenHeight, screenWidth);
                // widget.toggleChasingMode();
              },
              child: SizedBox(
                // color: Colors.red,
                height: (screenHeight) * 0.05,
                width: (screenHeight) * 0.05,

                child: Center(
                    child: SizedBox(
                        // color: Colors.red,
                        height: (screenHeight) * 0.03,
                        width: (screenHeight) * 0.03,
                        child: const Center(child: Icon(Icons.add)))),
              )),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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

    // if(widget.visitingAttraction != null){
    //   print('====== visitingAttraction name: ${widget.visitingAttraction.name}');
    //   print('====== visitingAttraction isVisiting: ${widget.visitingAttraction.isVisiting}');
    // }

    // Set up a periodic timer to call _getUserLocation every 5 seconds
    _timer = Timer.periodic(Duration(seconds: fetchLocationIntervalSeconds),
        (timer) {
      _getUserLocation(widget.home);
    });

    print('====== endof init');
  }

  Future<void> _getUserLocation(Attraction targetAttraction) async {
    try {
      print('=======_getUserLocation start');
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
      print('=======_getUserLocation end');
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

class BottomTouristList extends StatefulWidget {
  final List<Attraction> attractions;
  final double screenWidth;
  final double screenHeight;

  final AttractionDatabaseHelper attractionDatabaseHelper;
  final Attraction visitingAttraction;
  final Function(Attraction) updateVisitingAttraction;

  BottomTouristList(
    this.screenHeight,
    this.screenWidth,
    this.attractions,
    this.attractionDatabaseHelper,
    this.visitingAttraction,
    this.updateVisitingAttraction, {
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BottomTouristListState createState() => _BottomTouristListState();
}

class _BottomTouristListState extends State<BottomTouristList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight * 0.3,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: widget.attractions.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: index == 0
                    ? const BorderSide(
                        color: Colors.grey, // Customize the color as needed
                        width: 0.5, // Customize the width as needed
                      )
                    : BorderSide.none,
                bottom: const BorderSide(
                  color: Colors.grey, // Customize the color as needed
                  width: 0.5, // Customize the width as needed
                ),
              ),
            ),
            child: ListTile(
              title: Text(widget.attractions[index].name,
                  style: TextStyle(
                      fontFamily: 'Lucida',
                      fontSize: widget.screenWidth * 0.05,
                      fontWeight: FontWeight.normal)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // flag(visited) icon
                  SizedBox(
                    height: widget.screenHeight * 0.05,
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        depth: widget.attractions[index].isVisited ? -1.5 : 1.5,
                        color: config.backGroundWhite,
                      ),
                      onPressed: () async {
                        setState(() {
                          widget.attractions[index].isVisited =
                              !widget.attractions[index].isVisited;
                          widget.attractions[index].isVisiting = true;
                          widget.updateVisitingAttraction(
                              widget.attractions[index]);
                        });

                        await widget.attractionDatabaseHelper
                            .updateAttraction(widget.attractions[index]);
                      },
                      child: Center(
                        child: NeumorphicIcon(
                          style: const NeumorphicStyle(
                            depth: 1,
                            color: config.flagRed,
                          ),
                          Icons.flag_circle,
                          size: widget.screenHeight * 0.03,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widget.screenWidth * 0.03,
                  ),

                  // Navigation icon
                  // when the button is clicked the item will be set to navigation target
                  // SizedBox(
                  //   height: widget.screenHeight * 0.05,
                  //   child: NeumorphicButton(
                  //     style: NeumorphicStyle(
                  //       depth:
                  //           widget.attractions[index].isNavigating ? -1.5 : 1.5,
                  //       color: config.backGroundWhite,
                  //     ),
                  //     onPressed: () async {
                  //       for (int i = 0; i < widget.attractions.length; i++) {
                  //         widget.attractions[i].isNavigating = false;
                  //         await widget.attractionDatabaseHelper
                  //             .updateAttraction(widget.attractions[i]);
                  //       }
                  //       widget.attractions[index].isNavigating = true;
                  //       await widget.attractionDatabaseHelper
                  //           .updateAttraction(widget.attractions[index]);
                  //
                  //       setState(() {
                  //         widget.updateTargetAttraction(
                  //             widget.attractions[index]);
                  //         // for (int i = 0; i < widget.attractions.length; i++) {
                  //         //   widget
                  //         //       .updateTargetAttraction(widget.attractions[i]);
                  //         // }
                  //       });
                  //     },
                  //     child: Center(
                  //       child: NeumorphicIcon(
                  //         style: const NeumorphicStyle(
                  //           depth: 1,
                  //           color: Colors.grey,
                  //         ),
                  //         Icons.navigation,
                  //         size: widget.screenHeight * 0.03,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TicketsView extends StatefulWidget {
  bool isHideUsedTickets;

  final double screenWidth;
  final double widgetHeight;
  final double cardWidth;

  // all tickets
  List<Ticket> tickets;

  // tickets to display
  late List<Ticket> ticketsToDisplay;

  TicketsView(
    this.isHideUsedTickets,
    this.widgetHeight,
    this.screenWidth,
    this.cardWidth,
    this.tickets, {
    Key? key,
  })  : ticketsToDisplay = getTicketsToDisplay(tickets),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TicketsViewState createState() => _TicketsViewState();

  static List<Ticket> getTicketsToDisplay(List<Ticket> tickets,
      [bool isHideUsedTickets = false]) {
    List<Ticket> ticketsToDisplay = isHideUsedTickets
        ? tickets.where((ticket) => ticket.isUsed == false).toList()
        : tickets;

    return ticketsToDisplay;
  }

  // Print all Ticket objects in the list
  static void printTickets(List<Ticket> tickets) {
    for (Ticket ticket in tickets) {
      print(
          'Ticket ID: ${ticket.id}, departureStation: ${ticket.departureStation}');
    }
  }
}

class _TicketsViewState extends State<TicketsView> {
  List<Widget> barcode = [];
  final StreamController<String> controller = StreamController<String>();


  void setText(value) {
    controller.add(value);
  }

  void show(BuildContext context){
    print('====== showohwoehw');
    showDialog(context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Ticket'),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ScalableOCR(
                    paintboxCustom: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4.0
                      ..color = const Color.fromARGB(153, 102, 160, 241),
                    boxLeftOff: 5,
                    boxBottomOff: 2.5,
                    boxRightOff: 5,
                    boxTopOff: 2.5,
                    boxHeight: MediaQuery.of(context).size.height / 3,
                    getRawData: (value) {
                      inspect(value);
                    },
                    getScannedText: (value) {
                      setText(value);
                    }),
                StreamBuilder<String>(
                  stream: controller.stream,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Result(text: snapshot.data != null ? snapshot.data! : "");
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            // close button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            // create button
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String backgroundHint = '車票列表，可在此快速查看起迄時間並翻閱備忘。';
    generateBarcode(barcode);

    return Container(
        // color: Colors.white,
        height: widget.widgetHeight,
        child: Stack(
          children: [

            Padding(
              padding: EdgeInsets.all(widget.cardWidth * 0.1),
              child: SizedBox(
                width: widget.cardWidth * 0.6,
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      backgroundHint,
                      style: TextStyle(
                          fontSize: widget.cardWidth * 0.05,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            widget.ticketsToDisplay.isNotEmpty
                ? ListView.builder(
                    // shrinkWrap: true,
                    itemCount: widget.ticketsToDisplay.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                              widget.cardWidth * 0.7, 0, 0, 0),
                          child: Row(
                            children: [
                              Card(
                                  elevation: 2.5,
                                  color: config.ticketBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // side: const BorderSide(color: Colors.black, width: 0)
                                  ),
                                  child: Container(
                                    height: widget.widgetHeight,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Column(
                                        children: [
                                          Card(
                                            shape: BeveledRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.5),
                                              // side: const BorderSide(
                                              //     color: Colors.black, width: 0.15),
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: config.memoWhite,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.5)),
                                                // color: Colors.blueGrey,
                                                width: widget.cardWidth,
                                                height:
                                                    widget.widgetHeight * 0.5,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 5, 5, 5),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                          height: widget
                                                                  .widgetHeight *
                                                              0.39,
                                                          child:
                                                              SingleChildScrollView(
                                                                  child:
                                                                      Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    5,
                                                                    15,
                                                                    5),
                                                            child: Text(
                                                              widget
                                                                  .ticketsToDisplay[
                                                                      index]
                                                                  .memo,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                          ))),
                                                      Spacer(),

                                                      // date
                                                      Container(
                                                        width: widget.cardWidth,
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      widget.cardWidth *
                                                                          0.05,
                                                                      0),
                                                              child: Text(
                                                                widget
                                                                    .ticketsToDisplay[
                                                                        index]
                                                                    .date,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Ds-Digi'),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                          ),

                                          // Departure Time --- Arrival Time
                                          Container(
                                            // color: Colors.red,
                                            height: widget.widgetHeight * 0.13,
                                            width: widget.cardWidth,
                                            child: Row(
                                              children: [
                                                // Departure
                                                TimeContainer(
                                                    widgetHeight:
                                                        widget.widgetHeight,
                                                    cardWidth: widget.cardWidth,
                                                    label: '発',
                                                    time: widget
                                                        .ticketsToDisplay[index]
                                                        .departureTime),

                                                Expanded(
                                                    // color: Colors.red,
                                                    // width: widget.cardWidth * 0.6,
                                                    child: Column(
                                                  children: [
                                                    Text(
                                                      '${widget.ticketsToDisplay[index].trainName}   -   ${widget.ticketsToDisplay[index].trainNumber}   号',
                                                      style: TextStyle(
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Ds-digi'),
                                                    ),
                                                    Divider(
                                                      indent: widget.cardWidth *
                                                          0.05,
                                                      endIndent:
                                                          widget.cardWidth *
                                                              0.05,
                                                      color: Colors.black,
                                                    ),
                                                    Text(
                                                      '${widget.ticketsToDisplay[index].carNumber}   号車   ${widget.ticketsToDisplay[index].row}   番   ${widget.ticketsToDisplay[index].seat}   席',
                                                      style: TextStyle(
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Ds-digi'),
                                                    ),
                                                  ],
                                                )),

                                                // Arrival
                                                TimeContainer(
                                                    widgetHeight:
                                                        widget.widgetHeight,
                                                    cardWidth: widget.cardWidth,
                                                    label: '着',
                                                    time: widget
                                                        .ticketsToDisplay[index]
                                                        .arrivalTime), // Arrival
                                              ],
                                            ),
                                          ),

                                          Container(
                                            height: widget.widgetHeight * 0.015,
                                          ),

                                          // location --- location
                                          Container(
                                            width: widget.cardWidth,
                                            // color: Colors.red,
                                            height: widget.widgetHeight * 0.1,
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Container(
                                                  // color: Colors.red,
                                                  width:
                                                      widget.cardWidth * 0.35,
                                                  height:
                                                      widget.widgetHeight * 0.1,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                        widget
                                                            .ticketsToDisplay[
                                                                index]
                                                            .departureStation
                                                            .toString(),
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontSize: widget
                                                                    .widgetHeight *
                                                                0.06,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  // color: Colors.red,
                                                  height:
                                                      widget.widgetHeight * 0.1,
                                                  child: Text('---',
                                                      style: TextStyle(
                                                          height: 1,
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.06,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Container(
                                                  // color: Colors.red,
                                                  width:
                                                      widget.cardWidth * 0.35,
                                                  height:
                                                      widget.widgetHeight * 0.1,
                                                  child: SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                          widget
                                                              .ticketsToDisplay[
                                                                  index]
                                                              .arrivalStation
                                                              .toString(),
                                                          style: TextStyle(
                                                              height: 1,
                                                              fontSize: widget
                                                                      .widgetHeight *
                                                                  0.06,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                ),
                                                Spacer()
                                              ],
                                            ),
                                          ),

                                          // spacer
                                          Container(
                                            height: widget.widgetHeight * 0.02,
                                          ),

                                          DottedLine(
                                            direction: Axis.horizontal,
                                            lineLength: widget.cardWidth * 0.9,
                                            lineThickness:
                                                widget.widgetHeight * 0.012,
                                            dashLength:
                                                widget.widgetHeight * 0.012,
                                            dashColor: Colors.black,
                                            dashRadius: 100.0,
                                          ),

                                          // spacer
                                          Container(
                                            height: widget.widgetHeight * 0.02,
                                          ),

                                          Container(
                                            // color: config.bottom,
                                            height: widget.widgetHeight * 0.14,
                                            width: widget.cardWidth,
                                            child: Container(
                                              // color: Colors.green,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        widget.cardWidth * 0.15,
                                                    child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: Column(
                                                          children: [
                                                            // ## bottle location
                                                            Text('JAPAN',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        widget.widgetHeight *
                                                                            0.03,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        )),
                                                  ),
                                                  Container(
                                                    child: NeumorphicButton(
                                                        style: NeumorphicStyle(
                                                          lightSource:
                                                              LightSource
                                                                  .topLeft,
                                                          shape: NeumorphicShape
                                                              .flat,
                                                          boxShape:
                                                              const NeumorphicBoxShape
                                                                  .circle(),
                                                          intensity: 0.8,
                                                          color: config
                                                              .ticketBackground,
                                                          depth: widget
                                                                  .ticketsToDisplay[
                                                                      index]
                                                                  .isUsed
                                                              ? -2
                                                              : 2,
                                                        ),
                                                        onPressed: () async {
                                                          final ticket = widget
                                                                  .ticketsToDisplay[
                                                              index];
                                                          ticket.isUsed =
                                                              !ticket.isUsed;

                                                          await DatabaseHelper()
                                                              .updateTicket(
                                                                  ticket);

                                                          setState(() {
                                                            widget
                                                                    .ticketsToDisplay[
                                                                        index]
                                                                    .isUsed =
                                                                ticket.isUsed;
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Text(
                                                          '濟',
                                                          style: TextStyle(
                                                            // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                            fontSize: widget
                                                                    .widgetHeight *
                                                                0.02,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ))),
                                                  ),
                                                  Spacer(),
                                                  NeumorphicButton(
                                                      style:
                                                          const NeumorphicStyle(
                                                        lightSource:
                                                            LightSource.topLeft,
                                                        shape: NeumorphicShape
                                                            .flat,
                                                        boxShape:
                                                            NeumorphicBoxShape
                                                                .circle(),
                                                        intensity: 0.6,
                                                        color: config
                                                            .ticketBackground,
                                                        depth: 1,
                                                      ),
                                                      onPressed: () async {},
                                                      child: Center(
                                                          child: Text(
                                                        '修',
                                                        style: TextStyle(
                                                          // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ))),
                                                  Spacer(),
                                                  Container(
                                                    // color: Colors.red,
                                                    width:
                                                        widget.cardWidth * 0.4,
                                                    height:
                                                        widget.widgetHeight *
                                                            0.14,
                                                    child:
                                                        Row(children: barcode),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      } else if (index >= 1) {
                        // ticket
                        return Card(
                            elevation: 2.5,
                            color: config.ticketBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // side: const BorderSide(color: Colors.black, width: 0)
                            ),
                            child: SizedBox(
                              height: widget.widgetHeight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                  children: [
                                    // memo
                                    Card(
                                      shape: BeveledRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.5),
                                        // side: const BorderSide(
                                        //     color: Colors.black, width: 0.15),
                                      ),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: config.memoWhite,
                                              borderRadius:
                                                  BorderRadius.circular(10.5)),
                                          // color: Colors.blueGrey,
                                          width: widget.cardWidth,
                                          height: widget.widgetHeight * 0.5,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            child: Column(
                                              children: [
                                                Container(
                                                    height:
                                                        widget.widgetHeight *
                                                            0.39,
                                                    child:
                                                        SingleChildScrollView(
                                                            child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          20, 5, 15, 5),
                                                      child: Text(
                                                        widget
                                                            .ticketsToDisplay[
                                                                index]
                                                            .memo,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ))),
                                                Spacer(),

                                                // date
                                                Container(
                                                  width: widget.cardWidth,
                                                  child: Row(
                                                    children: [
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0,
                                                                0,
                                                                widget.cardWidth *
                                                                    0.05,
                                                                0),
                                                        child: Text(
                                                          widget.tickets[index]
                                                              .date,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Ds-Digi'),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),

                                    // Departure Time --- Arrival Time
                                    Container(
                                      // color: Colors.red,
                                      height: widget.widgetHeight * 0.13,
                                      width: widget.cardWidth,
                                      child: Row(
                                        children: [
                                          // Departure
                                          TimeContainer(
                                              widgetHeight: widget.widgetHeight,
                                              cardWidth: widget.cardWidth,
                                              label: '発',
                                              time: widget.tickets[index]
                                                  .departureTime),

                                          Expanded(
                                              // color: Colors.red,
                                              // width: widget.cardWidth * 0.6,
                                              child: Column(
                                            children: [
                                              Text(
                                                '${widget.ticketsToDisplay[index].trainName}   -   ${widget.ticketsToDisplay[index].trainNumber}   号',
                                                style: TextStyle(
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.02,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Ds-digi'),
                                              ),
                                              Divider(
                                                indent: widget.cardWidth * 0.05,
                                                endIndent:
                                                    widget.cardWidth * 0.05,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                '${widget.ticketsToDisplay[index].carNumber}   号車   ${widget.ticketsToDisplay[index].row}   番   ${widget.ticketsToDisplay[index].seat}   席',
                                                style: TextStyle(
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.02,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Ds-digi'),
                                              ),
                                            ],
                                          )),

                                          // Arrival
                                          TimeContainer(
                                              widgetHeight: widget.widgetHeight,
                                              cardWidth: widget.cardWidth,
                                              label: '着',
                                              time: widget
                                                  .ticketsToDisplay[index]
                                                  .arrivalTime), // Arrival
                                        ],
                                      ),
                                    ),

                                    Container(
                                      height: widget.widgetHeight * 0.015,
                                    ),

                                    // location --- location
                                    Container(
                                      width: widget.cardWidth,
                                      // color: Colors.red,
                                      height: widget.widgetHeight * 0.1,
                                      child: Row(
                                        children: [
                                          const Spacer(),
                                          Container(
                                            // color: Colors.red,
                                            width: widget.cardWidth * 0.35,
                                            height: widget.widgetHeight * 0.1,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                  widget.ticketsToDisplay[index]
                                                      .departureStation
                                                      .toString(),
                                                  style: TextStyle(
                                                      height: 1,
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.06,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          SizedBox(
                                            // color: Colors.red,
                                            height: widget.widgetHeight * 0.1,
                                            child: Text('---',
                                                style: TextStyle(
                                                    height: 1,
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.06,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Container(
                                            // color: Colors.red,
                                            width: widget.cardWidth * 0.35,
                                            height: widget.widgetHeight * 0.1,
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                    widget
                                                        .ticketsToDisplay[index]
                                                        .arrivalStation
                                                        .toString(),
                                                    style: TextStyle(
                                                        height: 1,
                                                        fontSize: widget
                                                                .widgetHeight *
                                                            0.06,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ),
                                          Spacer()
                                        ],
                                      ),
                                    ),

                                    // spacer
                                    Container(
                                      height: widget.widgetHeight * 0.02,
                                    ),

                                    DottedLine(
                                      direction: Axis.horizontal,
                                      lineLength: widget.cardWidth * 0.9,
                                      lineThickness:
                                          widget.widgetHeight * 0.012,
                                      dashLength: widget.widgetHeight * 0.012,
                                      dashColor: Colors.black,
                                      // dashGradient: const [Colors.red, Colors.blue],
                                      dashRadius: 100.0,
                                      // dashGapLength: 0.003,
                                      // dashGapColor: Colors.transparent,
                                      // dashGapGradient: const [Colors.red, Colors.blue],
                                      // dashGapRadius: 0.0,
                                    ),

                                    // spacer
                                    Container(
                                      height: widget.widgetHeight * 0.02,
                                    ),

                                    Container(
                                      // color: config.bottom,
                                      height: widget.widgetHeight * 0.14,
                                      width: widget.cardWidth,
                                      child: Container(
                                        // color: Colors.green,
                                        child: Row(
                                          // mainAxisAlignment: ,
                                          children: [
                                            // Container(
                                            //   color: Colors.red,
                                            //   width: screenWidth * 0.2,
                                            // ),

                                            // 0.15
                                            Container(
                                              // color: Colors.red,
                                              width: widget.cardWidth * 0.15,
                                              child: RotatedBox(
                                                  quarterTurns: 3,
                                                  child: Column(
                                                    children: [
                                                      // ## bottle location
                                                      Text('JAPAN',
                                                          style: TextStyle(
                                                              fontSize: widget
                                                                      .widgetHeight *
                                                                  0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  )),
                                            ),

                                            // 濟
                                            Container(
                                              child: NeumorphicButton(
                                                  style: NeumorphicStyle(
                                                    lightSource:
                                                        LightSource.topLeft,
                                                    shape: NeumorphicShape.flat,
                                                    boxShape:
                                                        const NeumorphicBoxShape
                                                            .circle(),
                                                    intensity: 0.6,
                                                    color:
                                                        config.ticketBackground,
                                                    depth: widget
                                                            .ticketsToDisplay[
                                                                index]
                                                            .isUsed
                                                        ? -1.5
                                                        : 1.5,
                                                  ),
                                                  onPressed: () async {
                                                    final ticket =
                                                        widget.ticketsToDisplay[
                                                            index];
                                                    ticket.isUsed =
                                                        !ticket.isUsed;

                                                    await DatabaseHelper()
                                                        .updateTicket(ticket);

                                                    setState(() {
                                                      widget
                                                              .ticketsToDisplay[
                                                                  index]
                                                              .isUsed =
                                                          ticket.isUsed;
                                                    });
                                                  },
                                                  child: Center(
                                                      child: Text(
                                                    '濟',
                                                    style: TextStyle(
                                                      // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))),
                                            ),
                                            Spacer(),
                                            // 修
                                            Container(
                                              child: NeumorphicButton(
                                                  style: const NeumorphicStyle(
                                                    lightSource:
                                                        LightSource.topLeft,
                                                    shape: NeumorphicShape.flat,
                                                    boxShape: NeumorphicBoxShape
                                                        .circle(),
                                                    intensity: 0.6,
                                                    color:
                                                        config.ticketBackground,
                                                    depth: 1,
                                                  ),
                                                  onPressed: () async {
                                                    // final ticket =
                                                    // widget.tickets[index];
                                                    // ticket.isUsed = !ticket.isUsed;
                                                    //
                                                    // await DatabaseHelper()
                                                    //     .updateTicket(ticket);
                                                    //
                                                    // setState(() {
                                                    //   widget.tickets[index].isUsed =
                                                    //       ticket.isUsed;
                                                    // });
                                                  },
                                                  child: Center(
                                                      child: Text(
                                                    '修',
                                                    style: TextStyle(
                                                      // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))),
                                            ),
                                            Spacer(),

                                            Container(
                                              // color: Colors.red,
                                              width: widget.cardWidth * 0.4,
                                              height:
                                                  widget.widgetHeight * 0.14,
                                              child: Row(children: barcode),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      } else {
                        return const SizedBox();
                      }
                    },
                    scrollDirection: Axis.horizontal,
                  )
                : const Center(
                    child: Text('List is empty'),
                  ),
            Positioned(
              top: widget.widgetHeight * 0.03,
              left: 0,
              right: 0,
              height: widget.widgetHeight * 0.3,
              child: SizedBox(
                  height: widget.widgetHeight * 0.3,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: widget.screenWidth * 0.05,
                          ),
                          Text('隱藏已使用車票',
                              style: TextStyle(
                                  fontSize: widget.screenWidth * 0.02,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(
                        height: widget.widgetHeight * 0.01,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: widget.screenWidth * 0.05,
                          ),
                          Container(
                            height: widget.screenWidth * 0.065,
                            width: widget.screenWidth * 0.15,
                            child: NeumorphicSwitch(
                              value: widget.isHideUsedTickets,
                              style: const NeumorphicSwitchStyle(
                                activeTrackColor: Color(0x0FD36300),
                                thumbShape: NeumorphicShape.concave,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  print('===== setSate hideUsedTickets');
                                  widget.isHideUsedTickets = value;
                                  widget.ticketsToDisplay =
                                      TicketsView.getTicketsToDisplay(
                                          widget.tickets,
                                          widget.isHideUsedTickets);
                                  print(
                                      'HideUsedTickets is ${widget.isHideUsedTickets}');
                                  print(
                                      'ticketsToDisplay: $widget.ticketsToDisplay');
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  )),
            ),
            Positioned(
                top: widget.screenWidth * 0.5,
                child: BackButton(
                  onPressed: () => {
                    show(context)
                  },
                )),
          ],
        ));
  }

  void generateBarcode(List<Widget> barcode) {
    print('====== generatedBarcode is called');
    if (barcode.isEmpty) {
      double barcodeWidth = 0;

      while (barcodeWidth < 0.9) {
        double widthPercentage = math.Random().nextInt(10) * 0.006;
        barcodeWidth += widthPercentage;
        barcode.add(
          VerticalDivider(
            thickness: widget.cardWidth *
                0.4 *
                widthPercentage *
                math.Random().nextInt(10) *
                0.1,
            width: widget.cardWidth * 0.4 * widthPercentage,
            color: Colors.black,
          ),
        );
      }
    }
  }
}
class Result extends StatelessWidget {
  const Result({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text("Readed text: $text");
  }
}
class AddTicketView extends StatelessWidget {
  final double widgetHeight;
  final double screenWidth;
  final double cardWidth;
  final List<Widget> barcode;

  // memo
  final TextEditingController memoController;

  // date
  final TextEditingController dateController;
  final TextEditingController departureTimeController;
  final TextEditingController arrivalTimeController;

  final TextEditingController departureStationController;
  final TextEditingController arrivalStationController;

  final TextEditingController trainNameController;
  final TextEditingController trainNumberController;

  final TextEditingController carNumberController;
  final TextEditingController rowNumberController;
  final TextEditingController seatNumberController;

  AddTicketView({
    Key? key,
    required this.widgetHeight,
    required this.screenWidth,
    required this.cardWidth,
  })  : memoController = TextEditingController(),
        dateController = TextEditingController(
          text:
              '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
        ),
        departureTimeController = TextEditingController(),
        arrivalTimeController = TextEditingController(),
        departureStationController = TextEditingController(),
        arrivalStationController = TextEditingController(),
        trainNameController = TextEditingController(),
        trainNumberController = TextEditingController(),
        carNumberController = TextEditingController(),
        rowNumberController = TextEditingController(),
        seatNumberController = TextEditingController(),
        barcode = _generateBarcode(cardWidth),
        super(key: key);

  static List<Widget> _generateBarcode(double cardWidth) {
    List<Widget> barcode = [];
    double barcodeWidth = 0;

    while (barcodeWidth < 0.9) {
      double widthPercentage = math.Random().nextInt(10) * 0.006;
      barcodeWidth += widthPercentage;
      barcode.add(
        VerticalDivider(
          thickness: cardWidth *
              0.4 *
              widthPercentage *
              math.Random().nextInt(10) *
              0.1,
          width: cardWidth * 0.4 * widthPercentage,
          color: Colors.black,
        ),
      );
    }

    return barcode;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
          elevation: 2.5,
          color: config.ticketBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: widgetHeight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  Card(
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10.5),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            color: config.memoWhite,
                            borderRadius: BorderRadius.circular(10.5)),
                        width: cardWidth,
                        height: widgetHeight * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Column(
                            children: [
                              Container(
                                  height: widgetHeight * 0.3,
                                  child: SingleChildScrollView(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 15, 5),
                                    child: TextField(
                                      controller: memoController,
                                      decoration: const InputDecoration(
                                        hintText: 'Leave your memo here',
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) {
                                        // Handle the input text change here if needed
                                      },
                                    ),
                                  ))),
                              const Spacer(),

                              // date
                              Container(
                                width: cardWidth,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0, 0, cardWidth * 0.05, 0),
                                        child: SizedBox(
                                          width: cardWidth * 0.35,
                                          child: TextField(
                                            controller: dateController,
                                            decoration: const InputDecoration(
                                              hintText: '2024/01/12',
                                              border: InputBorder.none,
                                            ),
                                            style: const TextStyle(
                                                fontFamily: 'Ds-Digi',
                                                fontSize: 16),
                                            onChanged: (value) {
                                              // Handle the input text change here if needed
                                            },
                                          ),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                  ),

                  // Departure Time --- Arrival Time
                  Container(
                    // color: Colors.green,
                    height: widgetHeight * 0.13,
                    width: cardWidth,
                    child: Row(
                      children: [
                        // Departure
                        Container(
                          // color: Colors.green,
                          width: cardWidth * 0.2,
                          height: widgetHeight * 0.13,
                          child: Column(
                            children: [
                              Container(
                                height: widgetHeight * 0.08,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      '発',
                                      style: TextStyle(
                                        fontSize: widgetHeight * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              Container(
                                width: cardWidth * 0.2,
                                height: widgetHeight * 0.03,
                                // color: Colors.red,
                                child: Center(
                                  child: TextField(
                                    controller: departureTimeController,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: '07:36',
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Ds-Digi',
                                      fontSize: widgetHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      // Handle the input text change here if needed
                                    },
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),

                        Expanded(
                            // color: Colors.red,
                            // width: cardWidth * 0.5,
                            child: Column(
                          children: [
                            Container(
                              height: widgetHeight * 0.06,
                              // color: Colors.green,
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      // color: Colors.red,
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: trainNameController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: 'のぞみ',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Ds-Digi',
                                          fontSize: widgetHeight * 0.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('-'),
                                    ),
                                    Expanded(
                                        child: SizedBox(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: trainNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '12',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Ds-Digi',
                                          fontSize: widgetHeight * 0.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('号'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: widgetHeight * 0.01,
                              child: Center(
                                child: Divider(
                                  indent: cardWidth * 0.05,
                                  endIndent: cardWidth * 0.05,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              height: widgetHeight * 0.06,
                              // color: Colors.green,
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      // color: Colors.red,
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: carNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '8',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Ds-Digi',
                                          fontSize: widgetHeight * 0.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('号車'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: rowNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '8',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Ds-Digi',
                                          fontSize: widgetHeight * 0.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('番'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: seatNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: 'A',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontFamily: 'Ds-Digi',
                                          fontSize: widgetHeight * 0.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('席'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),

                        // Arrival
                        Container(
                          // color: Colors.green,
                          width: cardWidth * 0.2,
                          height: widgetHeight * 0.13,
                          child: Column(
                            children: [
                              Container(
                                height: widgetHeight * 0.08,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      '着',
                                      style: TextStyle(
                                        fontSize: widgetHeight * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              Container(
                                width: cardWidth * 0.2,
                                height: widgetHeight * 0.03,
                                // color: Colors.red,
                                child: Center(
                                  child: TextField(
                                    controller: arrivalTimeController,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: '07:36',
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Ds-Digi',
                                      fontSize: widgetHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      // Handle the input text change here if needed
                                    },
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ), // Arrival
                      ],
                    ),
                  ),

                  Container(
                    height: widgetHeight * 0.015,
                  ),

                  // location --- location
                  Container(
                    width: cardWidth,
                    // color: Colors.red,
                    height: widgetHeight * 0.1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Center horizontally
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Center vertically
                        children: [
                          Expanded(
                              child: Center(
                            child: Container(
                              height: widgetHeight * 0.1,
                              // color: Colors.green,
                              child: TextField(
                                controller: departureStationController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: '東京',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                    height: 1,
                                    fontSize: widgetHeight * 0.05,
                                    fontWeight: FontWeight.bold),
                                onChanged: (value) {
                                  // Handle the input text change here if needed
                                },
                              ),
                            ),
                          )),
                          Text(
                            '---',
                            style: TextStyle(
                                height: 1,
                                fontSize: widgetHeight * 0.06,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                              child: Center(
                            child: Container(
                              height: widgetHeight * 0.1,
                              child: TextField(
                                controller: arrivalStationController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: '秋田',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                    height: 1,
                                    fontSize: widgetHeight * 0.05,
                                    fontWeight: FontWeight.bold),
                                onChanged: (value) {
                                  // Handle the input text change here if needed
                                },
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  DottedLine(
                    direction: Axis.horizontal,
                    lineLength: cardWidth * 0.9,
                    lineThickness: cardWidth * 0.012,
                    dashLength: cardWidth * 0.012,
                    dashColor: Colors.black,
                    // dashGradient: const [Colors.red, Colors.blue],
                    dashRadius: 100.0,
                    // dashGapLength: 0.003,
                    // dashGapColor: Colors.transparent,
                    // dashGapGradient: const [Colors.red, Colors.blue],
                    // dashGapRadius: 0.0,
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  Container(
                    // color: config.bottom,
                    height: widgetHeight * 0.14,
                    width: cardWidth,
                    child: Container(
                      // color: Colors.green,
                      child: Row(
                        // mainAxisAlignment: ,
                        children: [
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.15,
                            child: RotatedBox(
                                quarterTurns: 3,
                                child: Column(
                                  children: [
                                    // ## bottle location
                                    Text('JAPAN',
                                        style: TextStyle(
                                            fontSize: widgetHeight * 0.03,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                )),
                          ),
                          const Spacer(),
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.4,
                            height: widgetHeight * 0.14,
                            child: Row(children: barcode),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

class AddAttractionView extends StatelessWidget {
  final double widgetHeight;
  final double screenWidth;
  final double cardWidth;
  final List<Widget> barcode;

  final TextEditingController nameController;
  final TextEditingController memoController;

  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController departureTimeController;
  final TextEditingController arrivalTimeController;

  final TextEditingController departureStationController;
  final TextEditingController arrivalStationController;

  AddAttractionView({
    Key? key,
    required this.widgetHeight,
    required this.screenWidth,
    required this.cardWidth,
  })  : nameController = TextEditingController(),
        memoController = TextEditingController(),
        locationController = TextEditingController(),
        dateController = TextEditingController(
          text:
              '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
        ),
        departureTimeController = TextEditingController(),
        arrivalTimeController = TextEditingController(),
        departureStationController = TextEditingController(),
        arrivalStationController = TextEditingController(),
        barcode = _generateBarcode(cardWidth),
        super(key: key);

  static List<Widget> _generateBarcode(double cardWidth) {
    List<Widget> barcode = [];
    double barcodeWidth = 0;

    while (barcodeWidth < 0.9) {
      double widthPercentage = math.Random().nextInt(10) * 0.006;
      barcodeWidth += widthPercentage;
      barcode.add(
        VerticalDivider(
          thickness: cardWidth *
              0.4 *
              widthPercentage *
              math.Random().nextInt(10) *
              0.1,
          width: cardWidth * 0.4 * widthPercentage,
          color: Colors.black,
        ),
      );
    }

    return barcode;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
          elevation: 2.5,
          color: config.ticketBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: widgetHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  // memo
                  Card(
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10.5),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            color: config.memoWhite,
                            borderRadius: BorderRadius.circular(10.5)),
                        width: cardWidth,
                        height: widgetHeight * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Column(
                            children: [
                              Container(
                                  height: widgetHeight * 0.25,
                                  child: SingleChildScrollView(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 15, 5),
                                    child: TextField(
                                      controller: memoController,
                                      decoration: const InputDecoration(
                                        hintText: 'Leave your memo here',
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) {
                                        // Handle the input text change here if needed
                                      },
                                    ),
                                  ))),
                              Spacer(),

                              // date
                              Container(
                                height: widgetHeight * 0.05,
                                width: cardWidth,
                                // color: Colors.green,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Container(
                                      width: cardWidth * 0.8,
                                      // color: Colors.red,
                                      alignment: Alignment.bottomCenter,
                                      child: TextField(
                                        controller: dateController,
                                        textAlign: TextAlign.right,
                                        decoration: const InputDecoration(
                                          hintText: '2024/01/12',
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                            fontFamily: 'Ds-Digi',
                                            fontSize: 16),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),

                              // location
                              Container(
                                height: widgetHeight * 0.05,
                                width: cardWidth,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Container(
                                      width: cardWidth * 0.8,
                                      // color: Colors.green,
                                      child: TextField(
                                        controller: locationController,
                                        textAlign: TextAlign.right,
                                        decoration: const InputDecoration(
                                          hintText: '35.6226077, 139.7210550',
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                            fontFamily: 'Ds-Digi',
                                            fontSize: 16),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),

                  // Departure Time --- Arrival Time
                  Container(
                    // color: Colors.green,
                    height: widgetHeight * 0.13,
                    width: cardWidth,
                    child: Row(
                      children: [
                        // Departure
                        Container(
                          // color: Colors.green,
                          width: cardWidth * 0.2,
                          height: widgetHeight * 0.13,
                          child: Column(
                            children: [
                              Container(
                                height: widgetHeight * 0.08,
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      '到',
                                      style: TextStyle(
                                        fontSize: widgetHeight * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              Container(
                                width: cardWidth * 0.2,
                                height: widgetHeight * 0.03,
                                // color: Colors.red,
                                child: Center(
                                  child: TextField(
                                    controller: departureTimeController,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: '07:36',
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Ds-Digi',
                                      fontSize: widgetHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      // Handle the input text change here if needed
                                    },
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),

                        Expanded(
                            child: Column(
                          children: [
                            SizedBox(height: widgetHeight * 0.03),
                            Container(
                              height: widgetHeight * 0.06,
                              // color: Colors.green,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // Center horizontally
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // Center vertically
                                  children: [
                                    Container(
                                      width: cardWidth * 0.4,
                                      // height: widgetHeight * 0.05,
                                      // color: Colors.red,
                                      child: TextField(
                                        controller: departureStationController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '最近車站',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                            height: 1,
                                            fontSize: widgetHeight * 0.03,
                                            fontWeight: FontWeight.bold),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: widgetHeight * 0.005,
                              child: Center(
                                child: Divider(
                                  indent: cardWidth * 0.05,
                                  endIndent: cardWidth * 0.05,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                                // height: widgetHeight * 0.03,
                                // // color: Colors.green,
                                // child: Center(),
                                ),
                          ],
                        )),

                        // Arrival
                        Container(
                          // color: Colors.green,
                          width: cardWidth * 0.2,
                          height: widgetHeight * 0.13,
                          child: Column(
                            children: [
                              Container(
                                height: widgetHeight * 0.08,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      '離',
                                      style: TextStyle(
                                        fontSize: widgetHeight * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              Container(
                                width: cardWidth * 0.2,
                                height: widgetHeight * 0.03,
                                // color: Colors.red,
                                child: Center(
                                  child: TextField(
                                    controller: arrivalTimeController,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: '07:36',
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Ds-Digi',
                                      fontSize: widgetHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      // Handle the input text change here if needed
                                    },
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ), // Arrival
                      ],
                    ),
                  ),

                  Container(
                    height: widgetHeight * 0.015,
                  ),

                  // location --- location
                  Container(
                    width: cardWidth,
                    // color: Colors.red,
                    height: widgetHeight * 0.1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Center horizontally
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Center vertically
                        children: [
                          Container(
                            width: cardWidth * 0.5,
                            height: widgetHeight * 0.1,
                            // color: Colors.green,
                            child: TextField(
                              controller: nameController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '景點名',
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                  height: 1,
                                  fontSize: widgetHeight * 0.05,
                                  fontWeight: FontWeight.bold),
                              onChanged: (value) {
                                // Handle the input text change here if needed
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  DottedLine(
                    direction: Axis.horizontal,
                    lineLength: cardWidth * 0.9,
                    lineThickness: cardWidth * 0.012,
                    dashLength: cardWidth * 0.012,
                    dashColor: Colors.black,
                    // dashGradient: const [Colors.red, Colors.blue],
                    dashRadius: 100.0,
                    // dashGapLength: 0.003,
                    // dashGapColor: Colors.transparent,
                    // dashGapGradient: const [Colors.red, Colors.blue],
                    // dashGapRadius: 0.0,
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  Container(
                    height: widgetHeight * 0.14,
                    width: cardWidth,
                    child: Container(
                      // color: Colors.green,
                      child: Row(
                        // mainAxisAlignment: ,
                        children: [
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.25,
                            child: RotatedBox(
                                quarterTurns: 3,
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text('JAPAN',
                                          style: TextStyle(
                                              fontSize: widgetHeight * 0.03,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                )),
                          ),
                          const Spacer(),
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.4,
                            height: widgetHeight * 0.14,
                            child: Row(children: barcode),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

// Create a custom widget named `TimeContainer`
class TimeContainer extends StatelessWidget {
  final String label;
  final String time;
  final double cardWidth;
  final double widgetHeight;

  const TimeContainer({
    super.key,
    required this.widgetHeight,
    required this.cardWidth,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      width: cardWidth * 0.2,
      height: widgetHeight * 0.13,
      child: Column(
        children: [
          Container(
            height: widgetHeight * 0.08,
            child: Row(
              children: [
                Spacer(),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: widgetHeight * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
                fontSize: widgetHeight * 0.02,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ds-digi'),
          ),
          Spacer(),
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
