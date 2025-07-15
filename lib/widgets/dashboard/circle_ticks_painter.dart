import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircleTicksPainter extends CustomPainter {
  final List<String> items;
  final double arcRadius;
  final double tickWidth;
  final Color tickColor;
  final Color labelColor;

  CircleTicksPainter({
    required this.items,
    required this.arcRadius,
    this.tickWidth = 1.0,
    this.tickColor = Colors.black,
    this.labelColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (items.isEmpty) return;

    const angleOffset = -math.pi / 2; // 90度，逆時針方向（起始位置改為上方）

    for (int i = 0; i < items.length; i++) {
      final angle = 2 * math.pi * i / items.length + angleOffset;

      final fontSize = arcRadius * 0.2;
      final labelRadius = arcRadius + fontSize * 0.8;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);
      final labelOffset = Offset(labelX, labelY);

      final text = items[i][0];

      if (text.isNotEmpty) {
        final textSpan = TextSpan(
          text: text,
          style: TextStyle(
            color: labelColor,
            fontSize: fontSize,
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        final offset = labelOffset - Offset(tp.width / 2, tp.height / 2);
        tp.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(CircleTicksPainter oldDelegate) =>
      oldDelegate.items.length != items.length ||
          oldDelegate.arcRadius != arcRadius ||
          oldDelegate.tickWidth != tickWidth ||
          oldDelegate.tickColor != tickColor ||
          oldDelegate.labelColor != labelColor;
}
