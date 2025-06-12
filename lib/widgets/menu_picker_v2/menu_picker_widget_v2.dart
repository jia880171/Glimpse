import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/widgets/menu_picker_v2/rotary_knob.dart';
import 'package:vibration/vibration.dart';

import '../../config.dart' as config;
import '../orange_light_glass.dart';

class MenuPickerV2 extends StatefulWidget {
  final Size widgetSize;
  final List<String> items;
  final List<DateTime> datesOfSelectedAlbum;
  final Function(int index) onItemSelected;
  final Function setTargetDatePointer;
  final Function(int offset) setScrollOffset;

  const MenuPickerV2(
      {super.key,
      required this.widgetSize,
      required this.onItemSelected,
      required this.items,
      required this.datesOfSelectedAlbum,
      required this.setTargetDatePointer,
      required this.setScrollOffset});

  @override
  State<StatefulWidget> createState() => MenuPickerV2State();
}

class MenuPickerV2State extends State<MenuPickerV2> {
  final GlobalKey _keyForMenu = GlobalKey();
  final GlobalKey _keyForDate = GlobalKey();
  final GlobalKey _keyForFilmRoller = GlobalKey();

  double accumulatedDelta = 0.0;
  final double threshold = 10 * pi / 180;
  bool isVibrating = false;
  Timer? vibrationTimer;

  int _menuPointer = 0;
  int _datePointer = 0;

  // late double sensitivity;

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

    double pillHeight = widget.widgetSize.height * 0.1;
    double pillWidth = radius * 3;

    return Container(
      alignment: Alignment.center,
      // color: config.mainBackGroundWhite,
      // color: Colors.red,
      width: widget.widgetSize.width,
      height: widget.widgetSize.height,
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
              width: widget.widgetSize.width * 0.36,
              height: widget.widgetSize.height,
              child: Column(
                children: [
                  const Spacer(),
                  RotaryKnob(
                    widgetHeight: widget.widgetSize.height * 0.8,
                    widgetWidth: widget.widgetSize.width * 0.36,
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
              )),
          const Spacer(),
          Container(
            // color: Colors.green,
            width: widget.widgetSize.width * 0.5,
            height: widget.widgetSize.height,
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
                        width: widget.widgetSize.width * 0.5,
                        height: widget.widgetSize.height * 0.1,
                        color: config.mainBackGroundWhite,
                        child: Center(
                          child: Text(
                            widget.items[_menuPointer],
                            style: TextStyle(
                                fontSize: pillHeight * 0.3,
                                fontFamily: 'Ds-Digi'),
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
                Container(
                  // color: Colors.green,
                  width: widget.widgetSize.width * 0.5,
                  height: widget.widgetSize.height * 0.6,
                  child: Row(
                    children: [
                      const Spacer(),

                      // date
                      RotaryKnob(
                        widgetWidth: widget.widgetSize.width * 0.25,
                        widgetHeight: widget.widgetSize.height * 0.6,
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
                        widgetWidth: widget.widgetSize.width * 0.25,
                        widgetHeight: widget.widgetSize.height * 0.6,
                        dashWidth: dashWidth,
                        knobKey: _keyForFilmRoller,
                        backgroundColor: config.mainBackGroundWhite,
                        innerColor: config.mainBackGroundWhiteDarker,
                        dashColor: config.mainBackGroundWhiteDarker2,
                        dashCount: 0,
                        itemsLength: 0,
                        onItemSelected: (int oldIndex, int newIndex) {
                          widget.setScrollOffset(newIndex);
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
