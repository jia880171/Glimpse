import 'dart:math' as math;

import 'package:flutter/material.dart';

class SemiCirclePointerGauge extends StatefulWidget {
  final bool isRight;
  final Color backgroundColor;
  final String currentValue;
  final List<String> items;
  final List<String> itemsToDisplay;
  final double radius;

  const SemiCirclePointerGauge({
    super.key,
    required this.currentValue,
    required this.items,
    required this.radius,
    required this.backgroundColor,
    required this.isRight,
    required this.itemsToDisplay,
  });

  @override
  State<SemiCirclePointerGauge> createState() => _SemiCirclePointerGaugeState();
}

class _SemiCirclePointerGaugeState extends State<SemiCirclePointerGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _animatedIndex;

  final strongVersionEaseOutBack =
      const Cubic(0.175, 0.885, 0.320, 1.5); // 增強版 easeOutBack

  @override
  void initState() {
    super.initState();
    _animatedIndex = _getIndexForValue(widget.currentValue).toDouble();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween<double>(
      begin: _animatedIndex,
      end: _animatedIndex,
    ).animate(
        CurvedAnimation(parent: _controller, curve: strongVersionEaseOutBack));
  }

  @override
  void didUpdateWidget(covariant SemiCirclePointerGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      final newIndex = _getIndexForValue(widget.currentValue).toDouble();
      _animation = Tween<double>(
        begin: _animatedIndex,
        end: newIndex,
      ).animate(
          CurvedAnimation(parent: _controller, curve: strongVersionEaseOutBack))
        ..addListener(() {
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
    return Align(
      alignment: widget.isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: widget.radius,
        height: widget.radius * 2,
        child: Transform(
          alignment: Alignment.center,
          transform:
              widget.isRight ? Matrix4.identity() : Matrix4.rotationY(math.pi),
          child: CustomPaint(
            painter: _RightSemiCirclePainter(
                isRight: widget.isRight,
                animatedIndex: _animatedIndex,
                itemLength: widget.items.length,
                backgroundColor: widget.backgroundColor,
                items: widget.items,
                itemsToDisplay: widget.itemsToDisplay),
          ),
        ),
      ),
    );
  }

  int _getIndexForValue(String value) {
    return findClosestIndex(widget.items, value);
  }

  int findClosestIndex(List<String> items, String value) {

    double? parse(String val) {
      val = val.replaceAll('"', '').trim();
      if (val.startsWith('f/')) {
        return double.tryParse(val.replaceFirst('f/', ''));
      } else if (val.contains('/')) {
        final parts = val.split('/');
        final numerator = double.tryParse(parts[0]);
        final denominator = double.tryParse(parts[1]);
        if (numerator == null || denominator == null || denominator == 0)
          return null;
        return numerator / denominator;
      } else {
        return double.tryParse(val);
      }
    }

    final target = parse(value);
    if (target == null) return 0;

    double minDiff = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final parsed = parse(items[i]);
      if (parsed == null) continue;
      final diff = (parsed - target).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }

    return closestIndex;
  }
}

class _RightSemiCirclePainter extends CustomPainter {
  final List<String> items;
  final List<String> itemsToDisplay;
  final bool isRight;
  final double animatedIndex;
  final int itemLength;
  final Color backgroundColor;

  _RightSemiCirclePainter({
    required this.items,
    required this.itemsToDisplay,
    required this.isRight,
    required this.animatedIndex,
    required this.itemLength,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(0, size.height / 2);
    final radius = size.height / 2;
    final tickRadius = radius * 0.86;
    final double tickLength = radius * 0.1;

    final greyArcWidth = tickLength * 0.6;
    final greyArcRadius = tickRadius - greyArcWidth * 0.5;

    _drawArc(canvas, center, radius * 0.9, Colors.black, radius * 0.03);

    _drawArc(canvas, center, greyArcRadius, Colors.grey.withOpacity(0.68),
        greyArcWidth);

    _drawTicks(canvas, center, tickRadius, backgroundColor, tickLength);

    _drawNeedle(canvas, center, radius);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, Color color,
      double strokeWidth) {
    final Paint paintArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, math.pi / 2, -math.pi, false, paintArc);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius,
      Color backgroundColor, double tickLength) {
    if (itemLength < 1) return; // 👈 防止除以零或無意義繪製

    final Paint tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final Paint tickGapPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 3;

    double labelDistance = -tickLength * 2.4; // label 距離刻度的距離

    for (int i = 0; i < itemLength; i++) {
      final angle = itemLength > 1 ? math.pi * i / (itemLength - 1) : 0;

      final double baseAngle = math.pi / 2 - angle;
      final dx = math.cos(baseAngle);
      final dy = -math.sin(baseAngle);

      final outer = center + Offset(radius * dx, radius * dy);
      final inner = center +
          Offset((radius - tickLength) * dx, (radius - tickLength) * dy);

      // 畫背景隙縫與刻度線
      canvas.drawLine(inner, outer, tickGapPaint);
      canvas.drawLine(inner, outer, tickPaint);

      final double fontSize =
          items[i].length > 5 ? tickLength * 0.8 : tickLength * 0.9;

      final TextStyle textStyle = TextStyle(
        color: Colors.black,
        fontSize: fontSize,
      );

      // 畫文字標籤
      final labelOffset = center +
          Offset((radius + labelDistance) * dx, (radius + labelDistance) * dy);

      final textSpan = TextSpan(text: itemsToDisplay[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final labelCenter =
          labelOffset - Offset(textPainter.width / 2, textPainter.height / 2);

      if (i % 2 == 0) {
        if (isRight) {
          textPainter.paint(canvas, labelCenter);
        } else {
          // 文字翻轉處理
          canvas.save();
          canvas.translate(labelCenter.dx + textPainter.width / 2,
              labelCenter.dy + textPainter.height / 2);
          canvas.scale(-1, 1); // 水平翻轉
          canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
          textPainter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    if (itemLength < 1) return; // 👈 沒有必要畫針
    double clampedIndex = 0;
    double angle = 0;

    if (itemLength > 1) {
      clampedIndex = animatedIndex.clamp(0, itemLength - 1);
      angle = math.pi * clampedIndex / (itemLength - 1);
    }
    final double frontLength = radius * 0.6;
    final double backLength = radius * 0.2;

    final dx = math.cos(math.pi / 2 - angle);
    final dy = -math.sin(math.pi / 2 - angle);

    final frontTip = center + Offset(dx * frontLength, dy * frontLength);
    final backTip = center - Offset(dx * backLength, dy * backLength);

    final needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    canvas.drawLine(backTip, frontTip, needlePaint);

    final dotRadius = radius * 0.06;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final shadowOffset = isRight
        ? Offset(dotRadius * 0.5, dotRadius * 0.5)
        : Offset(-dotRadius * 0.5, dotRadius * 0.5);

    canvas.drawCircle(center + shadowOffset, dotRadius * 1.01, shadowPaint);

    final centerDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotRadius, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _RightSemiCirclePainter oldDelegate) =>
      animatedIndex != oldDelegate.animatedIndex ||
      itemLength != oldDelegate.itemLength ||
      backgroundColor != oldDelegate.backgroundColor;
}
