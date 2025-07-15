import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:glimpse/config.dart' as config;
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/widgets/rotatable_card/left_rotatable_Glimpse_card.dart';
import 'package:isar/isar.dart';

import '../rotatable_card/rotatable_Glimpse_card_view.dart';

class GlimpseBookView extends StatefulWidget {
  final Size widgetSize;

  const GlimpseBookView({super.key, required this.widgetSize});

  @override
  State<GlimpseBookView> createState() => _GlimpseBookViewState();
}

class _GlimpseBookViewState extends State<GlimpseBookView> {
  List<Glimpse> glimpses = [];
  List<Uint8List?> imageBytes = [];
  bool loading = true;
  int currentIndex = 0;
  double rotationY = 0;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      rotationY -= details.delta.dx * 0.03;
    });
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    print('======onHorizontalDragEnd');
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() > 300) {
      final isNext = velocity < 0;
      setState(() {
        if (isNext && currentIndex < glimpses.length - 1) {
          currentIndex++;
          print('=====currentIndex aftet ++: ${currentIndex}');
        } else if (!isNext && currentIndex > 0) {
          currentIndex--;
          print('=====currentIndex aftet --: ${currentIndex}');
        }
        rotationY = 0;
      });
    } else {
      setState(() {
        rotationY = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('====== building book');
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        onHorizontalDragEnd: onHorizontalDragEnd,
        child: SizedBox(
          width: widget.widgetSize.width,
          height: widget.widgetSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(glimpses.length, (index) {
              final g = glimpses[index];
              final img = imageBytes[index];
              if (img == null) return const SizedBox.shrink();

              final isCurrent = index == currentIndex;

              return LeftRotatableGlimpseCard(
                index: index,
                image: img,
                exifData: {},
                imagePath: g.photoPath,
                backLight: config.backLightB,
                isNeg: false,
                cardSize: Size(
                  widget.widgetSize.width * 0.6,
                  widget.widgetSize.height * 0.6,
                ),
                leaveCardMode: leaveCardMode,
                rotationAlignment: Alignment.centerLeft,
                widgetSize: widget.widgetSize,
                rotationOverride:
                    isCurrent ? rotationY : (index < currentIndex ? pi : 0),
                interactive: true,
              );
            }),
          ),
        ),
      ),
    );
  }
}
