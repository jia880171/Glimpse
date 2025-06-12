import 'dart:math';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/rotatable_Glimpse_card_back_view.dart';
import 'package:glimpse/rotatable_Glimpse_card_front_view.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:isar/isar.dart';

class RotatableGlimpseCardView extends StatefulWidget {
  final Uint8List image;
  final Map<String?, IfdTag> exifData;
  final String imagePath;
  final Color backLight;
  final bool isNeg;
  final int index;
  final Size cardSize;
  final Function leaveCardMode;

  const RotatableGlimpseCardView({
    Key? key,
    required this.image,
    required this.exifData,
    required this.imagePath,
    required this.backLight,
    this.index = 0,
    required this.isNeg,
    required this.cardSize,
    required this.leaveCardMode,
  }) : super(key: key);

  @override
  RotatableGlimpseCardViewState createState() =>
      RotatableGlimpseCardViewState();
}

class RotatableGlimpseCardViewState extends State<RotatableGlimpseCardView>
    with SingleTickerProviderStateMixin {
  Glimpse? _glimpse;

  double _rotationY = 0.0; // 當前旋轉角度
  late AnimationController _controller;
  late Animation<double> _animation;
  double _velocity = 0.0;

  Size? _screenSize;

  // Size _cardSize = const Size(200, 200);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000000),
    );

    _controller.addListener(() {
      setState(() {
        _rotationY += _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _velocity = 0.0;
      }
    });

    loadGlimpse();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
  }

  Future<void> loadGlimpse() async {
    // Get the single shared Isar instance.
    final isar = DatabaseService.isar;

    final glimpse = await isar.glimpses
        .filter()
        .photoPathEqualTo(widget.imagePath)
        .findFirst();

    print('====== [loading Glimpse], glimpse: ${glimpse ?? 'null'}');

    if (glimpse != null) {
      setState(() {
        _glimpse = glimpse;
      });
    }
  }

  void _startInertiaAnimation(double velocity) {
    const friction = 0.39; // 阻力係數
    final initialVelocity = velocity * 0.00008;

    double distance =
        -velocity.sign * initialVelocity * initialVelocity / (2 * friction);

    _animation = Tween<double>(begin: 0.0, end: distance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward(from: 0.0);
  }

  Widget _buildFront() {
    return SizedBox(
      // width: _cardSize.width,
      // height: _cardSize.height,
      child: RotatableGlimpseCardFrontView(
        index: widget.index,
        cardSize: widget.cardSize,
        image: widget.image,
        imagePath: widget.imagePath,
        exifData: widget.exifData,
        backLight: widget.backLight,
        isNeg: widget.isNeg,
        leaveCardMode: widget.leaveCardMode,
      ),
    );
  }

  Widget _buildBack() {
    return SizedBox(
      // width: _cardSize.width,
      // height: _cardSize.height,
      child: RotatableGlimpseCardBackView(
        cardSize: widget.cardSize,
        imagePath: widget.imagePath,
        glimpse: _glimpse,
        exifData: widget.exifData,
      ),
    );
  }

  Widget _buildCard(double angle) {
    // 角度超過 π/2（90°）時，顯示背面
    final isFront = cos(angle) >= 0;

    if (isFront) {
      return _buildFront();
    } else {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(pi),
        child: _buildBack(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 244, 229, 0.3),
      body: Center(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            _controller.stop(); // 拖動時停止動畫
            setState(() {
              _rotationY -= details.delta.dx * 0.03;
            });
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond.dx;
            if (velocity.abs() > 200) {
              _startInertiaAnimation(velocity);
            }
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_rotationY),
            child: _buildCard(_rotationY),
          ),
        ),
      ),
    );
  }
}
