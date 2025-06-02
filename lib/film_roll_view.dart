import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/common/utils/image_utils.dart';
import 'package:glimpse/rotatable_Glimpse_card_view.dart';
import 'package:photo_manager/photo_manager.dart';

import './config.dart' as config;
import 'film_frame_unit_view.dart';
import 'film_roll_right_view.dart';

class FilmRollView extends StatefulWidget {
  final Size viewSize;
  final List<AssetEntity> images;
  final Map<String, ui.Image> thumbnailCache;
  final Color backLight;
  final bool noHeader;
  final bool isNeg;
  final bool isContactSheet;

  const FilmRollView(
      {super.key,
      required this.viewSize,
      required this.images,
      required this.thumbnailCache,
      required this.backLight,
      required this.noHeader,
      required this.isNeg,
      required this.isContactSheet});

  @override
  State<StatefulWidget> createState() {
    return _FilmRollViewState();
  }
}

class _FilmRollViewState extends State<FilmRollView> {
  String filmMaker = '';
  String filmDate = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(FilmRollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _initExifData();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('====== [FilmRollView] building');
    return filmRoll();
  }

  void setFilmMaker(String filmMaker) {
    print('====== setting filmMaker, filmMaker: ${filmMaker}');
    setState(() {
      this.filmMaker = filmMaker;
    });
  }

  void setFilmDate(String filmDate) {
    setState(() {
      this.filmDate = filmDate;
    });
  }

  Future<void> _initExifData() async {
    print('====== _initExifData');
    if (widget.images.isEmpty) {
      print('====== _initExifData, empty return');
      return;
    }

    final imageBytes = await ImageUtils.getImageBytes(widget.images[0]);
    final exifData = await readExifFromBytes(imageBytes!);

    print('====== exifData, $exifData');

    setState(() {
      setFilmMaker(exifData?['Image Make']?.printable ?? '未知品牌');
      setFilmDate(exifData?['Image DateTime']?.printable ?? '未知日期');
    });
  }

  Widget filmRoll() {
    Size viewSize = widget.viewSize;
    // double picRatio = 3 / 4;
    double picRatio = 2 / 3;
    // double picRatio = 9 / 16;

    double photoFrameHeight = viewSize.height * 0.35;
    double photoFrameWidth = photoFrameHeight * picRatio;
    // double unitFrameWidth = photoFrameWidth * 1.6;
    double unitFrameWidth = viewSize.width;

    double headerHeight = photoFrameHeight * 1.8;

    return SizedBox(
        // color: Colors.red,
        height: viewSize.height,
        width: viewSize.width,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: SizedBox(
              // color: Colors.transparent,
              // color: Colors.green,
              height: viewSize.height,
              width: viewSize.width,
              child: Center(
                child: (widget.images.isEmpty && !widget.noHeader)
                    ? const Center(child: Text("No images found for this date"))
                    : (widget.images.isEmpty && widget.noHeader)
                        ? const Center(child: Text("."))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: widget.images.length,
                            itemBuilder: (context, index) {
                              final image = widget.images[index];
                              final thumbnail = widget.thumbnailCache[image.id];

                              return Align(
                                // alignment: Alignment.center,
                                child: SizedBox(
                                  // color: widget.backLight,
                                  width: unitFrameWidth,
                                  child: FilmFrameOrHeader(
                                    image: image,
                                    index: index,
                                    imagesLength: widget.images.length,
                                    thumbnail: thumbnail,
                                    unitFrameWidth: unitFrameWidth,
                                    headerHeight: headerHeight,
                                    photoFrameWidth: photoFrameWidth,
                                    photoFrameHeight: photoFrameHeight,
                                    picRatio: picRatio,
                                    filmColor: config.filmColor,
                                    backLight: widget.backLight,
                                    filmMaker: filmMaker,
                                    filmDate: filmDate,
                                    onTapPic: onTapPic,
                                    noHeader: widget.noHeader,
                                    isNeg: widget.isNeg,
                                    isContactSheet: widget.isContactSheet,
                                  ),
                                ),
                              );
                            },
                          ),
              )),
        ));
  }

  void onTapPic(AssetEntity image, int index, bool isNeg) async {
    // final isNeg = config.backLightB == widget.backLight;

    // 取得圖片 bytes
    final imageBytes = await ImageUtils.getImageBytes(image);

    // Get EXIF here. The exif will disappear after applying the neg. effect
    final exifData = await readExifFromBytes(imageBytes!);

    // Get the path of the image
    final file = await image.file;
    final imgPath = file?.path;

    final processedImage =
        widget.isNeg ? ImageUtils.applyNegativeEffect(imageBytes) : imageBytes;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RotatableGlimpseCardView(
          index: index,
          image: processedImage!,
          exifData: exifData!,
          imgPath: imgPath!,
          backLight: widget.backLight,
          isNeg: isNeg,
        ),
      ),
    );
  }
}

