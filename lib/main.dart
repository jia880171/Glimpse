import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:geolocator/geolocator.dart';
import './config.dart' as config;
import './ticket.dart';
import './ticket_db.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
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

  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Ticket> tickets = []; // Store fetched tickets

  final List<String> usernames = [
    '淺草雷門',
    '晴空塔',
    '麻布',
    'The bellwoods',
    'User5',
    'User6',
    'User7',
    'User8',
    'User9',
    'User10',
  ];

  @override
  void initState() {
    super.initState();
    fetchTickets(); // Fetch tickets when the widget is initialized
  }

  Future<void> fetchTickets() async {
    List<Ticket> fetchedTickets = await databaseHelper.getTickets();
    setState(() {
      tickets = fetchedTickets;
      print('====== fetched tickets: $tickets');
    });
  }

  void toggleChasingMode() {
    setState(() {
      isChasingMode = !isChasingMode;
    });
  }

  void clickAddNewTicketButton(BuildContext context, double screenHeight, double screenWidth) async {
    FloatCardView floatCardView = FloatCardView(
      widgetHeight: screenHeight * 0.5,
      screenWidth: screenWidth,
      cardWidth: screenWidth * 0.7,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Ticket'),
          content: floatCardView,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
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
                  departureStation: floatCardView.departureStationController.text,
                  arrivalStation: floatCardView.arrivalStationController.text,
                  isUsed: false,
                );

                print('newTicket as: ${newTicket.arrivalStation}');
                print('newTicket ds: ${newTicket.departureStation}');

                await databaseHelper.insertTicket(newTicket);

                fetchTickets();

                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TicketsView ticketsView = TicketsView(hideUsedTickets, screenHeight * 0.5, screenWidth, screenWidth * 0.8, tickets);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark status bar icons (like time, battery)
      ),
      child: Scaffold(
        // appBar: AppBar(
        //   // Here we take the value from the MyHomePage object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   title: Text(widget.title),
        // ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight * 0.08),
            Stack(
              children: [
                ChasingView(toggleChasingMode, screenHeight, screenWidth, screenHeight * 0.38, 20.0, 10.0),
              ],
            ),
            if (isChasingMode) const CenterTopText(),
            if (isChasingMode) BottomTouristList(screenHeight, screenWidth, usernames),
            if (!isChasingMode) ticketsView
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            clickAddNewTicketButton(context, screenHeight, screenWidth);
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class CenterTopText extends StatelessWidget {
  static const double topFontSize = 40;
  const CenterTopText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        SizedBox(
          width: screenWidth,
          height: screenHeight * 0.2,
        ),
        // Aligning the text to the middle-top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align text to top
              children: <Widget>[
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    //center this row horizontally
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        'Japan',
                        style: TextStyle(fontSize: topFontSize, fontFamily: 'Open-Sans'),
                      ),
                      SizedBox(width: 8.0), // Add some space between texts
                      Text(',', style: TextStyle(fontSize: topFontSize)),
                      Text(
                        'Tokyo',
                        style: TextStyle(fontSize: topFontSize, fontFamily: 'Open-Sans', fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('新宿御苑', style: TextStyle(fontSize: 25, fontFamily: 'Open-Sans', fontWeight: FontWeight.w300)),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChasingView extends StatefulWidget {
  final double ChasingViewHeight;
  final double screenWidth;
  final double screenHeight;
  final double sensorDegree;
  final double heading;
  final VoidCallback toggleChasingMode;

  const ChasingView(this.toggleChasingMode, this.screenHeight, this.screenWidth, this.ChasingViewHeight, this.sensorDegree, this.heading, {Key? key}) : super(key: key);

  @override
  _ChasingViewState createState() => _ChasingViewState();
}

class _ChasingViewState extends State<ChasingView> {
  late Timer _timer;
  final int fetchLocationIntervalSeconds = 10;

  double userLatitude = 0.0;
  double userLongitude = 0.0;

  DisplayBottle target = DisplayBottle('Taiwan', 80, 150, 24.397630, 121.264331);
  double _currentHeading = 0.0;
  late StreamSubscription<CompassEvent> _compassStreamSubscription;

  List<DisplayBottle> bottles = [];

  @override
  void initState() {
    // For demonstration purpose, adding sample bottles
    bottles = [
      DisplayBottle('taiwan', 80, 150, 24.397630, 121.264331), // taiwan
      DisplayBottle('zis', -10, 100, 35.622522, 139.720624), // zis
      DisplayBottle('tw', 80, 150, 24.397630, 121.264331),
    ];

    target = bottles[0];

    super.initState();
    _getUserLocation(target);
    _initCompass();

    // Set up a periodic timer to call _getUserLocation every 5 seconds
    _timer = Timer.periodic(Duration(seconds: fetchLocationIntervalSeconds), (timer) {
      _getUserLocation(target);
    });
  }

  Future<void> _getUserLocation(DisplayBottle target) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          // Handle location permission denied
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });

      target.distance = await Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            target.latitude,
            target.longitude,
          ) /
          1000;
    } catch (e) {
      // Handle location fetch errors
      print('Error getting user location: $e');
    }
  }

  void _initCompass() {
    Stream<CompassEvent> emptyStream = Stream<CompassEvent>.empty();
    _compassStreamSubscription = FlutterCompass.events?.listen((event) {
          if (event != null) {
            setState(() {
              _currentHeading = event.heading ?? 0.0;
            });
          }
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

    double sensorRadius = widget.ChasingViewHeight * 0.3;
    double smallSensorRadius = widget.ChasingViewHeight * 0.05;
    double dentRadius = sensorRadius + smallSensorRadius * 3.2;
    double backgroundRadius = sensorRadius + smallSensorRadius * 3.6;
    double rotatedNRadius = sensorRadius - smallSensorRadius * 0.5;

    final double targetRadiusToCenter = sensorRadius + smallSensorRadius * 2;
    final double centerX = ((widget.screenWidth / 2) - smallSensorRadius);
    final double centerY = ((widget.ChasingViewHeight / 2) - smallSensorRadius);

    List<Widget> targets = [];

    // display subsequent two items.
    for (int i = 0; i < bottles.length; i++) {
      double leftX = centerX + AngleCalculator().radiusProjector(bottles[i].bearingAngle + _currentHeading, targetRadiusToCenter).dx;
      double topY = centerY - AngleCalculator().radiusProjector(bottles[i].bearingAngle + _currentHeading, targetRadiusToCenter).dy;
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
                color: Colors.white,
                width: smallSensorRadius * 2,
                height: smallSensorRadius * 2,
                child: Align(
                  alignment: Alignment.center,
                  child: Text('${bottles[i].distance}M️', style: TextStyle(fontSize: 0.36 * smallSensorRadius, fontWeight: FontWeight.bold)),
                ))),
      ));
    }

    return SizedBox(
      height: widget.ChasingViewHeight,
      child: Stack(
        children: [
          // // background
          // Center(
          //   child: Transform.scale(
          //     scale: 2.5,
          //     // Set the scale factor as needed (1.0 is the default scale)
          //     child: Container(
          //       width: sensorRadius * 2, // Set the desired width of the circle
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle, // This makes the container a circle
          //         color: config.redJP, // Set the color of the circle
          //         // You can also add other decorations like border or shadows if needed
          //       ),
          //     ),
          //   ),
          // ),

          // rim
          Align(
            alignment: Alignment.center,
            child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: const NeumorphicBoxShape.circle(),
                  // intensity: 0.8,
                  // lightSource: neumorphiclightSource,
                  // color: config.themeColor,
                  // depth: -10,
                  // border: NeumorphicBorder(
                  //   color: Colors.white10,
                  //   width: 2,
                  // )
                ),
                child: Container(
                  color: Colors.white,
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
                  color: Colors.white,
                  depth: -5,
                ),
                child: Container(
                  color: Colors.white,
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
                    depth: 3,
                    lightSource: neumorphicLightSource,
                    color: Colors.white,
                    border: NeumorphicBorder(
                      color: config.border,
                      width: 0.3,
                    )),
                onPressed: () {
                  widget.toggleChasingMode();
                },
                child: Container(
                  // color: Colors.red,
                  height: (sensorRadius) * 2,
                  width: (sensorRadius) * 2,

                  child: Center(
                      child: Container(
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
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/monitor.png'),
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),

                        // distance
                        Positioned(
                          left: sensorRadius / 2,
                          width: sensorRadius,
                          child: Container(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: Text(
                                  target.distance.toStringAsFixed(3),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                  ),
                                ),
                              )),
                        ),

                        // KM
                        Positioned(
                          left: sensorRadius * 1.3,
                          bottom: sensorRadius * 0.7,
                          child: Container(
                              width: 50,
                              height: sensorRadius * 0.2,
                              // color: Colors.green,
                              child: Center(
                                child: Text(
                                  'KM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Open-Sans', // Replace 'SecondFontFamily' with your desired font family
                                  ),
                                ),
                              )),
                        )
                      ],
                    ),
                  )),
                )),
          ),

          // rotated N
          IgnorePointer(
            ignoring: true,
            child: Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: _currentHeading * (3.14159 / 180) * -1,
                  child: Container(
                    height: rotatedNRadius * 2,
                    width: rotatedNRadius * 2,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text('N', style: TextStyle(color: Colors.black, fontSize: widget.screenHeight * 0.025)),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Text('－', style: TextStyle(color: Colors.black, fontSize: widget.screenHeight * 0.02)),
                              const Spacer(),
                              Text('－', style: TextStyle(color: Colors.black, fontSize: widget.screenHeight * 0.02)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),

          Stack(children: targets),
        ],
      ),
    );
  }
}

