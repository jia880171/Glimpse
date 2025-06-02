import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:vibration/vibration.dart';

import 'circle_date_picker_view.dart';
import 'common/utils/rotation_utils.dart';

class RotarySelectorRing extends StatefulWidget {
  final double outerRadius;
  final double innerRadius;
  final double dashWidth;
  final int itemLength;
  final Function(int oldIndex, int newIndex) onItemSelected;
  final int initialPointer;
  final Color rimColor;
  final Color dashColor;
  final LightSource lightSource;
  final double sensitivity;

  const RotarySelectorRing({
    super.key,
    required this.outerRadius,
    required this.innerRadius,
    required this.dashWidth,
    required this.itemLength,
    required this.onItemSelected,
    this.initialPointer = 0,
    this.rimColor = Colors.white,
    this.dashColor = Colors.grey,
    this.lightSource = LightSource.topLeft,
    required this.sensitivity,
  });

  @override
  State<RotarySelectorRing> createState() => RotarySelectorRingState();
}

class RotarySelectorRingState extends State<RotarySelectorRing> {
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

  // ✅ 給外部使用的公開旋轉方法
  void rotateBy(double angleInRadians) {
    if (widget.itemLength == 0) {
      return;
    }

    final itemAngle = widget.sensitivity;
    setState(() {
      _totalTurns += angleInRadians / (2 * pi);
      _accumulatedAngle += angleInRadians;
      final oldPointer = _pointer;

      while (_accumulatedAngle.abs() >= itemAngle) {
        Vibration.vibrate(duration: 50, amplitude: 255);

        if (_accumulatedAngle > 0) {
          _pointer = (_pointer + 1) % widget.itemLength;
          _accumulatedAngle -= itemAngle;
        } else {
          _pointer = (_pointer - 1 + widget.itemLength) % widget.itemLength;
          _accumulatedAngle += itemAngle;
        }

        widget.onItemSelected(oldPointer, _pointer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final radiusItem = widget.itemRadius;

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
              width: widget.outerRadius * 2,
              height: widget.outerRadius * 2,
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
              _lastAngle = RotationUtils.getAngleFromOffset(_center, localPos);
            },
            onPanUpdate: (details) {
              final box = _key.currentContext!.findRenderObject() as RenderBox;
              final localPos = box.globalToLocal(details.globalPosition);
              final currentAngle =
                  RotationUtils.getAngleFromOffset(_center, localPos);

              if (_lastAngle != null) {
                final delta =
                    RotationUtils.normalizeAngle(currentAngle - _lastAngle!);
                rotateBy(delta);
              }

              _lastAngle = currentAngle;
            },
            onPanEnd: (_) {
              _lastAngle = null;
              _accumulatedAngle = 0;
            },
            child: SizedBox(
              key: _key,
              width: widget.outerRadius * 2,
              height: widget.outerRadius * 2,
              child: AnimatedRotation(
                turns: _totalTurns,
                duration: const Duration(milliseconds: 200),
                child: Stack(
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
                          width: widget.outerRadius * 2,
                          height: widget.outerRadius * 2,
                          color: widget.rimColor,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Align(
                        alignment: Alignment.center,
                        child: CustomPaint(
                          size: Size(
                              widget.innerRadius * 2, widget.innerRadius * 2),
                          painter: DashedCirclePainter(
                            dx: widget.innerRadius,
                            dy: widget.innerRadius,
                            radius: widget.outerRadius,
                            margin: widget.outerRadius * 0.05,
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
        )
      ],
    );
  }
}

// import 'dart:math';
//
// import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
// import 'package:vibration/vibration.dart';
//
// import 'circle_date_picker_view.dart';
//
// class RotarySelectorRing extends StatefulWidget {
//   final double itemRadius;
//   final double dentRadius;
//   final double dashWidth;
//   final int itemLength;
//   final Function onItemSelected;
//   final int initialPointer;
//   final Color rimColor;
//   final Color dashColor;
//   final LightSource lightSource;
//   final double sensitivity;
//
//   const RotarySelectorRing({
//     super.key,
//     required this.itemRadius,
//     required this.dentRadius,
//     required this.dashWidth,
//     required this.itemLength,
//     required this.onItemSelected,
//     this.initialPointer = 0,
//     this.rimColor = Colors.white,
//     this.dashColor = Colors.grey,
//     this.lightSource = LightSource.topLeft, required this.sensitivity,
//   });
//
//   @override
//   State<RotarySelectorRing> createState() => _RotarySelectorRingState();
// }
//
// class _RotarySelectorRingState extends State<RotarySelectorRing> {
//   final GlobalKey _key = GlobalKey();
//   late Offset _center;
//   double? _lastAngle;
//   double _totalTurns = 0;
//   double _accumulatedAngle = 0;
//   late int _pointer;
//
//   @override
//   void initState() {
//     super.initState();
//     _pointer = widget.initialPointer;
//   }
//
//   double _getAngleFromOffset(Offset center, Offset point) {
//     final dx = point.dx - center.dx;
//     final dy = point.dy - center.dy;
//     return atan2(dy, dx);
//   }
//
//   double _normalizeAngle(double angle) {
//     while (angle > pi) angle -= 2 * pi;
//     while (angle < -pi) angle += 2 * pi;
//     return angle;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double radiusItem = widget.itemRadius;
//
//     return Stack(
//       children: [
//         Center(
//           child: Neumorphic(
//             style: NeumorphicStyle(
//               lightSource: widget.lightSource,
//               shape: NeumorphicShape.convex,
//               boxShape: const NeumorphicBoxShape.circle(),
//               intensity: 1,
//               depth: 1,
//             ),
//             child: Container(
//               width: radiusItem * 2,
//               height: radiusItem * 2,
//               color: widget.rimColor,
//             ),
//           ),
//         ),
//
//         Center(
//           child: GestureDetector(
//             onPanStart: (details) {
//               final box = _key.currentContext!.findRenderObject() as RenderBox;
//               _center = box.size.center(Offset.zero);
//               final localPos = box.globalToLocal(details.globalPosition);
//               _lastAngle = _getAngleFromOffset(_center, localPos);
//             },
//             onPanUpdate: (details) {
//               final box = _key.currentContext!.findRenderObject() as RenderBox;
//               final localPos = box.globalToLocal(details.globalPosition);
//               final currentAngle = _getAngleFromOffset(_center, localPos);
//
//               if (_lastAngle != null) {
//                 final delta = _normalizeAngle(currentAngle - _lastAngle!);
//                 setState(() {
//                   _totalTurns += delta / (2 * pi);
//                   _accumulatedAngle += delta;
//
//                   // const sensitivity = 3;
//                   // final itemAngle = (pi / widget.itemLength) * widget.sensitivity;
//                   final itemAngle = widget.sensitivity;
//
//                   final oldPointer = _pointer;
//
//                   while (_accumulatedAngle.abs() >= itemAngle) {
//                     Vibration.vibrate(duration: 50, amplitude: 255);
//
//                     if (_accumulatedAngle > 0) {
//                       _pointer = (_pointer + 1) % widget.itemLength;
//                       _accumulatedAngle -= itemAngle;
//                     } else {
//                       _pointer = (_pointer - 1 + widget.itemLength) %
//                           widget.itemLength;
//                       _accumulatedAngle += itemAngle;
//                     }
//
//                     widget.onItemSelected(oldPointer, _pointer);
//                   }
//                 });
//               }
//
//               _lastAngle = currentAngle;
//             },
//             onPanEnd: (_) {
//               _lastAngle = null;
//               _accumulatedAngle = 0;
//             },
//
//             child: Align(
//               alignment: Alignment.center,
//               child: SizedBox(
//                 key: _key,
//                 width: radiusItem * 2,
//                 height: radiusItem * 2,
//                 child: AnimatedRotation(
//                   turns: _totalTurns,
//                   duration: const Duration(milliseconds: 200),
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: radiusItem * 2,
//                         height: radiusItem * 2,
//                         color: Colors.transparent,
//                       ),
//                       IgnorePointer(
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: CustomPaint(
//                             size: Size(
//                                 widget.dentRadius * 2, widget.dentRadius * 2),
//                             painter: DashedCirclePainter(
//                               dx: widget.dentRadius,
//                               dy: widget.dentRadius,
//                               radius: radiusItem,
//                               margin: widget.itemRadius * 0.05,
//                               dashCount: 31,
//                               dashWidth: widget.dashWidth,
//                               strokeWidth: widget.dashWidth * 0.035,
//                               strockColor: widget.dashColor,
//                               isMonth: false,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
