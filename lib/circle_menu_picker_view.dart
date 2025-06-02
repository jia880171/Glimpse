import 'dart:async';
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/common/utils/rotation_utils.dart';

import './config.dart' as config;
import 'AnimatedNeumorphicText.dart';
import 'circle_date_picker_view.dart';
import 'models/rotary_selector_with_drag_handle.dart';

const filmFinderItemName = 'FILMS';
const contactSheetItemName = 'CONTACT SHEET';

class CircleMenuPickerView extends StatefulWidget {
  final List<String> items;
  final int datesLength;
  final Function onItemSelected;
  final Function setTargetDatePointer;
  final double radius;
  final List<String> menuItemsPath;
  final Size widgetSize;

  const CircleMenuPickerView(
      {Key? key,
      required this.onItemSelected,
      required this.items,
      required this.radius,
      required this.menuItemsPath,
      l,
      required this.setTargetDatePointer,
      required this.datesLength,
      required this.widgetSize})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CircleMenuPickerViewState();
}

class CircleMenuPickerViewState extends State<CircleMenuPickerView> {
  static const IconData fingerprint =
      IconData(0xe287, fontFamily: 'MaterialIcons');

  final double _depthMax = 0.5;
  final double _depthMin = 0.0;
  final double _depthNormal = 0.3;

  double menuTurns = 0;
  double dateAngleShiftAmount = 0;

  late final double radiusMax = widget.radius;
  late final double itemRadius = widget.radius * 0.7;
  late final double dentRadius = widget.radius * 0.3;
  late final double dashWidth = widget.radius * 0.15;

  final Duration depthOutDuration = const Duration(milliseconds: 600);
  final Duration depthInDuration = const Duration(milliseconds: 600);

  Timer? _timer;

  late List<double> depths =
      List<double>.filled(widget.items.length, _depthMin);
  late List<double> prevDepths =
      List<double>.filled(widget.items.length, _depthMin);

  int _menuPointer = 0;
  int _datePointer = 0;
  final LightSource neumorphicLightSource = LightSource.topRight;

  late final double distanceFromMenuCenterToScreenCenter;
  late Offset dragMenuPosition; // left top
  late double radiusOfDragMenu;

  late final double distanceFromDateCenterToScreenCenter;
  late Offset dragDatePosition; // left top
  late double radiusOfDragDate;



  late final double centerX;
  late final double centerY;

