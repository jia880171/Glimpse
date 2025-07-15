import 'dart:math';

import 'package:flutter/material.dart';

import 'film_bottom_edge_painter.dart';
import 'film_edge_shape.dart';

// width:height 1:7
class FilmCanisterWidget extends StatefulWidget {
  final double width;
  final String filmMaker;
  final String filmName;
  final String filmFormat;
  final String iso;
  final Color bodyColor;

  const FilmCanisterWidget({
    super.key,
    required this.width,
    required this.iso,
    this.bodyColor = Colors.yellow,
    required this.filmFormat,
    required this.filmMaker,
    required this.filmName,
  });

  @override
  State<FilmCanisterWidget> createState() => _FilmCanisterWidgetState();
}

class _FilmCanisterWidgetState extends State<FilmCanisterWidget> {
  @override
  Widget build(BuildContext context) {
    double height = widget.width * 1.7;
    return CustomPaint(
      size: Size(widget.width, height),
      painter: _FilmRollPainter(
        iso: widget.iso,
        bodyColor: widget.bodyColor,
        filmMaker: widget.filmMaker,
        filmSize: widget.filmFormat,
        filmName: widget.filmName,
      ),
    );
  }
}

class _FilmRollPainter extends CustomPainter {
  final String filmMaker;
  final String filmName;
  final String filmSize;
  final String iso;
  final Color bodyColor;

  _FilmRollPainter({
    required this.filmMaker,
    required this.filmName,
    required this.filmSize,
    required this.iso,
    required this.bodyColor,
  });

  get text => null;

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;

    final double shaftWidth = size.width * 0.5;
    final double shaftHeight = height * 0.1;

    final Paint bodyPaint = Paint()..color = bodyColor;

    final double bodyHeight = size.height * 0.85; // 留 15% 給底部邊緣
    final double topOvalHeight = size.height * 0.1;
    final double bottomEdgeHeight = size.height * 0.15;
    final filmBottomEdgePainter = FilmEdgePainter();

    // 畫主體
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.025, shaftHeight, size.width * 0.95, height * 0.85),
      bodyPaint,
    );

    // 上邊緣
    canvas.save(); // 保存狀態
    canvas.translate(0, shaftHeight);

    drawShaft(canvas, size, size.width, bottomEdgeHeight * 0.5, 0);
    canvas.restore(); // 回復狀態

    // 上轉軸
    double leftOffset = (size.width - shaftWidth) / 2;
    drawShaft(canvas, size, shaftWidth, shaftHeight, leftOffset);

    final double bodyTop = shaftHeight;
    final double bodyLeft = size.width * 0.025;
    final double bodyWidth = size.width * 0.95;

    final double fontUnit = bodyHeight / 6.5; // 多預留一格間距
    final double bigFontSize = fontUnit * 1.5;
    final double mediumFontSize = fontUnit * 1;
    final double smallFontSize = fontUnit * 0.8;

// 計算總字高：2 + 2 + 1 = 5 → 總高 5 * unit
    final double totalTextHeight = bigFontSize * 2 + smallFontSize;

// 垂直置中起點（y）
    final double textStartY = bodyTop + (bodyHeight - totalTextHeight) / 2;

// 水平置中（x）
    final double leftStart = bodyLeft + smallFontSize * 1.5;

// 三段垂直排列（靠中線）
    drawRotatedText(
      canvas,
      '$filmSize $filmName',
      position: Offset(leftStart, textStartY),
      angle: pi / 2,
      fontSize: smallFontSize,
    );

    drawRotatedText(
      canvas,
      iso,
      position: Offset(bodyWidth / 2 + bigFontSize / 1.5, textStartY),
      angle: pi / 2,
      fontSize: bigFontSize,
    );

    drawRotatedText(
      canvas,
      filmMaker,
      position: Offset(bodyWidth, textStartY),
      angle: pi / 2,
      fontSize: mediumFontSize,
    );

    // 下邊緣
    canvas.save(); // 保存狀態
    canvas.translate(
        0, topOvalHeight + bodyHeight - bottomEdgeHeight / 4); // 移動到底部位置
    filmBottomEdgePainter.paint(
      canvas,
      Size(size.width, bottomEdgeHeight),
    );
    canvas.restore();
  }

  void drawShaft(Canvas canvas, Size size, double shaftWidth,
      double shaftHeight, double leftOffset) {
    canvas.save();
    canvas.translate(leftOffset, 0); // 調整位置
    FilmEdgeShape.draw(
      canvas,
      Size(shaftWidth, shaftHeight),
      isConvexUp: true, // ⌒
      color: Colors.grey,
    );
    canvas.restore();

    double shaftRimWidth = shaftWidth * 0.2;

    canvas.save();
    canvas.translate(
        leftOffset + shaftRimWidth * 0.5, shaftRimWidth * 0.1); // 調整位置
    FilmEdgeShape.draw(
      canvas,
      Size(shaftWidth - shaftRimWidth, shaftHeight),
      isConvexUp: true, // ⌒
      color: Colors.black,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(leftOffset, 0); // 調整位置
    FilmEdgeShape.draw(
      canvas,
      Size(shaftWidth, shaftHeight),
      isConvexUp: false, // ⌒
      color: Colors.grey,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(leftOffset, shaftRimWidth * 0.025); // 調整位置
    FilmEdgeShape.draw(
      canvas,
      Size(shaftWidth, shaftHeight * 1.1),
      isConvexUp: false, // ⌒
      color: Colors.black,
    );
    canvas.restore();
  }

  void drawRotatedText(
    Canvas canvas,
    String text, {
    required Offset position, // ← 傳入文字原點位置（會當成旋轉中心）
    double angle = -pi / 2, // 預設轉 -90 度（順時針）
    double fontSize = 14,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();

    // 平移到欲繪製位置
    canvas.translate(position.dx, position.dy);
    // 以該點為中心旋轉
    canvas.rotate(angle);
    // 畫文字（以旋轉後的新原點為起點）
    textPainter.paint(canvas, const Offset(0, 0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FilmRollPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.bodyColor != bodyColor;
  }
}
