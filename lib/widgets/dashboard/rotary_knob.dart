import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../common/utils/rotation_utils.dart';
import '../../config.dart' as config;
import '../jagged_circle.dart';
import 'circle_ticks_painter.dart';
import 'quarter_arc_painter.dart';

class RotaryKnob extends StatefulWidget {
  final bool isMenu;
  final bool isDrawArc;
  final List<String>? items;
  final String knobTitle;
  final double widgetHeight;
  final double widgetWidth;
  final double dashWidth;
  final GlobalKey knobKey;
  final Color knobColor;
  final Color gapColor;
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
    required this.knobColor,
    required this.gapColor,
    required this.dashColor,
    required this.dashCount,
    required this.itemsLength,
    required this.onItemSelected,
    required this.vibrate,
    required this.widgetHeight,
    required this.knobTitle,
    required this.widgetWidth,
    required this.isDrawArc,
    this.items,
    required this.isMenu,
  });

  @override
  State<RotaryKnob> createState() => _RotaryKnobState();
}

class _RotaryKnobState extends State<RotaryKnob> {
  late int _pointer;
  bool isVibrating = false;
  late double sensitivity;
  late Offset _center;
  double _totalTurns = 0;
  double? _lastAngle;
  double accumulatedDeltaForWeakVibration = 0;
  double _accumulatedAngle = 0;
  final double weakVibrationThreshold = pi / 30;
  final double rotationWithoutItemsThreshold = pi / 8;

  late bool isNoItem = widget.itemsLength == 0;

  late double arcRadius = widget.widgetHeight * 0.34;
  late double dentRadius = widget.widgetHeight * 0.26;
  late double radius = dentRadius * 0.98;
  late double innerRadius = radius * 0.75;
  late double dashWidth = (dentRadius - innerRadius);
  final int toothCount = 66;

  @override
  void initState() {
    super.initState();
    sensitivity = calculateSensitivity(widget.itemsLength);
    _pointer = 0;
  }