  @override
  void initState() {
    super.initState();

    radiusOfDragMenu = (itemRadius - dentRadius) / 2 * 0.66;
    distanceFromMenuCenterToScreenCenter = itemRadius - radiusOfDragMenu;

    radiusOfDragDate = (radiusMax - itemRadius) / 2 * 0.78;
    distanceFromDateCenterToScreenCenter = radiusMax - radiusOfDragDate;

    centerX = radiusMax;
    centerY = radiusMax;

    final dragMenuPositionCenter =
        Offset(centerX, centerY - distanceFromMenuCenterToScreenCenter);
    dragMenuPosition = RotationUtils.centerToTopLeft(
        dragMenuPositionCenter, radiusOfDragMenu);

    final dragDatePositionCenter =
    Offset(centerX, centerY - distanceFromDateCenterToScreenCenter);
    dragDatePosition = RotationUtils.centerToTopLeft(
        dragDatePositionCenter, radiusOfDragDate);

    // text's ani
    depths[_menuPointer] = _depthMax;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.red,
        height: radiusMax * 2,
        width: radiusMax * 2,
        child: Stack(
          children: [
            // panel or datePicker
            Center(
              child: datePickerOrRim(),
            ),

            RotarySelectorWithDragHandle(
              itemRadius: itemRadius,
              dentRadius: dentRadius,
              dashWidth: dashWidth,
              itemLength: widget.items.length,
              initialPointer: _menuPointer,
              onItemSelected: (int oldIndex, int newIndex) {
                widget.onItemSelected(newIndex);
                itemSwitchAni(oldIndex, newIndex);
                updatePointer(newIndex);
              },
              rimColor: config.menuPickerWhite,
              dashColor: config.backGroundWhiteDark,
              lightSource: neumorphicLightSource,
              // sensitivity: 1,
              initialDragObjPosition: dragMenuPosition,
              centerX: centerX,
              centerY: centerY,
              radiusOfDragObj: radiusOfDragMenu,
              distanceFromDragObjCenterToScreenCenter:
                  distanceFromMenuCenterToScreenCenter,
              dragHandleColor: Colors.orange,
            ),

            //dent
            Align(
              alignment: Alignment.center,
              child: NeumorphicButton(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: const NeumorphicBoxShape.circle(),
                  intensity: 1,
                  depth: .8,
                  lightSource: neumorphicLightSource,
                  color: config.menuPickerWhite,
                  // color: Colors.black,
                ),
                onPressed: () {
                  // print('===== pointer $_menuPointer');

                  // Delay to allow the button dent animation to finish before navigation.
                  Timer(
                      const Duration(milliseconds: 100),
                      () => Navigator.pushNamed(
                          context, widget.menuItemsPath[_menuPointer]));
                },
                child: Container(
                    // color: Colors.black,
                    width: (dentRadius * 2),
                    height: (dentRadius * 2),
                    child: Stack(
                        children: List.generate(
                      6,
                      (i) {
                        return Center(
                          child: AnimatedNeumorphicText(
                            text: widget.items[i],
                            prevDepth: prevDepths[i],
                            depth: depths[i],
                            onTap: () {
                              Navigator.pushNamed(
                                  context, widget.menuItemsPath[i]);
                            },
                            fontSize: dentRadius * 0.33,
                            color: config.backLightB,
                            depthInDuration: depthInDuration,
                            depthOutDuration: depthOutDuration,
                          ),
                        );
                      },
                    ))),
              ),
            ),
          ],
        ));
  }

  void rotateMenuPanel(double angleInRadian) {
    double totalTurns = angleInRadian / (2 * pi);
    setMenuTurns(totalTurns);
  }

  void setMenuTurns(double turns) {
    menuTurns = turns;
  }

  Widget datePickerOrRim() {
    return (widget.items[_menuPointer] == filmFinderItemName ||
            widget.items[_menuPointer] == contactSheetItemName)
        ? datePicker()
        : Neumorphic(
            style: NeumorphicStyle(
                lightSource: neumorphicLightSource,
                shape: NeumorphicShape.convex,
                boxShape: const NeumorphicBoxShape.circle(),
                intensity: 0.8,
                depth: -1),
            child: Container(
              color: config.menuPickerWhite,
              width: itemRadius * 1.05 * 2,
              height: itemRadius * 1.05 * 2,
            ));
  }

  int takeTheComplementOf12(int month) {
    int complement = 12 - month;
    if (complement <= 0) {
      return 12;
    } else {
      return complement;
    }
  }

  void rotateMonthPanel(Offset newFingerPosition) {
    final Offset center =
        Offset(centerX - radiusOfDragMenu, centerY - radiusOfDragMenu);
    final double newFingerAngelToCenterInDegree =
        angleInDegrees((newFingerPosition - center).direction);
    final double oldFingerAngelToCenterInDegree =
        angleInDegrees((dragMenuPosition - center).direction);

    setState(() {
      if (isCrossingOneDegree(
          newFingerAngelToCenterInDegree, oldFingerAngelToCenterInDegree)) {
        double amountOfRotationInDegrees = 1;
        double amountOfRotationInTurns =
            calculateRadiansInDegreeToTurns(amountOfRotationInDegrees);
        // if (newFingerAngelToCenterInDegree > oldFingerAngelToCenterInDegree) {
        //   _totalRotation += amountOfRotationInTurns;
        //   degreeOfRotated12OClockPositionOfMonth += amountOfRotationInDegrees;
        // } else {
        //   _totalRotation -= amountOfRotationInTurns;
        //   degreeOfRotated12OClockPositionOfMonth -= amountOfRotationInDegrees;
        // }
      }
    });
  }

  double calculateRadiansInDegreeToTurns(double degree) {
    return degree * (1 / 360);
  }

  bool isCrossingOneDegree(double angle1, double angle2) {
    // 確保角度在 0 到 360 之間
    angle1 = angle1 % 360;
    angle2 = angle2 % 360;

    // 將角度排序
    double start = angle1 < angle2 ? angle1 : angle2;
    double end = angle1 > angle2 ? angle1 : angle2;

    double unitDegree = 1;

    double lowerMultiple = (start / unitDegree).ceil() * unitDegree;
    double upperMultiple = (end / unitDegree).floor() * unitDegree;

    return lowerMultiple <= upperMultiple;
  }

  double angleInDegrees(double angle) {
    return angle * (180 / pi);
  }

  Widget datePicker() {
    return RotarySelectorWithDragHandle(
      itemRadius: radiusMax,
      dentRadius: itemRadius,
      dashWidth: dashWidth,
      itemLength: widget.datesLength,
      initialPointer: _datePointer,
      onItemSelected: (int oldIndex, int newIndex) {
        widget.setTargetDatePointer(newIndex - oldIndex);
      },
      rimColor: config.menuPickerWhite,
      dashColor: config.backGroundWhiteDark,
      lightSource: neumorphicLightSource,
      initialDragObjPosition: dragDatePosition,
      centerX: centerX,
      centerY: centerY,
      radiusOfDragObj: radiusOfDragDate,
      distanceFromDragObjCenterToScreenCenter:
          distanceFromDateCenterToScreenCenter,
      dragHandleColor: Colors.transparent,
    );
  }

  void itemSwitchAni(int oldIndex, int newIndex) {
    print('====== oldIndex: ${oldIndex}');
    print('====== newIndex: ${newIndex}');

    if (oldIndex == newIndex) return;

    // 👉 取消先前設定的延遲動畫，避免動畫疊加。
    _timer?.cancel();

    // 👉 在動畫前，先記錄每個項目的目前 depth 狀態
    for (int i = 0; i < depths.length; i++) {
      prevDepths[i] = depths[i];
    }

    // 👉 讓舊的選中項目凹陷（浮起 ➝ 凹陷）
    setState(() {
      depths[oldIndex] = _depthMin;
    });

    // 👉 等第一段動畫結束後，再讓新選中項目浮起
    _timer = Timer(depthOutDuration, () {
      // 👉 第二段動畫前，再次記錄目前狀態

      for (int i = 0; i < depths.length; i++) {
        prevDepths[i] = depths[i]; // 儲存當前狀態
      }

      setState(() {
        depths[newIndex] = _depthMax;
        print('====== new new Depteh: ${depths}');
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

  void updatePointer(int newPointer) {
    setState(() {
      _menuPointer = newPointer;
    });
  }

  double alignDegreeTo12OClock(double angleInDegrees) {
    // Adjust the angle to align 12 o'clock as the 0-degree reference point.
    // By default, angles are measured from the 3 o'clock position (0 degrees).
    // Adding 90 degrees shifts the reference to 12 o'clock (previously -90 degrees).
    double alignedDegrees = angleInDegrees + 90;

    // Ensure the resulting angle stays within the range of 0 to 360 degrees.
    if (alignedDegrees < 0) {
      alignedDegrees += 360;
    }
    return alignedDegrees;
  }

  double _getAngleFromOffset(Offset center, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return atan2(dy, dx);
  }

  double _normalizeAngle(double angle) {
    // Normalize angle to [-pi, pi] for smooth rotation
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }
}
