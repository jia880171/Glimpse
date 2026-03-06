// clickable_orbit_day_marker.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../common/utils/time_utils.dart';

/// A single clickable circular marker placed on a circular orbit.
/// IMPORTANT:
/// - Place this widget inside the SAME transform stack as your dial (the
///   same Transform.rotate / 3D tilt), so positions visually match.
/// - Do NOT re-apply dialRotationDegrees to angle when computing position
///   if this widget sits inside the already-rotated parent. Keep `angleDegrees` local.
class ClickableOrbitDayMarker extends StatelessWidget {
  final Size canvasSize;              // full canvas size for positioning
  final double radius;                // orbit radius (e.g., outerRadius)
  final double angleDegrees;          // local angle in degrees (midpoint of the day slice)
  final int day;                      // day number (1..31)
  final int count;                    // number of records for this day
  final Color color;                  // fill color
  final bool isMain;                  // styling hint
  final void Function(int day, int count)? onTap;

  // Visual scaling: dot size grows with count via sqrt curve.
  final double baseMarkerRadius;      // minimum radius in logical pixels (before scaling)
  final double maxMarkerRadiusFactor; // max cap as fraction of shortestSide (e.g., 0.06)

  // 3D tilt info (used ONLY for foreshortening scale, do not re-apply transform).
  final double tiltXDegrees;
  final double tiltYDegrees;
  final double perspective;           // currently unused in this child, passed for parity/API
  final bool applyForeshortening;     // if true, scale dot to mimic 3D tilt compression

  const ClickableOrbitDayMarker({
    Key? key,
    required this.canvasSize,
    required this.radius,
    required this.angleDegrees,
    required this.day,
    required this.count,
    required this.color,
    required this.isMain,
    this.onTap,
    this.baseMarkerRadius = 6.0,
    this.maxMarkerRadiusFactor = 0.06,
    this.tiltXDegrees = -30.0,
    this.tiltYDegrees = 30.0,
    this.perspective = 0.0015,
    this.applyForeshortening = true,
  }) : super(key: key);

  /// Compute visual marker radius based on `count`, clamped.
  double _scaledMarkerRadius(Size size) {
    final double minR = baseMarkerRadius;
    final double scaled = minR * (1.0 + math.sqrt(count.toDouble()) * 0.6);
    final double maxR = size.shortestSide * maxMarkerRadiusFactor;

    if (scaled < minR) {
      return minR;
    } else {
      if (scaled > maxR) {
        return maxR;
      } else {
        return scaled;
      }
    }
  }

  /// Compute simple foreshortening to hint tilt.
  /// - Compress X by cos(tiltY), compress Y by cos(tiltX).
  /// - Clamp to keep visible/readable.
  Offset _foreshorteningScale() {
    final double rx = math.cos(tiltYDegrees * math.pi / 180.0).abs();
    final double ry = math.cos(tiltXDegrees * math.pi / 180.0).abs();

    final double sx = rx.clamp(0.35, 1.0);
    final double sy = ry.clamp(0.35, 1.0);
    return Offset(sx, sy);
  }

  @override
  Widget build(BuildContext context) {
    // Center of the canvas.
    final Offset center = Offset(canvasSize.width / 2.0, canvasSize.height / 2.0);

    // Local angle only (parent already rotated/tilted).
    final double theta = angleDegrees * math.pi / 180.0;

    // Cartesian position on orbit circle.
    final double x = center.dx + radius * math.cos(theta);
    final double y = center.dy + radius * math.sin(theta);

    // Dot radius and size.
    final double r = _scaledMarkerRadius(canvasSize);
    final double diameter = r * 2.0;

    // Optional tilt foreshortening (visual only).
    final Offset scale = applyForeshortening ? _foreshorteningScale() : const Offset(1.0, 1.0);

    return Positioned(
      left: x - r,
      top: y - r,
      width: diameter,
      height: diameter,
      child: Transform.scale(
        // Scale around center of the dot.
        alignment: Alignment.center,
        scaleX: scale.dx,
        scaleY: scale.dy,
        child: GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap!(day, count);
            } else {
              // Default no-op.
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// A helper that iterates over `glimpseCountByDay` and adds one marker per day with count>0.
/// IMPORTANT:
/// - This widget should be placed inside the same transformed Stack as the dial.
/// - `angleDegrees` for each day is computed as the midpoint of the day's segment.
class ClickableOrbitDayMarkers extends StatelessWidget {
  final Size canvasSize;
  final double markOrbitRadius;
  final Map<int, int> glimpseCountByDay;
  final int targetYear;
  final int targetMonth;
  final Color color;
  final bool isMain;
  final void Function(int day, int count)? onMarkerTap;

  // Tilt info for foreshortening.
  final double tiltXDegrees;
  final double tiltYDegrees;
  final double perspective;
  final bool applyForeshortening;

  // Sizing knobs.
  final double baseMarkerRadius;
  final double maxMarkerRadiusFactor;

  const ClickableOrbitDayMarkers({
    Key? key,
    required this.canvasSize,
    required this.markOrbitRadius,
    required this.glimpseCountByDay,
    required this.targetYear,
    required this.targetMonth,
    required this.color,
    required this.isMain,
    this.onMarkerTap,
    this.tiltXDegrees = -30.0,
    this.tiltYDegrees = 30.0,
    this.perspective = 0.0015,
    this.applyForeshortening = true,
    this.baseMarkerRadius = 6.0,
    this.maxMarkerRadiusFactor = 0.06,
  }) : super(key: key);

  /// Compute the midpoint angle (deg) for a given day in this month.
  double _dayMidAngleDegrees(int day, int daysInMonth) {
    final double startBaseDeg = -90.0; // 12 o'clock
    final double stepDeg = 360.0 / daysInMonth;
    final int idx = day - 1;
    return startBaseDeg + (idx + 0.5) * stepDeg;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> markers = <Widget>[];

    // Compute actual number of days for the given year & month to be safe.
    final int days = TimeUtils.daysInTargetMonth(targetYear, targetMonth);

    glimpseCountByDay.forEach((int day, int count) {
      if (count > 0) {
        final double angleDeg = _dayMidAngleDegrees(day, days);

        markers.add(
          ClickableOrbitDayMarker(
            canvasSize: canvasSize,
            radius: markOrbitRadius,
            angleDegrees: angleDeg,
            day: day,
            count: count,
            color: color,
            isMain: isMain,
            onTap: onMarkerTap,
            baseMarkerRadius: baseMarkerRadius,
            maxMarkerRadiusFactor: maxMarkerRadiusFactor,
            tiltXDegrees: tiltXDegrees,
            tiltYDegrees: tiltYDegrees,
            perspective: perspective,
            applyForeshortening: applyForeshortening,
          ),
        );
      } else {
        // Skip zero-count days intentionally.
      }
    });

    // Return a Stack fragment with Positioned children.
    return Stack(children: markers);
  }
}
