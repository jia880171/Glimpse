import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vibration/vibration.dart';

import '../../common/utils/time_utils.dart';
import '../../config.dart' as config;
import '../../models/glimpse.dart';
import '../../services/database_service.dart';
import '../../services/glimpse_service.dart';
import 'clickable_orbit_day_marker.dart';
import 'concentric_rings_painter.dart';
import 'draggable_orbit_triangle.dart';

class TiltedConcentricRings extends StatefulWidget {
  final Size widgetSize; // External size control
  final double tiltXDegrees; // Rotation around X axis in degrees
  final double tiltYDegrees; // Rotation around Y axis in degrees
  final bool isMain;
  final Color ringBackgroundColor;

  /// Whole dial rotation speed (degrees per second). Set 0.0 if you only want the ball to move.
  final double rotationSpeed;

  final Color ringColor; // Ring stroke color
  final double strokeWidth; // Ring stroke width
  final double innerRingRatio; // Inner radius ratio (0~1)
  final int tickCount;

  // ===== Ball orbit params =====
  final bool ballEnabled; // Enable/disable the orbiting ball
  final Color ballColor; // Ball color
  final double ballRadius; // Ball circle radius in logical pixels
  final double
      ballSpeedDegreesPerSec; // Ball angular speed (deg/sec), positive = CCW
  final double
      ballTrackRadiusFactor; // 1.0 = on outerRadius, <1 = inner to it, >1 = outside

  final double? outerRadius;
  final Function? setTargetYear;
  final Function? setTargetMonth;

  final Function({DateTime? selectedDay}) setIsDisplayingGlimpses;

  const TiltedConcentricRings({
    Key? key,
    required this.widgetSize,
    this.setTargetYear,
    this.setTargetMonth,
    this.tiltXDegrees = -30.0,
    this.tiltYDegrees = 30.0,
    this.rotationSpeed = 1.0, // dial: 1 deg/sec
    this.ringColor = Colors.black87,
    this.strokeWidth = 2.0,
    this.innerRingRatio = 0.68,
    this.tickCount = 12,
    this.ballEnabled = false,
    this.ballColor = Colors.white,
    this.ballRadius = 4.0,
    this.ballSpeedDegreesPerSec = 30.0, // ball: 30 deg/sec by default
    this.ballTrackRadiusFactor = 1.0,
    this.outerRadius,
    this.isMain = false,
    this.ringBackgroundColor = Colors.yellow,
    required this.setIsDisplayingGlimpses,
  }) : super(key: key);

  @override
  State<TiltedConcentricRings> createState() => _TiltedConcentricRingsState();
}

