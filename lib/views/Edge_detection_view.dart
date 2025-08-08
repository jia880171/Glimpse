import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum CropShape {
  rectangle,
  roundedRectangle,
  circle,
  square,
  roundedSquare,
}

class EdgeDetectionPage extends StatefulWidget {
  const EdgeDetectionPage({super.key});

  @override
  State<EdgeDetectionPage> createState() => _EdgeDetectionPageState();
}

class _EdgeDetectionPageState extends State<EdgeDetectionPage> {
  String? detectedPath;
  File? detectedImage;
  Offset cropCenter = const Offset(200, 200);
  double cropRadius = 100;
  CropShape? selectedShape;

  Future<void> detectEdges() async {
    final directory = await getTemporaryDirectory();
    final path = p.join(directory.path, 'edge_detected_${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      bool success = await EdgeDetection.detectEdge(path);

      if (success && mounted) {
        setState(() {
          detectedPath = path;
          detectedImage = File(path);
        });
      }
    } catch (e) {
      print('Edge detection error: $e');
    }
  }

  Future<ui.Image> decodeImage(File file) async {
    final bytes = await file.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  List<Widget> buildIconWidgets(double iconSize) {
    return CropShape.values.map((shape) {
      final isSelected = selectedShape == shape;
      final widthFactor = (shape == CropShape.rectangle || shape == CropShape.roundedRectangle) ? 0.78 : 1.0;
      BorderRadius borderRadius;
      switch (shape) {
        case CropShape.rectangle:
        case CropShape.square:
          borderRadius = BorderRadius.zero;
          break;
        case CropShape.roundedRectangle:
        case CropShape.roundedSquare:
          borderRadius = BorderRadius.circular(iconSize * 0.1);
          break;
        case CropShape.circle:
          borderRadius = BorderRadius.circular(iconSize);
          break;
      }

      return GestureDetector(
        onTap: () => setState(() => selectedShape = shape),
        child: SizedBox(
          height: iconSize,
          width: iconSize * widthFactor,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.red : Colors.black,
                width: 2,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> previewCroppedImage() async {
    if (detectedImage == null) return;
    final croppedBytes = await _cropImage();
    if (croppedBytes == null) return;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("裁切預覽", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Image.memory(croppedBytes),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("關閉")),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> saveAndReturn() async {
    if (detectedImage == null) return;
    final croppedBytes = await _cropImage();
    if (croppedBytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final savedPath = p.join(directory.path, 'scanned_${DateTime.now().millisecondsSinceEpoch}.png');
    final file = File(savedPath);
    await file.writeAsBytes(croppedBytes);

    if (mounted) Navigator.pop(context, savedPath);
  }

  Future<Uint8List?> _cropImage() async {
    if (detectedImage == null) return null;

    final bytes = await detectedImage!.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final original = frame.image;

    // 螢幕顯示區域（跟圖片顯示一致，0.6 是圖片顯示比例）
    final displaySize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * 0.6,
    );

    final imageSize = Size(
      original.width.toDouble(),
      original.height.toDouble(),
    );

    final fitted = applyBoxFit(BoxFit.contain, imageSize, displaySize);
    final renderSize = fitted.destination;
    final dx = (displaySize.width - renderSize.width) / 2;
    final dy = (displaySize.height - renderSize.height) / 2;
    final renderScale = renderSize.width / imageSize.width;

    // 對應 crop 座標到圖像原始座標
    final scaledCenter = Offset(
      (cropCenter.dx - dx) / renderScale,
      (cropCenter.dy - dy) / renderScale,
    );
    final scaledRadius = cropRadius / renderScale;

    final rect = Rect.fromCenter(
      center: scaledCenter,
      width: (selectedShape == CropShape.rectangle || selectedShape == CropShape.roundedRectangle)
          ? scaledRadius * 2 * 0.78
          : scaledRadius * 2,
      height: scaledRadius * 2,
    );

    final path = Path();
    switch (selectedShape ?? CropShape.circle) {
      case CropShape.circle:
        path.addOval(Rect.fromCircle(center: scaledCenter, radius: scaledRadius));
        break;
      case CropShape.rectangle:
      case CropShape.square:
        path.addRect(rect);
        break;
      case CropShape.roundedRectangle:
      case CropShape.roundedSquare:
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(scaledRadius * 0.2)));
        break;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    canvas.clipPath(path);
    canvas.drawImage(original, Offset.zero, paint);

    final cropped = await recorder.endRecording().toImage(original.width, original.height);
    final pngBytes = await cropped.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes?.buffer.asUint8List();
  }


  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.height * 0.05;
    final iconWidgets = buildIconWidgets(iconSize);

    return Scaffold(
      appBar: AppBar(title: const Text('Edge Detection')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(onPressed: detectEdges, child: const Text('Detect Edges')),
            if (detectedImage != null)
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: FutureBuilder<ui.Image>(
                      future: decodeImage(detectedImage!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                        final image = snapshot.data!;
                        final displaySize = Size(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height * 0.6,
                        );
                        final fitted = applyBoxFit(
                          BoxFit.contain,
                          Size(image.width.toDouble(), image.height.toDouble()),
                          displaySize,
                        );
                        final renderSize = fitted.destination;
                        final dx = (displaySize.width - renderSize.width) / 2;
                        final dy = (displaySize.height - renderSize.height) / 2;

                        return Stack(
                          children: [
                            Positioned(
                              left: dx,
                              top: dy,
                              width: renderSize.width,
                              height: renderSize.height,
                              child: Image.file(detectedImage!, fit: BoxFit.contain),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              width: displaySize.width,
                              height: displaySize.height,
                              child: GestureDetector(
                                onScaleUpdate: (details) {
                                  setState(() {
                                    cropCenter += details.focalPointDelta;
                                    cropRadius *= (1 + (details.scale - 1) * 0.05);
                                    cropRadius = cropRadius.clamp(30.0, 500.0);
                                  });
                                },
                                child: CustomPaint(
                                  painter: CropShapePainter(
                                    center: cropCenter,
                                    radius: cropRadius,
                                    shape: selectedShape ?? CropShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: iconSize,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: iconWidgets.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: iconWidgets[index],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: previewCroppedImage, child: const Text('預覽')),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: saveAndReturn, child: const Text('儲存並返回')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class CropShapePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final CropShape shape;

  CropShapePainter({required this.center, required this.radius, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path;

    switch (shape) {
      case CropShape.circle:
        path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
        break;
      case CropShape.rectangle:
        path = Path()
          ..addRect(Rect.fromCenter(center: center, width: radius * 2 * 0.78, height: radius * 2));
        break;
      case CropShape.roundedRectangle:
        path = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: center, width: radius * 2 * 0.78, height: radius * 2),
              Radius.circular(radius * 0.2)));
        break;
      case CropShape.square:
        path = Path()..addRect(Rect.fromCenter(center: center, width: radius * 2, height: radius * 2));
        break;
      case CropShape.roundedSquare:
        path = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
              Radius.circular(radius * 0.2)));
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}