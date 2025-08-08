// import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config.dart' as config;
import '../../models/friend.dart';
import '../../models/glimpse.dart';
import '../../models/receipt.dart';

class LeftRotatableBackCardWidget extends StatefulWidget {
  final Glimpse? glimpse;
  final Receipt? receipt;
  final Size cardSize;
  final Uint8List? scannedImageBytes;

  const LeftRotatableBackCardWidget({
    Key? key,
    required this.cardSize,
    this.glimpse,
    this.receipt,
    this.scannedImageBytes,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LeftRotatableBackCardWidgetState();
}

class LeftRotatableBackCardWidgetState
    extends State<LeftRotatableBackCardWidget> {
  late final List<Widget> barcode;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: _buildCard(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    barcode = _generateBarcode(widget.cardSize.width);
  }

  Widget _buildCard() {
    final List<String> tags = ['居酒屋', '喫茶店', 'バー'];

    final selectedTags = widget.receipt?.shopType.value?.name != null
        ? <String>[widget.receipt!.shopType.value!.name]
        : <String>[];
    return Card(
      // color: config.hardCard,
      // color: const Color(0xffd2cec5).withOpacity(0.6),
      color: config.dashboardBackGroundMainTheme.withOpacity(0.68),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      child: Container(
        width: widget.cardSize.width,
        height: widget.cardSize.height,
        alignment: Alignment.center,
        child: Stack(
          children: [

            if (widget.receipt != null)
              Center(
                child: receipt(
                  tags,
                  selectedTags,
                  Size(widget.cardSize.width * 0.8,
                      widget.cardSize.height * 0.8),
                ),
              ),

            if (widget.scannedImageBytes != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Transform.rotate(
                  angle: 1.6 * pi / 180,
                  child: SizedBox(
                    width: widget.cardSize.width * 0.68,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        widget.scannedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget receipt(List<String> tags, List<String> selectedTags, Size paperSize) {
    return SizedBox(
      width: paperSize.width,
      height: paperSize.height,
      child: Transform.rotate(
          angle: 1.5 * pi / 180, // 5 度 => 弧度
          child: Container(
            color: Colors.white.withOpacity(1),
            width: paperSize.width,
            height: paperSize.height,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: paperSize.width,
                      height: paperSize.height * 0.05,
                    ),

                    // RECEIPT
                    Container(
                      width: paperSize.width,
                      height: paperSize.height * 0.1,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            16,
                            widget.cardSize.height * 0.01,
                            16,
                            widget.cardSize.height * 0.01),
                        child: Center(
                          child: Text(
                            'RECEIPT',
                            style: TextStyle(
                                fontSize: paperSize.height * 0.03,
                                fontFamily: 'Questrial'),
                          ),
                        ),
                      ),
                    ),

                    // Date
                    Container(
                        // color: Colors.red,
                        width: paperSize.width,
                        height: paperSize.height * 0.05,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  const Spacer(),
                                  Text(
                                    'No.${widget.receipt?.id.toString().padLeft(4, '0') ?? '----'}',
                                    style: TextStyle(
                                      fontSize: paperSize.height * 0.1 * 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  Spacer(),
                                  Text(
                                    widget.glimpse?.exifDateTime
                                            ?.toString()
                                            .substring(0, 10) ??
                                        '',
                                    style: TextStyle(
                                        fontSize: paperSize.height * 0.1 * 0.2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paperSize.width * 0.05),
                      child: Divider(
                        color: Colors.grey, // 顏色
                        thickness: 0.38, // 粗細
                        height: widget.cardSize.height *
                            0.005, // 上下間距（影響的是 Row/Column spacing）
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paperSize.width * 0.05),
                      child: Divider(
                        color: Colors.grey, // 顏色
                        thickness: 0.38, // 粗細
                        height: widget.cardSize.height *
                            0.005, // 上下間距（影響的是 Row/Column spacing）
                      ),
                    ),

                    // shop name
                    Container(
                        // color: Colors.red,
                        width: paperSize.width,
                        height: paperSize.height * 0.15,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Spacer(),
                              Text(
                                widget.receipt?.shopName ?? '',
                                style: TextStyle(
                                  fontSize: widget.cardSize.height * 0.1 * 0.6,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        )),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paperSize.width * 0.05),
                      child: Divider(
                        color: Colors.grey, // 顏色
                        thickness: 0.68, // 粗細
                        height: widget.cardSize.height *
                            0.01, // 上下間距（影響的是 Row/Column spacing）
                      ),
                    ),

                    Container(
                        // color: Colors.red,
                        width: paperSize.width,
                        height: paperSize.height * 0.1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: paperSize.width * 0.05),
                          child: Row(
                            children: [
                              const Spacer(),
                              for (int i = 0; i < tags.length; i++) ...[
                                if (i != 0) const Spacer(),
                                // 第 1 個之前不加 spacer，之後每個前面都 spacer
                                Column(
                                  children: [
                                    Spacer(),
                                    _buildTagWithCircle(
                                        selectedTags, tags, tags[i], paperSize),
                                    Spacer(),
                                  ],
                                ),
                              ],
                              const Spacer()
                            ],
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paperSize.width * 0.05),
                      child: Divider(
                        color: Colors.grey, // 顏色
                        thickness: 0.68, // 粗細
                        height: widget.cardSize.height *
                            0.01, // 上下間距（影響的是 Row/Column spacing）
                      ),
                    ),
                    Container(
                      width: paperSize.width,
                      height: paperSize.height * 0.1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: paperSize.width * 0.05),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'With:',
                              style: TextStyle(
                                fontSize: widget.cardSize.height * 0.1 * 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: _buildFriendWidgets(
                                    widget.cardSize.height * 0.1 * 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paperSize.width * 0.05),
                      child: Divider(
                        color: Colors.grey, // 顏色
                        thickness: 0.68, // 粗細
                        height: widget.cardSize.height *
                            0.01, // 上下間距（影響的是 Row/Column spacing）
                      ),
                    ),

                    Container(
                        // color: Colors.red,
                        width: paperSize.width,
                        height: paperSize.height * 0.1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: paperSize.width * 0.05),
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('Total:',
                                    style: TextStyle(
                                        fontSize: widget.cardSize.height *
                                            0.1 *
                                            0.2)),
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  const Spacer(),
                                  Text(
                                    '${widget.receipt?.totalCost ?? '----'} 円',
                                    style: TextStyle(
                                      fontSize:
                                          widget.cardSize.height * 0.1 * 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                            ],
                          ),
                        )),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paperSize.width * 0.05),
                      child: Divider(
                        color: Colors.grey, // 顏色
                        thickness: 0.68, // 粗細
                        height: widget.cardSize.height *
                            0.01, // 上下間距（影響的是 Row/Column spacing）
                      ),
                    ),

                    const Spacer(),

                    Container(
                      // color: Colors.red,
                      width: paperSize.width,
                      height: paperSize.height * 0.1,
                      child: Row(children: [Spacer(), ...barcode, Spacer()]),
                    ),
                    const Spacer(),
                  ],
                )
              ],
            ),
          )),
    );
  }

