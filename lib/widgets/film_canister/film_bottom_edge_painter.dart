import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilmEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    final double w = size.width;
    final double h = size.height;

    final double offsetY = h * 0.3; // 往上平移的量

    final path = Path();

    // ▶ 起點：左上角 (0, 0)
    path.moveTo(0, 0);

    // ▶ 上圓弧（向下拱）
    path.quadraticBezierTo(w / 2, h * 0.2, w, 0);

    // ▶ 右直線向下
    path.lineTo(w, h * 0.4);

    // ▶ 下圓弧（向下拱）
    path.quadraticBezierTo(w / 2, h * 0.7, 0, h * 0.4);

    // ▶ 左直線向上（回到起點）
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

