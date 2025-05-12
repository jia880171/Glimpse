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

class _MyHomePageStateold extends State<MyHomePage> {
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