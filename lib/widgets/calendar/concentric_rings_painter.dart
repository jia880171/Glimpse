import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/utils/time_utils.dart';
import '../../config.dart' as config;

class ConcentricRingsPainter extends CustomPainter {
  final Color ringColor;
  final Color ringBackgroundColor;
  final double strokeWidth;
  final double innerRatio; // 0~1 of outer radius
  final double? outerRadius; // nullable; if null, fit to available size
  final List<String> outerLabels;
  final List<String> innerLabels;
  final int daysInTargetMonth; // Number of tick divisions
  final int targetYear;
  final int targetMonth;
  final bool isMain;

  final Map<int, int> glimpseCountByDay;

  // ===== Ball orbit drawing inputs =====
  final bool ballEnabled;
  final Color ballColor;
  final double ballRadius;
  final double ballAngleDegrees; // current angle in degrees
  final double ballTrackRadiusFactor;

  ConcentricRingsPainter({
    required this.glimpseCountByDay,
    required this.targetYear,
    required this.targetMonth,
    required this.ringColor,
    required this.ringBackgroundColor,
    required this.strokeWidth,
    required this.innerRatio,
    required this.isMain,
    this.outerRadius,
    this.daysInTargetMonth = 12,
    List<String>? outerLabels,
    List<String>? innerLabels,
    this.ballEnabled = true,
    this.ballColor = Colors.white,
    this.ballRadius = 4.0,
    this.ballAngleDegrees = 0.0,
    this.ballTrackRadiusFactor = 1.0,
  })  : outerLabels = outerLabels ??
            const [
              '壹',
              '貳',
              '參',
              '肆',
              '伍',
              '陸',
              '柒',
              '捌',
              '玖',
              '拾',
              '拾壹',
              '拾貳',
              '拾參',
              '拾肆',
              '拾伍',
              '拾陸',
              '拾柒',
              '拾捌',
              '拾玖',
              '貳拾',
              '貳拾壹',
              '貳拾貳',
              '貳拾參',
              '貳拾肆',
              '貳拾伍',
              '貳拾陸',
              '貳拾柒',
              '貳拾捌',
              '貳拾玖',
              '參拾',
              '參拾壹',
            ],
        innerLabels = innerLabels ??
            const [
              '一',
              '二',
              '三',
              '四',
              '五',
              '六',
              '七',
              '八',
              '九',
              '十',
              '十一',
              '十二',
              '十三',
              '十四',
              '十五',
              '十六',
              '十七',
              '十八',
              '十九',
              '二十',
              '二十一',
              '二十二',
              '二十三',
              '二十四',
              '二十五',
              '二十六',
              '二十七',
              '二十八',
              '二十九',
              '三十',
              '三十一',
            ];

  final Color rimColorForMonth = config.floatBlue;
  int yearPointer = TimeUtils.currentYear;
  int monthPointer = TimeUtils.currentMonth;
  int dayPointer = TimeUtils.currentDay;

