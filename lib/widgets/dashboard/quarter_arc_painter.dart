import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class QuarterArcPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Color color;

  /// 起始角度（單位：度）
  final double startAngleDeg;

  /// 掃過角度（單位：度，正值順時針，負值逆時針）
  final double sweepAngleDeg;

  QuarterArcPainter({
    required this.radius,
    required this.strokeWidth,
    required this.color,
    required this.startAngleDeg,
    required this.sweepAngleDeg,
  });

  double degToRad(double degrees) {
    return degrees * math.pi / 180;
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// 箭頭方向角度（單位：度，通常 = start + sweep）
    double arrowDirectionDeg = startAngleDeg + sweepAngleDeg;

    final center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      degToRad(startAngleDeg),
      degToRad(sweepAngleDeg),
      false,
      paint,
    );

    // 箭頭
    double angle = degToRad(arrowDirectionDeg); // 箭頭方向：圓弧終點
    double arrowLength = radius * 0.1;
    const arrowAngle = math.pi / 3.14; // 箭頭開口角度

    final end = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final arrowP1 = Offset(
      end.dx + arrowLength * math.cos(angle - arrowAngle),
      end.dy + arrowLength * math.sin(angle - arrowAngle),
    );

    final arrowP2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(end, arrowP1, arrowPaint);
    canvas.drawLine(end, arrowP2, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
