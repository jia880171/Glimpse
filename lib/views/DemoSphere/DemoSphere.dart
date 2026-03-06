import 'dart:math' as math;

import 'package:flutter/material.dart';

// 球體尺寸相對於螢幕寬度的比例，愈大球愈佔滿畫面。
const double kDemoSphereRadiusFactor = 1;
// 控制點在南北極的集中程度：小於 1 越靠近兩端越密集，大於 1 則越接近赤道。
const double kPolarConcentrationExponent = 0.3;

// 點的總數，越多越密集但也越耗效能。
const dotNum = 1688;

// 呼吸動畫的週期，數值越小速度越快。
const Duration kPulseDuration = Duration(milliseconds: 9666);

// 呼吸時點大小的振幅，越大脈動越明顯。
const double kPulseAmplitude = 0.6;

// 飄移距離乘數，越大白點漂的範圍越大。
const double kDriftRangeMultiplier = 9;

class DemoSphere extends StatefulWidget {
  const DemoSphere({super.key});

  @override
  State<DemoSphere> createState() => _DemoSphereState();
}

class _DemoSphereState extends State<DemoSphere> with SingleTickerProviderStateMixin {
  // 旋轉角（弧度），左右 / 上下旋轉。
  double yaw = 0.0;
  double pitch = 0.0;

  // 球心拖移偏移量，可用來做整個球的平移。
  Offset centerOffset = Offset.zero;

  // 點雲
  late final List<_Vec3> points;
  late final AnimationController _pulseController;