class _TiltedConcentricRingsState extends State<TiltedConcentricRings>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false; // mark dragging state to suppress fetch
  Timer? _monthFetchDebounce; // debounce timer for month fetch
  bool _isFetching = false; // in-flight guard to avoid overlap

  late GlimpseService _glimpseService;

  // ===== Animation / timing =====
  late final Ticker _ticker;
  double _rotationDegrees = 0.0; // whole dial rotation (Z)
  double _ballAngleDegrees =
      0.0; // ball orbit angle (relative to painter space)
  double _effectiveRotationSpeed = 0.0; // can be set to 0 while dragging
  double _lastElapsedSec =
      0.0; // accumulate by delta time for deterministic updates
  Timer? _resumeTimer; // delay before resuming auto-rotation

  double dragRotationFactor = 0.6;

  // ===== Gesture state =====
  final GlobalKey _gestureKey =
      GlobalKey(); // to compute local center for angle
  double? _lastPanAngleRad; // previous pan angle relative to center
  int _lastTickIndex = -1;

  int targetYear = TimeUtils.currentYear;
  int targetMonth = TimeUtils.currentMonth;

  Map<int, int> glimpseCountByDay = <int, int>{};

  @override
  void initState() {
    super.initState();

    _effectiveRotationSpeed = widget.rotationSpeed;

    // Initialize GlimpseService with shared Isar instance.
    _glimpseService = GlimpseService(DatabaseService.isar);

    // Prefetch on first build so you have initial data.
    fetchGlimpseDaysForTargetMonth(targetYear, targetMonth);

    _ticker = createTicker((elapsed) {
      // Use elapsed total time to compute delta time deterministically.
      final double t = elapsed.inMilliseconds / 1000.0;
      final double dt = t - _lastElapsedSec;

      if (dt > 0.0) {
        // Dial rotation integrates speed over dt to preserve manual adjustments.
        _rotationDegrees =
            (_rotationDegrees + dt * _effectiveRotationSpeed) % 360.0;

        // Ball orbit rotation integrates its own speed over dt.
        _ballAngleDegrees =
            (_ballAngleDegrees + dt * widget.ballSpeedDegreesPerSec) % 360.0;

        _lastElapsedSec = t;
        setState(() {});
      } else {
        // If dt <= 0, do nothing to avoid negative or zero-time anomalies.
        // This branch intentionally left blank.
      }
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _monthFetchDebounce?.cancel();
    _resumeTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  /// Fetch all Glimpses in the target month and cache the day numbers (1..31)
  /// into _glimpseDaysInTargetMonth. Safe to call repeatedly.
  Future<void> fetchGlimpseDaysForTargetMonth(
      int targetYear, int targetMonth) async {
    if (_isFetching == true) {
      return;
    } else {
      _isFetching = true;
    }

    try {
      final int daysInMonth =
          TimeUtils.daysInTargetMonth(targetYear, targetMonth);
      final DateTime startDay = DateTime(targetYear, targetMonth, 1, 0, 0, 0);
      final DateTime endDay =
          DateTime(targetYear, targetMonth, daysInMonth, 23, 59, 59, 999);

      final List<Glimpse> results =
          await _glimpseService.getGlimpsesByExifTimeBetween(startDay, endDay);

      // accumulate counts per day
      final Map<int, int> counts =
          <int, int>{}; // key: day(1..31), value: count
      for (final Glimpse g in results) {
        // Defensive: make sure createdAt exists and is within month window.
        final DateTime? ts = g.exifDateTime;
        if (ts != null) {
          if (ts.year == targetYear && ts.month == targetMonth) {
            final int d = ts.day;
            final int prev = counts[d] ?? 0;
            counts[d] = prev + 1;
          } else {
            // ignore if outside month boundary
          }
        } else {
          // ignore if no timestamp
        }
      }

      if (!mounted) {
        return;
      } else {
        // Only update when changed to suppress noisy rebuild/logs.
        if (!_mapEquals(glimpseCountByDay, counts)) {
          setState(() {
            glimpseCountByDay = counts;
          });
          debugPrint(
              '===== day-counts updated (${targetYear.toString()}-${targetMonth.toString().padLeft(2, '0')}): $counts');
        } else {
          // unchanged -> do nothing
        }
      }
    } catch (e, st) {
      // Log error for debugging; do not crash UI.
      debugPrint('[fetchGlimpseDaysForTargetMonth] error: $e\n$st');
    } finally {
      _isFetching = false;
    }
  }

  bool _mapEquals(Map<int, int> a, Map<int, int> b) {
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

  Matrix4 _buildTiltMatrix() {
    final Matrix4 m = Matrix4.identity();
    m.setEntry(3, 2, 0.0015); // perspective depth
    m.rotateX(widget.tiltXDegrees * math.pi / 180.0);
    m.rotateY(widget.tiltYDegrees * math.pi / 180.0);
    return m;
  }

  double _normDeg(double d) {
    double x = d % 360.0;
    if (x < 0.0) {
      x += 360.0;
    } else {
      /* keep */
    }
    return x;
  }

  /// Return the visual center angle (degrees) for a month slice (0..11),
  /// aligned with painter's startBase=-90° and step=30°.
  double monthCenterDeg(int zeroBasedMonthIndex) {
    const double startBaseDeg = -90.0; // 12 o'clock
    const double step = 360.0 / 12.0; // 30°
    return _normDeg(startBaseDeg + (zeroBasedMonthIndex + 0.5) * step);
  }

  /// Returns the angle (radians) from center to the given global pointer position.
  double? _angleForGlobalPosition(Offset globalPosition) {
    final BuildContext? c = _gestureKey.currentContext;
    if (c == null) {
      return null;
    } else {
      final RenderObject? ro = c.findRenderObject();
      if (ro is! RenderBox) {
        return null;
      } else {
        final RenderBox box = ro;
        final Offset local = box.globalToLocal(globalPosition);
        final Size size = box.size;
        final Offset center = Offset(size.width / 2.0, size.height / 2.0);
        final Offset v = local - center;
        return math.atan2(v.dy, v.dx);
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true; // dragging started
    _resumeTimer?.cancel(); // Stop auto-rotation immediately.
    _effectiveRotationSpeed = 0.0;

    // Record initial angle for delta calculation.
    _lastPanAngleRad = _angleForGlobalPosition(details.globalPosition);
    if (_lastPanAngleRad == null) {
      // Fallback: do nothing if we cannot compute angle.
      // This branch intentionally left blank.
    } else {
      // Intentionally no-op here besides recording the angle.
    }

    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final double? currentAngle =
        _angleForGlobalPosition(details.globalPosition);
    if (currentAngle == null) {
      // If we cannot compute the angle, we skip updates.
      // This branch intentionally left blank.
    } else {
      if (_lastPanAngleRad == null) {
        _lastPanAngleRad = currentAngle;
      } else {
        double delta = currentAngle - _lastPanAngleRad!;

        // Normalize to [-pi, pi] to avoid jump when crossing the ±pi boundary.
        if (delta > math.pi) {
          delta -= 2.0 * math.pi;
        } else {
          if (delta < -math.pi) {
            delta += 2.0 * math.pi;
          } else {
            // within range, use as-is
          }
        }

        final double deltaDeg = delta * 180.0 / math.pi;
        _rotationDegrees =
            (_rotationDegrees + deltaDeg * dragRotationFactor) % 360.0;
        _lastPanAngleRad = currentAngle;

        // ✅ After updating rotation, check tick crossing
        final int days = TimeUtils.daysInTargetMonth(targetYear, targetMonth);
        final double tickSize = 360.0 / days;
        final int currentTick = ((_rotationDegrees % 360.0) / tickSize).floor();

        if (currentTick != _lastTickIndex) {
          _lastTickIndex = currentTick;
          Vibration.vibrate(duration: 50, amplitude: 168);
        }
      }
    }

    setState(() {});
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    _lastPanAngleRad = null;

    _isDragging = false; // dragging ended
    _scheduleMonthFetch(); // <-- add this line

    // Resume auto-rotation after 1 second.
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      } else {
        _effectiveRotationSpeed = widget.rotationSpeed;
        setState(() {});
      }
    });
  }

  void _onPanCancel() {
    _lastPanAngleRad = null;

    // Same behavior as end: resume after 1 second.
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 50), () {
      if (!mounted) {
        return;
      } else {
        // _effectiveRotationSpeed = widget.rotationSpeed;
        setState(() {});
      }
    });
  }

  void _scheduleMonthFetch() {
    // If still dragging, do nothing; we will fetch on _onPanEnd.
    if (_isDragging == true) {
      return;
    } else {
      // debounce to avoid bursts when months change quickly
      _monthFetchDebounce?.cancel();
      _monthFetchDebounce = Timer(const Duration(milliseconds: 180), () {
        if (!mounted) {
          return;
        } else {
          fetchGlimpseDaysForTargetMonth(targetYear, targetMonth);
        }
      });
    }
  }

  String toBankNum(String digits) {
    const Map<String, String> bankNums = {
      '0': '零',
      '1': '壹',
      '2': '貳',
      '3': '參',
      '4': '肆',
      '5': '伍',
      '6': '陸',
      '7': '柒',
      '8': '捌',
      '9': '玖',
    };

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      String? mapped = bankNums[digits[i]];
      if (mapped != null) {
        sb.write(mapped);
      } else {
        sb.write(digits[i]); // fallback
      }
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final double outerR = widget.outerRadius ?? widget.widgetSize.width;
    final double dateInnerR = outerR * widget.innerRingRatio;
    final double monthInnerR = dateInnerR * 0.8;
    final double middleR = outerR - ((outerR - dateInnerR) * 0.2);
    final double glimpseMarkOrbitR = (dateInnerR + middleR) / 2;

    return SizedBox(
      width: widget.widgetSize.width,
      height: widget.widgetSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: Transform(
                alignment: Alignment.center,
                transform: _buildTiltMatrix(),
                child: Transform.rotate(
                    angle: _rotationDegrees * math.pi / 180.0,
                    // whole dial rotation
                    child: Stack(
                      children: [
                        if (widget.isMain) ...[
                          Center(
                            child: Container(
                              // color: Colors.green,
                              width: widget.widgetSize.width * 0.2,
                              height: widget.widgetSize.height * 0.2,
                              child: Stack(
                                alignment: Alignment.center, // 保證所有子元件以中心對齊
                                children: [
                                  // 背景紅色圓
                                  Container(
                                    width: widget.widgetSize.width * 0.1,
                                    height: widget.widgetSize.height * 0.1,
                                    decoration: BoxDecoration(
                                      color: config.trashPointerRed
                                          .withOpacity(0.78),
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  // 年份文字，兩行垂直置中
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    // 讓 Column 只包住文字，不撐滿容器
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.translate(
                                        offset: const Offset(0, 3.0),
                                        // tweak: negative = move slightly up
                                        // child: Text(
                                        //   // targetYear.toString().substring(0,2),
                                        //   toBankNum(targetYear.toString().substring(0, 2)),
                                        //   style: TextStyle(
                                        //     fontFamily: 'Sacramento',
                                        //     fontSize:
                                        //         widget.widgetSize.width * 0.068,
                                        //     height: 1.0,
                                        //   ),
                                        // ),
                                        child: Text(
                                          // targetYear.toString().substring(0,2),
                                          targetYear.toString().substring(0, 2),
                                          style: TextStyle(
                                            fontFamily: 'Jura',
                                            fontSize:
                                                widget.widgetSize.width * 0.068,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, 3.0),
                                        // tweak: negative = move slightly up
                                        child: Text(
                                          (targetYear.toString().substring(2)),
                                          style: TextStyle(
                                            fontFamily: 'Jura',
                                            fontSize:
                                                widget.widgetSize.width * 0.068,
                                            height: 1.0,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        SizedBox(
                          key: _gestureKey, // key for local center computations
                          width: widget.widgetSize.width,
                          height: widget.widgetSize.height,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            // ensure we catch drags anywhere inside
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            // onPanCancel: _onPanCancel,
                            child: Container(
                              color: Colors.transparent,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                    sigmaX: (!widget.isMain) ? 3.6 : 0.0,
                                    sigmaY: (!widget.isMain) ? 3.6 : 0.0),
                                child: CustomPaint(
                                  painter: ConcentricRingsPainter(
                                    ringColor: widget.isMain
                                        ? widget.ringColor
                                        : widget.ringColor.withOpacity(0.133),
                                    strokeWidth: widget.strokeWidth,
                                    innerRatio: widget.innerRingRatio,
                                    outerRadius: widget.outerRadius ??
                                        widget.widgetSize.width * 0.6,
                                    daysInTargetMonth:
                                        TimeUtils.daysInTargetMonth(
                                            targetYear, targetMonth),
                                    ballEnabled: widget.ballEnabled,
                                    ballColor: widget.ballColor,
                                    ballRadius: widget.ballRadius,
                                    ballAngleDegrees: _ballAngleDegrees,
                                    ballTrackRadiusFactor:
                                        widget.ballTrackRadiusFactor,
                                    isMain: widget.isMain,
                                    ringBackgroundColor:
                                        widget.ringBackgroundColor,
                                    targetYear: targetYear,
                                    targetMonth: targetMonth,
                                    glimpseCountByDay: glimpseCountByDay,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.isMain) ...[
                          DraggableOrbitTriangle(
                            canvasSize: widget.widgetSize,
                            parentKey: _gestureKey,
                            orbitRadius: monthInnerR,
                            size: widget.ballRadius * 1.68 * 8.8,
                            initialLocalAngleDegrees:
                                monthCenterDeg(TimeUtils.currentMonth - 1),
                            dialRotationDegrees: _rotationDegrees,
                            tiltXDegrees: widget.tiltXDegrees,
                            tiltYDegrees: widget.tiltYDegrees,
                            perspective: 0.0015,
                            color: config.trashPointerRed,
                            setTargetMonth: setTargetMonth,
                            setTargetYear: setTargetYear,
                          ),
                          ClickableOrbitDayMarkers(
                            canvasSize: widget.widgetSize,
                            markOrbitRadius: glimpseMarkOrbitR,
                            glimpseCountByDay: glimpseCountByDay,
                            targetYear: targetYear,
                            targetMonth: targetMonth,
                            color: config.floatBlue.withOpacity(0.6),
                            isMain: widget.isMain,
                            onMarkerTap: (int day, int count) {
                              // TODO: Replace with your desired action (e.g., open a list page).
                              debugPrint('Tapped day=$day, count=$count');
                              Vibration.vibrate(duration: 30, amplitude: 96);
                              widget.setIsDisplayingGlimpses(
                                  selectedDay:
                                      DateTime(targetYear, targetMonth, day));
                            },
                            tiltXDegrees: widget.tiltXDegrees,
                            tiltYDegrees: widget.tiltYDegrees,
                            perspective: 0.0015,
                            applyForeshortening: true,
                            baseMarkerRadius: 6.0,
                            maxMarkerRadiusFactor: 0.06,
                          ),
                        ]
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setTargetMonth(int targetMonth) async {
    if (this.targetMonth != targetMonth) {
      setState(() {
        this.targetMonth = targetMonth;
        if(widget.setTargetMonth != null){
          widget.setTargetMonth!(targetMonth);
        }
      });

      // Do not fetch immediately while dragging; debounce instead.
      _scheduleMonthFetch();
    } else {
      // unchanged month -> do nothing
    }
  }

  void setTargetYear(int targetYear) {
    widget.setTargetYear!(targetYear);
    setState(() {
      this.targetYear = targetYear;
    });
  }
}
