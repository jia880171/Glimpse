import 'dart:io';
import 'dart:math';

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:photo_manager/photo_manager.dart';
import './config.dart' as config;
import 'package:image/image.dart' as img;

class RotatableGlimpseCardFrontView extends StatefulWidget {
  final String? imagePath;
  final Uint8List image;
  final bool isNeg;
  final Size cardSize;

  const RotatableGlimpseCardFrontView({
    Key? key,
    required this.image,
    required this.imagePath,
    required this.isNeg,
    required this.cardSize,
  }) : super(key: key);

  @override
  RotatableGlimpseCardFrontViewState createState() =>
      RotatableGlimpseCardFrontViewState();
}

class RotatableGlimpseCardFrontViewState
    extends State<RotatableGlimpseCardFrontView> {
  LightSource _neumorphicLightSource = LightSource.topLeft;
  late Uint8List image;

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

  Future<Map<String?, IfdTag>?> extractExifFromBytes(
      Uint8List imageBytes) async {
    final data = await readExifFromBytes(imageBytes);
    // print('======data ${data} ');
    if (data != null && data.isNotEmpty) {
      print('Exif data:');
      for (var entry in data.entries) {
        print('${entry.key}: ${entry.value}');
      }

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
      });

      // final dateTime = data['EXIF DateTimeOriginal'];

      print('📷 Camera Model: ${cameraModel}');
      // print('🕓 Date Time: ${dateTime?.printable}');
    } else {
      print('No EXIF data found.');
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    extractExifFromBytes(widget.image); // 僅跑一次
    setImage();
  }

  void setImage() {
    image = widget.isNeg ? applyNegativeEffect(widget.image) : widget.image;
  }

  Widget _buildCard() {
    return Card(
      color: config.hardCard,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(11),
      ),
      child: SizedBox(
          width: widget.cardSize.width,
          height: widget.cardSize.height,
          child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const Spacer(),
                Text(imageMake,
                    style: TextStyle(
                        fontFamily: 'Open-Sans',
                        fontSize: widget.cardSize.width * 0.06)),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
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
                        width: widget.cardSize.width * 0.75,
                        height: widget.cardSize.height * 0.75,
                      ),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          width: widget.cardSize.width * 0.7,
                          height: widget.cardSize.height * 0.7,
                          child: _buildImage(),
                        ),
                        Positioned(
                            bottom: 0 + widget.cardSize.width * 0.017 * 6,
                            right: 0 - widget.cardSize.width * 0.017 * 3,
                            child: Transform.rotate(
                              angle: 90 * pi / 180,
                              child: Column(
                                children: [
                                  Text(dateOFPic,
                                      style: TextStyle(
                                          fontFamily: 'DS-DIGI',
                                          color: Colors.yellow,
                                          fontSize:
                                              widget.cardSize.width * 0.017)),
                                ],
                              ),
                            ))
                      ],
                    ),
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
          Positioned(
              top: widget.cardSize.height * 0.5,
              left: widget.cardSize.width * 0.88,
              child: Transform.rotate(
                angle: 90 * pi / 180,
                child: Column(
                  children: [
                    Text(shutterSpeed,
                        style: TextStyle(
                            fontFamily: 'Open-Sans',
                            fontSize: widget.cardSize.width * 0.02)),
                    Text(aperture,
                        style: TextStyle(
                            fontFamily: 'Open-Sans',
                            fontSize: widget.cardSize.width * 0.02)),
                  ],
                ),
              )),
        ],
      )),
    );
  }

  Widget _buildImage() {
    return Image.memory(
      image,
      fit: BoxFit.contain,
    );
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
