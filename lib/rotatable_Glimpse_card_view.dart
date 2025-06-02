import 'dart:math';

import 'package:exif/src/exif_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glimpse/rotatable_Glimpse_card_back_view.dart';
import 'package:glimpse/rotatable_Glimpse_card_front_view.dart';

class RotatableGlimpseCardView extends StatefulWidget {
  final String? imagePath;
  final Uint8List image;
  final Map<String?, IfdTag> exifData;
  final String imgPath;
  final Color backLight;
  final bool isNeg;
  final int index;

  const RotatableGlimpseCardView({
    Key? key,
    required this.image,
    this.imagePath,
    required Map<String?, IfdTag> this.exifData,
    required String this.imgPath,
    required this.backLight,
    this.index = 0,
    required this.isNeg,
  }) : super(key: key);

  @override
  RotatableGlimpseCardViewState createState() =>
      RotatableGlimpseCardViewState();
}

class RotatableGlimpseCardViewState extends State<RotatableGlimpseCardView>
    with SingleTickerProviderStateMixin {
  double _rotationY = 0.0; // 當前旋轉角度
  late AnimationController _controller;
  late Animation<double> _animation;
  double _velocity = 0.0;

  Size? _screenSize;
  Size _cardSize = Size(200, 200);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000000),
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    _cardSize = Size(
      _screenSize!.width * 0.9,
      _screenSize!.height * 0.6,
    );
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
        cardSize: _cardSize,
        image: widget.image,
        imagePath: widget.imagePath,
        exifData: widget.exifData,
        backLight: widget.backLight,
        isNeg: widget.isNeg,
      ),
    );
  }

  Widget _buildBack() {
    return SizedBox(
      // width: _cardSize.width,
      // height: _cardSize.height,
      child: RotatableGlimpseCardBackView(
        cardSize: _cardSize,
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
