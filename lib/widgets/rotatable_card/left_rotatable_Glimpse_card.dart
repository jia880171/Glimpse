import 'dart:math';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/widgets/rotatable_card/rotatable_Glimpse_card_front_view.dart';
import 'package:isar/isar.dart';

class LeftRotatableGlimpseCard extends StatefulWidget {
  final Alignment rotationAlignment;
  final Uint8List image;
  final Map<String?, IfdTag> exifData;
  final String imagePath;
  final Color backLight;
  final bool isNeg;
  final int index;
  final Size cardSize;
  final Size widgetSize;
  final Function leaveCardMode;
  final double? rotationOverride;
  final bool interactive;

  const LeftRotatableGlimpseCard({
    Key? key,
    required this.image,
    required this.exifData,
    required this.imagePath,
    required this.backLight,
    this.index = 0,
    required this.isNeg,
    required this.cardSize,
    required this.leaveCardMode,
    required this.rotationAlignment,
    required this.widgetSize,
    this.rotationOverride,
    required this.interactive,
  }) : super(key: key);

  @override
  LeftRotatableGlimpseCardState createState() =>
      LeftRotatableGlimpseCardState();
}

class LeftRotatableGlimpseCardState extends State<LeftRotatableGlimpseCard>
    with SingleTickerProviderStateMixin {
  Glimpse? _glimpse;

  ui.Image? processedImage;

  double _rotationY = 0.0; // 當前旋轉角度
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000000),
    );

    _controller.addListener(() {
      setState(() {
        _rotationY += _animation.value;
      });
    });

    _controller.addStatusListener((status) {});

    loadGlimpse();

    _processImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> loadGlimpse() async {
    // Get the single shared Isar instance.
    final isar = DatabaseService.isar;

    final glimpse = await isar.glimpses
        .filter()
        .photoPathEqualTo(widget.imagePath)
        .findFirst();

    if (glimpse != null) {
      setState(() {
        _glimpse = glimpse;
      });
    }
  }

  void _startInertiaAnimation(double velocity) {
    const friction = 0.39; // 阻力係數
    final initialVelocity = velocity * 0.00008;

    double distance =
        -velocity.sign * initialVelocity * initialVelocity / (2 * friction);

    _animation = Tween<double>(begin: 0.0, end: distance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward(from: 0.0);
  }

  Widget _buildFront() {
    return SizedBox(
      child: RotatableGlimpseCardFrontView(
          index: widget.index,
          cardSize: widget.cardSize,
          image: widget.image,
          // imagePath: widget.imagePath,
          exifData: widget.exifData,
          backLight: widget.backLight,
          isNeg: widget.isNeg,
          leaveCardMode: widget.leaveCardMode,
          processedImage: processedImage),
    );
  }

  Widget _buildBack() {
    return SizedBox(
      // child: RotatableGlimpseCardBackView(
      //   cardSize: widget.cardSize,
      //   imagePath: widget.imagePath,
      //   glimpse: _glimpse,
      //   exifData: widget.exifData,
      // ),

      child: Card(
        child: Container(
          width: widget.cardSize.width,
          height: widget.cardSize.height,
          child: Text(widget.index.toString()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double rotationY = widget.rotationOverride ?? 0;
    final bool isFront = cos(rotationY) >= 0;
    final bool isFlipped =
        widget.rotationAlignment == Alignment.centerLeft && !isFront;

    final Alignment dynamicAlignment =
    isFlipped ? Alignment.centerRight : widget.rotationAlignment;

    final double rotationAngle = isFront ? rotationY : rotationY + pi;

    final transformedCard = Transform(
      alignment: dynamicAlignment,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotationAngle),
      child: isFront ? _buildFront() : _buildBack(),
    );

    return SizedBox(
      width: widget.widgetSize.width,
      height: widget.widgetSize.height,
      child: Stack(
        children: [
          Positioned(
            left: isFlipped
                ? widget.widgetSize.width / 2 - widget.cardSize.width
                : widget.widgetSize.width / 2,
            top: (widget.widgetSize.height - widget.cardSize.height) / 2,
            width: widget.cardSize.width,
            height: widget.cardSize.height,
            child: transformedCard,
          ),
        ],
      ),
    );
  }


  Future<void> _processImage() async {
    final rawImage = await decodeAndRotateIfNeeded(widget.image);
    setState(() {
      processedImage = rawImage;
    });
  }

  Widget _buildTransformedCard() {
    final isFront = cos(_rotationY) >= 0;
    final bool isFlipped =
        widget.rotationAlignment == Alignment.centerLeft && !isFront;

    final Alignment dynamicAlignment =
    isFlipped ? Alignment.centerRight : widget.rotationAlignment;

    final double rotationAngle = isFront ? _rotationY : _rotationY + pi;

    return Transform(
      alignment: dynamicAlignment,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotationAngle),
      child: isFront ? _buildFront() : _buildBack(),
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
}
