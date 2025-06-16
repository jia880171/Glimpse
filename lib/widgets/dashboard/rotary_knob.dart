import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../common/utils/rotation_utils.dart';
import '../../config.dart' as config;
import '../jagged_circle.dart';

class RotaryKnob extends StatefulWidget {
  final String knobTitle;
  final double widgetHeight;
  final double widgetWidth;
  final double dashWidth;
  final GlobalKey knobKey;
  final Color backgroundColor;
  final Color innerColor;
  final Color dashColor;
  final int itemsLength;
  final Function(int oldIndex, int newIndex) onItemSelected;
  final int dashCount;
  final Function(
      {required int duration,
      required int amplitude,
      required bool isMajor}) vibrate;

  const RotaryKnob({
    super.key,
    required this.dashWidth,
    required this.knobKey,
    required this.backgroundColor,
    required this.innerColor,
    required this.dashColor,
    required this.dashCount,
    required this.itemsLength,
    required this.onItemSelected,
    required this.vibrate,
    required this.widgetHeight,
    required this.knobTitle,
    required this.widgetWidth,
  });

  @override
  State<RotaryKnob> createState() => _RotaryKnobState();
}

class _RotaryKnobState extends State<RotaryKnob> {
  late int _pointer;
  bool isVibrating = false;
  late double sensitivity;
  late double itemAngle;
  late Offset _center;
  double _totalTurns = 0;
  double? _lastAngle;
  double accumulatedDeltaForWeakVibration = 0;
  double _accumulatedAngle = 0;
  final double weakVibrationThreshold = pi / 30;
  final double rotationWithoutItemsThreshold = pi / 8;

  late bool isNoItem = widget.itemsLength == 0;

  late double dentRadius =
      math.min(widget.widgetWidth, widget.widgetHeight) * 0.3;
  late double radius = dentRadius * 0.98;
  late double innerRadius = radius * 0.6;
  late double dashWidth = (dentRadius - innerRadius);
  final int toothCount = 66;

