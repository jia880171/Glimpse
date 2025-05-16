import 'dart:math';
import 'package:flutter/material.dart';

class CircularTextDemo extends StatelessWidget {
  final String text;
  final double radius;
  final double fontSize;
  final Color color;
  final double size;
  final double opacity;

  const CircularTextDemo({
    super.key,
    required this.text,
    this.radius = 66,
    this.fontSize = 14,
    this.color = Colors.black,
    this.size = 160,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircularTextPainter(
          text: text,
          radius: radius,
          fontSize: fontSize,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}

class CircularTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final double textAngleSpacing;
  final double fontSize;
  final Color color;


  CircularTextPainter({
    required this.text,
    required this.color,
    required this.fontSize,
    this.radius = 66,
    this.textAngleSpacing = 15, // 每個字的角度間距（度）
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 畫圓
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // 畫字
    final anglePerChar = textAngleSpacing * pi / 180;
    final totalAngle = anglePerChar * text.length;
    final startAngle = -totalAngle / 2;

    for (int i = 0; i < text.length; i++) {
      final charAngle = startAngle + i * anglePerChar;
      final x = center.dx + radius * 0.8 * cos(charAngle);
      final y = center.dy + radius * 0.8 * sin(charAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: text[i],
          style: TextStyle(
            fontSize: fontSize,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(charAngle + pi / 2); // 調整字體垂直於圓
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
