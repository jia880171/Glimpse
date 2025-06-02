import 'dart:math';
import 'dart:math' as math;

import 'dart:ui';

class RotationUtils {
  static double normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }

  static double getAngleFromOffset(Offset center, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return atan2(dy, dx);
  }

  static centerToTopLeft(Offset center, double radius) {
    return Offset(center.dx - radius, center.dy - radius);
  }


  /// Projects a point from the center of a circle given an angle in degrees and a radius.
  ///
  /// Converts the input angle from degrees to radians, then calculates the (x, y) coordinates
  /// on the circle's circumference using trigonometric functions.
  ///
  /// [degree] - The angle in degrees (0° is along the positive x-axis).
  /// [radius] - The distance from the center of the circle.
  ///
  /// Returns an [Offset] representing the position relative to the center.
  static Offset radiusProjector(double degree, double radius) {
    degree = 2 * math.pi * (degree / 360); // Convert degrees to radians

    double x = radius * math.cos(degree);
    double y = radius * math.sin(degree);

    return Offset(x, y); // Position relative to center
  }
}
