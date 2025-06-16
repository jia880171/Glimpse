import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'film_roll_left.dart';
import 'film_roll_right_view.dart';

class FilmFrameUnit extends StatefulWidget {
  final int index;
  final double unitFrameWidth;
  final double unitFrameHeight;
  final double holeHeight;
  final double picRatio;
  final ui.Image? thumbnail;
  final dynamic image;
  final Color filmColor;
  final bool isNeg;
  final bool isContactSheet;
  final Color backLight;
  final String filmMaker;
  final String filmDate;
  final Function(AssetEntity image, int index, bool isNeg)? onTapPic;

  const FilmFrameUnit({
    super.key,
    required this.index,
    required this.unitFrameHeight,
    required this.unitFrameWidth,
    required this.holeHeight,
    required this.picRatio,
    this.thumbnail,
    required this.image,
    required this.filmColor,
    required this.backLight,
    required this.filmMaker,
    required this.filmDate,
    this.onTapPic,
    required this.isNeg,
    required this.isContactSheet,
  });

  @override
  State<FilmFrameUnit> createState() => _FilmFrameUnitState();
}

class _FilmFrameUnitState extends State<FilmFrameUnit> {
  late int randox;

  @override
  void initState() {
    super.initState();
    randox = math.Random().nextInt(2) - 1; // -1 or 0
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = widget.unitFrameHeight * 0.95;
    final double maxWidth = widget.unitFrameWidth * 0.6;

    final List<String> noise = [
      'assets/images/x.png',
      'assets/images/o0.png',
      'assets/images/o2.png',
      'assets/images/o3.png',
      'assets/images/o4.png',
      'assets/images/o5.png',
    ];

    return ClipRect(
      child: Row(
        children: [
          FilmRowLeftSide(
            index: widget.index,
            height: widget.unitFrameHeight,
            width: widget.unitFrameWidth * 0.2,
            holeHeight: widget.holeHeight,
            backLight: widget.backLight,
          ),
          Stack(
            children: [
              SizedBox(
                width: widget.unitFrameWidth * 0.6,
                height: widget.unitFrameHeight,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.thumbnail != null && widget.onTapPic != null) {
                        await widget.onTapPic!(
                            widget.image, widget.index, widget.isNeg);
                      }
                    },
                    child: SizedBox(
                      height: maxHeight,
                      width: maxWidth,
                      child: (widget.thumbnail != null)
                          ? Builder(builder: (context) {
                              final double imageWidth =
                                  widget.thumbnail!.width.toDouble();
                              final double imageHeight =
                                  widget.thumbnail!.height.toDouble();

                              final double estimatedWidth =
                                  maxHeight * imageWidth / imageHeight;

                              final BoxFit fitMode = estimatedWidth > maxWidth
                                  ? BoxFit.fitWidth
                                  : BoxFit.fitHeight;

                              return FittedBox(
                                fit: fitMode,
                                alignment: Alignment.center,
                                child: RawImage(image: widget.thumbnail),
                              );
                            })
                          : Container(
                              color: Colors.grey[200],
                              height: widget.unitFrameHeight * 0.95,
                              width: widget.unitFrameWidth * 0.6,
                              child: const Center(
                                  child: Icon(Icons.photo, color: Colors.grey)),
                            ),
                    ),
                  ),
                ),
              ),
              // (widget.isContactSheet && randox == -1)
              //     ? Positioned.fill(
              //   child: IgnorePointer(
              //     child: ClipRRect(
              //       child: Opacity(
              //         opacity: 0.9,
              //         child: Image.asset(
              //           noise[math.Random().nextInt(noise.length)],
              //           fit: BoxFit.cover,
              //           color: Colors.red.withOpacity(0.2),
              //           colorBlendMode: BlendMode.multiply,
              //         ),
              //       ),
              //     ),
              //   ),
              // )
              //     : const SizedBox(),
            ],
          ),
          FilmRowRightSide(
            height: widget.unitFrameHeight,
            width: widget.unitFrameWidth * 0.2,
            holeHeight: widget.holeHeight,
            backLight: widget.backLight,
            filmMaker: widget.filmMaker,
            filmDate: widget.filmDate,
          ),
        ],
      ),
    );
  }
}
