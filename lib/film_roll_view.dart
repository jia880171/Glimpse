import 'dart:ui' as ui;
import 'dart:ui';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/common/utils/image_utils.dart';
import 'package:glimpse/rotatable_Glimpse_card_view.dart';
import 'package:photo_manager/photo_manager.dart';

import './config.dart' as config;

class FilmRollView extends StatefulWidget {
  final Size viewSize;
  final List<AssetEntity> images;
  final Map<String, ui.Image> thumbnailCache;
  final Color backLight;

  const FilmRollView(
      {super.key,
      required this.viewSize,
      required this.images,
      required this.thumbnailCache,
      required this.backLight});

  @override
  State<StatefulWidget> createState() {
    return _FilmRollViewState();
  }
}

class _FilmRollViewState extends State<FilmRollView> {
  String filmMaker = '';
  String filmDate = '';

  @override
  Widget build(BuildContext context) {
    _initExifData();
    return filmRoll();
  }

  void setFilmMaker(String filmMaker) {
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
    final imageBytes = await ImageUtils.getImageBytes(widget.images[0]);
    final exifData = await readExifFromBytes(imageBytes!);

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
    double filmRollWidth = photoFrameWidth * 1.4;
    double headerHeight = photoFrameHeight * 1.2;

    return Container(
        color: widget.backLight,
        // color: config.backLightB,
        width: viewSize.width,
        height: viewSize.height,
        child: Center(
          child: widget.images.isEmpty
              ? const Center(child: Text("No images found for this date"))
              : ListView.builder(
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final image = widget.images[index];
                    final thumbnail = widget.thumbnailCache[image.id];

                    return Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        // color: widget.backLight,
                        width: filmRollWidth,
                        child: FilmFrame(
                          image: image,
                          index: index,
                          imagesLength: widget.images.length,
                          thumbnail: thumbnail!,
                          filmRollWidth: filmRollWidth,
                          headerHeight: headerHeight,
                          photoFrameWidth: photoFrameWidth,
                          photoFrameHeight: photoFrameHeight,
                          picRatio: picRatio,
                          filmColor: config.filmColor,
                          backLight: widget.backLight,
                          filmMaker: filmMaker,
                          filmDate: filmDate,
                          onTapPic: onTapPic,
                        ),
                      ),
                    );
                  },
                ),
        ));
  }

  Future<void> onTapPic(image) async {
    final isNeg = config.backLightB == widget.backLight;

    // 取得圖片 bytes
    final imageBytes = await ImageUtils.getImageBytes(image);

    // Get EXIF here. The exif will disappear after applying the neg. effect
    final exifData = await readExifFromBytes(imageBytes!);

    // Get the path of the image
    final file = await image.file;
    final imgPath = file?.path;

    final processedImage =
        isNeg ? ImageUtils.applyNegativeEffect(imageBytes) : imageBytes;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RotatableGlimpseCardView(
          image: processedImage!,
          exifData: exifData!,
          imgPath: imgPath!,
        ),
      ),
    );
  }
}

class FilmFrame extends StatelessWidget {
  final dynamic image;
  final int index;
  final int imagesLength;
  final ui.Image thumbnail;
  final double filmRollWidth;
  final double headerHeight;
  final double photoFrameWidth;
  final double photoFrameHeight;
  final double picRatio;
  final Color filmColor;
  final Color backLight;
  final String filmMaker;
  final String filmDate;
  final Future<void> Function(dynamic image) onTapPic;

