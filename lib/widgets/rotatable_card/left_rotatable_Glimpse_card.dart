import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/widgets/rotatable_card/receipt.dart';
import 'package:glimpse/widgets/rotatable_card/rotatable_Glimpse_card_front_view.dart';

import '../../models/receipt.dart';
import '../../services/glimpse_service.dart';

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
  final bool isAnyCardAnimating;
  final Function setCardAnimationState;
  final Function(bool fromPrevious, int draggingIndex) setDraggingContext;
  final Function(
      bool flippedForward,
      bool isDsetIsDraggingPreviousPageraggingPreviousPage,
      int index)? onFlipCompleted;
  final bool isPrevious;
  final bool isSecondPrevious;
  final bool isCurrent;
  final Glimpse glimpse;
  final Receipt? receipt;

  const LeftRotatableGlimpseCard({
    Key? key,
    required this.image,
    required this.exifData,
    required this.imagePath,
    required this.backLight,
    required this.index,
    required this.isNeg,
    required this.cardSize,
    required this.leaveCardMode,
    required this.rotationAlignment,
    required this.widgetSize,
    this.onFlipCompleted,
    required this.isPrevious,
    required this.isCurrent,
    required this.setDraggingContext,
    required this.isSecondPrevious,
    required this.isAnyCardAnimating,
    required this.setCardAnimationState,
    required this.glimpse,
    this.receipt,
  }) : super(key: key);

  @override
  State<LeftRotatableGlimpseCard> createState() =>
      _LeftRotatableGlimpseCardState();
}

