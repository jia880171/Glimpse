import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:exif/exif.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/common/utils/image_utils.dart';
import 'package:glimpse/widgets/film/film_roll_left.dart';
import 'package:glimpse/widgets/film/film_roll_right_view.dart';
import 'package:image/image.dart' as img;

import '../../config.dart' as config;

/// Film Simulation 對照表
const Map<int, String> filmModeMap = {
  0x000: 'Provia',
  0x100: 'Portrait',
  0x110: 'Portrait + Saturation',
  0x120: 'Astia',
  0x130: 'Portrait + Sharpness',
  0x300: 'Portrait + Ex',
  0x200: 'Velvia',
  0x400: 'Velvia',
  0x500: 'Pro Neg. Std',
  0x501: 'Pro Neg. Hi',
  0x600: 'Classic Chrome',
  0x700: 'Eterna',
  0x800: 'Classic Negative',
  0x900: 'Eterna Bleach Bypass',
  0xa00: 'Nostalgic Negative',
  0xb00: 'Reala ACE',
};

const Map<int, String> saturationModeMap = {
  0x300: 'Monochrome',
  0x301: 'Monochrome + R Filter',
  0x302: 'Monochrome + Ye Filter',
  0x303: 'Monochrome + G Filter',
  0x310: 'Sepia',
  0x500: 'ACROS',
  0x501: 'ACROS + R Filter',
  0x502: 'ACROS + Ye Filter',
  0x503: 'ACROS + G Filter',
};

class RotatableGlimpseCardFrontView extends StatefulWidget {
  // final String? imagePath;
  final Uint8List image;
  final Size cardSize;
  final Map<String?, IfdTag> exifData;
  final Color backLight;
  final int index;
  final bool isNeg;
  final Function leaveCardMode;
  final bool? isPlastic;
  final ui.Image? processedImage;
  final bool noX;

  const RotatableGlimpseCardFrontView({
    Key? key,
    required this.image,
    // required this.imagePath,
    required this.cardSize,
    required this.exifData,
    required this.backLight,
    required this.index,
    required this.isNeg,
    required this.leaveCardMode,
    this.processedImage,
    this.isPlastic, required this.noX,
  }) : super(key: key);

  @override
  RotatableGlimpseCardFrontViewState createState() =>
      RotatableGlimpseCardFrontViewState();
}

