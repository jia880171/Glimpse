import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/widgets/dashboard/rotary_knob.dart';
import 'package:glimpse/widgets/timeline_group/timeline_group.dart';
import 'package:vibration/vibration.dart';

import '../../config.dart' as config;

class Dashboard extends StatefulWidget {
  final Size widgetSize;
  final List<String> items;
  final List<DateTime> datesOfSelectedAlbum;
  final Function(int index) onItemSelected;
  final Function setSelectedDateByOffset;
  final Function(int currentIndex) setImagesWithDummiesPointer;
  final int imageWithDummiesPointer;
  final int imagesWithDummiesLength;
  final String shutterSpeed;
  final String aperture;
  final String iso;
  final DateTime selectedDate;
  final Map<DateTime, int> photosCountPerDay;
  final Function onImagesReset;

  const Dashboard(
      {super.key,
      required this.widgetSize,
      required this.onItemSelected,
      required this.items,
      required this.datesOfSelectedAlbum,
      required this.setSelectedDateByOffset,
      required this.imageWithDummiesPointer,
      required this.setImagesWithDummiesPointer,
      required this.imagesWithDummiesLength,
      required this.shutterSpeed,
      required this.aperture,
      required this.iso,
      required this.selectedDate,
      required this.photosCountPerDay,
      required this.onImagesReset});

  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final GlobalKey _keyForMenu = GlobalKey();
  final GlobalKey _keyForDate = GlobalKey();
  final GlobalKey _keyForFilmRoller = GlobalKey();

  double accumulatedDelta = 0.0;
  final double threshold = 10 * pi / 180;
  bool isVibrating = false;
  Timer? vibrationTimer;

  int testPointer = 0;

