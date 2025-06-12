import 'dart:math';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/widgets/film/film_roll_left.dart';
import 'package:glimpse/widgets/film/film_roll_right_view.dart';
import 'package:image/image.dart' as img;

import './config.dart' as config;

class RotatableGlimpseCardFrontView extends StatefulWidget {
  final String? imagePath;
  final Uint8List image;
  final Size cardSize;
  final Map<String?, IfdTag> exifData;
  final Color backLight;
  final int index;
  final bool isNeg;
  final Function leaveCardMode;

  const RotatableGlimpseCardFrontView({
    Key? key,
    required this.image,
    required this.imagePath,
    required this.cardSize,
    required this.exifData,
    required this.backLight,
    required this.index,
    required this.isNeg,
    required this.leaveCardMode,
  }) : super(key: key);

  @override
  RotatableGlimpseCardFrontViewState createState() =>
      RotatableGlimpseCardFrontViewState();
}

class RotatableGlimpseCardFrontViewState
    extends State<RotatableGlimpseCardFrontView> {
  LightSource _neumorphicLightSource = LightSource.topLeft;
  late Uint8List image;
  ui.Image? _processedImage;

  String imageMake = '';
  String cameraModel = '';
  String lensModel = '';
  String iso = '';
  String shutterSpeed = '';
  String aperture = '';
  String dateOFPic = '';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: _buildCard(),
        ),
      ),
    );
  }

  String formatAperture(String rawValue) {
    try {
      double av;

      if (rawValue.contains('/')) {
        final parts = rawValue.split('/');
        final num = double.parse(parts[0]);
        final denom = double.parse(parts[1]);
        av = num / denom;
      } else {
        av = double.parse(rawValue);
      }

      final fNumber = pow(2, av / 2);
      return 'f/${fNumber.toStringAsFixed(1)}';
    } catch (e) {
      print('====== Aperture Parse Error: $e');
      return '未知光圈';
    }
  }

  String formatShutterSpeed(String rawValue) {
    try {
      double log2Value;

      if (rawValue.contains('/')) {
        final parts = rawValue.split('/');
        final num = double.parse(parts[0]);
        final denom = double.parse(parts[1]);
        log2Value = num / denom;
      } else {
        log2Value = double.parse(rawValue);
      }

      final shutterTime = pow(2, -log2Value).toDouble();

      if (shutterTime >= 1.0) {
        return '${shutterTime.toStringAsFixed(1)}s';
      } else {
        final reciprocal = (1 / shutterTime).round();
        return '1/$reciprocal';
      }
    } catch (e) {
      print('====== Shutter Parse Error: $e');
      return '未知快門';
    }
  }

  void setImgInformation() {
    final data = widget.exifData;
    // print('======data ${data} ');
    if (data.isNotEmpty) {
      print('====== setting setImgInformation [Exif data]');
      // for (var entry in data.entries) {
      //   print('${entry.key}: ${entry.value}');
      // }

      // final cameraModel = data['Image Model'];

      setState(() {
        imageMake = data['Image Make']?.printable ?? '未知品牌';
        cameraModel = data['Image Model']?.printable ?? '未知機型';
        lensModel = data['EXIF LensModel']?.printable ?? '未知鏡頭';
        shutterSpeed = data['EXIF ShutterSpeedValue']?.printable != null
            ? formatShutterSpeed(data['EXIF ShutterSpeedValue']!.printable!)
            : '未知快門';
        aperture = data['EXIF ApertureValue']?.printable != null
            ? formatAperture(data['EXIF ApertureValue']!.printable!)
            : '未知快門';
        dateOFPic = data['Image DateTime']?.printable ?? '未知日期';
        iso = data['EXIF ISOSpeedRatings']?.printable ?? '未知';
      });

      // final dateTime = data['EXIF DateTimeOriginal'];

      // print('📷 Camera Model: ${cameraModel}');
      // print('🕓 Date Time: ${dateTime?.printable}');
    } else {
      print('No EXIF data found.');
    }
  }

  @override
  void initState() {
    super.initState();
    setImgInformation(); // 僅跑一次
    setImage();
    _processImage();
  }

  Future<void> _processImage() async {
    final rawImage = await decodeAndRotateIfNeeded(image);
    setState(() {
      _processedImage = rawImage;
    });
  }

  void setImage() {
    image = widget.image;
  }

  Widget _buildCard() {
    return Card(
      color: config.hardCard.withOpacity(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      child: SizedBox(
          width: widget.cardSize.width,
          height: widget.cardSize.height,
          child: Stack(
            children: [
              Stack(
                children: [
                  Container(
                    width: widget.cardSize.width,
                    height: widget.cardSize.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: const LinearGradient(
                        colors: [config.hardCard, config.hardCard],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Opacity(
                        opacity: 0.0766,
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

              Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Text(imageMake,
                        style: TextStyle(
                            fontFamily: 'Open-Sans',
                            fontSize: widget.cardSize.height * 0.3*0.1)),
                    const Spacer(),
                    Stack(
                      alignment: Alignment.center,
                      children: [

                        // dent
                        Neumorphic(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            depth: -1.36,
                            intensity: 1,
                            lightSource: _neumorphicLightSource,
                          ),
                          child: Container(
                            // color: config.backGroundWhite,
                            color: config.hardCard,
                            width: widget.cardSize.width * 0.7,
                            height: widget.cardSize.height * 0.7,
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Opacity(
                              opacity: 0.0766,
                              child: Image.asset(
                                'assets/images/noise.png',
                                fit: BoxFit.cover,
                                color: Colors.brown.withOpacity(0.2),
                                colorBlendMode: BlendMode.multiply,
                              ),
                            ),
                          ),
                        ),

                        Container(
                            // color: Colors.red,
                            width: widget.cardSize.width * 0.69,
                            height: widget.cardSize.height * 0.69,
                            child: Center(
                              child: Transform.rotate(
                                angle: -1 * pi / 180,
                                child: Stack(
                                  children: [
                                    _buildFrameUnit(
                                        widget.cardSize.width * 0.66,
                                        widget.cardSize.height * 0.66,
                                        widget.backLight),
                                    !widget.isNeg
                                        ? Positioned.fill(
                                            child: IgnorePointer(
                                              child: ClipRRect(
                                                // borderRadius: BorderRadius.circular(11),
                                                child: Opacity(
                                                  opacity: 0.2,
                                                  child: Image.asset(
                                                    'assets/images/noise.png',
                                                    fit: BoxFit.cover,
                                                    color: Colors.brown
                                                        .withOpacity(0.3),
                                                    colorBlendMode:
                                                        BlendMode.multiply,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Positioned.fill(
                                            child: IgnorePointer(
                                              child: Opacity(
                                                opacity: 0.2,
                                                child: Image.asset(
                                                  'assets/images/noise.png',
                                                  fit: BoxFit.cover,
                                                  color: Colors.red
                                                      .withOpacity(0.2),
                                                  colorBlendMode:
                                                      BlendMode.multiply,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                    const Spacer(),
                    Text(cameraModel,
                        style: TextStyle(
                            fontFamily: 'Open-Sans',
                            fontSize: widget.cardSize.width * 0.035)),
                    Text(lensModel,
                        style: TextStyle(
                            fontFamily: 'Open-Sans',
                            fontSize: widget.cardSize.width * 0.03)),
                    const Spacer(),
                  ],
                ),
              ),

              // text on the right
              Positioned(
                  top: widget.cardSize.height * 0.5,
                  left: widget.cardSize.width * 0.73,
                  child: Transform.rotate(
                    angle: 90 * pi / 180,
                    child: Row(
                      children: [
                        Text(shutterSpeed,
                            style: TextStyle(
                                fontFamily: 'Open-Sans',
                                fontSize: widget.cardSize.width * 0.02)),
                        SizedBox(width: widget.cardSize.height * 0.05),
                        Text(aperture,
                            style: TextStyle(
                                fontFamily: 'Open-Sans',
                                fontSize: widget.cardSize.width * 0.02)),
                        SizedBox(width: widget.cardSize.height * 0.05),
                        Text('ISO/$iso',
                            style: TextStyle(
                                fontFamily: 'Open-Sans',
                                fontSize: widget.cardSize.width * 0.02)),
                      ],
                    ),
                  )),

              // x
              Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      widget.leaveCardMode();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.highlight_off),
                    ),
                  )),
            ],
          )),
    );
  }

  Widget _buildFrameUnit(
      double frameWidth, double frameHeight, Color backLight) {
    final double photoFrameHeight = frameHeight * 0.7;
    final holeHeight = frameHeight * 0.06;

    return Container(
      width: frameWidth,
      height: frameHeight,
      color: config.backLightB.withOpacity(0.8),
      child: Center(
        child: Row(
          children: [
            FilmRowLeftSide(
              height: frameHeight,
              width: frameWidth * 0.15,
              holeHeight: holeHeight,
              backLight: config.backLightB,
              index: widget.index,
            ),
            SizedBox(
              height: photoFrameHeight,
              width: frameWidth * 0.7,
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                  child: RawImage(
                    image: _processedImage,
                    fit: BoxFit.contain,
                  )),
            ),
            FilmRowRightSide(
              height: frameHeight,
              width: frameWidth * 0.15,
              holeHeight: holeHeight,
              backLight: config.backLightB,
              filmMaker: imageMake,
              filmDate: dateOFPic,
            )
          ],
        ),
      ),
    );
  }

  Future<ui.Image> decodeAndRotateIfNeeded(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    if (image.width > image.height) {
      // 橫圖 → 旋轉 90 度
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final rotatedWidth = image.height.toDouble();
      final rotatedHeight = image.width.toDouble();

      canvas.translate(rotatedWidth, 0);
      canvas.rotate(90 * 3.1415927 / 180);

      canvas.drawImage(image, Offset.zero, Paint());

      final picture = recorder.endRecording();
      return await picture.toImage(rotatedWidth.toInt(), rotatedHeight.toInt());
    }

    return image; // 直圖，不旋轉
  }

  Uint8List applyNegativeEffect(Uint8List imageData) {
    // 解碼圖片
    final originalImage = img.decodeImage(imageData);
    if (originalImage == null) {
      throw Exception("無法解碼圖片");
    }

    // 套用負片效果
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final pixel = originalImage.getPixel(x, y);

        // 取出 RGB 值
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // 取反 RGB 值
        final invertedColor = img.getColor(255 - r, 255 - g, 255 - b);
        originalImage.setPixel(x, y, invertedColor);
      }
    }

    // 將處理後的圖片編碼回 Uint8List
    return Uint8List.fromList(img.encodeJpg(originalImage));
  }
}
