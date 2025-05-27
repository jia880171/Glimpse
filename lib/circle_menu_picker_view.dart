import 'dart:async';
import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:vibration/vibration.dart';

import './config.dart' as config;
import 'AnimatedNeumorphicText.dart';
import 'RotarySelectorRing.dart';
import 'circle_date_picker_view.dart';

const filmFinderItemName = '+Glimpse';

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

  late final double radiusMax = widget.radius;
  late final double radiusItem = widget.radius * 0.7;
  late final double dentRadius = widget.radius * 0.3;
  late final double dashWidth = widget.radius * 0.15;

  final Duration depthOutDuration = Duration(milliseconds: 600);
  final Duration depthInDuration = Duration(milliseconds: 600);

  Timer? _timer;

  late List<double> depths =
      List<double>.filled(widget.items.length, _depthMin);
  late List<double> prevDepths =
      List<double>.filled(widget.items.length, _depthMin);

  int _menuPointer = 0;
  int _datePointer = 0;
  final LightSource neumorphicLightSource = LightSource.topRight;

  @override
  void initState() {
    super.initState();
    depths[_menuPointer] = _depthMax;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: radiusMax * 2,
        width: radiusMax * 2,
        child: Stack(
          children: [
            // panel or datePicker
            Center(
              child: datePickerOrRim(),
            ),

            // items
            RotarySelectorRing(
              itemRadius: radiusItem,
              dentRadius: dentRadius,
              dashWidth: dashWidth,
              items: widget.items,
              onItemSelected: (int oldIndex, int newIndex) {
                widget.onItemSelected(newIndex);
                itemSwitchAni(oldIndex, newIndex);
                updatePointer(newIndex);
              },
              initialPointer: _menuPointer,
              rimColor: config.menuPickerWhite,
              dashColor: config.backGroundWhiteDark,
              lightSource: neumorphicLightSource,
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
                  print('===== pointer $_menuPointer');

                  // Delay to allow the button dent animation to finish before navigation.
                  Timer(
                      const Duration(milliseconds: 100),
                      () => Navigator.pushNamed(
                          context, widget.menuItemsPath[_menuPointer]));
                },
                child: SizedBox(
                    // color: config.menuPickerWhite,
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
                            color: config.menuPickerWhite,
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

  Widget datePickerOrRim() {
    return widget.items[_menuPointer] == filmFinderItemName
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
              width: radiusItem * 1.05 * 2,
              height: radiusItem * 1.05 * 2,
            ));
  }

  Widget datePicker() {
    return             RotarySelectorRing(
      itemRadius: radiusMax,
      dentRadius: radiusItem,
      dashWidth: dashWidth,
      items: widget.items,
      onItemSelected: (int oldIndex, int newIndex) {
        // widget.onItemSelected(newIndex);
        // itemSwitchAni(oldIndex, newIndex);
        // updatePointer(newIndex);
      },
      initialPointer: _datePointer,
      rimColor: config.menuPickerWhite,
      dashColor: config.backGroundWhiteDark,
      lightSource: neumorphicLightSource,
    );



      Neumorphic(
        style: NeumorphicStyle(
            lightSource: neumorphicLightSource,
            shape: NeumorphicShape.convex,
            boxShape: const NeumorphicBoxShape.circle(),
            intensity: 0.8,
            depth: -1),
        child: Container(
          color: config.menuPickerWhite,
          width: radiusMax * 2,
          height: radiusMax * 2,
        ));
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

  void updatePointer(int newPointer){
    setState(() {
      _menuPointer = newPointer;
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
