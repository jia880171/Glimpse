import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glimpse/models/glimpse.dart';
// TODO: adjust to your actual paths.
import 'package:glimpse/services/glimpse_service.dart';

import '../../config.dart' as config;
import '../../services/database_service.dart';
import '../journals/journals.dart';

/// A transparent layer that places a single circular Container (radius = R)
/// and tilts it in 3D using the given X/Y tilt degrees.
/// - Background is fully transparent.
/// - Size is controlled by [widgetSize].
/// - The circle's visual radius is [circleRadius] (diameter = 2R).
/// - The tilt uses a perspective matrix with rotateX/rotateY.
/// - Comments are in English; no if/else braces are omitted.
///
/// NOTE:
/// If you need the circle to be visibly outlined, set [borderColor]/[borderWidth].
/// If you need a filled circle, set [fillColor].
class TiltedTransparentCircle extends StatefulWidget {
  final Size widgetSize;
  final double tiltXDegrees;
  final double tiltYDegrees;

  /// Radius R for the circle (logical pixels).
  final double circleRadius;

  /// Optional visual customization for the circle.
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  /// Perspective depth (Matrix4 setEntry(3,2,perspectiveDepth)).
  final double perspectiveDepth;

  final int targetYear;
  final int targetMonth;

  /// Base card count when there are few or no glimpses.
  final int defaultGlimpsesCounts;
  final Function({DateTime? selectedDay}) setIsDisplayingGlimpses;
  final DateTime selectedGlimpseDay;

  const TiltedTransparentCircle({
    Key? key,
    required this.selectedGlimpseDay,
    required this.setIsDisplayingGlimpses,
    required this.targetYear,
    required this.targetMonth,
    required this.widgetSize,
    required this.tiltXDegrees,
    required this.tiltYDegrees,
    required this.circleRadius,
    required this.defaultGlimpsesCounts,
    this.fillColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.borderWidth = 1.5,
    this.perspectiveDepth = 0.0015,
  }) : super(key: key);

  @override
  State<TiltedTransparentCircle> createState() =>
      _TiltedTransparentCircleState();
}

// Spin phase for auto-rotation.
enum _SpinPhase { accelerating, decelerating, stopped }