  // 手感調整
  final double rotateSensitivity = 0.01; // 越大旋轉越靈敏
  @override
  void initState() {
    super.initState();
    points = _generateSpherePoints(count: dotNum, seed: DateTime.now().millisecondsSinceEpoch);
    _pulseController = AnimationController(vsync: this, duration: kPulseDuration)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 單指拖：旋轉
  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      yaw += d.delta.dx * rotateSensitivity;
      pitch -= d.delta.dy * rotateSensitivity;
      // 避免翻到奇怪角度（可拿掉）
      pitch = pitch.clamp(-math.pi / 2, math.pi / 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          // 球體的實際半徑，跟螢幕寬度成比例。
          final double radius = size.width * kDemoSphereRadiusFactor;
          final center = Offset(size.width / 2, size.height / 2) + centerOffset;

          return GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _SpherePainter(
                  points: points,
                  center: center,
                  radius: radius,
                  yaw: yaw,
                  pitch: pitch,
                  pulseValue: _pulseController.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpherePainter extends CustomPainter {
  final List<_Vec3> points;
  final Offset center;
  final double radius;
  final double yaw;
  final double pitch;
  final double pulseValue;

  _SpherePainter({
    required this.points,
    required this.center,
    required this.radius,
    required this.yaw,
    required this.pitch,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景（可省略，Scaffold 已黑底）
    // canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    // 相機參數
    const double cameraDist = 3.0; // 越大越“平”（透視弱）
    final double r = radius;

    // 先算旋轉矩陣（yaw around Y, pitch around X）
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cx = math.cos(pitch), sx = math.sin(pitch);

    // 旋轉後的點會依 z 排序：先畫遠的、後畫近的會比較像 3D
    final projected = <_Projected>[];

    for (final p in points) {
      // 原點在球心，半徑=1 的單位球；放大到 r
      var x = p.x;
      var y = p.y;
      var z = p.z;

      // yaw: 繞Y軸
      final x1 = x * cy + z * sy;
      final z1 = -x * sy + z * cy;

      // pitch: 繞X軸
      final y2 = y * cx - z1 * sx;
      final z2 = y * sx + z1 * cx;

      x = x1;
      y = y2;
      z = z2;

      // 透視投影：scale = 1/(cameraDist - z)
      final depth = (cameraDist - z).clamp(0.2, 10.0);
      final scale = 1.0 / depth;

      final sx2d = center.dx + x * r * scale;
      final sy2d = center.dy + y * r * scale;

      // 點的亮度/大小依 z（越靠近越亮越大）
      final t = ((z + 1) / 2).clamp(0.0, 1.0); // z in [-1,1] -> [0,1]
      final alpha = (0.9 + 0.1 * t);
      final baseRadius = (0.6 + 1.8 * t) * scale * 0.6;
      final phase = pulseValue * 2 * math.pi + p.pulsePhase;
      final breathingFactor = 1 + kPulseAmplitude * p.pulseAmplitude * math.sin(phase);
      final dotRadius = baseRadius * breathingFactor.clamp(0.4, 1.6);

      final driftBase = dotRadius * kDriftRangeMultiplier * p.driftMagnitude;
      final driftPhase = pulseValue * 4 * math.pi + p.driftPhase; // 加快且使用各自相位
      final driftOffsetX = p.driftDirX * math.sin(driftPhase) * driftBase;
      final driftOffsetY = p.driftDirY * math.cos(driftPhase) * driftBase;
      final driftX = driftOffsetX * 0.8; // 調整比例讓軌跡有橢圓感
      final driftY = driftOffsetY;

      projected.add(_Projected(x: sx2d + driftX, y: sy2d + driftY, z: z, a: alpha, r: dotRadius));
    }

    projected.sort((a, b) => a.z.compareTo(b.z)); // 先遠後近

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final q in projected) {
      paint.color = Colors.white.withOpacity(q.a);
      canvas.drawCircle(Offset(q.x, q.y), q.r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpherePainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.points != points ||
        oldDelegate.pulseValue != pulseValue;
  }
}

// === 3D & helper ===

class _Vec3 {
  final double x, y, z;
  final double driftDirX, driftDirY; // 漂移方向（單位向量）
  final double driftPhase; // 漂移起始相位，決定開始時的位置
  final double driftMagnitude; // 漂移強度（0~1）
  final double pulsePhase; // 呼吸起始相位
  final double pulseAmplitude; // 呼吸大小倍率

  const _Vec3(
    this.x,
    this.y,
    this.z, {
    required this.driftDirX,
    required this.driftDirY,
    required this.driftPhase,
    required this.driftMagnitude,
    required this.pulsePhase,
    required this.pulseAmplitude,
  });
}

class _Projected {
  final double x, y, z, a, r;
  const _Projected({required this.x, required this.y, required this.z, required this.a, required this.r});
}

/// 生成均勻分布在球面的點（Fibonacci sphere / 或用球座標+修正）
List<_Vec3> _generateSpherePoints({required int count, int seed = 0}) {
  // Fibonacci sphere：分布很漂亮、速度快
  final rnd = math.Random(seed);
  final points = <_Vec3>[];
  final goldenAngle = math.pi * (3 - math.sqrt(5));

  for (int i = 0; i < count; i++) {
    final t = i / (count - 1);
    final linearY = 1 - 2 * t; // 1 -> -1
    final sign = linearY >= 0 ? 1.0 : -1.0;
    final biasedAbs = math.pow(linearY.abs(), kPolarConcentrationExponent).toDouble();
    final y = (sign * biasedAbs).clamp(-1.0, 1.0);
    final radius = math.sqrt(1 - y * y);
    final theta = goldenAngle * i + rnd.nextDouble() * 0.6; // 少量抖動更自然

    final x = math.cos(theta) * radius;
    final z = math.sin(theta) * radius;

    final driftAngle = rnd.nextDouble() * 2 * math.pi;
    final driftDirX = math.cos(driftAngle);
    final driftDirY = math.sin(driftAngle);
    final driftMagnitude = rnd.nextDouble(); // 0~1
    final driftPhase = rnd.nextDouble() * 2 * math.pi;
    final pulsePhase = rnd.nextDouble() * 2 * math.pi;
    final pulseAmplitude = 0.5 + rnd.nextDouble() * 0.5; // 0.5 ~ 1.0

    points.add(
      _Vec3(
        x,
        y,
        z,
        driftDirX: driftDirX,
        driftDirY: driftDirY,
        driftPhase: driftPhase,
        driftMagnitude: driftMagnitude,
        pulsePhase: pulsePhase,
        pulseAmplitude: pulseAmplitude,
      ),
    );
  }
  return points;
}
