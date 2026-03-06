import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:glimpse/common/utils/time_utils.dart';
import 'package:glimpse/widgets/calendar/tilted_concentric_rings_widget.dart';
import 'package:glimpse/widgets/calendar/tilted_glimpses_circle.dart';

import '../../config.dart' as config;

class TiltedCircleCalendar extends StatefulWidget {
  final Size widgetSize; // External size control
  final double tiltXDegrees; // Rotation around X axis in degrees
  final double tiltYDegrees; // Rotation around Y axis in degrees
  final double rotationSpeed; // Degrees per second
  final Color ringColor; // Ring stroke color
  final double strokeWidth; // Ring stroke width
  final double innerRingRatio; // Inner radius ratio (0~1)

  const TiltedCircleCalendar({
    Key? key,
    required this.widgetSize,
    this.tiltXDegrees = -30.0,
    this.tiltYDegrees = 30.0,
    this.rotationSpeed = 1.0, // 每秒 1 度
    this.ringColor = Colors.black87,
    this.strokeWidth = 2.0,
    this.innerRingRatio = 0.62,
  }) : super(key: key);

  @override
  State<TiltedCircleCalendar> createState() => _TiltedCircleCalendarState();
}

class _TiltedCircleCalendarState extends State<TiltedCircleCalendar> {
  final ringBackgroundColor = config.ringBackgroundColor;
  final tiltedCalendarRim = config.tiltedCalendarRim;
  int targetYear = TimeUtils.currentYear;
  int targetMonth = TimeUtils.currentMonth;

  final double mainTiltXDegrees = -20;
  final double mainTiltYDegrees = 30;

  Matrix4 _buildTiltMatrix() {
    final Matrix4 m = Matrix4.identity();
    m.setEntry(3, 2, 0.0015); // perspective depth

    m.rotateZ(8.8 * math.pi / 180.0);
    m.rotateX(mainTiltXDegrees * math.pi / 180.0);
    m.rotateY(mainTiltYDegrees * math.pi / 180.0);
    return m;
  }

  bool isDisplayingGlimpses = false;
  DateTime selectedGlimpseDay = DateTime.now();


  void setIsDisplayingGlimpses({DateTime? selectedDay}) {
    setState(() {
      if(selectedDay != null){
        selectedGlimpseDay = selectedDay;
      }
      isDisplayingGlimpses = (isDisplayingGlimpses == true) ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strokeWidth = widget.widgetSize.width * 0.00168;
    return Container(
        // color: config.tiltedCalendarBackground,
        color: config.hardCardPaperW,
        width: widget.widgetSize.width,
        height: widget.widgetSize.height,
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaX: (isDisplayingGlimpses) ? 3.6 : 0.0,
                  sigmaY: (isDisplayingGlimpses) ? 3.6 : 0.0),
              child: Stack(
                children: [
                  TiltedConcentricRings(
                    widgetSize: widget.widgetSize,
                    outerRadius: widget.widgetSize.width * 0.8,
                    rotationSpeed: 5.0,
                    tiltXDegrees: -60,
                    tiltYDegrees: 130,
                    ringColor: tiltedCalendarRim,
                    strokeWidth: widget.widgetSize.width * 0.006,
                    ballEnabled: true,
                    ballSpeedDegreesPerSec: 16.8,
                    ballRadius: strokeWidth * 3,
                    ballColor: config.trashPointerRed,
                    ballTrackRadiusFactor: 1.0,
                    ringBackgroundColor: ringBackgroundColor,
                    setIsDisplayingGlimpses: setIsDisplayingGlimpses,
                  ),

                  // 水平
                  TiltedConcentricRings(
                    widgetSize: widget.widgetSize,
                    outerRadius: widget.widgetSize.width * 0.8,
                    rotationSpeed: 5.0,
                    tiltXDegrees: -78,
                    tiltYDegrees: 0,
                    ringColor: tiltedCalendarRim,
                    strokeWidth: widget.widgetSize.width * 0.006,
                    tickCount: 12,
                    ballEnabled: true,
                    ballSpeedDegreesPerSec: 16.8,
                    ballRadius: strokeWidth * 3,
                    ballColor: config.trashPointerRed,
                    ballTrackRadiusFactor: 1.0,
                    ringBackgroundColor: ringBackgroundColor,
                    setIsDisplayingGlimpses: setIsDisplayingGlimpses,
                  ),

                  // Main
                  TiltedConcentricRings(
                    widgetSize: widget.widgetSize,
                    outerRadius: widget.widgetSize.width * 0.65,
                    rotationSpeed: 1.68,
                    // rotationSpeed: 0.0,
                    tiltXDegrees: mainTiltXDegrees,
                    tiltYDegrees: mainTiltYDegrees,
                    ringColor: tiltedCalendarRim,
                    strokeWidth: strokeWidth,
                    tickCount: 30,
                    ballEnabled: true,
                    ballSpeedDegreesPerSec: 1.68,
                    ballRadius: strokeWidth * 3,
                    ballColor: config.trashPointerRed,
                    ballTrackRadiusFactor: 1.0,
                    isMain: true,
                    ringBackgroundColor: ringBackgroundColor,
                    setTargetYear: setTargetYear,
                    setIsDisplayingGlimpses: setIsDisplayingGlimpses,
                  ),
                ],
              ),
            ),

            if (isDisplayingGlimpses) ...[
              TiltedTransparentCircle(
                widgetSize: widget.widgetSize,
                tiltXDegrees: widget.tiltXDegrees,
                tiltYDegrees: widget.tiltYDegrees,
                circleRadius: widget.widgetSize.width * 0.1,
                targetYear: targetYear,
                targetMonth: targetMonth,
                defaultGlimpsesCounts: 1,
                selectedGlimpseDay: selectedGlimpseDay,
                setIsDisplayingGlimpses: setIsDisplayingGlimpses,
              )
            ]
          ],
        ));
  }

  void setTargetYear(int targetYear) {
    setState(() {
      this.targetYear = targetYear;
    });
  }

  void setTargetMonth(int targetMonth) {
    setState(() {
      this.targetMonth = targetMonth;
    });
  }
}
