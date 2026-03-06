// draggable_orbit_triangle.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:glimpse/common/utils/time_utils.dart';
import 'package:vector_math/vector_math_64.dart' as v;

/// Triangle that orbits at fixed radius under a tilted + rotating dial.
/// IMPORTANT: If this widget sits inside the same Transform.rotate(dialRotationDegrees)
/// as the dial, DO NOT apply dialRotationDegrees again when computing its
/// position or visual rotation. Only use _localDeg here. We still subtract
/// dialRotationDegrees when measuring drag to get the correct local angle.
class DraggableOrbitTriangle extends StatefulWidget {
  final Size canvasSize;
  final double orbitRadius; // distance from parent's center
  final double size; // box size (w == h)
  final double initialLocalAngleDegrees; // relative to dial
  final double dialRotationDegrees; // current dial Z-rotation (deg)
  final double tiltXDegrees; // same tilt as parent
  final double tiltYDegrees; // same tilt as parent
  final double perspective; // same setEntry(3,2,...) as parent
  final Color color;
  final GlobalKey parentKey;
  final ValueChanged<int>? setTargetMonth;
  final ValueChanged<int>? setTargetYear;


  const DraggableOrbitTriangle({
    super.key,
    required this.canvasSize,
    required this.orbitRadius,
    required this.size,
    required this.initialLocalAngleDegrees,
    required this.dialRotationDegrees,
    required this.tiltXDegrees,
    required this.tiltYDegrees,
    required this.perspective,
    required this.color,
    required this.parentKey,
    this.setTargetMonth,
    this.setTargetYear,
  });

  @override
  State<DraggableOrbitTriangle> createState() => _DraggableOrbitTriangleState();
}

class _DraggableOrbitTriangleState extends State<DraggableOrbitTriangle> {
  late double _localDeg; // 0..360
  double? _dragOffsetDeg; // angle offset captured on pan start

  int yearTemp = TimeUtils.currentYear; // temp year counter
  int? _lastMonthIdx; // remember last month index during drag

  @override
  void initState() {
    super.initState();
    _localDeg = _norm(widget.initialLocalAngleDegrees);
  }