class BottomTouristList extends StatelessWidget {
  final List<String> usernames;
  final double screenWidth;
  final double screenHeight;

  const BottomTouristList(this.screenHeight, this.screenWidth, this.usernames, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.3,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: usernames.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: index == 0
                    ? BorderSide(
                        color: Colors.grey, // Customize the color as needed
                        width: 0.5, // Customize the width as needed
                      )
                    : BorderSide.none,
                bottom: BorderSide(
                  color: Colors.grey, // Customize the color as needed
                  width: 0.5, // Customize the width as needed
                ),
              ),
            ),
            child: ListTile(
              title: Text(usernames[index]),
              // You can customize the ListTile or add more widgets here
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
  _TicketsViewState createState() => _TicketsViewState();

  static List<Ticket> getTicketsToDisplay(List<Ticket> tickets, [bool isHideUsedTickets = false]) {
    print('====== allTickets: ');
    printTickets(tickets);

    List<Ticket> ticketsToDisplay = isHideUsedTickets ? tickets.where((ticket) => ticket.isUsed == false).toList() : tickets;

    print('====== tickets to display');
    printTickets(ticketsToDisplay);

    return ticketsToDisplay;
  }

  // Print all Ticket objects in the list
  static void printTickets(List<Ticket> tickets) {
    for (Ticket ticket in tickets) {
      print('Ticket ID: ${ticket.id}, departureStation: ${ticket.departureStation}');
    }
  }
}

