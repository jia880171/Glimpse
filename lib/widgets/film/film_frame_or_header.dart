import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'film_frame_unit_view.dart';
import 'film_roll_view.dart';

class FilmFrameOrHeader extends StatelessWidget {
  final bool noHeader;
  final bool isNeg;
  final bool isContactSheet;
  final dynamic image;
  final int index;
  final int imagesLength;
  final ui.Image? thumbnail;
  final double unitFrameWidth;
  final double unitFrameHeight;
  final double headerHeight;
  final double photoFrameWidth;
  final double photoHeight;
  final double holeHeight;
  final double picRatio;
  final Color filmColor;
  final Color backLight;
  final String filmMaker;
  final String filmDate;
  final Function(AssetEntity image, int index, bool isNeg) onTapPic;

  const FilmFrameOrHeader({
    super.key,
    required this.image,
    required this.index,
    required this.imagesLength,
    required this.thumbnail,
    required this.unitFrameWidth,
    required this.unitFrameHeight,
    required this.headerHeight,
    required this.photoFrameWidth,
    required this.photoHeight,
    required this.picRatio,
    required this.filmColor,
    required this.backLight,
    required this.filmMaker,
    required this.filmDate,
    required this.onTapPic,
    required this.noHeader,
    required this.isNeg,
    required this.isContactSheet, required this.holeHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = index == 0;
    final isLast = index == imagesLength - 1;


    if (isFirst) {
      if (!noHeader) {
        return Stack(
          children: [
            FilmHead(
              unitFrameWidth: unitFrameWidth,
              headerHeight: headerHeight,
              filmColor: filmColor,
              backLight: backLight,
              filmMaker: filmMaker,
              filmDate: filmDate,
              photoFrameWidth: photoFrameWidth,
              holeHeight: holeHeight,
              isNeg: isNeg,
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    } else if (isLast) {
      return const SizedBox();
    } else {
      return Row(
        children: [
          Container(
            width: unitFrameWidth,
            height: unitFrameHeight,
            color: filmColor,
            child: Stack(
              children: [
                FilmFrameUnit(
                  unitFrameWidth: unitFrameWidth,
                  index: index,
                  holeHeight: holeHeight,
                  picRatio: picRatio,
                  thumbnail: thumbnail,
                  image: image,
                  filmColor: filmColor,
                  backLight: backLight,
                  filmMaker: filmMaker,
                  filmDate: filmDate,
                  onTapPic: onTapPic,
                  unitFrameHeight: unitFrameHeight,
                  isNeg: isNeg,
                  isContactSheet: isContactSheet,
                ),
                !isNeg
                    ? Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(11),
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/noise.png',
                          fit: BoxFit.cover,
                          color: Colors.brown.withOpacity(0.3),
                          colorBlendMode: BlendMode.multiply,
                        ),
                      ),
                    ),
                  ),
                )
                    : Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/noise.png',
                        fit: BoxFit.cover,
                        color: Colors.red.withOpacity(0.2),
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}