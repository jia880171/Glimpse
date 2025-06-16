import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/widgets/dashboard/nikon28_like_dashboard.dart';
import 'package:glimpse/widgets/dashboard/rotary_knob.dart';
import 'package:vibration/vibration.dart';

import '../../config.dart' as config;
import '../orange_light_glass.dart';

class Dashboard extends StatefulWidget {
  final Size widgetSize;
  final List<String> items;
  final List<DateTime> datesOfSelectedAlbum;
  final Function(int index) onItemSelected;
  final Function setTargetDatePointer;
  final Function(int currentIndex) setImagesPointer;
  final int imageWithDummiesPointer;
  final int imagesWithDummiesLength;
  final String shutterSpeed;
  final String aperture;
  final String iso;

  const Dashboard(
      {super.key,
      required this.widgetSize,
      required this.onItemSelected,
      required this.items,
      required this.datesOfSelectedAlbum,
      required this.setTargetDatePointer,
      required this.imageWithDummiesPointer,
      required this.setImagesPointer,
      required this.imagesWithDummiesLength,
      required this.shutterSpeed,
      required this.aperture,
      required this.iso});

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

    double borderWidth = widget.widgetSize.width * 0.95;
    double borderHeight = widget.widgetSize.height * 0.95;

    double widgetInnerWidth = widget.widgetSize.width * 0.9;
    double widgetInnerHeight = widget.widgetSize.height * 0.9;

    double nikonHeight = widgetInnerHeight * 0.6;
    double lowerSectionHeight = widgetInnerHeight * 0.4;

    double pillHeight = widget.widgetSize.height * 0.1;
    double roundRadiusOfMainWidget = widget.widgetSize.width * 0.0168;