  @override
  void paint(Canvas canvas, Size size) {
    // Center.
    final Offset c = Offset(size.width / 2.0, size.height / 2.0);

    // Radii (outerRadius is required by current usage).
    final double outerR = outerRadius!;
    final double dateInnerR = outerR * innerRatio;
    final double monthInnerR = dateInnerR * 0.8;
    final double middleR = outerR - ((outerR - dateInnerR) * 0.2);

    // Ring paint.
    final Paint ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final Paint ringBackPaint = Paint()
      ..color = isMain
          ? ringBackgroundColor.withOpacity(0.368)
          : ringBackgroundColor.withOpacity(0.168)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (outerR - middleR)
      ..isAntiAlias = true;

    // Draw three concentric circles.
    canvas.drawCircle(c, middleR + (outerR - middleR) / 2, ringBackPaint);

    canvas.drawCircle(c, outerR, ringPaint);
    canvas.drawCircle(c, middleR, ringPaint);
    canvas.drawCircle(c, dateInnerR, ringPaint);
    canvas.drawCircle(c, monthInnerR, ringPaint);

    // Ticks. Start at top (12 o'clock).
    final double angleStep = 2.0 * math.pi / daysInTargetMonth;
    final double monthAngleStep = 2.0 * math.pi / 12;
    final double startAngle = -math.pi / 2.0;

    final Paint tickPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Text painter reused for all labels.
    final TextPainter tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    // Distances and font sizes for labels.
    final double labelDistance = (outerR - middleR) * 0.6;
    final double outerFontSize = (outerR - middleR) * 0.78;
    final double innerFontSize = (middleR - dateInnerR) * 0.1;

    // Current month (1~12) -> zero-based index (0~11).
    final int currentMonthIndex = TimeUtils.currentMonth - 1;
    final int currentDateIndex = TimeUtils.currentDay - 1;

    // draw month ticks
    drawMonthTicks(
      innerR: dateInnerR,
      startAngle: startAngle,
      monthAngleStep: monthAngleStep,
      c: c,
      monthR: monthInnerR,
      canvas: canvas,
      tickPaint: tickPaint,
      tp: tp,
      innerFontSize: innerFontSize,
      currentMonthIndex: currentMonthIndex,
      // highlightColor: rimColorForMonth,
      highlightColor: ringColor,
    );

    // draw month arc
    drawArcSegment(
      canvas: canvas,
      center: c,
      radius: monthInnerR,
      targetIndex: currentMonthIndex,
      color: config.trashPointerRed,
      strokeWidth: strokeWidth,
      gapRadians: 0.0,
      segments: 12,
    );

    drawDateBall(
      canvas: canvas,
      center: c,
      radius: dateInnerR,
      theta: getDateTheta(currentDateIndex),
      color: config.trashPointerRed,
      ballRadius: ballRadius * 1.68,
    );

    // draw date ticks
    drawDateTicks(
      innerR: dateInnerR,
      startAngle: startAngle,
      c: c,
      canvas: canvas,
      tickPaint: tickPaint,
      tp: tp,
      innerFontSize: innerFontSize,
      angleStep: angleStep,
      middleR: middleR,
      labelDistance: labelDistance,
      outerFontSize: outerFontSize,
      outerR: outerR,
      glimpseCountByDay: glimpseCountByDay,
    );

    // ===== Draw orbiting ball on outer track =====
    if (ballEnabled) {
      final double trackR =
          outerR * (ballTrackRadiusFactor <= 0.0 ? 0.0 : ballTrackRadiusFactor);
      final double thetaBall = (ballAngleDegrees * math.pi / 180.0);

      drawOrbitBall(
        canvas: canvas,
        center: c,
        radius: trackR,
        theta: thetaBall,
        color: ballColor,
        ballRadius: ballRadius,
      );
    }
  }

  double getDateTheta(int currentDateIndex) {
    // days & index (0-based)
    final int days = TimeUtils.daysInCurrentMonth;
    final int idx = currentDateIndex; // or用你現有的 currentDateIndex

    // angle config
    final double step = 2.0 * math.pi / days; // radians per day
    final double startBase = -math.pi / 2.0; // 12 o'clock

    // A) align to the day's tick boundary (exactly on the tick line)
    // final double dateTheta = startBase + idx * step;

    // B) align to the center of the day's segment (midpoint between two ticks)
    final double dateTheta = startBase + (idx + 0.5) * step;

    return dateTheta;
  }

  double getMonthTheta(int currentMonthIndex) {
    // days & index (0-based)
    final int months = 12;
    final int idx = currentMonthIndex; // or用你現有的 currentDateIndex

    // angle config
    final double step = 2.0 * math.pi / months; // radians per day
    final double startBase = -math.pi / 2.0; // 12 o'clock

    // A) align to the day's tick boundary (exactly on the tick line)
    // final double dateTheta = startBase + idx * step;

    // B) align to the center of the day's segment (midpoint between two ticks)
    final double monthTheta = startBase + (idx + 0.5) * step;

    return monthTheta;
  }