  List<Widget> _buildFriendWidgets(double fontSize) {
    final friends =
        widget.receipt?.friends.whereType<Friend>().map((f) => f.name).toList();

    if (friends == null || friends.isEmpty) return [];

    return friends
        .map((name) => Text(name, style: TextStyle(fontSize: fontSize)))
        .toList();
  }

  static List<Widget> _generateBarcode(double cardWidth) {
    List<Widget> barcode = [];
    double barcodeWidth = 0;

    while (barcodeWidth < 0.9) {
      double widthPercentage = Random().nextInt(10) * 0.006;
      barcodeWidth += widthPercentage;
      barcode.add(
        VerticalDivider(
          thickness:
              cardWidth * 0.4 * widthPercentage * Random().nextInt(10) * 0.1,
          width: cardWidth * 0.4 * widthPercentage,
          color: Colors.black,
        ),
      );
    }

    return barcode;
  }

  Widget _buildTagWithCircle(List<String> selectedTags, List<String> tags,
      String label, Size paperSize) {
    final isSelected = selectedTags.contains(label);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: SizedBox(
        // color: Colors.green,
        width: (paperSize.width - paperSize.width * 0.1) / (1.5 * tags.length),
        height: paperSize.height * 0.1 * 0.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              CustomPaint(
                painter: RoughCirclePainter(),
                // painter: RoughCheckPainter(),

                size: Size(
                  paperSize.width / (3 * tags.length),
                  paperSize.height * 0.1 * 0.6,
                ),
              ),
            SizedBox(
              height: widget.cardSize.height * 0.1 * 0.6,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: paperSize.width * (1 / tags.length) * 0.16,
                  fontFamily: 'Questrial',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoughCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.68)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 2;

    // 模擬手繪抖動 (簡單抖兩圈)
    final path = Path();
    for (int i = 0; i < 2; i++) {
      final jitter = i == 0 ? 0.0 : 1.2;
      path.addOval(Rect.fromCircle(
          center: center.translate(jitter, jitter), radius: radius + jitter));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoughCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.68)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final double width = size.width;
    final double height = size.height;

    // 模擬一個略帶手繪的打勾 ✓ 路徑
    path.moveTo(width * 0.25, height * 0.55);
    path.lineTo(width * 0.45, height * 0.75);
    path.lineTo(width * 0.75, height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
