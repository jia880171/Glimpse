import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import './config.dart' as config;
import 'database/attraction.dart';
import 'main.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

class PerpetualView extends StatefulWidget {
  final double perpetualViewHeight;
  final double screenWidth;
  final Attraction home;
  final Function setDate;

  const PerpetualView(
      this.perpetualViewHeight, this.screenWidth, this.home, this.setDate,
      {Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PerpetualViewState createState() => _PerpetualViewState();
}

class _PerpetualViewState extends State<PerpetualView> {
  static const IconData fingerprint =
      IconData(0xe287, fontFamily: 'MaterialIcons');

  AngleCalculator angleCalculator = AngleCalculator();

  late double dx;
  late double dy;
  double test = 0;
  late LightSource neumorphicLightSource;
  late double dragObjectRadius;
  late double smallSensorRadius;
  late double dentRadius;
  late double backgroundRadius;
  late final double monthRadius;
  late List<DisplayBottle> bottles;

  late final double centerOfTargetToCenterPlusTargetRadius;
  late final double centerOfTargetToCenter;

  late final double centerX;
  late final double centerY;

  late Offset dragDayPosition;

  late Offset dragObjectPositionOfMonth;
  double degreeOfRotated12OClockPositionOfMonth = 0.0;

  int dragDay = 1;
  int dragMonth = 1;
  int dragYear = 2024;

  double _totalRotation = 0.0;

  void calculateDragDay(degrees) {
    // 計算 dragDay
    double adjustedDegrees = degrees + 90; // 以 -90 為基準點
    if (adjustedDegrees < 0) {
      adjustedDegrees += 360; // 確保在 0 到 360 度之間
    }

    // 每一天的角度範圍
    double degreesPerDay = 360 / 31;
    dragDay = (adjustedDegrees / degreesPerDay).floor() + 1;

    // 確保 dragDay 在 1 到 31 之間
    if (dragDay > 31) {
      dragDay = 31;
    } else if (dragDay < 1) {
      dragDay = 1;
    }
    setState(() {
      widget.setDate(dragYear, dragMonth, dragDay);
    });
  }

  void calculateDragMonth(degrees) {
    final oldMonth = dragMonth;

    double adjustedDegrees = degrees + 90; // 以 -90 為基準點
    if (adjustedDegrees < 0) {
      adjustedDegrees += 360; // 確保在 0 到 360 度之間
    }

    print('======= adjustedDegrees ${adjustedDegrees}');

    // 每一天的角度範圍
    double degreesPerMonth = 360 / 12;
    dragMonth = (adjustedDegrees / degreesPerMonth).floor() + 1;

    // 確保 dragDay 在 1 到 31 之間
    if (dragMonth > 12) {
      dragMonth = 12;
    } else if (dragMonth < 1) {
      dragMonth = 1;
    }

    double unitRotation = ((2 * pi) / 12) * 1;

    if (dragMonth > oldMonth) {
      setState(() {
        if (dragMonth == 12 && oldMonth == 1) {
          _totalRotation -= unitRotation;
        } else {
          _totalRotation += unitRotation;
        }
      });
    } else if (dragMonth < oldMonth) {
      setState(() {
        if (dragMonth == 1 && oldMonth == 12) {
          _totalRotation += unitRotation;
        } else {
          _totalRotation -= unitRotation;
        }
      });
    }
  }

  double angleInDegrees(double angle) {
    return angle * (180 / pi);
  }

  double calculateDegreeBetween(Offset oldPosition, Offset newPosition) {
// 使用一個固定旋轉中心，通常是畫布中心點
    final Offset center =
        Offset(centerX - smallSensorRadius, centerY - smallSensorRadius);

    // 計算兩個向量分別相對於中心的角度
    final double angleOfNewPosition = (newPosition - center).direction;
    final double angleOfOldPosition = (oldPosition - center).direction;

    // 計算角度變化（夾角）
    final double angleDifference = angleOfNewPosition - angleOfOldPosition;

    return angleDifference;
  }

  bool isCrossingOneDegree(double angle1, double angle2) {
    // 確保角度在 0 到 360 之間
    angle1 = angle1 % 360;
    angle2 = angle2 % 360;

    // 將角度排序
    double start = angle1 < angle2 ? angle1 : angle2;
    double end = angle1 > angle2 ? angle1 : angle2;

    double unitDegree = 1;

    // 計算範圍內的最小和最大 15 的倍數
    double lowerMultiple = (start / unitDegree).ceil() * unitDegree;
    double upperMultiple = (end / unitDegree).floor() * unitDegree;

    return lowerMultiple <= upperMultiple;
  }

  double calculateRadiansInDegreeToTurns(double degree) {
    return degree * (1 / 360);
  }

  void rotateMonthPanel(Offset newFingerPosition) {
    final Offset center =
        Offset(centerX - smallSensorRadius, centerY - smallSensorRadius);
    final double newFingerAngelToCenterInDegree =
        angleInDegrees((newFingerPosition - center).direction);
    final double oldFingerAngelToCenterInDegree =
        angleInDegrees((dragObjectPositionOfMonth - center).direction);

    setState(() {
      if (isCrossingOneDegree(
          newFingerAngelToCenterInDegree, oldFingerAngelToCenterInDegree)) {
        double amountOfRotationInDegrees = 1;
        double amountOfRotationInTurns =
            calculateRadiansInDegreeToTurns(amountOfRotationInDegrees);
        if (newFingerAngelToCenterInDegree > oldFingerAngelToCenterInDegree) {
          _totalRotation += amountOfRotationInTurns;
          degreeOfRotated12OClockPositionOfMonth += amountOfRotationInDegrees;
        } else {
          _totalRotation -= amountOfRotationInTurns;
          degreeOfRotated12OClockPositionOfMonth -= amountOfRotationInDegrees;
        }
      }
    });
  }

  int takeTheComplementOf12(int month) {
    int complement = 12 - month;
    if (complement <= 0) {
      return 12;
    } else {
      return complement;
    }
  }

  void calculateMonthByTheDegreeOfRotated12OClockPosition(double degrees) {
    // 校正用
    // double adjustedDegrees = degrees + 90; // 以 -90 為基準點
    // if (adjustedDegrees < 0) {
    //   adjustedDegrees += 360; // 確保在 0 到 360 度之間
    // }

    double adjustedDegrees =
        ((degrees % 360) < 0) ? (degrees + 360) % 360 : (degrees % 360);

    double degreesPerMonth = 360 / 12;
    dragMonth = (adjustedDegrees / degreesPerMonth).floor();

    // The dial rotates in reverse direction
    dragMonth = takeTheComplementOf12(dragMonth);

    setState(() {
      widget.setDate(dragYear, dragMonth, dragDay);
    });
  }

  double calculateAngleByOffset(Offset location, Offset center) {
    // Calculate the angle between the new position and the center
    final angle = (location - center).direction;

    return angle;
  }

  void moveDragMonthObjectToCertainDegree(double angle) {
    final dragPositionCenter = Offset(
      centerX + (monthRadius * cos(angle)),
      centerY + (monthRadius * sin(angle)),
    );
    setState(() {
      dragObjectPositionOfMonth = angleCalculator.calibrateCoordination(
          dragPositionCenter, smallSensorRadius);
    });
  }

  @override
  void initState() {
    super.initState();
    neumorphicLightSource = LightSource.top;
    dragObjectRadius = widget.perpetualViewHeight * 0.23;
    smallSensorRadius = widget.perpetualViewHeight * 0.06;

    dentRadius = (dragObjectRadius * 1.05) + smallSensorRadius * 2;

    backgroundRadius = (dragObjectRadius * 1.05) + smallSensorRadius * 2.2;
    bottles = [
      DisplayBottle('E', 0, 150, 24.397630, 121.264331),
      DisplayBottle('N', 90, 100, 35.622522, 139.720624),
      DisplayBottle('W', 180, 150, 24.397630, 121.264331),
    ];

    // (center of target) to the center + (radius of target)
    // 小圓圓心與中心距離 ＋ 小圓半徑
    centerOfTargetToCenterPlusTargetRadius =
        dragObjectRadius + smallSensorRadius * 2;

    centerX = (widget.screenWidth / 2);
    centerY = (widget.perpetualViewHeight / 2);

    // center
    final dragPositionCenter =
        Offset(centerX, centerY - (dragObjectRadius + smallSensorRadius));
    // the position of that dragable object
    dragDayPosition = angleCalculator.calibrateCoordination(
        dragPositionCenter, smallSensorRadius);

    // Initialise the position
    monthRadius = dragObjectRadius + smallSensorRadius * 3.5;
    final dragMonthPositionCenter = Offset(centerX, centerY - monthRadius);

    dragObjectPositionOfMonth = angleCalculator.calibrateCoordination(
        dragMonthPositionCenter, smallSensorRadius);
  }

  @override
  Widget build(BuildContext context) {
    double fontSizeForText = widget.screenWidth * 0.036;
    return SizedBox(
      height: widget.perpetualViewHeight,
      width: widget.screenWidth,
      child: Stack(
        children: [
          // month panel
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              Offset localPosition = details.localPosition;

              print(
                  "========Tapped at X: $localPosition.dx, Y: $localPosition.dy");

              final angle = calculateAngleByOffset(
                  localPosition,
                  Offset(centerX - smallSensorRadius,
                      centerY - smallSensorRadius));

              moveDragMonthObjectToCertainDegree(angle);
            },
            child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: widget.screenWidth,
                  height: widget.perpetualViewHeight,
                  child: Stack(
                    children: [
                      AnimatedRotation(
                        turns: _totalRotation,
                        // Convert radians to turns
                        duration: const Duration(milliseconds: 200),
                        // Smooth rotation animation
                        child: Neumorphic(
                            style: const NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              intensity: 1,
                              depth: 1,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  color: config.backGroundWhite,
                                  width: widget.screenWidth,
                                  height: widget.perpetualViewHeight,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: CustomPaint(
                                    size: Size(widget.screenWidth,
                                        widget.perpetualViewHeight),
                                    // Adjust the size as needed
                                    painter: DashedCirclePainter(
                                        dx: centerX,
                                        dy: centerY,
                                        radius: dentRadius + smallSensorRadius,
                                        margin: 0.0,
                                        dashCount: 31,
                                        dashWidth: smallSensorRadius * 0.8,
                                        strokeWidth: smallSensorRadius * 0.03,
                                        strockColor: Colors.grey,
                                        isMonth: true),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                )),
          ),

          // rim
          Align(
            alignment: Alignment.center,
            child: Neumorphic(
                style: const NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  intensity: 1,
                  depth: 1,
                ),
                child: Container(
                  color: config.backGroundWhite,
                  width: (backgroundRadius * 2),
                  height: (backgroundRadius * 2),
                )),
          ),

          // dent R: dentRadius = (sensorRadius + smallSensorRadius * 3.2;)
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

          // hint R: sensorRadius
          Align(
            alignment: Alignment.center,
            child: Container(
              // color: Colors.green,
              height: (dragObjectRadius) * 1.9,
              width: (dragObjectRadius) * 1.9,
              child: NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    // shape: NeumorphicShape.convex,
                    boxShape: const NeumorphicBoxShape.circle(),
                    intensity: 0.8,
                    depth: 1.5,
                    lightSource: neumorphicLightSource,
                    color: config.backGroundWhite,
                  ),
                  onPressed: () {
                    // widget.toggleChasingMode();
                  },
                  child: SizedBox(
                    height: (dragObjectRadius) * 3,
                    width: (dragObjectRadius) * 3,
                  )),
            ),
          ),

          // png
          Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  // png
                  // Center(
                  //   child: Container(
                  //     width: dragObjectRadius * 1.8,
                  //     height: dragObjectRadius * 1.8,
                  //     decoration: const BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         image: DecorationImage(
                  //           image: AssetImage('assets/images/monitor.png'),
                  //           fit: BoxFit.cover,
                  //         )),
                  //   ),
                  // ),

                  // Text
                  Center(
                      child: SizedBox(
                          width: dragObjectRadius * 1.9,
                          height: dragObjectRadius * 1.9,
                          child: Column(
                            children: [
                              const Spacer(),

                              // const Spacer(),

                              // date
                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.end,
                              //   children: [
                              //     const Spacer(),
                              //
                              //     // year
                              //     SizedBox(
                              //       width: fontSizeForText * 4,
                              //       child: Text(
                              //         dragYear.toString(),
                              //         overflow: TextOverflow.clip,
                              //         maxLines: 1,
                              //         textAlign: TextAlign.center,
                              //         style: TextStyle(
                              //           fontSize: fontSizeForText,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily:
                              //               'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                              //         ),
                              //       ),
                              //     ),
                              //
                              //     // /
                              //     SizedBox(
                              //       child: Text(
                              //         '/',
                              //         overflow: TextOverflow.clip,
                              //         maxLines: 1,
                              //         textAlign: TextAlign.center,
                              //         style: TextStyle(
                              //           fontSize: fontSizeForText,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily:
                              //               'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                              //         ),
                              //       ),
                              //     ),
                              //
                              //     // month
                              //     SizedBox(
                              //       width: fontSizeForText * 2,
                              //       child: Text(
                              //         dragMonth < 10
                              //             ? '0$dragMonth'
                              //             : dragMonth.toString(),
                              //         overflow: TextOverflow.clip,
                              //         maxLines: 1,
                              //         textAlign: TextAlign.center,
                              //         style: TextStyle(
                              //           fontSize: fontSizeForText,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily:
                              //               'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                              //         ),
                              //       ),
                              //     ),
                              //
                              //     // /
                              //     SizedBox(
                              //       child: Text(
                              //         '/',
                              //         overflow: TextOverflow.clip,
                              //         maxLines: 1,
                              //         textAlign: TextAlign.center,
                              //         style: TextStyle(
                              //           fontSize: fontSizeForText,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily:
                              //               'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                              //         ),
                              //       ),
                              //     ),
                              //
                              //     // date
                              //     SizedBox(
                              //         width: fontSizeForText * 2,
                              //         child: Text(
                              //       dragDay < 10
                              //           ? '0$dragDay'
                              //           : dragDay.toString(),
                              //       overflow: TextOverflow.clip,
                              //       maxLines: 1,
                              //       textAlign: TextAlign.center,
                              //       style: TextStyle(
                              //         fontSize: fontSizeForText,
                              //         fontWeight: FontWeight.w500,
                              //         fontFamily:
                              //             'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                              //       ),
                              //     )),
                              //     const Spacer(),
                              //   ],
                              // ),

                              // cups
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  Container(
                                      // color: Colors.blue,
                                      width: dragObjectRadius * 1.9 * 0.4,
                                      child: Text(
                                        dragDay < 10
                                            ? '0$dragDay'
                                            : dragDay.toString(),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: dragObjectRadius *
                                              1.9 *
                                              0.5 *
                                              0.5,
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                        ),
                                      )),
                                  const Spacer(),
                                ],
                              ),
                              // glimpse

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  SizedBox(
                                      // color: Colors.blue,
                                      width: dragObjectRadius * 1.9 * 0.4,
                                      child: const Text(
                                        '',
                                      )),
                                  Text(
                                    'Glimpses',
                                    style: TextStyle(
                                      fontSize: widget.screenWidth * 0.02,
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'Ds-Digi', // Replace 'SecondFontFamily' with your desired font family
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),

                              const Spacer(),
                            ],
                          ))),
                ],
              )),

          // Draw date dash
          Align(
            alignment: Alignment.center,
            child: Container(
              // color: Colors.black,
              child: CustomPaint(
                size: Size(dentRadius * 2, dentRadius * 2),
                // Adjust the size as needed
                painter: DashedCirclePainter(
                    dx: dentRadius,
                    dy: dentRadius,
                    radius: dentRadius,
                    margin: dentRadius * 0.1,
                    dashCount: 31,
                    dashWidth: smallSensorRadius * 0.8,
                    strokeWidth: smallSensorRadius * 0.03,
                    strockColor: Colors.grey,
                    isMonth: false),
              ),
            ),
          ),

          // drag day
          Stack(children: [
            Positioned(
              left: dragDayPosition.dx,
              top: dragDayPosition.dy,
              child: Container(
                // color: config.redJP,
                width: (smallSensorRadius * (2)),
                height: (smallSensorRadius * (2)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Neumorphic(
                          style: const NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.circle(),
                            intensity: 1,
                            depth: 1.8,
                          ),
                          child: Container(
                            color: config.dragButton,
                            width: (smallSensorRadius * 2),
                            height: (smallSensorRadius * 2),
                          )),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Calculate the angle of the dragged position relative to the calibrated center point
                          Offset newPosition = dragDayPosition + details.delta;
                          Offset centerOfCalibratedDragPosition = Offset(
                              centerX - smallSensorRadius,
                              centerY - smallSensorRadius);

                          // Calculate the angle between the new position and the center
                          final angle =
                              (newPosition - centerOfCalibratedDragPosition)
                                  .direction;

                          final degrees = angle * (180 / pi);
                          if (degrees.ceil() % 15 == 0) {
                            Vibration.vibrate(duration: 25, amplitude: 255);
                          }
                          calculateDragDay(degrees);

                          final dragPositionCenter = Offset(
                            centerX +
                                ((dragObjectRadius + smallSensorRadius) *
                                    cos(angle)),
                            centerY +
                                (dragObjectRadius + smallSensorRadius) *
                                    sin(angle),
                          );

                          setState(() {
                            // dragPosition = Offset(tdx, tdy);
                            dragDayPosition =
                                angleCalculator.calibrateCoordination(
                                    dragPositionCenter, smallSensorRadius);
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {});
                        },
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
                                color: config.dragButton,
                                width: smallSensorRadius * (0.9) * 2,
                                height: smallSensorRadius * (0.9) * 2,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // monitor background

                                    Center(
                                        child: SizedBox(
                                            width: dragObjectRadius * 2,
                                            height: dragObjectRadius * 2,
                                            child:  Center(
                                              child:
                                                  // Icon(fingerprint),
                                                  // Icon(null),
                                              Text(
                                                dragDay.toString(),
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
                                            ))),
                                  ],
                                ))),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: Neumorphic(
                    //       style: const NeumorphicStyle(
                    //         shape: NeumorphicShape.flat,
                    //         boxShape: NeumorphicBoxShape.circle(),
                    //         intensity: 0.5,
                    //         depth: 0.6,
                    //       ),
                    //       child: Container(
                    //         color: config.dragButtonOrange,
                    //         width: (smallSensorRadius * 0.3),
                    //         height: (smallSensorRadius * 0.3),
                    //       )),
                    // ),
                  ],
                ),
              ),
            )
          ]),

          // drag month
          Stack(children: [
            Positioned(
              left: dragObjectPositionOfMonth.dx,
              top: dragObjectPositionOfMonth.dy,
              child: Container(
                // color: config.redJP,
                width: (smallSensorRadius * (2)),
                height: (smallSensorRadius * (2)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Neumorphic(
                          style: const NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.circle(),
                            intensity: 1,
                            depth: 1.8,
                          ),
                          child: Container(
                            color: config.backGroundWhite,
                            width: (smallSensorRadius * 2),
                            height: (smallSensorRadius * 2),
                          )),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Calculate the angle of the dragged position relative to the calibrated center point
                          Offset newFingerPosition =
                              dragObjectPositionOfMonth + details.delta;
                          Offset centerOfRime = Offset(
                              centerX - smallSensorRadius,
                              centerY - smallSensorRadius);

                          // Calculate the angle Of the new position to the center
                          final angleInRadian =
                              (newFingerPosition - centerOfRime).direction;

                          final degrees = angleInRadian * (180 / pi);
                          if (degrees.ceil() % 30 == 0) {
                            Vibration.vibrate(duration: 50, amplitude: 255);
                          }

                          rotateMonthPanel(newFingerPosition);

                          calculateMonthByTheDegreeOfRotated12OClockPosition(
                              degreeOfRotated12OClockPositionOfMonth);

                          final dragPositionCenter = Offset(
                            centerX + (monthRadius * cos(angleInRadian)),
                            centerY + monthRadius * sin(angleInRadian),
                          );

                          setState(() {
                            dragObjectPositionOfMonth =
                                angleCalculator.calibrateCoordination(
                                    dragPositionCenter, smallSensorRadius);
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {});
                        },
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
                                width: smallSensorRadius * (0.9) * 2,
                                height: smallSensorRadius * (0.9) * 2,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // monitor background
                                    // Center(
                                    //   child: Container(
                                    //     width: smallSensorRadius * 2,
                                    //     height: smallSensorRadius * 2,
                                    //     decoration: const BoxDecoration(
                                    //         shape: BoxShape.circle,
                                    //         image: DecorationImage(
                                    //           image: AssetImage(
                                    //               'assets/images/monitor.png'),
                                    //           fit: BoxFit.cover,
                                    //         )),
                                    //   ),
                                    // ),
                                    Center(
                                        child: SizedBox(
                                            width: dragObjectRadius * 2,
                                            height: dragObjectRadius * 2,
                                            child: const Center(
                                              child: Icon(fingerprint),
                                              // Text(
                                              //   dragMonth.toString(),
                                              //   overflow: TextOverflow.clip,
                                              //   maxLines: 1,
                                              //   textAlign: TextAlign.center,
                                              //   style: TextStyle(
                                              //     fontSize:
                                              //         widget.screenWidth * 0.03,
                                              //     fontWeight: FontWeight.w500,
                                              //     fontFamily:
                                              //         'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                              //   ),
                                              // ),
                                            ))),
                                  ],
                                )
                                // Align(
                                //   alignment: Alignment.center,
                                //   child: Text(dragDay.toString(),
                                //       style: TextStyle(
                                //           fontSize: 0.36 * smallSensorRadius,
                                //           fontWeight: FontWeight.bold)),
                                // )
                                )),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
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

  Offset calibrateCoordination(Offset originCoordination, double radius) {
    Offset calibratedCoordination =
        Offset(originCoordination.dx - radius, originCoordination.dy - radius);

    return calibratedCoordination;
  }

  double calculateLeftOfObject(
      double centerX, double centerXOfObject, double radius) {
    late double newLeft;

    if (centerXOfObject >= centerX) {
      newLeft = centerXOfObject + radius;
    } else {
      newLeft = centerXOfObject - radius;
    }

    return newLeft;
  }

  double calculateTopOfObject(
      double centerY, double centerYOfObject, double radius) {
    late double newTop;

    if (centerYOfObject >= centerY) {
      newTop = centerYOfObject + radius;
    } else {
      newTop = centerYOfObject - radius;
    }

    return newTop;
  }
}