class _TicketsViewState extends State<TicketsView> {
  List<Widget> barcode = [];

  @override
  Widget build(BuildContext context) {
    const String backgroundHint = '車票列表，可在此快速查看起迄時間並翻閱備忘。';
    generateBarcode(barcode);

    return Container(
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
                      style: TextStyle(fontSize: widget.cardWidth * 0.05, fontWeight: FontWeight.bold),
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
                        print('====== length: 0');
                        return Padding(
                          padding: EdgeInsets.fromLTRB(widget.cardWidth * 0.2, 0, 0, 0),
                          child: Row(
                            children: [
                              Container(
                                width: widget.cardWidth * 0.7,
                              ),
                              Card(
                                  elevation: 2.5,
                                  color: config.bottleSheet,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // side: const BorderSide(color: Colors.black, width: 0)
                                  ),
                                  child: Container(
                                    height: widget.widgetHeight,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Column(
                                        children: [
                                          Card(
                                            shape: BeveledRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.5),
                                              // side: const BorderSide(
                                              //     color: Colors.black, width: 0.15),
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(color: Color(0x0FD36300), borderRadius: BorderRadius.circular(10.5)),
                                                // color: Colors.blueGrey,
                                                width: widget.cardWidth,
                                                height: widget.widgetHeight * 0.5,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                          height: widget.widgetHeight * 0.39,
                                                          child: SingleChildScrollView(
                                                              child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(20, 5, 15, 5),
                                                            child: Text(
                                                              widget.ticketsToDisplay[index].memo,
                                                              style: const TextStyle(fontSize: 16),
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
                                                              padding: EdgeInsets.fromLTRB(0, 0, widget.cardWidth * 0.05, 0),
                                                              child: Text(
                                                                widget.ticketsToDisplay[index].date,
                                                                style: TextStyle(fontFamily: 'Ds-Digi'),
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
                                                TimeContainer(widgetHeight: widget.widgetHeight, cardWidth: widget.cardWidth, label: '発', time: widget.ticketsToDisplay[index].departureTime),

                                                Expanded(
                                                    // color: Colors.red,
                                                    // width: widget.cardWidth * 0.6,
                                                    child: Column(
                                                  children: [
                                                    Text(
                                                      widget.ticketsToDisplay[index].trainName + '   -   ' + widget.ticketsToDisplay[index].trainNumber + '   号',
                                                      style: TextStyle(fontSize: widget.widgetHeight * 0.02, fontWeight: FontWeight.bold, fontFamily: 'Ds-digi'),
                                                    ),
                                                    Divider(
                                                      indent: widget.cardWidth * 0.05,
                                                      endIndent: widget.cardWidth * 0.05,
                                                      color: Colors.black,
                                                    ),
                                                    Text(
                                                      widget.ticketsToDisplay[index].carNumber +
                                                          '   号車   ' +
                                                          widget.ticketsToDisplay[index].row +
                                                          '   番   ' +
                                                          widget.ticketsToDisplay[index].seat +
                                                          '   席',
                                                      style: TextStyle(fontSize: widget.widgetHeight * 0.02, fontWeight: FontWeight.bold, fontFamily: 'Ds-digi'),
                                                    ),
                                                  ],
                                                )),

                                                // Arrival
                                                TimeContainer(widgetHeight: widget.widgetHeight, cardWidth: widget.cardWidth, label: '着', time: widget.ticketsToDisplay[index].arrivalTime), // Arrival
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
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Spacer(),
                                                Container(
                                                  // color: Colors.red,
                                                  height: widget.widgetHeight * 0.1,
                                                  child: Text(widget.ticketsToDisplay[index].departureStation + '---' + widget.ticketsToDisplay[index].arrivalStation,
                                                      style: TextStyle(height: 1, fontSize: widget.widgetHeight * 0.06, fontWeight: FontWeight.bold)),
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
                                            lineThickness: widget.widgetHeight * 0.012,
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
                                                  Container(
                                                    // color: Colors.red,
                                                    width: widget.cardWidth * 0.15,
                                                    child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: Column(
                                                          children: [
                                                            // ## bottle location
                                                            Text('JAPAN', style: TextStyle(fontSize: widget.widgetHeight * 0.03, fontWeight: FontWeight.bold)),
                                                            // ## bottle location
                                                            Text('Tokyo', style: TextStyle(fontSize: widget.widgetHeight * 0.025, fontWeight: FontWeight.bold)),
                                                          ],
                                                        )),
                                                  ),
                                                  // Spacer(),
                                                  Container(
                                                    child: NeumorphicButton(
                                                        style: NeumorphicStyle(
                                                          lightSource: LightSource.topLeft,
                                                          shape: NeumorphicShape.flat,
                                                          boxShape: NeumorphicBoxShape.circle(),
                                                          intensity: 1,
                                                          color: Colors.white,
                                                          depth: widget.ticketsToDisplay[index].isUsed ? -1.5 : 1.5,
                                                        ),
                                                        onPressed: () async {
                                                          final ticket = widget.ticketsToDisplay[index];
                                                          ticket.isUsed = !ticket.isUsed;

                                                          await DatabaseHelper().updateTicket(ticket);

                                                          setState(() {
                                                            widget.ticketsToDisplay[index].isUsed = ticket.isUsed;
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Text(
                                                          '濟',
                                                          style: TextStyle(
                                                            // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                            fontSize: widget.widgetHeight * 0.05,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ))),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    child: NeumorphicButton(
                                                        style: NeumorphicStyle(
                                                          lightSource: LightSource.topLeft,
                                                          shape: NeumorphicShape.flat,
                                                          boxShape: NeumorphicBoxShape.circle(),
                                                          intensity: 0.8,
                                                          color: Colors.white,
                                                          depth: 1,
                                                        ),
                                                        onPressed: () async {
                                                        },
                                                        child: Center(
                                                            child: Text(
                                                          '修',
                                                          style: TextStyle(
                                                            // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                            fontSize: widget.widgetHeight * 0.05,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ))),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    // color: Colors.red,
                                                    width: widget.cardWidth * 0.4,
                                                    height: widget.widgetHeight * 0.14,
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
                            ],
                          ),
                        );
                      } else if (index >= 1) {
                        print('====== length: $widget.ticketsToDisplay.length');
                        return Container(
                          // color: config.redJP,
                          child: Card(
                              elevation: 2.5,
                              color: config.bottleSheet,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                // side: const BorderSide(color: Colors.black, width: 0)
                              ),
                              child: Container(
                                height: widget.widgetHeight,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      Card(
                                        shape: BeveledRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.5),
                                          // side: const BorderSide(
                                          //     color: Colors.black, width: 0.15),
                                        ),
                                        child: Container(
                                            decoration: BoxDecoration(color: Color(0x0FD36300), borderRadius: BorderRadius.circular(10.5)),
                                            // color: Colors.blueGrey,
                                            width: widget.cardWidth,
                                            height: widget.widgetHeight * 0.5,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                              child: Column(
                                                children: [
                                                  Container(
                                                      height: widget.widgetHeight * 0.39,
                                                      child: SingleChildScrollView(
                                                          child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(20, 5, 15, 5),
                                                        child: Text(
                                                          widget.ticketsToDisplay[index].memo,
                                                          style: const TextStyle(fontSize: 16),
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
                                                          padding: EdgeInsets.fromLTRB(0, 0, widget.cardWidth * 0.05, 0),
                                                          child: Text(
                                                            widget.tickets[index].date,
                                                            style: TextStyle(fontFamily: 'Ds-Digi'),
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
                                            TimeContainer(widgetHeight: widget.widgetHeight, cardWidth: widget.cardWidth, label: '発', time: widget.tickets[index].departureTime),

                                            Expanded(
                                                // color: Colors.red,
                                                // width: widget.cardWidth * 0.6,
                                                child: Column(
                                              children: [
                                                Text(
                                                  widget.ticketsToDisplay[index].trainName + '   -   ' + widget.ticketsToDisplay[index].trainNumber + '   号',
                                                  style: TextStyle(fontSize: widget.widgetHeight * 0.02, fontWeight: FontWeight.bold, fontFamily: 'Ds-digi'),
                                                ),
                                                Divider(
                                                  indent: widget.cardWidth * 0.05,
                                                  endIndent: widget.cardWidth * 0.05,
                                                  color: Colors.black,
                                                ),
                                                Text(
                                                  widget.ticketsToDisplay[index].carNumber + '   号車   ' + widget.ticketsToDisplay[index].row + '   番   ' + widget.ticketsToDisplay[index].seat + '   席',
                                                  style: TextStyle(fontSize: widget.widgetHeight * 0.02, fontWeight: FontWeight.bold, fontFamily: 'Ds-digi'),
                                                ),
                                              ],
                                            )),

                                            // Arrival
                                            TimeContainer(widgetHeight: widget.widgetHeight, cardWidth: widget.cardWidth, label: '着', time: widget.ticketsToDisplay[index].arrivalTime), // Arrival
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
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Spacer(),
                                            Container(
                                              // color: Colors.red,
                                              height: widget.widgetHeight * 0.1,
                                              child: Text(widget.ticketsToDisplay[index].departureStation + '---' + widget.ticketsToDisplay[index].arrivalStation,
                                                  style: TextStyle(height: 1, fontSize: widget.widgetHeight * 0.06, fontWeight: FontWeight.bold)),
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
                                        lineThickness: widget.widgetHeight * 0.012,
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
                                              Container(
                                                // color: Colors.red,
                                                width: widget.cardWidth * 0.15,
                                                child: RotatedBox(
                                                    quarterTurns: 3,
                                                    child: Column(
                                                      children: [
                                                        // ## bottle location
                                                        Text('JAPAN', style: TextStyle(fontSize: widget.widgetHeight * 0.03, fontWeight: FontWeight.bold)),
                                                        // ## bottle location
                                                        Text('Tokyo', style: TextStyle(fontSize: widget.widgetHeight * 0.025, fontWeight: FontWeight.bold)),
                                                      ],
                                                    )),
                                              ),
                                              // Spacer(),
                                              Container(
                                                child: NeumorphicButton(
                                                    style: NeumorphicStyle(
                                                      lightSource: LightSource.topLeft,
                                                      shape: NeumorphicShape.flat,
                                                      boxShape: NeumorphicBoxShape.circle(),
                                                      intensity: 1,
                                                      color: Colors.white,
                                                      depth: widget.ticketsToDisplay[index].isUsed ? -1.5 : 1.5,
                                                    ),
                                                    onPressed: () async {
                                                      final ticket = widget.ticketsToDisplay[index];
                                                      ticket.isUsed = !ticket.isUsed;

                                                      await DatabaseHelper().updateTicket(ticket);

                                                      setState(() {
                                                        widget.ticketsToDisplay[index].isUsed = ticket.isUsed;
                                                      });
                                                    },
                                                    child: Center(
                                                        child: Text(
                                                      '濟',
                                                      style: TextStyle(
                                                        // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                        fontSize: widget.widgetHeight * 0.05,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ))),
                                              ),
                                              Spacer(),
                                              Container(
                                                child: NeumorphicButton(
                                                    style: NeumorphicStyle(
                                                      lightSource: LightSource.topLeft,
                                                      shape: NeumorphicShape.flat,
                                                      boxShape: NeumorphicBoxShape.circle(),
                                                      intensity: 0.8,
                                                      color: Colors.white,
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
                                                        fontSize: widget.widgetHeight * 0.05,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ))),
                                              ),
                                              Spacer(),

                                              Container(
                                                // color: Colors.red,
                                                width: widget.cardWidth * 0.4,
                                                height: widget.widgetHeight * 0.14,
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
                      } else {
                        print('====== else length: $widget.ticketsToDisplay.length');
                        return SizedBox();
                      }
                    },
                    scrollDirection: Axis.horizontal,
                  )
                : Center(
                    child: Text('List is empty'),
                  ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: widget.widgetHeight * 0.3,
              child: Container(
                  height: widget.widgetHeight * 0.3,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: widget.screenWidth * 0.05,
                          ),
                          Text('隱藏已使用車票', style: TextStyle(fontSize: widget.screenWidth * 0.02, fontWeight: FontWeight.bold)),
                          Spacer(),
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
                              style: NeumorphicSwitchStyle(
                                activeTrackColor: Color(0x0FD36300),
                                thumbShape: NeumorphicShape.concave,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  print('===== setSate hideUsedTickets');
                                  widget.isHideUsedTickets = value;
                                  widget.ticketsToDisplay = TicketsView.getTicketsToDisplay(widget.tickets, widget.isHideUsedTickets);
                                  print('HideUsedTickets is ${widget.isHideUsedTickets}');
                                  print('ticketsToDisplay: $widget.ticketsToDisplay');
                                });
                              },
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  )),
            ),
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
            thickness: widget.cardWidth * 0.4 * widthPercentage * math.Random().nextInt(10) * 0.1,
            width: widget.cardWidth * 0.4 * widthPercentage,
            color: Colors.black,
          ),
        );
      }
    }
  }
}

class FloatCardView extends StatelessWidget {
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

  FloatCardView({
    Key? key,
    required this.widgetHeight,
    required this.screenWidth,
    required this.cardWidth,
  })  : memoController = TextEditingController(),
        dateController = TextEditingController(
          text: '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
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
          thickness: cardWidth * 0.4 * widthPercentage * math.Random().nextInt(10) * 0.1,
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
          color: config.bottleSheet,
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
                    // color: config.bottleSheet,
                    // color: Colors.red,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10.5),
                    ),

                    child: Container(
                        decoration: BoxDecoration(color: Color(0x0FD36300), borderRadius: BorderRadius.circular(10.5)),
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
                                    padding: const EdgeInsets.fromLTRB(20, 5, 15, 5),
                                    child: TextField(
                                      controller: memoController,
                                      decoration: InputDecoration(
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
                                width: cardWidth,
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 0, cardWidth * 0.05, 0),
                                        child: SizedBox(
                                          width: cardWidth * 0.35,
                                          child: TextField(
                                            controller: dateController,
                                            decoration: InputDecoration(
                                              hintText: '2024/01/12',
                                              border: InputBorder.none,
                                            ),
                                            style: TextStyle(fontFamily: 'Ds-Digi', fontSize: 16),
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
                                    Spacer(),
                                    Text(
                                      '発',
                                      style: TextStyle(
                                        fontSize: widgetHeight * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
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
                                    decoration: InputDecoration(
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
                                        decoration: InputDecoration(
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
                                      child: Text('-'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: trainNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
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
                                      child: Text('号'),
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
                                        decoration: InputDecoration(
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
                                      child: Text('号車'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: rowNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
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
                                      child: Text('番'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: seatNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
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
                                      child: Text('席'),
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
                                    Spacer(),
                                    Text(
                                      '着',
                                      style: TextStyle(
                                        fontSize: widgetHeight * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
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
                                    decoration: InputDecoration(
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
                          Expanded(
                              child: Center(
                            child: Container(
                              height: widgetHeight * 0.1,
                              // color: Colors.green,
                              child: TextField(
                                controller: departureStationController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '東京',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(height: 1, fontSize: widgetHeight * 0.05, fontWeight: FontWeight.bold),
                                onChanged: (value) {
                                  // Handle the input text change here if needed
                                },
                              ),
                            ),
                          )),
                          Text(
                            '---',
                            style: TextStyle(height: 1, fontSize: widgetHeight * 0.06, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                              child: Center(
                            child: Container(
                              height: widgetHeight * 0.1,
                              child: TextField(
                                controller: arrivalStationController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '秋田',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(height: 1, fontSize: widgetHeight * 0.05, fontWeight: FontWeight.bold),
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
                                    Text('JAPAN', style: TextStyle(fontSize: widgetHeight * 0.03, fontWeight: FontWeight.bold)),
                                    // ## bottle location
                                    Text('Tokyo', style: TextStyle(fontSize: widgetHeight * 0.025, fontWeight: FontWeight.bold)),
                                  ],
                                )),
                          ),
                          Spacer(),
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
            style: TextStyle(fontSize: widgetHeight * 0.02, fontWeight: FontWeight.bold, fontFamily: 'Ds-digi'),
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

  DisplayBottle(this.name, this.bearingAngle, this.distance, this.latitude, this.longitude);
}