class _TiltedTransparentCircleState extends State<TiltedTransparentCircle>
    with SingleTickerProviderStateMixin {
  // Auto-spin state & timers.
  late final Ticker _ticker;
  bool _isLoadingImages = true;
  bool _decelRequested = false; // set true when loading finishes
  double _autoSpinDegrees = 0.0;
  double _currentSpinDegPerSec = 0.0;
  _SpinPhase _spinPhase = _SpinPhase.stopped;
  Duration? _lastTick;

// Tunables.
  static const double _minSpinDegPerSec =
      30.0; // start speed (deg/s), a bit snappier
  static const double _maxSpinRps =
      1.68; // rotations per second (e.g., 1.5 rps)
  static const double _maxSpinDegPerSec = _maxSpinRps * 168.8; // => 540 deg/s

  static const double _accelDegPerSec2 = 66.6; // deg/s^2, reaches max in ~1.7s
  static const double _decelDegPerSec2 = 36.8; // deg/s^2, slows down in ~3s

  static const double _minAccelSeconds =
      1.68; // must accelerate at least this long

  double _accelElapsedSeconds = 0.0; // accumulated accel time

  static const double _spinDegPerSec = 30.0; // constant spin speed

  // Visual configs for cards.
  final Color _cardColor = config.hardCard; // card color
  final double _outsideGap = 10.0; // extra gap outside the circle

  // Rotation state driven by drag.
  double _rotationDegrees = 0.0; // accumulated Z rotation (deg)
  double?
      _lastPanAngleRad; // last touch polar angle (rad), for delta computation

  // Loaded month glimpses and images.
  List<Glimpse> _glimpses = <Glimpse>[];
  List<Uint8List?> _images = <Uint8List?>[];

  late GlimpseService _glimpseService;

  // Effective card count after comparing default vs. data size.
  int get _effectiveCounts {
    final int dataCount = _glimpses.length;
    if (dataCount > widget.defaultGlimpsesCounts) {
      return dataCount;
    } else {
      return widget.defaultGlimpsesCounts;
    }
  }

  late double _effectiveCircleRadius = widget.circleRadius;

  void _startAutoSpinWithAcceleration() {
    _spinPhase = _SpinPhase.accelerating;
    _currentSpinDegPerSec = _minSpinDegPerSec;
    if (_ticker.isActive == false) {
      _lastTick = null;
      _ticker.start();
    } else {
      // already running
    }
  }

  void _beginDeceleration() {
    if (_spinPhase == _SpinPhase.decelerating) {
      return;
    } else {
      _spinPhase = _SpinPhase.decelerating;
    }
  }

  void _stopSpinCompletely() {
    _spinPhase = _SpinPhase.stopped;
    _currentSpinDegPerSec = 0.0;
    if (_ticker.isActive == true) {
      _ticker.stop();
    } else {
      // already stopped
    }
    _lastTick = null;
  }

  /// Ticker tick: advance time, update speed by phase, integrate angle.
  void _onTick(Duration elapsed) {
    if (_spinPhase == _SpinPhase.stopped) {
      return;
    } else {
      // proceed
    }

    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    } else {
      final Duration dtDur = elapsed - _lastTick!;
      _lastTick = elapsed;
      final double dt = dtDur.inMicroseconds / 1000000.0; // seconds

      if (_spinPhase == _SpinPhase.accelerating) {
        // 1) integrate speed with acceleration
        _currentSpinDegPerSec = (_currentSpinDegPerSec + _accelDegPerSec2 * dt)
            .clamp(_minSpinDegPerSec, _maxSpinDegPerSec);

        // 2) accumulate accel time
        _accelElapsedSeconds += dt;

        // 3) switch to decelerating ONLY IF:
        //    - loading finished (decel requested), AND
        //    - minimum acceleration time reached
        if (_decelRequested == true) {
          if (_accelElapsedSeconds >= _minAccelSeconds) {
            _beginDeceleration();
          } else {
            // keep accelerating until minimum time reached
          }
        } else {
          // still loading; keep accelerating up to _maxSpinDegPerSec
        }
      } else {
        if (_spinPhase == _SpinPhase.decelerating) {
          _currentSpinDegPerSec =
              (_currentSpinDegPerSec - _decelDegPerSec2 * dt);
          if (_currentSpinDegPerSec <= 0.0) {
            _stopSpinCompletely();
            if (mounted) {
              setState(() {});
            } else {
              // not mounted
            }
            return;
          } else {
            // keep decelerating
          }
        } else {
          // stopped
        }
      }

      // integrate angle
      _autoSpinDegrees =
          (_autoSpinDegrees + _currentSpinDegPerSec * dt) % 360.0;

      if (mounted) {
        setState(() {});
      } else {
        // not mounted
      }
    }
  }

  @override
  void initState() {
    super.initState();

    print('====== initState');

    _glimpseService = GlimpseService(DatabaseService.isar);
    _ticker = createTicker(_onTick);

    _isLoadingImages = true;
    _decelRequested = false;
    _accelElapsedSeconds = 0.0;

    _startAutoSpinWithAcceleration();
    _loadDayGlimpses();
  }

  void _startAutoSpin() {
    if (_isLoadingImages == true) {
      if (_ticker.isActive == false) {
        _lastTick = null;
        _ticker.start();
      } else {
        // already running
      }
    } else {
      // not loading, no need to start
    }
  }

  void _stopAutoSpin() {
    if (_ticker.isActive == true) {
      _ticker.stop();
    } else {
      // already stopped
    }
    _lastTick = null;
  }

  /// Build the 3D tilt transform matrix with perspective, rotateX, rotateY.
  Matrix4 _buildTiltMatrix() {
    final Matrix4 m = Matrix4.identity();
    m.setEntry(3, 2, widget.perspectiveDepth);
    m.rotateX(widget.tiltXDegrees * math.pi / 180.0);
    m.rotateY(widget.tiltYDegrees * math.pi / 180.0);
    return m;
  }

  /// Build the circular widget (diameter = 2R) with optional fill/border.
  Widget _buildCircle() {
    final double diameter = widget.circleRadius * 2.0;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.fillColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
      ),
    );
  }

  /// Compute polar angle (radians) for a given global pointer position w.r.t. the widget's center.
  double? _angleForGlobalPosition(Offset globalPosition) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    } else {
      final Offset local = box.globalToLocal(globalPosition);
      final Offset center =
          Offset(widget.widgetSize.width / 2.0, widget.widgetSize.height / 2.0);
      final double dx = local.dx - center.dx;
      final double dy = local.dy - center.dy;
      final double angle =
          math.atan2(dy, dx); // [-pi, pi], 0 at +X axis, CCW positive
      return angle;
    }
  }

  /// Handle pan start: capture the initial angle for delta calculation.
  void _onPanStart(DragStartDetails details) {
    final double? angle = _angleForGlobalPosition(details.globalPosition);
    if (angle == null) {
      // Keep last state unchanged.
    } else {
      _lastPanAngleRad = angle;
    }
  }

  /// Handle pan update: compute delta angle and accumulate to _rotationDegrees.
  void _onPanUpdate(DragUpdateDetails details) {
    final double? currentAngle =
        _angleForGlobalPosition(details.globalPosition);
    if (currentAngle == null) {
      // No-op if angle cannot be computed.
    } else {
      if (_lastPanAngleRad == null) {
        _lastPanAngleRad = currentAngle;
      } else {
        double delta = currentAngle - _lastPanAngleRad!;

        // Normalize to [-pi, pi] to avoid jump across the wrap boundary.
        if (delta > math.pi) {
          delta -= 2.0 * math.pi;
        } else {
          if (delta < -math.pi) {
            delta += 2.0 * math.pi;
          } else {
            // within range
          }
        }

        final double deltaDeg = delta * 180.0 / math.pi;
        _rotationDegrees = (_rotationDegrees + deltaDeg) % 360.0;
        _lastPanAngleRad = currentAngle;
      }
    }

    setState(() {});
  }

  /// Handle pan end/cancel: clear the last angle.
  void _onPanEndOrCancel() {
    _lastPanAngleRad = null;
  }

  /// Load all glimpses for the target year/month and cache their images.
  Future<void> _loadDayGlimpses() async {
    print('====== _loadDatGlimpses');

    _isLoadingImages = true;

    try {
      print('====== widget.selectedGlimpseDay: ${widget.selectedGlimpseDay}');
      final List<Glimpse> results = await _glimpseService
          .getGlimpsesByExifTimeOnDay(widget.selectedGlimpseDay);

      print('====== results: ${results}');

      final List<Uint8List?> imgs = <Uint8List?>[];

      for (int i = 0; i < results.length; i++) {
        final String? path = _imagePathOf(results[i]);
        if (path == null) {
          imgs.add(null);
        } else {
          imgs.add(await _readImageBytes(path));
        }
      }

      if (mounted) {
        setState(() {
          _glimpses = results;
          _images = imgs;
          _isLoadingImages = false;
          _decelRequested = true; // request deceleration, but not yet
          setEffectiveCircleRadius();
        });
      } else {
        _isLoadingImages = false;
        _decelRequested = true; // request deceleration
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _glimpses = <Glimpse>[];
          _images = <Uint8List?>[];
          _isLoadingImages = false;
          _decelRequested = true; // DO NOT call _beginDeceleration() here
          setEffectiveCircleRadius();
        });
      } else {
        _isLoadingImages = false;
        _decelRequested = true; // DO NOT call _beginDeceleration() here
      }
    }
  }

  void setEffectiveCircleRadius() {
    // Most specific condition first to avoid double scaling.
    if (_effectiveCounts > 10.0) {
      print('====== > 9');
      setState(() {
        _effectiveCircleRadius = _effectiveCircleRadius * 3.6;
      });
    } else {
      if (_effectiveCounts >= 0) {
        print('====== > 6');
        setState(() {
          _effectiveCircleRadius = _effectiveCircleRadius * 3.3;
        });
      } else {
        // Keep as-is.
      }
    }
  }

  /// Extract the primary image path from a Glimpse.
  String? _imagePathOf(Glimpse g) {
    // TODO: adjust this to your model. Use the correct field that stores the main image path.
    // Example assumption:
    if (g.photoPath != null && g.photoPath!.isNotEmpty) {
      return g.photoPath!;
    } else {
      return null;
    }
  }

  /// Read image bytes from filesystem safely.
  Future<Uint8List?> _readImageBytes(String path) async {
    try {
      final File f = File(path);
      if (await f.exists()) {
        return await f.readAsBytes();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    if (_ticker.isActive == true) {
      _ticker.stop();
    } else {
      // already stopped
    }
    _ticker.dispose();
    super.dispose();
  }

  /// Build the full list of orbiting cards, evenly spaced outside the circle.
  List<Widget> _buildOrbitCards() {
    // global rotation offset in radians
    final double baseRad =
        ((_rotationDegrees + _autoSpinDegrees) * math.pi / 180.0);

    final int counts = math.max(1, _effectiveCounts);

    // circumference and card size
    double circumference = 2.0 * math.pi * _effectiveCircleRadius;

    double cardWidth = circumference / counts;
    double cardHeight = cardWidth * 0.75; // 4:3 (w:h) -> h = w * 3/4

    // enforce a max height to avoid overgrowing cards
    final double maxCardHeight = widget.widgetSize.height / 3.6;
    if (cardHeight > maxCardHeight) {
      cardHeight = maxCardHeight;
      cardWidth = cardHeight * (4.0 / 3.0);
    } else {
      // keep base 4:3
    }

    // compute pixel target for decoding (device pixels)
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final int targetWidthPx = math.max(1, (cardWidth * dpr).round());
    final int targetHeightPx = math.max(1, (cardHeight * dpr).round());

    // place radius puts card center outside the circle by half height + gap
    final double placeRadius =
        _effectiveCircleRadius + (cardHeight / 2.0) + _outsideGap;

    // center of the scene in the outer SizedBox
    final Offset sceneCenter =
        Offset(widget.widgetSize.width / 2.0, widget.widgetSize.height / 2.0);

    // angular step
    final double dTheta = (2.0 * math.pi) / counts;

    final List<Widget> cards = <Widget>[];
    for (int i = 0; i < counts; i++) {
      final double theta = i * dTheta + baseRad; // add global rotation offset

      // position (outside the circle)
      final double cx = sceneCenter.dx + placeRadius * math.cos(theta);
      final double cy = sceneCenter.dy + placeRadius * math.sin(theta);

      // rotate each card so its long axis aligns with the radial normal (pointing outward)
      final double rotateRad = theta;

      final Uint8List? img = _images.isEmpty
          ? null
          : _images[i % _images.length]; // cycle when counts > images

      cards.add(
        Positioned(
          left: cx - (cardWidth / 2.0),
          top: cy - (cardHeight / 2.0),
          width: cardWidth,
          height: cardHeight,
          child: Transform.rotate(
            angle: rotateRad,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JournalsView(
                            selectedGlimpseDay: widget.selectedGlimpseDay,
                          )),
                )
              },
              child: Card(
                elevation: 3.0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardWidth * 0.06),
                ),
                child: _buildCardContent(img, targetWidthPx, targetHeightPx),
              ),
            ),
          ),
        ),
      );
    }

    return cards;
  }

  /// Build the content of a single card: image if available, otherwise a placeholder.
  /// Build the content of a single card: image if available, otherwise a placeholder.
  Widget _buildCardContent(
      Uint8List? imgBytes, int cacheWidth, int cacheHeight) {
    if (imgBytes == null) {
      return Container(
        color: _cardColor,
        alignment: Alignment.center,
        child: const Text(
          'No Image',
          // comments must be in English per your rule
          style: TextStyle(fontSize: 12.0, color: Colors.white),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.zero, // card shape already has radius
        child: Image.memory(
          imgBytes,
          // Decode directly to a downscaled raster near display size (device pixels).
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          // prefer speed
          gaplessPlayback: true, // avoid brief flicker on image swap
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gesture area covers the entire widget; not dependent on card count.
    return Container(
      color: Colors.transparent,
      width: widget.widgetSize.width,
      height: widget.widgetSize.height,
      child: ClipRect(
        // clip to the outer container's bounds
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) {
            _onPanEndOrCancel();
          },
          onPanCancel: _onPanEndOrCancel,
          child: Stack(
            // Hard clip at the outer boundary so overflow is cut off.
            clipBehavior: Clip.hardEdge,
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                left: 10,
                top: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    widget.setIsDisplayingGlimpses();
                  },
                ),
              ),

              // Centered tilted stage with a FIXED size equal to widget.widgetSize.
              Align(
                alignment: Alignment.center,
                child: Transform(
                  alignment: Alignment.center,
                  transform: _buildTiltMatrix(),
                  child: SizedBox(
                    width: widget.widgetSize.width,
                    height: widget.widgetSize.height,
                    child: Stack(
                      // Do not clip inside; outer ClipRect already clips to widget bounds.
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        // If you want the circle visible, uncomment this:
                        // Align(
                        //   alignment: Alignment.center,
                        //   child: _buildCircle(),
                        // ),
                        // Orbiting cards; positions computed around the FIXED center.
                        ..._buildOrbitCards(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