    return Container(
      // color: Colors.cyan,
      width: widget.widgetSize.width,
      height: widget.widgetSize.height,
      child: Center(
        child:
        Neumorphic(
          style: NeumorphicStyle(
              color: config.mainBackGroundWhite,
              shape: NeumorphicShape.convex,
              boxShape:
              NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(
                      roundRadiusOfMainWidget)),
              intensity: 1,
              depth: -0.8),
          child: Container(
            width: borderWidth,
            height: borderHeight,
            child: Column(
              children: [
                // nikon
                Container(
                  // color: Colors.green,
                    width: widgetInnerWidth,
                    height: nikonHeight,
                    child: Row(
                      children: [
                        const Spacer(),
                        Nikon28TiDashboard(
                          widgetSize: Size(
                              widget.widgetSize.width * 0.8, nikonHeight * 0.8),
                          imagesWithDummiesPointer:
                          widget.imageWithDummiesPointer,
                          imagesLength: widget.imagesWithDummiesLength,
                          backgroundColor: config.mainBackGroundWhite,
                          shutterSpeed: widget.shutterSpeed,
                          aperture: widget.aperture,
                          iso: widget.iso,
                        ),
                        const Spacer(),
                      ],
                    )),

                SizedBox(
                  width: widgetInnerWidth,
                  height: lowerSectionHeight,
                  child: Row(
                    children: [
                      // const Spacer(),
                      // mainMenuDashboard(dashWidth, pillHeight,
                      //     Size(widgetInnerWidth * 0.3, lowerSectionHeight)),
                      const Spacer(),
                      lowerSection(dashWidth,
                          Size(widgetInnerWidth, lowerSectionHeight)),
                      const Spacer(),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
        ,
      ),
    );
  }

  Widget mainMenuDashboard(
      double dashWidth, double pillHeight, Size widgetSize) {
    return SizedBox(
        width: widgetSize.width,
        height: widgetSize.height,
        child: Column(
          children: [
            const Spacer(),
            Stack(
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    lightSource: LightSource.topRight,
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(1.68)),
                    intensity: 1,
                    depth: -1,
                  ),
                  child: Container(
                    width: widgetSize.width * 0.8,
                    height: widgetSize.height * 0.1,
                    color: config.mainBackGroundWhite,
                    child: Center(
                      child: Text(
                        widget.items[_menuPointer],
                        style: TextStyle(
                            fontSize: pillHeight * 0.3, fontFamily: 'Ds-Digi'),
                      ),
                    ),
                  ),
                ),
                const OrangeGlass(
                  lightRadius: 8,
                  blur: 0.23,
                  borderRadiusCircular: 1.68,
                )
              ],
            ),
            const Spacer(),
            RotaryKnob(
              widgetHeight: widgetSize.height * 0.8,
              widgetWidth: widgetSize.width,
              dashWidth: dashWidth,
              knobKey: _keyForMenu,
              backgroundColor: config.mainBackGroundWhite,
              innerColor: config.mainBackGroundWhiteDarker,
              dashColor: config.mainBackGroundWhiteDarker2,
              dashCount: widget.items.length,
              itemsLength: widget.items.length,
              onItemSelected: (int oldIndex, int newIndex) {
                widget.onItemSelected(newIndex);
                updateMenuPointer(newIndex);
              },
              vibrate: vibrate,
              knobTitle: 'menu',
            ),
            const Spacer(),
          ],
        ));
  }

  Widget lowerSection(double dashWidth, Size widgetSize) {
    return Container(
      // color: Colors.black,
      width: widgetSize.width,
      height: widget.widgetSize.height,
      child: Column(
        children: [
          const Spacer(),
          Container(
            // color: Colors.green,
            // width: widgetSize.width,
            // height: widgetSize.height * 0.6,
            child: Row(
              children: [

                Stack(
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                        lightSource: LightSource.topRight,
                        shape: NeumorphicShape.convex,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(1.68)),
                        intensity: 1,
                        depth: -1,
                      ),
                      child: Container(
                        width: widgetSize.width * 0.1,
                        height: widgetSize.height * 0.1,
                        color: config.mainBackGroundWhite,
                        child: Center(
                          child: Text(
                            widget.items[_menuPointer],
                            style: TextStyle(
                                fontSize: widgetSize.width * 0.01, fontFamily: 'Ds-Digi'),
                          ),
                        ),
                      ),
                    ),
                    const OrangeGlass(
                      lightRadius: 8,
                      blur: 0.23,
                      borderRadiusCircular: 1.68,
                    )
                  ],
                ),
                const Spacer(),

                RotaryKnob(
                  widgetWidth: widgetSize.width * 0.3,
                  widgetHeight: widgetSize.height * 0.8,
                  dashWidth: dashWidth,
                  knobKey: _keyForMenu,
                  backgroundColor: config.mainBackGroundWhite,
                  innerColor: config.mainBackGroundWhiteDarker,
                  dashColor: config.mainBackGroundWhiteDarker2,
                  dashCount: widget.items.length,
                  itemsLength: widget.items.length,
                  onItemSelected: (int oldIndex, int newIndex) {
                    widget.onItemSelected(newIndex);
                    updateMenuPointer(newIndex);
                  },
                  vibrate: vibrate,
                  knobTitle: 'menu',
                ),

                const Spacer(),

                // date
                RotaryKnob(
                  widgetWidth: widgetSize.width * 0.3,
                  widgetHeight: widgetSize.height * 0.8,
                  dashWidth: dashWidth,
                  knobKey: _keyForDate,
                  backgroundColor: config.mainBackGroundWhite,
                  innerColor: config.mainBackGroundWhiteDarker,
                  dashColor: config.mainBackGroundWhiteDarker2,
                  dashCount: 0,
                  itemsLength: widget.datesOfSelectedAlbum.length,
                  onItemSelected: (int oldIndex, int newIndex) {
                    widget.setTargetDatePointer(newIndex - oldIndex);
                  },
                  vibrate: vibrate,
                  knobTitle: 'date',
                ),

                const Spacer(),

                // film roller
                RotaryKnob(
                  widgetWidth: widgetSize.width * 0.3,
                  widgetHeight: widgetSize.height * 0.8,
                  dashWidth: dashWidth,
                  knobKey: _keyForFilmRoller,
                  backgroundColor: config.mainBackGroundWhite,
                  innerColor: config.mainBackGroundWhiteDarker,
                  dashColor: config.mainBackGroundWhiteDarker2,
                  dashCount: 0,
                  itemsLength: 0,
                  onItemSelected: (int oldIndex, int newIndex) {
                    setState(() {
                      int currentIndex =
                          widget.imageWithDummiesPointer + newIndex;
                      print(
                          '====== [dash] [rotating], currentIndex:  ${currentIndex}, widget.imageLength ${widget.imagesWithDummiesLength}');

                      if (currentIndex >= widget.imagesWithDummiesLength - 2) {
                        currentIndex = widget.imagesWithDummiesLength - 2;
                      } else if (currentIndex <= 1) {
                        currentIndex = 1;
                      }

                      print(
                          '====== [dash] setImagesPointer, currentIndex:  ${currentIndex}, widget.imagesWithDummiesLength** ${widget.imagesWithDummiesLength}');
                      widget.setImagesPointer(currentIndex);
                    });
                  },
                  vibrate: vibrate,
                  knobTitle: 'scroll',
                ),
                const Spacer(),
              ],
            ),
          ),
          const Spacer(),
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