  @override
  void didUpdateWidget(RotaryKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemsLength != oldWidget.itemsLength) {
      sensitivity = calculateSensitivity(widget.itemsLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final box =
            widget.knobKey.currentContext!.findRenderObject() as RenderBox;
        _center = box.size.center(Offset.zero);
        final localPos = box.globalToLocal(details.globalPosition);
        _lastAngle = RotationUtils.getAngleFromOffset(_center, localPos);
      },
      onPanUpdate: (details) {
        if (widget.isMenu) {
          onMenuPanUpdate(details);
        } else {
          onNormalPanUpdate(details);
        }
      },
      onPanEnd: (details) {
        if (widget.isMenu) {
          onMenuPanEnd();
        }
      },
      child: Container(
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
                          if (widget.isDrawArc)
                            Center(
                              child: CustomPaint(
                                size: Size(arcRadius * 2, arcRadius * 2),
                                painter: QuarterArcPainter(
                                    radius: arcRadius,
                                    strokeWidth: arcRadius * 0.02,
                                    color: Colors.black.withOpacity(0.2),
                                    startAngleDeg: 20,
                                    sweepAngleDeg: 40),
                              ),
                            ),

                          if (widget.items != null)
                            Center(
                              child: CustomPaint(
                                size: Size(arcRadius * 2, arcRadius * 2),
                                painter: CircleTicksPainter(
                                    items: widget.items!,
                                    arcRadius: dentRadius * 1.1,
                                    labelColor: Colors.black.withOpacity(0.3)),
                              ),
                            ),

                          // Main rotary area
                          Center(
                            child: SizedBox(
                              key: widget.knobKey,
                              child: Neumorphic(
                                style: const NeumorphicStyle(
                                  lightSource: LightSource.topRight,
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape.circle(),
                                  intensity: 0.8,
                                  depth: -0.6,
                                ),
                                child: Container(
                                  width: radius * 2,
                                  height: radius * 2,
                                  color: widget.knobColor,
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
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // title
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
          )),
    );
  }

  void onMenuPanUpdate(DragUpdateDetails details) {
    final box = widget.knobKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    final currentAngle = RotationUtils.getAngleFromOffset(_center, localPos);

    if (_lastAngle != null && widget.items != null) {
      final delta = RotationUtils.normalizeAngle(currentAngle - _lastAngle!);
      vibrateForMenu(delta);

      setState(() {
        _totalTurns += delta / (2 * math.pi); // 自行累積旋轉量
      });
    }

    _lastAngle = currentAngle;
  }

  void vibrateForMenu(delta) {
    _accumulatedAngle += delta;

    while (_accumulatedAngle.abs() >= sensitivity) {
      widget.vibrate(duration: 50, amplitude: 168, isMajor: true);
      if (_accumulatedAngle > 0) {
        _accumulatedAngle -= sensitivity;
      } else {
        _accumulatedAngle += sensitivity;
      }
    }
  }

  void onMenuPanEnd() {
    // 角度轉為項目 index
    final anglePerItem = 2 * math.pi / widget.items!.length;
    final currentTotalAngle = (_totalTurns * 2 * math.pi);
    int nearestIndex =
        (currentTotalAngle / anglePerItem).round() % widget.items!.length;

    print('======nearestIndex: ${nearestIndex}, _pointer: ${_pointer}');

    final oldPointer = _pointer;
    final oldTurns = _totalTurns;
    final targetTurns = nearestIndex / widget.items!.length;

    // 要在onpanupdate記錄一個假的targetTurn這樣在連續轉動時 才不會有問題

    // 找出最短距離
    double diff = targetTurns - oldTurns;

    // 調整 diff 進入 [-0.5, 0.5] 區間，表示最短旋轉路徑
    if (diff > 0.5) {
      diff -= 1;
    } else if (diff < -0.5) {
      diff += 1;
    }

    setState(() {
      _pointer = nearestIndex;
      _totalTurns = oldTurns + diff; // 用最短距離達成目標
      print('====== _totalTurns: ${_totalTurns}');
    });

    widget.vibrate(duration: 50, amplitude: 128, isMajor: true);
    widget.onItemSelected(oldPointer, _pointer);
  }

  void onNormalPanUpdate(DragUpdateDetails details) {
    final box = widget.knobKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    final currentAngle = RotationUtils.getAngleFromOffset(_center, localPos);

    if (_lastAngle != null) {
      final delta = RotationUtils.normalizeAngle(currentAngle - _lastAngle!);
      rotateBy(delta);

      accumulatedDeltaForWeakVibration += delta.abs();
      if (accumulatedDeltaForWeakVibration >= weakVibrationThreshold &&
          widget.itemsLength != 0) {
        widget.vibrate(duration: 30, amplitude: 66, isMajor: false);
        accumulatedDeltaForWeakVibration = 0.0;
      }
    }
    _lastAngle = currentAngle;
  }

  void rotateBy(double angleInRadians) {
    setState(() {
      _totalTurns += angleInRadians / (2 * pi);
      _accumulatedAngle += angleInRadians;
      final oldPointer = _pointer;
      if (widget.itemsLength > 0) {
        // for date
        rotateWithItems(oldPointer);
      } else {
        // for film scroll
        rotateWithoutItems(oldPointer);
      }
    });
  }

  void rotateWithItems(int oldPointer) {
    while (_accumulatedAngle.abs() >= sensitivity) {
      widget.vibrate(duration: 50, amplitude: 168, isMajor: true);

      if (_accumulatedAngle > 0) {
        _pointer = (_pointer - 1 + widget.itemsLength) % widget.itemsLength;
        _accumulatedAngle -= sensitivity;
      } else {
        _pointer = (_pointer + 1) % widget.itemsLength;
        _accumulatedAngle += sensitivity;
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
    if (widget.isMenu) {
      return 2 * pi / itemLength;
    }

    const minAngle = pi / 180 * 80; // 80 度
    const maxAngle = pi; // 180 度

    if (itemLength == 0) {
      return pi / 180 * 80; // 預設為最小值 80 度
    }

    final anglePerItem = pi / itemLength;

    double sensitivity;
    if (anglePerItem > maxAngle) {
      sensitivity = maxAngle;
    } else if (anglePerItem < minAngle) {
      sensitivity = minAngle;
    } else {
      sensitivity = anglePerItem;
    }

    return sensitivity;
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
                    depth: 1, // 凸起
                    intensity: 0.6,
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

  Widget jaggedSpinner({
    required double radius,
  }) {
    double smallRadius = radius * 0.1;
    double innerRadius = radius * 0.96;
    double horizontalLineWidth = innerRadius * 0.5;
    double horizontalLineEnd = innerRadius * 0.96 * 2 - innerRadius * 0.1;

    return Center(
        child: Stack(
      alignment: Alignment.center,
      children: [
        JaggedCircle(
          radius: radius,
          innerRadius: innerRadius,
          color: config.knobJagged,
          toothCount: toothCount, // 越多鋸齒越細
        ),

        // for menu
        if (widget.dashCount != 0)
          Neumorphic(
            style: const NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 0.6,
                intensity: 0.8,
                lightSource: LightSource.topLeft,
                color: config.backGroundMainTheme),
            child: SizedBox(
              width: innerRadius * 0.96 * 2,
              height: innerRadius * 0.96 * 2,
              child: Stack(
                children: [
                  _buildHole(Offset(0, -radius * 0.6), smallRadius,
                      config.mainBackGroundWhite),
                  // _buildHole(Offset(-radius * 0.5, radius * 0.4), smallRadius,
                  //     config.mainBackGroundWhite),
                  // _buildHole(Offset(radius * 0.5, radius * 0.4), smallRadius,
                  //     config.mainBackGroundWhite),
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
              color: config.backGroundMainTheme,
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
                        start: horizontalLineEnd - horizontalLineWidth,
                        end: horizontalLineEnd,
                        lineColor: config.knobPointer,
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
