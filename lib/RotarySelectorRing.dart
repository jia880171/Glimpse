import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:vibration/vibration.dart';

import 'circle_date_picker_view.dart';

class RotarySelectorRing extends StatefulWidget {
  final double itemRadius;
  final double dentRadius;
  final double dashWidth;
  final List<dynamic> items;
  final Function onItemSelected;
  final int initialPointer;
  final Color rimColor;
  final Color dashColor;
  final LightSource lightSource;

  const RotarySelectorRing({
    super.key,
    required this.itemRadius,
    required this.dentRadius,
    required this.dashWidth,
    required this.items,
    required this.onItemSelected,
    this.initialPointer = 0,
    this.rimColor = Colors.white,
    this.dashColor = Colors.grey,
    this.lightSource = LightSource.topLeft,
  });

  @override
  State<RotarySelectorRing> createState() => _RotarySelectorRingState();
}

class _RotarySelectorRingState extends State<RotarySelectorRing> {
  final GlobalKey _key = GlobalKey();
  late Offset _center;
  double? _lastAngle;
  double _totalTurns = 0;
  double _accumulatedAngle = 0;
  late int _pointer;

  @override
  void initState() {
    super.initState();
    _pointer = widget.initialPointer;
  }

  double _getAngleFromOffset(Offset center, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return atan2(dy, dx);
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }

  @override
  Widget build(BuildContext context) {
    final double radiusItem = widget.itemRadius;

    return Stack(
      children: [
        Center(
          child: Neumorphic(
            style: NeumorphicStyle(
              lightSource: widget.lightSource,
              shape: NeumorphicShape.convex,
              boxShape: const NeumorphicBoxShape.circle(),
              intensity: 1,
              depth: 1,
            ),
            child: Container(
              width: radiusItem * 2,
              height: radiusItem * 2,
              color: widget.rimColor,
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            onPanStart: (details) {
              final box = _key.currentContext!.findRenderObject() as RenderBox;
              _center = box.size.center(Offset.zero);
              final localPos = box.globalToLocal(details.globalPosition);
              _lastAngle = _getAngleFromOffset(_center, localPos);
            },
            onPanUpdate: (details) {
              final box = _key.currentContext!.findRenderObject() as RenderBox;
              final localPos = box.globalToLocal(details.globalPosition);
              final currentAngle = _getAngleFromOffset(_center, localPos);

              if (_lastAngle != null) {
                final delta = _normalizeAngle(currentAngle - _lastAngle!);
                setState(() {
                  _totalTurns += delta / (2 * pi);
                  _accumulatedAngle += delta;

                  const sensitivity = 0.9;
                  final itemAngle = (pi / widget.items.length) * sensitivity;
                  final _oldPointer = _pointer;

                  while (_accumulatedAngle.abs() >= itemAngle) {
                    Vibration.vibrate(duration: 50, amplitude: 255);

                    if (_accumulatedAngle > 0) {
                      _pointer = (_pointer + 1) % widget.items.length;
                      _accumulatedAngle -= itemAngle;
                    } else {
                      _pointer = (_pointer - 1 + widget.items.length) %
                          widget.items.length;
                      _accumulatedAngle += itemAngle;
                    }

                    widget.onItemSelected(_oldPointer, _pointer);
                  }
                });
              }

              _lastAngle = currentAngle;
            },
            onPanEnd: (_) {
              _lastAngle = null;
              _accumulatedAngle = 0;
            },
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                key: _key,
                width: radiusItem * 2,
                height: radiusItem * 2,
                child: AnimatedRotation(
                  turns: _totalTurns,
                  duration: const Duration(milliseconds: 200),
                  child: Stack(
                    children: [
                      Container(
                        width: radiusItem * 2,
                        height: radiusItem * 2,
                        color: Colors.transparent,
                      ),
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.center,
                          child: CustomPaint(
                            size: Size(
                                widget.dentRadius * 2, widget.dentRadius * 2),
                            painter: DashedCirclePainter(
                              dx: widget.dentRadius,
                              dy: widget.dentRadius,
                              radius: radiusItem,
                              margin: widget.itemRadius * 0.05,
                              dashCount: 31,
                              dashWidth: widget.dashWidth,
                              strokeWidth: widget.dashWidth * 0.035,
                              strockColor: widget.dashColor,
                              isMonth: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
