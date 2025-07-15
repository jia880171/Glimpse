import 'package:flutter/material.dart';

class FilmEdgeShape {
  static void draw(
      Canvas canvas,
      Size size, {
        bool isConvexUp = false,
        Color color = Colors.black,
      }) {
    final Paint paint = Paint()..color = color;
    final double w = size.width;
    final double h = size.height;
    final Path path = Path();

    if (isConvexUp) {
      // 兩邊弧線都凸起向上（中間高）
      path.moveTo(0, h); // 左下
      // 下弧凸起向上 → 中間點 y < h （比底部高）
      path.quadraticBezierTo(w / 2, h * 0.7, w, h);
      path.lineTo(w, 0); // 右上
      // 上弧凸起向上 → 中間點 y < 0（比頂部更高，y < 0）
      path.quadraticBezierTo(w / 2, -h * 0.3, 0, 0);
    } else {
      // 兩邊弧線都凸起向下（中間低）
      path.moveTo(0, 0); // 左上
      path.quadraticBezierTo(w / 2, h * 0.3, w, 0); // 上弧向下凸
      path.lineTo(w, h); // 右下
      path.quadraticBezierTo(w / 2, h * 1.3, 0, h); // 下弧向下凸
    }

    path.close();
    canvas.drawPath(path, paint);
  }
}