  const FilmFrame({
    super.key,
    required this.image,
    required this.index,
    required this.imagesLength,
    required this.thumbnail,
    required this.filmRollWidth,
    required this.headerHeight,
    required this.photoFrameWidth,
    required this.photoFrameHeight,
    required this.picRatio,
    required this.filmColor,
    required this.backLight,
    required this.filmMaker,
    required this.filmDate,
    required this.onTapPic,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = index == 0;
    final isLast = index == imagesLength - 1;

    if (isFirst) {
      return FilmHead(
        filmRollWidth: filmRollWidth,
        headerHeight: headerHeight,
        filmColor: filmColor,
        backLight: backLight,
        filmMaker: filmMaker,
        filmDate: filmDate,
      );
    } else if (isLast) {
      return const SizedBox();
    } else {
      return Row(
        children: [
          Container(
            width: photoFrameWidth * 1.4,
            height: photoFrameHeight,
            color: filmColor,
            child: Stack(
              children: [
                Row(
                  children: [
                    FilmRowLeftSide(
                      index: index,
                      height: photoFrameHeight,
                      width: photoFrameWidth * 0.2,
                      holeHeight: photoFrameWidth * 0.05,
                      backLight: backLight,
                    ),
                    SizedBox(
                      width: photoFrameWidth,
                      child: (thumbnail != null)
                          ? GestureDetector(
                              onTap: () async {
                                await onTapPic(image);
                              },
                              child: Container(
                                color: filmColor,
                                height: photoFrameHeight * 0.9,
                                width: photoFrameHeight * 0.9 * picRatio,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  alignment: Alignment.center,
                                  child: RawImage(
                                    image: thumbnail,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              height: 100,
                              width: 100 * picRatio,
                            ),
                    ),
                    FilmRowRightSide(
                      height: photoFrameHeight,
                      width: photoFrameWidth * 0.2,
                      holeHeight: photoFrameWidth * 0.05,
                      backLight: backLight,
                      filmMaker: filmMaker,
                      filmDate: filmDate,
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/noise.png',
                        fit: BoxFit.cover,
                        color: Colors.brown.withOpacity(0.2),
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

class FilmRowRightSide extends StatelessWidget {
  final double height; // Total height (including spacing) passed as a parameter
  final double width;
  final double holeHeight; // The height of each hole
  final Color backLight;
  final String filmMaker;
  final String filmDate;

  const FilmRowRightSide({
    super.key,
    required this.height,
    required this.holeHeight,
    required this.backLight,
    required this.width,
    required this.filmMaker,
    required this.filmDate,
  });

  @override
  Widget build(BuildContext context) {
    final gapWidthBetweenHole = holeHeight;
    // Calculate the number of rectangles that can fit within the total height
    final numberOfRectangles =
        (height / (holeHeight + gapWidthBetweenHole)).floor();

    return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
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
                          '${filmMaker}',
                          style: TextStyle(
                              fontSize: width * 0.3 * 0.8,
                              color: config.dateColor,
                              fontFamily: 'DS-DIGI'),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        const Spacer(),
                        Text(
                          '${filmDate.split(' ')[0]}',
                          style: TextStyle(
                              fontSize: width * 0.3 * 0.8,
                              color: config.dateColor,
                              fontFamily: 'DS-DIGI'),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        const Spacer(),
                      ],
                    )),
              ),
            ),
            Column(
              children: List.generate(
                numberOfRectangles,
                (index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: width * 0.3,
                        height: holeHeight,
                      ),
                      Container(
                        width: width * 0.4,
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
                        width: width * 0.3,
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

    return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: RotatedBox(
                quarterTurns: 1, // 90 degrees clockwise
                child: Container(
                  width: height,
                  height: width * 0.35,
                  // color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    '${index}',
                    style: TextStyle(
                        color: config.dateColor,
                        fontSize: width * 0.3 * 0.68,
                        fontFamily: 'Anton'),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
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
                        width: width * 0.3,
                        height: holeHeight,
                      ),
                      Container(
                        width: width * 0.4,
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
                        width: width * 0.3,
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
  final double filmRollWidth;
  final double headerHeight;
  final Color filmColor;
  final Color backLight;
  final String filmMaker;
  final String filmDate;

  const FilmHead({
    Key? key,
    required this.filmRollWidth,
    required this.headerHeight,
    required this.filmColor,
    required this.backLight,
    required this.filmMaker,
    required this.filmDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(filmRollWidth, headerHeight),
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
                    width: filmRollWidth * 0.2,
                    holeHeight: filmRollWidth * 0.05,
                    backLight: backLight,
                    index: 0,
                  ),
                  SizedBox(
                    width: filmRollWidth * 0.6,
                    child: Container(
                      color: config.filmColor,
                      height: headerHeight,
                    ),
                  ),
                  FilmRowRightSide(
                    height: headerHeight,
                    width: filmRollWidth * 0.2,
                    holeHeight: filmRollWidth * 0.05,
                    backLight: backLight,
                    filmMaker: filmMaker,
                    filmDate: filmDate,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: FilmHeadClipper(),
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/noise.png',
                fit: BoxFit.cover,
                color: Colors.brown.withOpacity(0.2),
                colorBlendMode: BlendMode.multiply,
              ),
            ),
          ),
        ),
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
