import 'dart:math';

import 'package:flutter/material.dart';

class JaggedCircle extends StatelessWidget {
  final double radius;
  final double innerRadius;
  final Color color;
  final int toothCount;

  const JaggedCircle({
    super.key,
    required this.radius,
    required this.color,
    this.toothCount = 30,
    required this.innerRadius, // 鋸齒數量
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: JaggedCirclePainter(
        radius: radius,
        color: color,
        toothCount: toothCount,
        innerRadius: innerRadius,
      ),
    );
  }
}

class JaggedCirclePainter extends CustomPainter {
  final double radius;
  final Color color;
  final int toothCount;
  final double innerRadius;

  JaggedCirclePainter({
    required this.innerRadius,
    required this.radius,
    required this.color,
    required this.toothCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(radius, radius);
    final outerRadius = radius;
    final angleStep = 2 * pi / toothCount;

    final path = Path();

    for (int i = 0; i < toothCount; i++) {
      final angle = i * angleStep;
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