  void drawArcSegment({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required int segments, // 總分割數，例如 12 代表 12 等分
    required int targetIndex, // 要畫哪一段 (0-based index)
    required Color color,
    required double strokeWidth,
    double gapRadians = 0.0, // optional tiny gap
  }) {
    if (!isMain) {
      return;
    }

    // 安全處理 index 範圍
    int idx = targetIndex;
    if (idx < 0) idx = 0;
    if (idx >= segments) idx = segments - 1;

    // 每段角度
    final double step = 2.0 * math.pi / segments;
    final double startBase = -math.pi / 2.0; // 12 點鐘方向開始

    // 起始角度 = 基準角度 + index * step
    final double start = startBase + idx * step + gapRadians;
    // 弧度範圍 = step 減去兩側 gap
    final double sweep = step - (2.0 * gapRadians);
    if (sweep <= 0.0) return;

    // 繪製區域
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    // 畫筆
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(arcRect, start, sweep, false, p);
  }

  void drawDateTicks({
    required double startAngle,
    required double angleStep,
    required double middleR,
    required double outerR,
    required Offset c,
    required double innerR,
    required Canvas canvas,
    required Paint tickPaint,
    required double labelDistance,
    required TextPainter tp,
    required double outerFontSize,
    required double innerFontSize,
    required Map<int, int> glimpseCountByDay,
  }) {
    for (int i = 0; i < daysInTargetMonth; i++) {
      final double theta = startAngle + i * angleStep;

      // Tick endpoints (from middleR inward to innerR).
      final Offset pOuter = Offset(
        c.dx + (middleR - strokeWidth) * math.cos(theta),
        c.dy + (middleR - strokeWidth) * math.sin(theta),
      );
      final Offset pInner = Offset(
        c.dx + (innerR + strokeWidth) * math.cos(theta),
        c.dy + (innerR + strokeWidth) * math.sin(theta),
      );
      canvas.drawLine(pOuter, pInner, tickPaint);

      final double midTheta = theta + (angleStep / 2.0);

      // Outer label
      final double outerLabelBaseRadius = (middleR - strokeWidth);
      final double outerLabelRadius = outerLabelBaseRadius + labelDistance;
      final String textOuter = outerLabels[i % outerLabels.length];
      drawOuterLabel(
        canvas: canvas,
        textPainter: tp,
        center: c,
        radius: outerLabelRadius,
        // base ring + outward offset applied here
        theta: midTheta,
        text: textOuter,
        color: ringColor,
        // color: Colors.yellow.withOpacity(0.6),
        fontSize: outerFontSize,
      );

      // draw weekday
      final double weekdayMarkRadius = middleR - outerFontSize * 0.5;
      drawOuterLabel(
        canvas: canvas,
        textPainter: tp,
        center: c,
        radius: weekdayMarkRadius,
        theta: midTheta,
        text: TimeUtils.weekdayLabel(yearPointer, monthPointer, i + 1),
        // color: ringColor,
        color: isMain ? Colors.blue : Colors.blue.withOpacity(0.6),
        fontSize: outerFontSize * 0.7,
      );

      final double midRadius = innerR + ((middleR - innerR) * 0.5);
      final String textInner = innerLabels[i % innerLabels.length];
      drawInnerLabel(
        canvas: canvas,
        textPainter: tp,
        center: c,
        radius: midRadius,
        theta: midTheta,
        text: textInner,
        color: ringColor,
        fontSize: innerFontSize,
        glimpseCountByDay: glimpseCountByDay,
        dayNumber: i + 1,
      );
    }
  }