class FilmFrameOrHeader extends StatelessWidget {
  final bool noHeader;
  final bool isNeg;
  final bool isContactSheet;
  final dynamic image;
  final int index;
  final int imagesLength;
  final ui.Image? thumbnail;
  final double unitFrameWidth;
  final double headerHeight;
  final double photoFrameWidth;
  final double photoFrameHeight;
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
    required this.headerHeight,
    required this.photoFrameWidth,
    required this.photoFrameHeight,
    required this.picRatio,
    required this.filmColor,
    required this.backLight,
    required this.filmMaker,
    required this.filmDate,
    required this.onTapPic,
    required this.noHeader,
    required this.isNeg,
    required this.isContactSheet,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = index == 0;
    final isLast = index == imagesLength - 1;
    final holeHeight = photoFrameHeight * 0.078;
    final unitFrameHeight = photoFrameHeight * 1.1;

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
      print('====== isLast, do nothing');
      return SizedBox(
          // width: unitFrameWidth,
          // height: unitFrameHeight,
          );
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
                  photoHeight: photoFrameHeight,
                  photoWidth: photoFrameWidth,
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

// class FilmRowRightSide extends StatelessWidget {
//   final double height; // Total height (including spacing) passed as a parameter
//   final double width;
//   final double holeHeight; // The height of each hole
//   final Color backLight;
//   final String filmMaker;
//   final String filmDate;
//
//   const FilmRowRightSide({
//     super.key,
//     required this.height,
//     required this.holeHeight,
//     required this.backLight,
//     required this.width,
//     required this.filmMaker,
//     required this.filmDate,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final gapWidthBetweenHole = holeHeight;
//     // Calculate the number of rectangles that can fit within the total height
//     final numberOfRectangles =
//         (height / (holeHeight + gapWidthBetweenHole)).floor();
//
//     print('====== right, maker: ${filmMaker}');
//     return Container(
//         // color: Colors.green,
//         width: width,
//         height: height,
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topLeft,
//               child: RotatedBox(
//                 quarterTurns: 1, // 90 degrees clockwise
//                 child: Container(
//                     width: height,
//                     height: width * 0.3,
//                     // color: Colors.red,
//                     alignment: Alignment.center,
//                     child: Row(
//                       children: [
//                         const Spacer(),
//                         Text(
//                           filmMaker,
//                           style: TextStyle(
//                               fontSize: width * 0.3 * 0.5,
//                               color: config.dateColor,
//                               fontFamily: 'DS-DIGI'),
//                           overflow: TextOverflow.ellipsis,
//                           softWrap: false,
//                         ),
//                         const Spacer(),
//                         Text(
//                           filmDate.split(' ')[0],
//                           style: TextStyle(
//                               fontSize: width * 0.3 * 0.5,
//                               color: config.dateColor,
//                               fontFamily: 'DS-DIGI'),
//                           overflow: TextOverflow.ellipsis,
//                           softWrap: false,
//                         ),
//                         const Spacer(),
//                       ],
//                     )),
//               ),
//             ),
//             Column(
//               children: List.generate(
//                 numberOfRectangles,
//                 (index) {
//                   return Row(
//                     children: [
//                       SizedBox(
//                         width: width * 0.25,
//                         height: holeHeight,
//                       ),
//                       Container(
//                         width: width * 0.5,
//                         height: holeHeight,
//                         margin: EdgeInsets.only(
//                             top: gapWidthBetweenHole / 2,
//                             bottom: gapWidthBetweenHole / 2),
//                         decoration: BoxDecoration(
//                           color: backLight,
//                           borderRadius: BorderRadius.circular(1),
//                         ),
//                       ),
//                       SizedBox(
//                         width: width * 0.25,
//                         height: holeHeight,
//                       )
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ));
//   }
// }

class FilmRowLeftSide extends StatelessWidget {
  final double height; // Total height (including spacing) passed as a parameter
  final double width;
  final double holeHeight; // The height of each hole
  final Color backLight;
  final int index;

