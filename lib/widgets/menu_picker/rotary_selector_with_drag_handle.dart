import 'dart:async';
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/common/utils/rotation_utils.dart';
import 'package:vibration/vibration.dart';

import 'rotary_selector_ring.dart';

class RotarySelectorWithDragHandle extends StatefulWidget {
  final double itemRadius;
  final double dentRadius;
  final double dashWidth;
  final int itemLength;
  final int initialPointer;
  final Function(int oldIndex, int newIndex) onItemSelected;
  final Color rimColor;
  final Color dashColor;
  final LightSource lightSource;

  final Offset initialDragObjPosition;
  final double centerX;
  final double centerY;
  final double radiusOfDragObj;
  final double distanceFromDragObjCenterToScreenCenter;
  final Color dragHandleColor;

  const RotarySelectorWithDragHandle({
    super.key,
    required this.itemRadius,
    required this.dentRadius,
    required this.dashWidth,
    required this.itemLength,
    required this.initialPointer,
    required this.onItemSelected,
    required this.rimColor,
    required this.dashColor,
    required this.lightSource,
    required this.initialDragObjPosition,
    required this.centerX,
    required this.centerY,
    required this.radiusOfDragObj,
    required this.distanceFromDragObjCenterToScreenCenter,
    required this.dragHandleColor,
  });

  @override
  State<RotarySelectorWithDragHandle> createState() =>
      _RotarySelectorWithDragHandleState();
}

class _RotarySelectorWithDragHandleState
    extends State<RotarySelectorWithDragHandle> {
  final GlobalKey<RotarySelectorRingState> ringKey = GlobalKey();

  late double sensitivity;

  double? _lastAngle;

  double menuTurns = 0;
  late Offset dragMenuPosition;

  double calculateSensitivity(int itemLength) {
    if (itemLength == 0) {
      return pi / 10;
    }

    final anglePerItem = pi / itemLength;
    const minAngle = pi / 10; // 18 度
    const maxAngle = pi / 3; // 60 度

    if (anglePerItem > maxAngle) {
      return maxAngle;
    } else if (anglePerItem < minAngle) {
      return minAngle;
    } else {
      return anglePerItem;
    }
  }

  @override
  void initState() {
    super.initState();
    sensitivity = calculateSensitivity(widget.itemLength);
    dragMenuPosition = widget.initialDragObjPosition;
  }

  void rotateMenuPanel(double angleInRadian) {
    setMenuTurns(angleInRadian / (2 * pi));
  }

  void setMenuTurns(double turns) {
    setState(() {
      menuTurns = turns;
    });
  }

  bool isVibrating = false;
  Timer? vibrationTimer;

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

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedRotation(
        turns: menuTurns,
        duration: const Duration(milliseconds: 200),
        child: RotarySelectorRing(
          key: ringKey,
          outerRadius: widget.itemRadius,
          innerRadius: widget.dentRadius,
          dashWidth: widget.dashWidth,
          itemLength: widget.itemLength,
          onItemSelected: widget.onItemSelected,
          initialPointer: widget.initialPointer,
          rimColor: widget.rimColor,
          dashColor: widget.dashColor,
          lightSource: widget.lightSource,
          sensitivity: sensitivity,
          vibrate: vibrate,
        ),
      ),

      // drag widget
      if (widget.dragHandleColor != Colors.transparent)
        Positioned(
          left: dragMenuPosition.dx,
          top: dragMenuPosition.dy,
          child: SizedBox(
            width: widget.radiusOfDragObj * 2,
            height: widget.radiusOfDragObj * 2,
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
                      color: widget.dragHandleColor,
                      width: widget.radiusOfDragObj * 2,
                      height: widget.radiusOfDragObj * 2,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final newFingerPosition =
                          dragMenuPosition + details.delta;

                      final centerOfRime = Offset(
                        widget.centerX - widget.radiusOfDragObj,
                        widget.centerY - widget.radiusOfDragObj,
                      );

                      final currentAngle =
                          (newFingerPosition - centerOfRime).direction;

                      if (_lastAngle != null) {
                        final delta = RotationUtils.normalizeAngle(
                            currentAngle - _lastAngle!);
                        ringKey.currentState
                            ?.rotateBy(delta); // 將 delta 傳給 RotarySelectorRing
                      }

                      _lastAngle = currentAngle;

                      // 震動判斷
                      if ((currentAngle * 180 / pi).ceil() % sensitivity == 0) {
                        // Vibration.vibrate(duration: 50, amplitude: 255);
                        vibrate(duration: 50, amplitude: 255, isMajor: true);
                      }

                      // 控制器位置計算
                      final dragPositionCenter = Offset(
                        widget.centerX +
                            (widget.distanceFromDragObjCenterToScreenCenter *
                                cos(currentAngle)),
                        widget.centerY +
                            widget.distanceFromDragObjCenterToScreenCenter *
                                sin(currentAngle),
                      );

                      setState(() {
                        dragMenuPosition = RotationUtils.centerToTopLeft(
                            dragPositionCenter, widget.radiusOfDragObj);
                      });
                    },
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: const NeumorphicBoxShape.circle(),
                        intensity: 0.9,
                        depth: 1.5,
                        lightSource: widget.lightSource,
                      ),
                      child: Container(
                        color: widget.dragHandleColor,
                        width: widget.radiusOfDragObj * 0.9 * 2,
                        height: widget.radiusOfDragObj * 0.9 * 2,
                        child: const Center(
                          child: Icon(Icons.fingerprint),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    ]);
  }
}