  void drawMonthTicks({
    required double innerR,
    required double startAngle,
    required double monthAngleStep,
    required Offset c,
    required double monthR,
    required Canvas canvas,
    required Paint tickPaint,
    required TextPainter tp,
    required double innerFontSize,
    required int currentMonthIndex,
    required Color highlightColor,
  }) {
    final Paint highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < 12; i++) {
      final double theta = startAngle + i * monthAngleStep;

      // Tick endpoints (from middleR inward to innerR).
      final Offset pOuter = Offset(
        c.dx + (innerR - strokeWidth) * math.cos(theta),
        c.dy + (innerR - strokeWidth) * math.sin(theta),
      );
      final Offset pInner = Offset(
        c.dx + (monthR + strokeWidth) * math.cos(theta),
        c.dy + (monthR + strokeWidth) * math.sin(theta),
      );

      final bool isBoundary =
          (i == currentMonthIndex) || (i == ((currentMonthIndex + 1) % 12));

      final Paint linePaint = isBoundary
          ? isMain
              ? highlightPaint
              : tickPaint
          : tickPaint;

      canvas.drawLine(pOuter, pInner, linePaint);

      final double midTheta = theta + (monthAngleStep / 2.0);
      final double midRadius = monthR + ((innerR - monthR) * 0.5);
      final String textInner = innerLabels[i % innerLabels.length];
      drawInnerLabel(
        canvas: canvas,
        textPainter: tp,
        center: c,
        radius: midRadius,
        theta: midTheta,
        text: textInner,
        color: ringColor,
        fontSize: innerFontSize,
      );
    }
  }

  /// Draw an outer label using absolute polar coordinates, same semantics as drawInnerLabel.
  void drawOuterLabel({
    required Canvas canvas,
    required TextPainter textPainter,
    required Offset center,
    required double radius,
    required double theta,
    required String text,
    required Color color,
    required double fontSize,
  }) {
    // if(!isMain){
    //   return;
    // }

    // Anchor point on the circle at (center + radius * dir(theta)).
    final Offset anchor = Offset(
      center.dx + radius * math.cos(theta),
      center.dy + radius * math.sin(theta),
    );

    // Prepare styled text.
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
      ),
    );
    textPainter.layout();

    // Tangential orientation (perpendicular to radial line).
    final double rotation = theta + math.pi / 2.0;

    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(rotation);
    // Center the text at the anchor.
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2.0, -textPainter.height / 2.0),
    );
    canvas.restore();
  }

  void drawScaledHighlightDot({
    required Canvas canvas,
    required Offset center,
    required double baseRadius, // radius used for the text anchor
    required double theta,      // angle in radians
    required double fontSize,   // font size baseline
    required int count,         // number of records for that day
    required Color dotColor,
  }) {
    // base size, keep minimum for readability
    final double minSize = math.max(3.0, fontSize * 0.3);

    // scale factor: sqrt to avoid explosive growth, adjust multiplier to taste
    final double scaledSize = minSize * (1.0 + math.sqrt(count.toDouble()) * 0.5);

    // Place the dot slightly inward from the text anchor.
    final double dotR = baseRadius - (fontSize * 0.9);

    final Offset dotCenter = Offset(
      center.dx + dotR * math.cos(theta),
      center.dy + dotR * math.sin(theta),
    );

    final Paint dotPaint = Paint()
      ..color = dotColor.withOpacity(0.56)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(dotCenter, scaledSize, dotPaint);
  }



  void drawHighlightDots({
    required Canvas canvas,
    required Offset center,
    required double baseRadius, // radius used for the text anchor
    required double theta,      // angle in radians
    required double fontSize,   // font size to scale dot placement/size
    required int count,         // number of dots to draw
  }) {
    // Compute base dot size.
    final double dotSize = math.max(3.0, fontSize * 0.28);

    // Use a larger multiplier for spacing to make dots more separated.
    final double gap = dotSize * 6; // << was 1.4, now more loose

    // Place the first dot slightly inward from the text anchor.
    final double firstDotR = baseRadius - (fontSize * 0.9);

    final Paint dotPaint = Paint()
      ..color = isMain ? config.floatBlue : ringColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (int i = 0; i < count; i++) {
      final double r = firstDotR - (i * gap);
      final Offset dotCenter = Offset(
        center.dx + r * math.cos(theta),
        center.dy + r * math.sin(theta),
      );
      canvas.drawCircle(dotCenter, dotSize, dotPaint);
    }
  }



  /// Draw a label between two ticks (angular midpoint), tangential to the arc.
  void drawInnerLabel({
    required Canvas canvas,
    required TextPainter textPainter,
    required Offset center,
    required double radius,
    required double theta,
    required String text,
    required Color color,
    required double fontSize,
    Map<int, int>? glimpseCountByDay,
    int? dayNumber,
  }) {
    final Offset anchor = Offset(
      center.dx + radius * math.cos(theta),
      center.dy + radius * math.sin(theta),
    );

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize),
    );
    textPainter.layout();

    final double rotation = theta + math.pi / 2.0;

    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(rotation);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2.0, -textPainter.height / 2.0),
    );
    canvas.restore();

    // Get count for this day; draw that many dots along the same radial line inward.
    // int count = 0;
    // if (glimpseCountByDay != null && dayNumber != null) {
    //   count = glimpseCountByDay[dayNumber] ?? 0;
    // } else {
    //   // keep default 0
    // }

    // if (count > 0) {
    //   // drawHighlightDots(
    //   //   canvas: canvas,
    //   //   center: center,
    //   //   baseRadius: radius,
    //   //   theta: theta,
    //   //   fontSize: fontSize,
    //   //   count: count,
    //   // );
    //
    //   drawScaledHighlightDot(
    //     canvas: canvas,
    //     center: center,
    //     baseRadius: radius,
    //     theta: theta,
    //     fontSize: fontSize,
    //     count: count,
    //     dotColor: config.floatBlue
    //   );
    // } else {
    //   // No highlight -> do nothing.
    // }
  }

  /// Draw the orbiting ball centered at (center + radius * dir(theta)).
  void drawOrbitBall({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double theta,
    required Color color,
    required double ballRadius,
  }) {
    final Offset pos = Offset(
      center.dx + radius * math.cos(theta),
      center.dy + radius * math.sin(theta),
    );

    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(pos, ballRadius, p);
  }

  void drawDateBall({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double theta,
    required Color color,
    required double ballRadius,
  }) {
    if (!isMain ||
        !(targetYear == TimeUtils.currentYear &&
            targetMonth == TimeUtils.currentMonth)) {
      return;
    }

    final Offset pos = Offset(
      center.dx + radius * math.cos(theta),
      center.dy + radius * math.sin(theta),
    );

    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(pos, ballRadius, p);
  }

  bool _mapEqualsIntInt(Map<int, int> a, Map<int, int> b) {
    if (identical(a, b)) {
      return true;
    } else {
      if (a.length != b.length) {
        return false;
      } else {
        for (final MapEntry<int, int> e in a.entries) {
          if (b[e.key] != e.value) {
            return false;
          } else {
            // keep
          }
        }
        return true;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConcentricRingsPainter oldDelegate) {
    if (oldDelegate.ringColor != ringColor) {
      return true;
    }
    if (oldDelegate.strokeWidth != strokeWidth) {
      return true;
    }
    if (oldDelegate.innerRatio != innerRatio) {
      return true;
    }
    if (oldDelegate.outerRadius != outerRadius) {
      return true;
    }
    if (oldDelegate.outerLabels != outerLabels) {
      return true;
    }
    if (oldDelegate.innerLabels != innerLabels) {
      return true;
    }
    if (oldDelegate.daysInTargetMonth != daysInTargetMonth) {
      return true;
    }
    if (oldDelegate.ballEnabled != ballEnabled) {
      return true;
    }
    if (oldDelegate.ballColor != ballColor) {
      return true;
    }
    if (oldDelegate.ballRadius != ballRadius) {
      return true;
    }
    if (oldDelegate.ballAngleDegrees != ballAngleDegrees) {
      return true;
    }
    if (oldDelegate.ballTrackRadiusFactor != ballTrackRadiusFactor) {
      return true;
    }
    if (!_mapEqualsIntInt(oldDelegate.glimpseCountByDay, glimpseCountByDay)) {
      return true;
    }
    return false;
  }
}