  int _menuPointer = 0;
  int _datePointer = 0;
  double blur = 0.3;
  Color radioGlassColor = Colors.white.withOpacity(0.9);
  Color radioBackLightColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _menuPointer = 0;
    _datePointer = 0;
  }

  @override
  Widget build(BuildContext context) {
    double dentRadius =
        math.min(widget.widgetSize.width, widget.widgetSize.height) * 0.5 * 0.5;

    double radius = dentRadius * 0.98;

    double innerRadius = radius * 0.6;
    double dashWidth = (dentRadius - innerRadius);

    double dentPanelWidth = widget.widgetSize.width * 0.96;
    double borderHeight = widget.widgetSize.height * 0.95;

    double widgetWidth = widget.widgetSize.width;
    double widgetHeight = widget.widgetSize.height;

    double nikonHeight = widgetHeight * 0.4;

    double radioSectionHeight = widgetHeight * 0.39;
    double radioHeight = radioSectionHeight * 0.8;
    double lowerSectionHeight = widgetHeight * 0.5;

    double pillHeight = widget.widgetSize.height * 0.1;
    double roundRadiusOfMainWidget = widget.widgetSize.width * 0.0168;

    double nikonDialWidth = widgetWidth * 0.68;

    double minorMonitorWidth = widgetWidth * 0.11;
    double minorMonitorHeight = nikonHeight * 0.123;

    double minorMonitorFontSize = minorMonitorWidth * 0.2;

    return Container(
      decoration: BoxDecoration(
          color: config.dashboardBackGroundMainTheme,
          borderRadius: BorderRadius.circular(roundRadiusOfMainWidget)),
      width: widget.widgetSize.width,
      height: widget.widgetSize.height,
      child: Center(
        child: Column(
          children: [
            const Spacer(),

            // radio section
            TimelineGroup(
              widgetWidth: widgetWidth,
              widgetHeight: radioHeight,
              blur: blur,
              radioBackLightColor: radioBackLightColor,
              radioGlassColor: radioGlassColor,
              selectedDate: widget.selectedDate,
              photosCountPerDay: widget.photosCountPerDay,
            ),

            const Spacer(),

            // lower section
            Container(
              width: widgetWidth,
              height: lowerSectionHeight,
              // color: Colors.yellow,
              child: Row(
                children: [
                  lowerSection(
                      dashWidth, Size(widgetWidth, lowerSectionHeight)),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget lowerSection(double dashWidth, Size widgetSize) {
    double rotaryKnobWidgetHeight = widgetSize.height;
    return Container(
      // color: Colors.black,
      width: widgetSize.width,
      height: widget.widgetSize.height,
      child: Column(
        children: [
          Container(
            // color: Colors.green,
            // width: widgetSize.width,
            // height: widgetSize.height * 0.6,
            child: Row(
              children: [
                const Spacer(),

                RotaryKnob(
                  items: widget.items,
                  widgetWidth: widgetSize.width * 0.3,
                  widgetHeight: rotaryKnobWidgetHeight,
                  dashWidth: dashWidth,
                  knobKey: _keyForMenu,
                  knobColor: config.backGroundMainTheme,
                  gapColor: config.backGroundWhite,
                  dashColor: config.backGroundMainTheme,
                  dashCount: 3,
                  itemsLength: widget.items.length,
                  onItemSelected: (int oldIndex, int newIndex) {
                    widget.onItemSelected(newIndex);
                    updateMenuPointer(newIndex);
                  },
                  vibrate: vibrate,
                  knobTitle: 'menu',
                  isDrawArc: false,
                  isMenu: true,
                ),

                const Spacer(),

                // date
                RotaryKnob(
                  widgetWidth: widgetSize.width * 0.3,
                  widgetHeight: rotaryKnobWidgetHeight,
                  dashWidth: dashWidth,
                  knobKey: _keyForDate,
                  knobColor: config.backGroundMainTheme,
                  gapColor: config.backGroundWhite,
                  dashColor: config.mainBackGroundWhiteDarker2,
                  dashCount: 0,
                  itemsLength: widget.datesOfSelectedAlbum.length,
                  onItemSelected: (int oldIndex, int newIndex) {
                    widget.setSelectedDateByOffset(newIndex - oldIndex);
                    widget.setImagesWithDummiesPointer(1);
                    widget.onImagesReset();
                  },
                  vibrate: vibrate,
                  knobTitle: 'date',
                  isDrawArc: false,
                  isMenu: false,
                ),

                const Spacer(),

                // film roller
                RotaryKnob(
                  widgetWidth: widgetSize.width * 0.3,
                  widgetHeight: rotaryKnobWidgetHeight,
                  dashWidth: dashWidth,
                  knobKey: _keyForFilmRoller,
                  knobColor: config.backGroundMainTheme,
                  // knobColor: config.knob,
                  gapColor: config.backGroundWhite,
                  dashColor: config.mainBackGroundWhiteDarker2,
                  dashCount: 0,
                  itemsLength: 0,
                  onItemSelected: (int oldIndex, int newIndex) {
                    setState(() {
                      int currentIndex =
                          widget.imageWithDummiesPointer + newIndex;

                      if (currentIndex >= widget.imagesWithDummiesLength - 2) {
                        currentIndex = widget.imagesWithDummiesLength - 2;
                      } else if (currentIndex <= 1) {
                        currentIndex = 1;
                      }

                      widget.setImagesWithDummiesPointer(currentIndex);
                    });
                  },
                  vibrate: vibrate,
                  knobTitle: 'scroll',
                  isDrawArc: true,
                  isMenu: false,
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateMenuPointer(int newPointer) {
    setState(() {
      _menuPointer = newPointer;
    });
  }

  void vibrate(
      {required int duration, required int amplitude, bool isMajor = false}) {
    if (isVibrating && !isMajor) return; // ❗小震動若有主震動進行中，直接略過

    isVibrating = true;
    Vibration.vibrate(duration: duration, amplitude: amplitude);

    // 用 Timer 控制震動狀態回復
    vibrationTimer?.cancel();
    vibrationTimer = Timer(Duration(milliseconds: duration + 10), () {
      isVibrating = false;
    });
  }
}