class RotatableGlimpseCardFrontViewState
    extends State<RotatableGlimpseCardFrontView>
    with SingleTickerProviderStateMixin {
  final LightSource _neumorphicLightSource = LightSource.topLeft;
  late Uint8List image;

  String imageMake = '';
  String filmSimulation = '';
  String cameraModel = '';
  String lensModel = '';
  String iso = '';
  String shutterSpeed = '';
  String aperture = '';
  String dateOFPic = '';

  double _scale = 1.0;
  double _baseScale = 1.0;
  late AnimationController _controller;
  late Animation<double> _animation;



  void setImgInformation() {
    final data = widget.exifData;
    if (data.isNotEmpty) {
      final makerNoteTag = data['EXIF MakerNote'];

      if (makerNoteTag != null && makerNoteTag.values is List) {
        final dynamicList = makerNoteTag.values as List;
        final intList = dynamicList.cast<int>(); // 轉成 List<int>
        final bytes = Uint8List.fromList(intList); // 再轉 Uint8List

        parseFujiFilmMakerNote(bytes);
      }

      setState(() {
        imageMake = data['Image Make']?.printable ?? '未知品牌';
        cameraModel = data['Image Model']?.printable ?? '未知機型';
        lensModel = data['EXIF LensModel']?.printable ?? '未知鏡頭';
        shutterSpeed = data['EXIF ShutterSpeedValue']?.printable != null
            ? ImageUtils.formatShutterSpeed(
                data['EXIF ShutterSpeedValue']!.printable!)
            : '未知快門';
        aperture = data['EXIF ApertureValue']?.printable != null
            ? ImageUtils.formatAperture(data['EXIF ApertureValue']!.printable!)
            : '未知光圈';
        dateOFPic = data['Image DateTime']?.printable ?? '未知日期';
        iso = data['EXIF ISOSpeedRatings']?.printable ?? '未知';
      });

      // print('📷 Camera Model: ${cameraModel}');
      // print('🕓 Date Time: ${dateTime?.printable}');
    } else {
      print('No EXIF data found.');
    }
  }

  void parseFujiFilmMakerNote(Uint8List bytes) {
    final header = ascii.decode(bytes.sublist(0, 8));
    if (!header.startsWith('FUJIFILM')) {
      // print('❌ 不是富士相機的 MakerNote');
      return;
    }

    int offset = 12;
    const littleEndian = true;
    final entryCount = readUInt16(bytes, offset, littleEndian);
    offset += 2;

    for (int i = 0; i < entryCount; i++) {
      final tagOffset = offset + (i * 12);
      final tag = readUInt16(bytes, tagOffset, littleEndian);
      final valueOffset = tagOffset + 8;
      final val = readUInt16(bytes, valueOffset, littleEndian);

      if (tag == 0x1401) {
        final name = filmModeMap[val];
        if (name != null) {
          print('🎞️ Film Simulation (0x1401): $name');
          filmSimulation = name;
        } else {
          // print('❓ 未知 Film Mode: 0x${val.toRadixString(16)}');
        }
      } else if (tag == 0x1003) {
        final name = saturationModeMap[val];
        if (name != null) {
          print('🎞️ Film Simulation (Saturation 0x1003): $name');
          filmSimulation = name;
        } else {
          // print('❓ 未知 Saturation Mode: 0x${val.toRadixString(16)}');
        }
      }
    }
  }

  /// 讀取 16-bit unsigned int
  int readUInt16(Uint8List bytes, int offset, bool littleEndian) {
    if (offset + 2 > bytes.length) return 0;
    final b1 = bytes[offset];
    final b2 = bytes[offset + 1];
    return littleEndian ? (b2 << 8) + b1 : (b1 << 8) + b2;
  }

  @override
  void initState() {
    super.initState();
    setImgInformation(); // 僅跑一次
    setImage();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addListener(() {
      setState(() {
        _scale = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setImage() {
    image = widget.image;
  }

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

  Widget _buildCard() {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      child: SizedBox(
          width: widget.cardSize.width,
          height: widget.cardSize.height,
          child:
          Stack(
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
                            fontSize: widget.cardSize.height * 0.3 * 0.1)),
                    SizedBox(height: widget.cardSize.height * 0.01),
                    Text(filmSimulation,
                        style: TextStyle(
                            fontFamily: 'Open-Sans',
                            fontSize: widget.cardSize.width * 0.02)),
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
                                    widget.processedImage == null
                                        ? const CircularProgressIndicator()
                                        : _buildFrameUnit(
                                            widget.cardSize.width * 0.66,
                                            widget.cardSize.height * 0.66,
                                            widget.backLight,
                                          ),
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
              if(!widget.noX)
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
    final double photoFrameWidth = frameWidth * 0.7;
    final holeHeight = frameHeight * 0.06;

    final double photoMaxHeight = photoFrameHeight;
    final double photoMaxWidth = photoFrameWidth;

    if (widget.processedImage == null) {
      return const SizedBox();
    }

    final double imageWidth = widget.processedImage!.width.toDouble();
    final double imageHeight = widget.processedImage!.height.toDouble();

    final double estimatedWidth = photoMaxHeight * imageWidth / imageHeight;

    final BoxFit fitMode =
        estimatedWidth > photoMaxWidth ? BoxFit.fitHeight : BoxFit.fitWidth;

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

            // 用 Stack 讓圖片可以超出父容器限制
            Expanded(
              child: Stack(
                clipBehavior: Clip.none, // 允許超出父容器
                children: [
                  // 這個SizedBox限制高度寬度，但圖片會放大超出
                  SizedBox(
                    height: frameHeight,
                    child: GestureDetector(
                      onScaleStart: (details) {
                        _baseScale = _scale;
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          _scale = (_baseScale * details.scale).clamp(1.0, 4.0);
                        });
                      },
                      onScaleEnd: (details) {
                        _handleScaleEnd();
                      },
                      child: Center(
                        child: Transform.scale(
                          scale: _scale,
                          alignment: Alignment.center,
                          child: RawImage(
                            image: widget.processedImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  void _handleScaleEnd() {
    _animation = Tween<double>(begin: _scale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0);
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