  @override
  void initState() {
    super.initState();
    sensitivity = calculateSensitivity(widget.itemsLength);
    itemAngle = sensitivity;
    print('====== itemAngle $itemAngle');
    _pointer = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.yellow,
        height: widget.widgetHeight,
        width: widget.widgetWidth,
        child: Column(
          children: [
            SizedBox(
              height: widget.widgetHeight * 0.8,
              width: widget.widgetWidth,
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: dentRadius * 2,
                    height: dentRadius * 2,
                    child: Stack(
                      children: [
                        // Outer dent circle
                        Center(
                          child: Neumorphic(
                            style: const NeumorphicStyle(
                              lightSource: LightSource.topRight,
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                              intensity: 1,
                              depth: -1,
                            ),
                            child: Container(
                              width: dentRadius * 2,
                              height: dentRadius * 2,
                              color: widget.innerColor,
                            ),
                          ),
                        ),

                        // Main rotary area
                        Center(
                          child: GestureDetector(
                            onPanStart: (details) {
                              final box = widget.knobKey.currentContext!
                                  .findRenderObject() as RenderBox;
                              _center = box.size.center(Offset.zero);
                              final localPos =
                                  box.globalToLocal(details.globalPosition);
                              _lastAngle = RotationUtils.getAngleFromOffset(
                                  _center, localPos);
                            },
                            onPanUpdate: (details) {
                              final box = widget.knobKey.currentContext!
                                  .findRenderObject() as RenderBox;
                              final localPos =
                                  box.globalToLocal(details.globalPosition);
                              final currentAngle =
                                  RotationUtils.getAngleFromOffset(
                                      _center, localPos);

                              if (_lastAngle != null) {
                                final delta = RotationUtils.normalizeAngle(
                                    currentAngle - _lastAngle!);
                                rotateBy(delta);

                                accumulatedDeltaForWeakVibration += delta.abs();
                                if (accumulatedDeltaForWeakVibration >=
                                        weakVibrationThreshold &&
                                    widget.itemsLength != 0) {
                                  widget.vibrate(
                                      duration: 30,
                                      amplitude: 66,
                                      isMajor: false);
                                  accumulatedDeltaForWeakVibration = 0.0;
                                }
                              }
                              _lastAngle = currentAngle;
                            },
                            onPanEnd: (_) {
                              _lastAngle = null;
                              if (isNoItem) {
                                widget.onItemSelected(0, 0);
                              }
                            },
                            child: SizedBox(
                              key: widget.knobKey,
                              child: Neumorphic(
                                style: const NeumorphicStyle(
                                  lightSource: LightSource.topRight,
                                  shape: NeumorphicShape.convex,
                                  boxShape: NeumorphicBoxShape.circle(),
                                  intensity: 1,
                                  depth: 1,
                                ),
                                child: Container(
                                  width: radius * 2,
                                  height: radius * 2,
                                  color: widget.backgroundColor,
                                  child: AnimatedRotation(
                                    turns: _totalTurns,
                                    duration: const Duration(milliseconds: 200),
                                    child: Stack(
                                      children: [
                                        IgnorePointer(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: buildCircularDashes(
                                              radius: radius * 0.95,
                                              dashCount: widget.dashCount,
                                              dashLength:
                                                  widget.dashWidth * 0.95,
                                              dashThickness:
                                                  widget.dashWidth * 0.035,
                                              color: widget.dashColor,
                                            ),
                                          ),
                                        ),
                                        jaggedSpinner(
                                          radius: innerRadius,
                                          color: widget.dashColor,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(
                height: widget.widgetHeight * 0.2,
                child: Center(
                  child: Text(
                    widget.knobTitle,
                    style: TextStyle(
                      fontSize: dentRadius * 0.2,
                      fontFamily: 'Questrial',
                    ),
                  ),
                ))
          ],
        ));
  }

  void rotateBy(double angleInRadians) {
    setState(() {
      _totalTurns += angleInRadians / (2 * pi);
      _accumulatedAngle += angleInRadians;
      final oldPointer = _pointer;
      if (widget.itemsLength > 0) {
        rotateWithItems(oldPointer);
      } else {
        rotateWithoutItems(oldPointer);
      }
    });
  }

  void rotateWithItems(int oldPointer) {
    while (_accumulatedAngle.abs() >= itemAngle) {
      widget.vibrate(duration: 50, amplitude: 168, isMajor: true);

      if (_accumulatedAngle > 0) {
        _pointer = (_pointer - 1 + widget.itemsLength) % widget.itemsLength;
        _accumulatedAngle -= itemAngle;
      } else {
        _pointer = (_pointer + 1) % widget.itemsLength;
        _accumulatedAngle += itemAngle;
      }

      widget.onItemSelected(oldPointer, _pointer);
    }
  }

  void rotateWithoutItems(int oldPointer) {
    while (_accumulatedAngle.abs() >= rotationWithoutItemsThreshold) {
      widget.vibrate(duration: 50, amplitude: 168, isMajor: true);

      if (_accumulatedAngle > 0) {
        _accumulatedAngle -= rotationWithoutItemsThreshold;
      } else {
        _accumulatedAngle += rotationWithoutItemsThreshold;
      }

      // 無 items，只判斷方向傳給 callback（可用 +1 表右轉，-1 表左轉）
      final int direction = _accumulatedAngle > 0 ? -1 : 1;
      _accumulatedAngle += direction * rotationWithoutItemsThreshold; // 調整累積角度
      widget.onItemSelected(-direction, -direction);
    }
  }

  double calculateSensitivity(int itemLength) {
    if (itemLength == 0) {
      return pi / 3; // 預設為最小值 60 度
    }

    final anglePerItem = pi / itemLength;
    const minAngle = pi / 3; // 60 度
    const maxAngle = pi / 2; // 90 度

    if (anglePerItem > maxAngle) {
      return maxAngle;
    } else if (anglePerItem < minAngle) {
      return minAngle;
    } else {
      return anglePerItem;
    }
  }

  Widget buildCircularDashes(
      {required double radius,
      required int dashCount,
      required double dashLength,
      required double dashThickness,
      required Color color}) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        children: List.generate(dashCount, (i) {
          final angle = (2 * pi * i) / dashCount;

          return Align(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: angle,
              child: Align(
                alignment: Alignment.topCenter,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: 10, // 凸起
                    intensity: 1,
                    lightSource: LightSource.topLeft,
                    color: color,
                  ),
                  child: SizedBox(
                    width: dashThickness,
                    height: dashLength,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHole(Offset offset, double radius, Color holeColor) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: offset,
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            boxShape: const NeumorphicBoxShape.circle(),
            depth: -0.8,
            intensity: 1,
            lightSource: LightSource.topLeft,
            color: holeColor,
          ),
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
          ),
        ),
      ),
    );
  }

  Widget jaggedSpinner({required double radius, required Color color}) {
    double smallRadius = radius * 0.1;
    double innerRadius = radius * 0.96;

    return Center(
        child: Stack(
      alignment: Alignment.center,
      children: [
        JaggedCircle(
          radius: radius,
          innerRadius: innerRadius,
          color: color,
          toothCount: toothCount, // 越多鋸齒越細
        ),
        if (widget.dashCount != 0)
          Neumorphic(
            style: const NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 0.6,
                intensity: 0.8,
                lightSource: LightSource.topLeft,
                // color: const Color(0xFF444444).withOpacity(0.9), // 深灰背景
                color: config.mainBackGroundWhite),
            child: SizedBox(
              width: innerRadius * 0.96 * 2,
              height: innerRadius * 0.96 * 2,
              child: Stack(
                children: [
                  _buildHole(Offset(0, -radius * 0.6), smallRadius,
                      config.mainBackGroundWhite),
                  _buildHole(Offset(-radius * 0.5, radius * 0.4), smallRadius,
                      config.mainBackGroundWhite),
                  _buildHole(Offset(radius * 0.5, radius * 0.4), smallRadius,
                      config.mainBackGroundWhite),
                ],
              ),
            ),
          ),
        if (widget.dashCount == 0)
          Neumorphic(
            style: const NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 0.6,
              intensity: 0.8,
              lightSource: LightSource.topLeft,
              color: config.mainBackGroundWhite,
            ),
            child: Container(
              // color: Colors.red,
              width: innerRadius * 0.96 * 2,
              height: innerRadius * 0.96 * 2,
              child: Stack(
                children: [
                  // _buildHole(const Offset(0, 0), smallRadius,
                  //     config.mainBackGroundWhite),
                  SizedBox(
                    width: innerRadius * 0.96 * 2,
                    height: innerRadius * 0.96 * 2,
                    child: CustomPaint(
                      painter: _HorizontalLinePainter(
                        start: innerRadius * 0.96 + innerRadius * 0.5,
                        end: innerRadius * 0.96 * 2 - innerRadius * 0.1,
                        lineColor: config.timelinePointerRed,
                        strokeWidth: radius * 0.068,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    ));
  }
}

class _HorizontalLinePainter extends CustomPainter {
  final double end;
  final double start;
  final Color lineColor;
  final double strokeWidth;

  _HorizontalLinePainter({
    required this.start,
    required this.end,
    required this.lineColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(start, size.height / 2);
    final end = Offset(this.end, center.dy);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