  // ===== Gesture handlers =====
  void _onPanStart(DragStartDetails d) {
    final double? measured = _measureLocalAngleFromGlobal(d.globalPosition);
    if (measured != null) {
      _dragOffsetDeg = _norm(_localDeg - measured);
      // Record the month index at drag start for crossing detection.
      _lastMonthIdx = _monthIndexFromLocalDeg(_localDeg);
    } else {
      _dragOffsetDeg = null;
      _lastMonthIdx = null;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final double? measured = _measureLocalAngleFromGlobal(d.globalPosition);
    if (measured != null) {
      final double offset = (_dragOffsetDeg != null) ? _dragOffsetDeg! : 0.0;
      final double nextLocal = _norm(measured + offset);
      final int currIdx = _monthIndexFromLocalDeg(nextLocal);

      // Detect crossing 12<->1 boundary and call setTargetYear accordingly.
      if (_lastMonthIdx != null) {
        _handleYearCrossing(_lastMonthIdx!, currIdx);
      } else {
        // no-op
      }
      _lastMonthIdx = currIdx;

      setState(() {
        _localDeg = nextLocal;
      });

      if (widget.setTargetMonth != null) {
        widget.setTargetMonth!(getTargetMonth());
      } else {
        // no-op
      }
    } else {
      // no-op
    }
  }

  void _onPanEnd(DragEndDetails d) {
    _dragOffsetDeg = null;
    _printCurrentMonth();
    if (widget.setTargetMonth != null) {
      widget.setTargetMonth!(getTargetMonth());
    } else {
      // no-op
    }
    // Optional: clear last index after gesture ends.
    _lastMonthIdx = null;
  }

  // ===== Math =====

  void _handleYearCrossing(int prevIdx, int currIdx) {
    // Dec -> Jan (11 -> 0): moving left-to-right across the top
    if (prevIdx == 11 && currIdx == 0) {
      yearTemp = yearTemp + 1;
      if (widget.setTargetYear != null) {
        widget.setTargetYear!(yearTemp);
      } else {
        // no-op
      }
    } else {
      // Jan -> Dec (0 -> 11): moving right-to-left across the top
      if (prevIdx == 0 && currIdx == 11) {
        yearTemp = yearTemp - 1;
        if (widget.setTargetYear != null) {
          widget.setTargetYear!(yearTemp);
        } else {
          // no-op
        }
      } else {
        // No year boundary crossing; do nothing.
      }
    }
  }

  double _norm(double deg) {
    double x = deg % 360.0;
    if (x < 0.0) {
      x += 360.0;
    } else {
      /* keep */
    }
    return x;
  }

  /// Convert global pointer -> parent local -> vector from center,
  /// then undo parent's perspective + rotateX + rotateY to get the vector in the dial plane,
  /// finally compute angle in that plane and subtract dial Z-rotation to get local angle.
  double? _measureLocalAngleFromGlobal(Offset global) {
    final BuildContext? ctx = widget.parentKey.currentContext;
    if (ctx == null) {
      return null;
    } else {
      final RenderObject? ro = ctx.findRenderObject();
      if (ro is! RenderBox) {
        return null;
      } else {
        final RenderBox box = ro;
        final Offset local = box.globalToLocal(global);

        // Parent center in its local (pre-transform) space.
        final Offset center = Offset(
            widget.canvasSize.width / 2.0, widget.canvasSize.height / 2.0);
        final Offset v2 = local - center;

        // Build parent's tilt matrix (same as used to paint the dial).
        final v.Matrix4 tilt = v.Matrix4.identity()
          ..setEntry(3, 2, widget.perspective)
          ..rotateX(widget.tiltXDegrees * math.pi / 180.0)
          ..rotateY(widget.tiltYDegrees * math.pi / 180.0);

        // Inverse to "un-tilt" the screen-space vector back to the dial plane.
        final v.Matrix4 inv = v.Matrix4.copy(tilt)..invert();

        // Promote 2D to 3D vector and transform.
        final v.Vector3 p = v.Vector3(v2.dx, v2.dy, 0.0);
        final v.Vector3 q = inv.transform3(p);

        // Angle in dial plane (radians -> degrees).
        double deg = math.atan2(q.y, q.x) * 180.0 / math.pi;

        // Subtract current Z-rotation to get local angle.
        deg = deg - widget.dialRotationDegrees;

        return _norm(deg);
      }
    }
  }

  Offset _center() {
    return Offset(
        widget.canvasSize.width / 2.0, widget.canvasSize.height / 2.0);
  }

  /// IMPORTANT: Do NOT add dialRotationDegrees here, because the whole Stack
  /// is already inside Transform.rotate(dialRotationDegrees). Using only _localDeg
  /// keeps the triangle locked to the same tick while the parent rotates both together.
  Offset _currentCenter() {
    final double rad = _localDeg * math.pi / 180.0; // <-- use local only
    return _center() +
        Offset(widget.orbitRadius * math.cos(rad), widget.orbitRadius * math.sin(rad));
  }

  // ===== Month helpers (12 segments, start at -90°) =====

  /// Return 0..11 month index based on _localDeg, aligned with painter's 12 slices.
  int _monthIndexFromLocalDeg(double localDeg) {
    const double startBaseDeg = -90.0; // 12 o'clock
    const double step = 360.0 / 12.0; // 30°
    final double t = _norm(localDeg - startBaseDeg);
    final int idx = (t ~/ step) % 12;
    return idx;
  }

  /// Print current month number (1..12) to console.
  void _printCurrentMonth() {
    final int idx = _monthIndexFromLocalDeg(_localDeg);
    final int month = idx + 1;
    print('Triangle month = $month'); // keep simple print for visibility
  }

  int getTargetMonth() {
    final int idx = _monthIndexFromLocalDeg(_localDeg);
    return idx + 1;
  }

  @override
  Widget build(BuildContext context) {
    final Offset cc = _currentCenter();
    final double half = widget.size / 2.0;

    return Positioned(
      left: cc.dx - half,
      top: cc.dy - half,
      width: widget.size,
      height: widget.size,
      child: Transform.rotate(
        angle: (_localDeg + 90.0) * math.pi / 180.0,
        child: ClipPath(
          clipper: _TriangleClipper(),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            // moved inside ClipPath
            behavior: HitTestBehavior.opaque,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(painter: _TrianglePainter(widget.color)),
          ),
        ),
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final Path p = Path()
      ..moveTo(s.width / 2.0, 0.0)
      ..lineTo(0.0, s.height)
      ..lineTo(s.width, s.height)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant _TriangleClipper oldClipper) {
    return false;
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas c, Size s) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    c.drawPath(_TriangleClipper().getClip(s), p);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    if (oldDelegate.color != color) {
      return true;
    } else {
      return false;
    }
  }
}