class DashedCirclePainter extends CustomPainter {
  final double dx;
  final double dy;
  final double radius;
  final double margin;
  final double dashWidth;
  final double dashCount;
  final double strokeWidth;
  final Color strockColor;
  final bool isMonth;

  DashedCirclePainter(
      {required this.dx,
      required this.dy,
      required this.radius,
      required this.margin,
      required this.dashCount,
      required this.dashWidth,
      required this.strokeWidth,
      required this.strockColor,
      required this.isMonth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = strockColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (isMonth) {
      double newRadius = radius - margin;

      for (int i = 1; i < 13; i++) {
        double angle = (2 * pi * i) / 12 - (pi / 2);
        double x = dx + newRadius * cos(angle);
        double y = dy + newRadius * sin(angle);

        // Draw the text at the calculated position
        final textSpan = TextSpan(
          text: '$i', // Display the index
          style: const TextStyle(color: Colors.black, fontSize: 12),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Adjust the position to center the text around the point
        final offset =
            Offset(x - textPainter.width / 2, y - textPainter.height / 2);
        textPainter.paint(canvas, offset);
      }
    } else {
      double newRadius = radius - margin;

      for (int i = 0; i < dashCount; i++) {
        // Start angle at -pi / 2 to align the first dash to the 12 o'clock position
        double angle = (2 * pi * i) / dashCount - (pi / 2);
        double startX = dx + newRadius * cos(angle);
        double startY = dy + newRadius * sin(angle);
        double endX = dx + (newRadius - dashWidth) * cos(angle);
        double endY = dy + (newRadius - dashWidth) * sin(angle);

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
