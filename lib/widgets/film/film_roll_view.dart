import 'dart:ui' as ui;
import 'package:async/async.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/common/utils/image_utils.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../config.dart' as config;
import 'film_frame_or_header.dart';
import 'film_roll_left.dart';
import 'film_roll_right_view.dart';

class FilmRollView extends StatefulWidget {
  final Size viewSize;
  final String targetAlbumName;
  final DateTime selectedDate;
  final List<AssetEntity> images;
  final Map<String, ui.Image> thumbnailCache;
  final Color backLight;
  final bool noHeader;
  final bool isNeg;
  final bool isContactSheet;
  final int offset;
  final Function(AssetEntity image, int index, bool isNeg) onTapPic;
  final Function leaveCardMode;

  const FilmRollView(
      {super.key,
      required this.viewSize,
      required this.images,
      required this.thumbnailCache,
      required this.backLight,
      required this.noHeader,
      required this.isNeg,
      required this.isContactSheet,
      required this.offset,
      required this.targetAlbumName,
      required this.selectedDate,
      required this.onTapPic,
      required this.leaveCardMode});

  @override
  State<StatefulWidget> createState() {
    return _FilmRollViewState();
  }
}

class _FilmRollViewState extends State<FilmRollView> {

  CancelableOperation<void>? _scrollOperation;

  int currentIndex = 0;
  String filmMaker = '';
  String filmDate = '';
  final ScrollController _scrollController = ScrollController();
  double picRatio = 2 / 3;
  late double photoHeight = widget.viewSize.height * 0.35;
  late double photoFrameWidth = photoHeight * picRatio;
  late double unitFrameWidth =
      widget.isContactSheet ? widget.viewSize.width : widget.viewSize.width * 0.5;
  late double headerHeight = photoHeight * 1.75;
  late double holeHeight = photoHeight * 0.078;
  late double unitFrameHeight = photoHeight * 1.1;

  bool isCardViewMode = false;
  bool isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    calculateCurrentIndex();
    jumpToCurrentIndex();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FilmRollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _initExifData();
    }

    // clear currentIndex when targetAlbumName and selectedDate have changed
    if (widget.targetAlbumName != oldWidget.targetAlbumName ||
        widget.selectedDate != oldWidget.selectedDate) {
      currentIndex = 0;
      jumpToCurrentIndex();
    } else {
      int previousIndex = currentIndex;
      calculateCurrentIndex();
      if (currentIndex != previousIndex) {
        jumpToCurrentIndex();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return filmRoll();
  }

  void _onScroll() {
    if (isAutoScrolling) return;

    double offset = _scrollController.offset;

    // 拿掉 header 高度差
    double contentOffset = offset - (unitFrameHeight - headerHeight);
    if (contentOffset < 0) contentOffset = 0;

    int newIndex = (contentOffset / unitFrameHeight).floor() + 1;
    print('====== [film_roll] [_onScroll]Scroll updating currentIndex: $currentIndex, new: ${newIndex}, isAutoScrolling: ${isAutoScrolling}');

    if (newIndex != currentIndex &&
        newIndex >= 0 &&
        newIndex < widget.images.length) {
      setState(() {
        currentIndex = newIndex;
        print('====== [film_roll]Scroll updated currentIndex: $currentIndex');
      });
    }
  }

  void jumpToCurrentIndex() {
    print('===== [film_roll][jumpToCurrentIndex], current: ${currentIndex}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        double scrollOffset = calculateScrollOffset(currentIndex);

        // 取消之前尚未完成的動畫
        _scrollOperation?.cancel();
        isAutoScrolling = true;

        _scrollOperation = CancelableOperation.fromFuture(
          _scrollController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
          ),
          // onCancel: () {
          //   print('Scroll animation cancelled');
          // },
        );

        _scrollOperation!.value.whenComplete(() {
          isAutoScrolling = false;
        });
      }
    });
  }

  double calculateScrollOffset(int index) {
    double scrollOffset = 0;
    if (index > 0) {
      scrollOffset += headerHeight;
      scrollOffset += unitFrameHeight * (index - 1);
    }

    return scrollOffset;
  }

  void calculateCurrentIndex() {
    print(
        '====== calculating current Index: c: ${currentIndex}, offset: ${widget.offset}');
    currentIndex += widget.offset;
    if (currentIndex >= widget.images.length - 3) {
      currentIndex = widget.images.length - 3;
    } else if (currentIndex < 0) {
      currentIndex = 0;
    }
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
    if (widget.images.isEmpty) {
      return;
    }

    final imageBytes = await ImageUtils.getImageBytes(widget.images[0]);
    final exifData = await readExifFromBytes(imageBytes!);

    setState(() {
      setFilmMaker(exifData?['Image Make']?.printable ?? '未知品牌');
      setFilmDate(exifData?['Image DateTime']?.printable ?? '未知日期');
    });
  }

  Widget filmRoll() {
    return Container(
        color: widget.backLight,
        height: widget.viewSize.height,
        width: widget.viewSize.width,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: SizedBox(
              height: widget.viewSize.height,
              width:widget. viewSize.width,
              child: Center(
                  child: (widget.images.isEmpty && !widget.noHeader)
                      ? const Center(
                          child: Text("No images found for this date"))
                      : ListView.builder(
                          controller: _scrollController,
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
                                  photoHeight: photoHeight,
                                  picRatio: picRatio,
                                  filmColor: config.filmColor,
                                  backLight: widget.backLight,
                                  filmMaker: filmMaker,
                                  filmDate: filmDate,
                                  onTapPic: widget.onTapPic,
                                  noHeader: widget.noHeader,
                                  isNeg: widget.isNeg,
                                  isContactSheet: widget.isContactSheet,
                                  unitFrameHeight: unitFrameHeight,
                                  holeHeight: holeHeight,
                                ),
                              ),
                            );
                          },
                        ))),
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
  double thirdEdgeBetween = size.width * 0.3;

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
