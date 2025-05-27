import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glimpse/circle_date_picker_view.dart';

import 'light_box_view.dart';

class GlimpsesPickerView extends StatefulWidget {
  const GlimpsesPickerView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GlimpsesPickerViewState();
  }
}

class _GlimpsesPickerViewState extends State<GlimpsesPickerView> {
  bool isShowFilms = true;

  late DateTime selectedDate;
  int year = 2025;
  int month = 1;
  int day = 1;
  int glimpseCount = 0;

  double panelScale = 1;
  bool isPanelBig = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    print('====== film roll building');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Size widgetSize = Size(screenWidth, screenHeight);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                Opacity(
                    opacity: (isShowFilms == true) ? 1.0 : 0.0,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: LightBoxView(
                        selectedDate: selectedDate,
                        setGlimpseCount: setGlimpseCount,
                        widgetSize: widgetSize,
                      ),
                    )),

                // date picker
                Positioned(
                    bottom: screenHeight * 0.02,
                    child: GestureDetector(
                        onTap: _togglePanel,
                        child: AnimatedScale(
                          scale: panelScale,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Transform.rotate(
                            angle: 0 * 3.1415926535897932 / 180,
                            child: CircleDatePickerView(
                                _togglePanel,
                                screenHeight * 0.38,
                                screenWidth,
                                setDate,
                                glimpseCount,
                                isPanelBig,
                                makePanelSmall,
                                startCountdown),
                          ),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setGlimpseCount(int count) {
    setState(() {
      glimpseCount = count;
    });
  }

  void setDate(int year, int month, int day) {
    setState(() {
      this.year = year;
      this.month = month;
      this.day = day;
      selectedDate = DateTime(year, month, day);
    });
  }

  void startCountdown() {
    // Stop the old one if there is any.
    _timer?.cancel();

    _timer = Timer(const Duration(milliseconds: 3500), () {
      setState(() {
        isPanelBig = false;
        panelScale = 0.3;
      });
    });
  }

  void _togglePanel() {
    startCountdown();

    setState(() {
      if (!isPanelBig) {
        isPanelBig = true;
        panelScale = 1;
      }
    });
  }

  void makePanelSmall() {
    setState(() {
      if (isPanelBig) {
        isPanelBig = false;
        panelScale = 0.3;
      }
    });
  }
}
