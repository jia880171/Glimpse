import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:glimpse/config.dart' as config;
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/widgets/rotatable_card/left_rotatable_Glimpse_card.dart';
import 'package:isar/isar.dart';

class GlimpseBookView extends StatefulWidget {
  final Size widgetSize;

  const GlimpseBookView({super.key, required this.widgetSize});

  @override
  State<GlimpseBookView> createState() => _GlimpseBookViewState();
}

class _GlimpseBookViewState extends State<GlimpseBookView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animRotation;
  List<Glimpse> glimpses = [];
  List<Uint8List?> imageBytes = [];
  bool loading = true;
  int currentIndex = 0;
  double? rotationY; // allow null when not dragging/animating
  double dragAccumulated = 0;
  bool isAnimating = false;
  bool isDraggingToRight = true; // true = 右滑, false = 左滑

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animController.addListener(() {
      if (!isAnimating) return;
      setState(() {
        rotationY = _animRotation.value;
      });
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final finalAngle = _animRotation.value;

        bool pageFlipped = false;
        int? newIndex;

        if (finalAngle.abs() > pi * 0.9) {
          if (finalAngle > 0 && currentIndex <= glimpses.length - 1) {
            newIndex = currentIndex + 1;
            pageFlipped = true;
          } else if (finalAngle < 0 && currentIndex > 0) {
            newIndex = currentIndex - 1;
            pageFlipped = true;
          }
        }

        if (pageFlipped && newIndex != null) { //翻成功
          final keepRotation = _animRotation.value;

          // ✅ 第一次 setState：暫時保留 rotationY、不變更 index
          setState(() {
            dragAccumulated = 0;
            isAnimating = false;
            rotationY = keepRotation;
            _animController.reset();
          });

          // ✅ 下一幀才更新 currentIndex 並清除 rotationY，避免新卡片受到干擾
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              if(currentIndex != newIndex){
                print('====== currentIndex(${currentIndex}) != newIndex(${newIndex}) ');
                rotationY = null;
                currentIndex = newIndex!;
              }

            });
          });
        } else { //翻失敗（沒過半又彈回０）
          print('======翻失敗, pageFlipped: ${pageFlipped}, newIndex: ${newIndex}');
          setState(() {
            rotationY = null;
            dragAccumulated = 0;
            isAnimating = false;
            _animController.reset();
          });
        }


      }
    });

    loadGlimpses();
  }

  Future<void> loadGlimpses() async {
    final isar = DatabaseService.isar;
    final loaded = await isar.glimpses.where().sortByCreatedAtDesc().findAll();

    final byteList = await Future.wait(loaded.map((g) async {
      try {
        final file = File(g.photoPath);
        return await file.exists() ? await file.readAsBytes() : null;
      } catch (_) {
        return null;
      }
    }));

    setState(() {
      glimpses = loaded;
      imageBytes = byteList;
      loading = false;
    });
  }

  void leaveCardMode() => Navigator.of(context).pop();

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (isAnimating) return;

    // ✅ 記錄滑動方向
    final deltaX = details.delta.dx;
    if (deltaX.abs() > 0.01) {
      isDraggingToRight = deltaX > 0;
    }

    setState(() {
      dragAccumulated += details.delta.dx;
      rotationY = -dragAccumulated * 0.01;
    });
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (isAnimating) return;
    isAnimating = true;
    final currentRotation = rotationY ?? 0.0;
    final shouldFlip = currentRotation.abs() > pi / 2;
    double targetAngle = 0;

    if (shouldFlip) {
      targetAngle = currentRotation > 0 ? pi : 0;
    } else {
      targetAngle = currentRotation > 0 ? 0 : -pi;
    }

    _animRotation = Tween<double>(
      begin: currentRotation,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Text('rotationY: ' +(rotationY ?? 0).toString()),
              Text('currentIndex: ' + (currentIndex).toString()),
              Text('newIndex: ' +(currentIndex).toString()),
              Text('isDraggingToRight: ' + (isDraggingToRight? 'true': 'false')),
            ],
          ),
          GestureDetector(
            onHorizontalDragUpdate: onHorizontalDragUpdate,
            onHorizontalDragEnd: onHorizontalDragEnd,
            child: SizedBox(
              width: widget.widgetSize.width,
              height: widget.widgetSize.height,
              child: Stack(
                alignment: Alignment.center,
                children: () {
                  final cardWidgets = <Widget>[];

                  for (int index = 0; index < glimpses.length; index++) {
                    final g = glimpses[index];
                    final img = imageBytes[index];
                    if (img == null) continue;

                    final isCurrent = index == currentIndex;
                    final isPrevious = index == currentIndex - 1;

                    final card = LeftRotatableGlimpseCard(
                      key: ValueKey('card-${g.photoPath}'),
                      index: index,
                      image: img,
                      exifData: {},
                      imagePath: g.photoPath,
                      backLight: config.backLightB,
                      isNeg: false,
                      cardSize: Size(
                        widget.widgetSize.width * 0.5,
                        widget.widgetSize.height * 0.6,
                      ),
                      leaveCardMode: leaveCardMode,
                      rotationAlignment: Alignment.centerLeft,
                      widgetSize: widget.widgetSize,
                      rotationOverride: () {
                        if (isCurrent) return (rotationY ?? 0).toDouble();
                        if (isPrevious) return pi;
                        return 0.0;
                      }(),
                      interactive: isCurrent || isPrevious,
                    );

                    if (isPrevious) {
                      cardWidgets.add(card); // 左側的上一張
                    } else if (index > currentIndex) {
                      cardWidgets.insert(0, card); // 僅插入未來要顯示的卡片
                    }
                  }


                  // 確保 currentIndex 的卡片在最上層
                  if (currentIndex >= 0 && currentIndex < glimpses.length) {
                    final g = glimpses[currentIndex];
                    final img = imageBytes[currentIndex];
                    if (img != null) {
                      cardWidgets.add(LeftRotatableGlimpseCard(
                        key: ValueKey('card-${g.photoPath}'),
                        index: currentIndex,
                        image: img,
                        exifData: {},
                        imagePath: g.photoPath,
                        backLight: config.backLightB,
                        isNeg: false,
                        cardSize: Size(
                          widget.widgetSize.width * 0.5,
                          widget.widgetSize.height * 0.6,
                        ),
                        leaveCardMode: leaveCardMode,
                        rotationAlignment: Alignment.centerLeft,
                        widgetSize: widget.widgetSize,
                        rotationOverride: rotationY ?? 0,
                        interactive: true,
                      ));
                    }
                  }

                  return cardWidgets;
                }(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