class _LeftRotatableGlimpseCardState extends State<LeftRotatableGlimpseCard>
    with SingleTickerProviderStateMixin {
  late Glimpse? _glimpse;
  Receipt? _receipt;
  ui.Image? processedImage;
  double _rotationY = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  double dragAccumulated = 0;
  bool isDraggingPreviousPage = false;
  bool didFlipPage = false; // 不論是正翻還是逆翻
  Uint8List? _scannedImageBytes;

  @override
  void initState() {
    super.initState();

    if (widget.isPrevious || widget.isSecondPrevious) {
      _rotationY = pi;
    }

    _glimpse = widget.glimpse;
    _receipt = widget.receipt;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _controller.addListener(() {
      setState(() {
        _rotationY = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.setCardAnimationState(false);
        widget.onFlipCompleted
            ?.call(didFlipPage, isDraggingPreviousPage, widget.index);
        setState(() {
          dragAccumulated = 0;
        });
      }
    });

    // loadGlimpseWithReceipt();

    _loadScannedImage();
    _processImage();
  }

  Future<void> _loadScannedImage() async {
    if (_glimpse?.scannedImagePath != null) {
      try {
        final file = File(_glimpse!.scannedImagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          setState(() {
            _scannedImageBytes = bytes;
          });
        }
      } catch (_) {
        // 讀檔失敗就不顯示圖片
      }
    }
  }


  Future<void> loadGlimpseWithReceipt() async {
    final service = GlimpseService(DatabaseService.isar);
    final glimpse = await service.getGlimpseByPhotoPath(widget.imagePath);

    if (glimpse != null) {
      await glimpse.receipt.load();
      final receipt = glimpse.receipt.value;

      Uint8List? scannedImageBytes;
      if (glimpse.scannedImagePath != null) {
        try {
          final file = File(glimpse.scannedImagePath!);
          if (await file.exists()) {
            scannedImageBytes = await file.readAsBytes();
          }
        } catch (_) {
          // 讀檔失敗就不顯示圖片
        }
      }

      setState(() {
        _glimpse = glimpse;
        _receipt = receipt;
        _scannedImageBytes = scannedImageBytes;
      });
    }
  }

  Future<void> _processImage() async {
    final rawImage = await decodeAndRotateIfNeeded(widget.image);
    setState(() {
      processedImage = rawImage;
    });
  }

  Future<ui.Image> decodeAndRotateIfNeeded(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    if (image.width > image.height) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final rotatedWidth = image.height.toDouble();
      final rotatedHeight = image.width.toDouble();

      canvas.translate(rotatedWidth, 0);
      canvas.rotate(90 * pi / 180);
      canvas.drawImage(image, Offset.zero, Paint());

      final picture = recorder.endRecording();
      return await picture.toImage(rotatedWidth.toInt(), rotatedHeight.toInt());
    }

    return image;
  }

  Widget _buildFront() {
    return SizedBox(
      width: widget.cardSize.width,
      height: widget.cardSize.height,
      child: Stack(
        children: [
          RotatableGlimpseCardFrontView(
            index: widget.index,
            cardSize: widget.cardSize,
            image: widget.image,
            exifData: widget.exifData,
            backLight: widget.backLight,
            isNeg: widget.isNeg,
            leaveCardMode: widget.leaveCardMode,
            processedImage: processedImage,
            isPlastic: true,
            noX: true,
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Opacity(
                opacity: 0.068,
                child: Image.asset(
                  'assets/images/plastic_overlay2.png',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.screen,
                  color: Colors.white.withOpacity(0.0),
                ),
              ),
            ),
          ),
          // blur
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.01),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return SizedBox(
        width: widget.cardSize.width,
        height: widget.cardSize.height,
        child: Stack(
          children: [
            LeftRotatableBackCardWidget(
              cardSize: widget.cardSize,
              glimpse: _glimpse,
              receipt: _receipt,
              scannedImageBytes: _scannedImageBytes,
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Opacity(
                  opacity: 0.068,
                  child: Image.asset(
                    'assets/images/plastic_overlay2.png',
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.screen,
                    color: Colors.white.withOpacity(0),
                  ),
                ),
              ),
            ),

            // blur
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.01),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
                top: 0, right: widget.cardSize.width * 0.1, child: sticker())
          ],
        ));
  }

  Widget sticker() {
    final stickerHeight = widget.cardSize.height * 0.3;
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      color: const Color(0xFFE2D9CE),
      child: Container(
        height: widget.cardSize.height * 0.2,
        child: Column(
          children: [
            Spacer(),
            Container(
              width: widget.cardSize.width * 0.25,
              height: stickerHeight * 0.38,
              child: Center(
                child: Transform.rotate(
                  angle: 3.5 * pi / 180,
                  child: Text(
                    'Glimpse\nPack.',
                    style: TextStyle(
                        fontFamily: 'Jura',
                        fontSize: widget.cardSize.height * 0.02,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: widget.cardSize.width * 0.25,
              height: stickerHeight * 0.12,
              child: Divider(
                endIndent: 5,
                indent: 5,
                color: Colors.black.withOpacity(0.3), // 調整顏色
                thickness: widget.cardSize.height * 0.001,
              ),
            ),
            Text(
              'Limited',
              style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: stickerHeight * 0.06,
                  color: Colors.black),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFront = cos(_rotationY) >= 0;
    final isFlipped =
        widget.rotationAlignment == Alignment.centerLeft && !isFront;
    final Alignment dynamicAlignment =
        isFlipped ? Alignment.centerRight : widget.rotationAlignment;
    final double rotationAngle = isFront ? _rotationY : _rotationY + pi;

    final transformedCard = Transform(
      alignment: dynamicAlignment,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotationAngle),
      child: isFront ? _buildFront() : _buildBack(),
    );

    return Positioned(
      left: isFlipped
          ? widget.widgetSize.width / 2 - widget.cardSize.width
          : widget.widgetSize.width / 2,
      top: (widget.widgetSize.height - widget.cardSize.height) / 2,
      width: widget.cardSize.width,
      height: widget.cardSize.height,
      child: GestureDetector(
        onHorizontalDragStart: onHorizontalDragStart,
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        onHorizontalDragEnd: onHorizontalDragEnd,
        child: transformedCard,
      ),
    );
  }

  void onHorizontalDragStart(DragStartDetails details) {
    final touchX = details.globalPosition.dx;
    final screenWidth = widget.widgetSize.width;

    if (!widget.isAnyCardAnimating) {
      isDraggingPreviousPage = touchX < screenWidth / 2;
    }

    widget.setDraggingContext(isDraggingPreviousPage, widget.index);
    if (isDraggingPreviousPage) {
      dragAccumulated = pi;
    }
  }

  void onHorizontalDragUpdate(details) {
    if (!widget.isCurrent && !widget.isPrevious) {
      // 非當下 非之前
      return;
    } else if (widget.isAnyCardAnimating) {
      return;
    } else {
      if (isDraggingPreviousPage && widget.isPrevious) {
        // previous

        dragAccumulated += -(details.delta.dx) * 0.01;
        setState(() {
          _rotationY = dragAccumulated;
        });
      } else if (!isDraggingPreviousPage && widget.isCurrent) {
        // current

        dragAccumulated += details.delta.dx;
        final nextRotation = -dragAccumulated * 0.01;
        setState(() {
          _rotationY = nextRotation;
        });
      }
    }
  }

  void onHorizontalDragEnd(_) {
    dragAccumulated = 0;

    if (!widget.isCurrent && !widget.isPrevious) {
      return;
    }

    if (isDraggingPreviousPage) {
      // 翻上一張

      didFlipPage = _rotationY < pi / 2; // 翻回右半邊
      final targetAngle = didFlipPage ? 0.0 : pi;

      if (!_controller.isAnimating) {
        widget.setCardAnimationState(true);

        _animation = Tween<double>(
          begin: _rotationY,
          end: targetAngle,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ));

        _controller.forward(from: 0.0);
      }
    } else {
      // 翻當下
      didFlipPage = _rotationY > pi / 2; // 翻過中線
      final targetAngle = didFlipPage ? (_rotationY > 0 ? pi : -pi) : 0.0;

      if (!_controller.isAnimating) {
        widget.setCardAnimationState(true);

        _animation = Tween<double>(
          begin: _rotationY,
          end: targetAngle,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ));
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
