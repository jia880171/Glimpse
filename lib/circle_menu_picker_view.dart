import 'dart:async';
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:vibration/vibration.dart';

import './config.dart' as config;
import 'AnimatedNeumorphicText.dart';
import 'circle_date_picker_view.dart';

class CircleMenuPickerView extends StatefulWidget {
  final List<String> items;
  final Function onItemSelected;
  final double radius;
  final List<String> menuItemsPath;

  const CircleMenuPickerView(
      {Key? key,
      required this.onItemSelected,
      required this.items,
      required this.radius,
      required this.menuItemsPath,
      l})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CircleMenuPickerViewState();
}

class CircleMenuPickerViewState extends State<CircleMenuPickerView> {
  final double _depthMax = 0.5;
  final double _depthMin = 0.0;
  final double _depthNormal = 0.3;

  late final double radius = widget.radius;
  late final double radiusItem = widget.radius * 0.95;
  late final double rimRadius = widget.radius * 0.6;
  late final double dentRadius = widget.radius * 0.56;
  late final double dashWidth = widget.radius * 0.2;

  final Duration depthOutDuration = Duration(milliseconds: 500);
  final Duration depthInDuration = Duration(milliseconds: 500);

  Timer? _timer;

  late List<double> depths =
      List<double>.filled(widget.items.length, _depthMin);
  late List<double> prevDepths =
      List<double>.filled(widget.items.length, _depthMin);

  int _pointer = 0; // 當前指到哪個 item
  double _accumulatedAngle = 0; // 累積旋轉角度
  double _totalTurns = 0;
  double? _lastAngle;
  late Offset _center;
  final GlobalKey _key = GlobalKey();

  final LightSource neumorphicLightSource = LightSource.topRight;

  @override
  void initState() {
    super.initState();
    depths[_pointer] = _depthMax;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: Stack(
          children: [
            // panel
            Neumorphic(
                style: NeumorphicStyle(
                    lightSource: neumorphicLightSource,
                    shape: NeumorphicShape.convex,
                    boxShape: const NeumorphicBoxShape.circle(),
                    intensity: 0.8,
                    depth: 0.8),
                child: Container(
                  color: config.backGroundWhite,
                  width: radius * 2,
                  height: radius * 2,
                )),

            // items
            Center(
              child: Neumorphic(
                  style: NeumorphicStyle(
                      lightSource: neumorphicLightSource,
                      shape: NeumorphicShape.convex,
                      boxShape: const NeumorphicBoxShape.circle(),
                      intensity: 0.6,
                      depth: -0.6),
                  child: Container(
                    color: config.backGroundWhite,
                    width: radiusItem * 2,
                    height: radiusItem * 2,
                  )),
            ),

            //  items' GestureDetector
            GestureDetector(
              onPanStart: (details) {
                final box =
                    _key.currentContext!.findRenderObject() as RenderBox;

                _center = box.size.center(Offset.zero);

                final localPos = box.globalToLocal(details.globalPosition);

                _lastAngle = _getAngleFromOffset(_center, localPos);
              },
              onPanUpdate: (details) {
                final box =
                    _key.currentContext!.findRenderObject() as RenderBox;
                final localPos = box.globalToLocal(details.globalPosition);
                final currentAngle = _getAngleFromOffset(_center, localPos);

                if (_lastAngle != null) {
                  final delta = _normalizeAngle(currentAngle - _lastAngle!);
                  setState(() {
                    _totalTurns += delta / (2 * pi); // convert radians to turns
                    _accumulatedAngle += delta;

                    const sensitivity = 0.9; // 0.5 表示只要轉動一半的角度就觸發（越小越敏感）
                    final itemAngle = (pi / widget.items.length) * sensitivity;

                    final int oldPointer = _pointer;

                    // 根據累積角度來調整 pointer
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

                      // 呼叫 callback，通知外部選到了什麼
                      widget.onItemSelected(_pointer);
                      print('selected item: ${widget.items[_pointer]}');

                      onItemSelected(oldPointer);
                    }
                  });
                }

                _lastAngle = currentAngle;
              },
              onPanEnd: (_) {
                _lastAngle = null;
                _accumulatedAngle = 0; // 清除暫存角度
              },
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  key: _key,
                  height: radius * 2,
                  width: radius * 2,
                  child: Stack(
                    children: [
                      AnimatedRotation(
                          turns: _totalTurns,
                          duration: const Duration(milliseconds: 200),
                          child: Stack(
                            children: [
                              Container(
                                color: config.backGroundWhite.withOpacity(0),
                                width: radiusItem * 2,
                                height: radiusItem * 2,
                              ),
                              IgnorePointer(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: CustomPaint(
                                    size: Size(dentRadius * 2, dentRadius * 2),
                                    // Adjust the size as needed
                                    painter: DashedCirclePainter(
                                        dx: dentRadius,
                                        dy: dentRadius,
                                        radius: radiusItem,
                                        margin: dentRadius * 0.1,
                                        dashCount: 31,
                                        dashWidth: dashWidth,
                                        strokeWidth: dashWidth * 0.035,
                                        strockColor: config.backGroundWhiteDark,
                                        isMonth: false),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // rim
            Align(
              alignment: Alignment.center,
              child: Neumorphic(
                  style: NeumorphicStyle(
                    lightSource: neumorphicLightSource,
                    shape: NeumorphicShape.convex,
                    boxShape: const NeumorphicBoxShape.circle(),
                    intensity: 1,
                    depth: 0.8,
                  ),
                  child: Container(
                    color: config.backGroundWhite,
                    width: (rimRadius * 2),
                    height: (rimRadius * 2),
                  )),
            ),

            //dent
            Align(
              alignment: Alignment.center,
              child: Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: const NeumorphicBoxShape.circle(),
                    intensity: 0.6,
                    lightSource: neumorphicLightSource,
                    color: config.backGroundWhite,
                    depth: -0.8,
                  ),
                  child: Container(
                      color: config.backGroundWhite,
                      width: (dentRadius * 2),
                      height: (dentRadius * 2),
                      child: Stack(
                          children: List.generate(
                        6,
                        (i) {
                          return Center(
                            child: AnimatedNeumorphicText(
                              text: '${widget.items[i]}',
                              prevDepth: prevDepths[i],
                              depth: depths[i],
                              onTap: () {
                                Navigator.pushNamed(context, widget.menuItemsPath[i]);
                              },
                              fontSize: dentRadius * 0.23,
                              color: config.backGroundWhite,
                              depthInDuration: depthInDuration,
                              depthOutDuration: depthOutDuration,
                            ),
                          );
                        },
                      ))

                      )),
            ),
          ],
        ));
  }

  void onItemSelected(int oldIndex) {
    print('====== oldIndex: ${oldIndex}');
    print('====== newIndex: ${_pointer}');

    if (oldIndex == _pointer) return;

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
        depths[_pointer] = _depthMax;
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
