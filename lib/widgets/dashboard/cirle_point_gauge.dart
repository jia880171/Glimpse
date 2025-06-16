import 'dart:math' as math;

import 'package:flutter/material.dart';

class CirclePointerGauge extends StatefulWidget {
  final Color backgroundColor;
  final int currentIndex;
  final int itemLength;
  final double radius;

  const CirclePointerGauge({
    super.key,
    required this.currentIndex,
    required this.itemLength,
    required this.radius,
    required this.backgroundColor,
  });

  @override
  State<CirclePointerGauge> createState() => _CirclePointerGaugeState();
}

class _CirclePointerGaugeState extends State<CirclePointerGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _animatedIndex;

  final strongVersionEaseOutBack =
      const Cubic(0.175, 0.885, 0.320, 1.5); // 增強版 easeOutBack

  @override
  void initState() {
    super.initState();
    _animatedIndex = widget.currentIndex.toDouble();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween<double>(
      begin: _animatedIndex,
      end: _animatedIndex,
    ).animate(
      CurvedAnimation(parent: _controller, curve: strongVersionEaseOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant CirclePointerGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      final newIndex = widget.currentIndex.toDouble();
      _animation = Tween<double>(
        begin: _animatedIndex,
        end: newIndex,
      ).animate(
        CurvedAnimation(parent: _controller, curve: strongVersionEaseOutBack),
      )..addListener(() {
          setState(() {
            _animatedIndex = _animation.value;
          });
        });

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: CustomPaint(
        painter: _FullCirclePainter(
          animatedIndex: _animatedIndex,
          itemLength: widget.itemLength,
          backgroundColor: widget.backgroundColor,
        ),
      ),
    );
  }
}

class _FullCirclePainter extends CustomPainter {
  final double animatedIndex;
  final int itemLength;
  final Color backgroundColor;

  _FullCirclePainter({
    required this.animatedIndex,
    required this.itemLength,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final arcRadius = radius * 0.8;
    final innerArcRadius = arcRadius * 0.88;
    double tickLength = arcRadius - innerArcRadius;

    // outer arc
    _drawArc(canvas, center, arcRadius, Colors.black, radius * 0.02);

    // inner arc
    _drawArc(canvas, center, innerArcRadius, Colors.black, radius * 0.02);

    _drawTicks(canvas, center, arcRadius, innerArcRadius, tickLength,
        radius * 0.02, backgroundColor);

    _drawNeedle(canvas, center, arcRadius * 0.6);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, Color color,
      double strokeWidth) {
    final Paint paintArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, paintArc);
  }

  void _drawTicks(
      Canvas canvas,
      Offset center,
      double outerArcRadius,
      double innerArcRadius,
      double tickLength,
      double tickWidth,
      Color backgroundColor) {
    if (itemLength < 1) return;

    for (int i = 0; i < itemLength; i++) {
      final angle = 2 * math.pi * i / itemLength;

      final outerX = center.dx + outerArcRadius * math.cos(angle);
      final outerY = center.dy + outerArcRadius * math.sin(angle);

      final innerX = center.dx + (innerArcRadius) * math.cos(angle);
      final innerY = center.dy + (innerArcRadius) * math.sin(angle);

      final double currentTickWidth = ((i+1) % 5 == 0) ? tickWidth * 2.5 : tickWidth;

      final Paint tickPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = currentTickWidth;

      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);

      // ➕畫數字
      final fontSize = outerArcRadius * 0.2;
      final labelRadius = outerArcRadius + fontSize * 0.8;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);
      final labelOffset = Offset(labelX, labelY);

      final textSpan = TextSpan(
        text: (i + 1) % 2 != 0 ? (i + 1).toString() : '',
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
        ),
      );

      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      // 將文字中心對齊圓點位置
      final offset = labelOffset - Offset(tp.width / 2, tp.height / 2);
      tp.paint(canvas, offset);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    if (itemLength < 1) return; // 👈 沒有必要畫針
    final clampedIndex = animatedIndex.clamp(0, itemLength - 1);
    final angle = 2 * math.pi * clampedIndex / itemLength;
    final double frontLength = radius * 0.6;
    final double backLength = radius * 0.2;

    final dx = math.cos(angle);
    final dy = math.sin(angle);

    final frontTip = center + Offset(dx * frontLength, dy * frontLength);
    final backTip = center - Offset(dx * backLength, dy * backLength);

    final needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = radius * 0.06;

    canvas.drawLine(backTip, frontTip, needlePaint);

    final dotRadius = radius * 0.06;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final shadowOffset = Offset(dotRadius * 0.5, dotRadius * 0.5);
    canvas.drawCircle(center + shadowOffset, dotRadius * 1.01, shadowPaint);

    final centerDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotRadius, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _FullCirclePainter oldDelegate) =>
      animatedIndex != oldDelegate.animatedIndex ||
      itemLength != oldDelegate.itemLength ||
      backgroundColor != oldDelegate.backgroundColor;
}