  const FilmRowLeftSide({
    super.key,
    required this.height,
    required this.holeHeight,
    required this.backLight,
    required this.width,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final gapWidthBetweenHole = holeHeight;
    // Calculate the number of rectangles that can fit within the total height
    final numberOfRectangles =
        (height / (holeHeight + gapWidthBetweenHole)).floor();

    return Container(
        // color: Colors.green,
        width: width,
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: RotatedBox(
                quarterTurns: 1, // 90 degrees clockwise
                child: Container(
                  width: height,
                  height: width * 0.3,
                  // color: Colors.red,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        '${index}',
                        style: TextStyle(
                            color: config.dateColor,
                            fontSize: width * 0.3 * 0.36,
                            fontFamily: 'Anton'),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: List.generate(
                numberOfRectangles,
                (index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: width * 0.25,
                        height: holeHeight,
                      ),
                      Container(
                        width: width * 0.5,
                        height: holeHeight,
                        margin: EdgeInsets.only(
                            top: gapWidthBetweenHole / 2,
                            bottom: gapWidthBetweenHole / 2),
                        decoration: BoxDecoration(
                          color: backLight,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.25,
                        height: holeHeight,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }
}

class FilmHead extends StatelessWidget {
  final double unitFrameWidth;
  final double headerHeight;
  final double photoFrameWidth;
  final Color filmColor;
  final Color backLight;
  final String filmMaker;
  final String filmDate;
  final double holeHeight;
  final bool isNeg;

  const FilmHead({
    Key? key,
    required this.unitFrameWidth,
    required this.headerHeight,
    required this.filmColor,
    required this.backLight,
    required this.filmMaker,
    required this.filmDate,
    required this.photoFrameWidth,
    required this.holeHeight,
    required this.isNeg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(unitFrameWidth, headerHeight),
          painter: FilmHeadPainter(
            filmColor: config.filmColor,
          ),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: FilmHeadClipper(),
            child: Opacity(
              opacity: 1,
              child: Row(
                children: [
                  FilmRowLeftSide(
                    height: headerHeight,
                    width: unitFrameWidth * 0.2,
                    holeHeight: holeHeight,
                    backLight: backLight,
                    index: 0,
                  ),
                  SizedBox(
                    width: unitFrameWidth * 0.6,
                    child: Container(
                      color: config.filmColor,
                      height: headerHeight,
                    ),
                  ),
                  FilmRowRightSide(
                    height: headerHeight,
                    width: unitFrameWidth * 0.2,
                    holeHeight: holeHeight,
                    backLight: backLight,
                    filmMaker: filmMaker,
                    filmDate: filmDate,
                  ),
                ],
              ),
            ),
          ),
        ),
        !isNeg
            ? Positioned.fill(
                child: IgnorePointer(
                    child: ClipPath(
                  clipper: FilmHeadClipper(),
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
                )),
              )
            : Positioned.fill(
                child: IgnorePointer(
                    child: ClipPath(
                  clipper: FilmHeadClipper(),
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/noise.png',
                      fit: BoxFit.cover,
                      color: Colors.red.withOpacity(0.2),
                      colorBlendMode: BlendMode.multiply,
                    ),
                  ),
                )),
              ),
        // Positioned.fill(
        //   child: ClipPath(
        //     clipper: FilmHeadClipper(),
        //     child: Opacity(
        //       opacity: 0.1,
        //       child: Image.asset(
        //         'assets/images/noise.png',
        //         fit: BoxFit.cover,
        //         color: Colors.brown.withOpacity(0.2),
        //         colorBlendMode: BlendMode.multiply,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

Path buildFilmHeadPath(Size size) {
  final path = Path();

  // Set start point
  double xTemp = 0;
  double yTemp = size.height;

  // 1 up height
  double firstUpHeight = size.height * 0.3;

  // 2 outer
  double secondOuter = size.width * 0.16;

  // 3
  double thirdEdgeBetween = size.width * 0.088;

  // 4 inner
  double fourthInner = size.width * 0.25;

  // 5 outer
  double fifthOuter = size.width * 0.16;

  // Start point
  path.moveTo(xTemp, yTemp);

  // 1 up
  yTemp -= firstUpHeight;
  path.lineTo(xTemp, yTemp);

  // 2 draw first outer arc (凸)
  // xTemp += secondOuter;
  // yTemp -= secondOuter;
  // path.quadraticBezierTo(
  //   xTemp - secondOuter * 0.9, yTemp - secondOuter * 0.0, // 控制點 (根據形狀手動調)
  //   xTemp, yTemp, // 終點
  // );

  // edgeBetween
  xTemp += thirdEdgeBetween;
  path.lineTo(xTemp, yTemp);

  // 3 draw first outer arc (凹)
  xTemp += fourthInner;
  yTemp -= fourthInner;
  path.quadraticBezierTo(
    xTemp + fourthInner * 0.03, yTemp + fourthInner * 0.95, // 控制點 (根據形狀手動調)
    xTemp, yTemp, // 終點
  );

  // 4 draw up
  yTemp = fifthOuter;
  path.lineTo(xTemp, yTemp);

  // 5 draw second outer arc (凸)
  xTemp += fifthOuter;
  yTemp -= fifthOuter;
  path.quadraticBezierTo(
    xTemp - fifthOuter * 0.9, yTemp - fifthOuter * 0.0, // 控制點 (根據形狀手動調)
    xTemp, yTemp, // 終點
  );

  // Top edge
  path.lineTo(size.width, 0);

  // Right edge down
  path.lineTo(size.width, size.height);

  path.close();

  return path;
}

class FilmHeadPainter extends CustomPainter {
  final Color filmColor;

  FilmHeadPainter({required this.filmColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = filmColor
      ..style = PaintingStyle.fill;

    final path = buildFilmHeadPath(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FilmHeadClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => buildFilmHeadPath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
