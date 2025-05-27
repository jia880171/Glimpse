import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/cirvular_text.dart';

import './config.dart' as config;

class RotatableGlimpseCardBackView extends StatefulWidget {
  final String? cardID;
  final Size cardSize;

  const RotatableGlimpseCardBackView(
      {Key? key, required this.cardSize, this.cardID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RotatableGlimpseCardBackViewState();
}

class RotatableGlimpseCardBackViewState
    extends State<RotatableGlimpseCardBackView> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: _buildCardCaseWithCard(),
          ),
        ));
  }

  Widget _buildCardCaseWithCard() {
    return Card(
        // color: config.backGroundWhite,
        color: config.hardCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        child: SizedBox(
          width: widget.cardSize.width,
          height: widget.cardSize.height,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: _isTapped ? widget.cardSize.width * 0.06 : 0,
                right: 0,
                bottom: _isTapped ? widget.cardSize.height * 0.08 : 0,
                // 向上移動 10
                child: Center(
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _isTapped = true;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _isTapped = false;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _isTapped = false;
                      });
                    },
                    child: Stack(
                      children: [
                        _buildCard(),

                        // Positioned(
                        //   top: widget.cardSize.height * 0.4,
                        //   left: widget.cardSize.width * 0.1,
                        //   child: Transform.rotate(
                        //     angle: 1 * pi / 180,
                        //     child: _buildReceiptCard(),
                        //   ),
                        // ),

                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            // 這邊改成你的 Card 圓角大小
                            child: Opacity(
                              opacity: 0.1,
                              child: Image.asset(
                                'assets/images/plastic_overlay2.png',
                                fit: BoxFit.cover,
                                colorBlendMode: BlendMode.screen,
                                color: Colors.white.withOpacity(0),
                              ),
                            ),
                          ),
                        ),
                        // blur
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.01),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                            top: 0,
                            right: widget.cardSize.width * 0.1,
                            child: sticker()),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: 0,
                  bottom: 0,
                  child: Card(
                    // color: Colors.white,
                    color: config.hardCard,
                    elevation: 3,
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                    child: SizedBox(
                      width: widget.cardSize.width * 0.8,
                      height: widget.cardSize.height * 0.168,
                      // child: Center(child: Text('Card')),
                      child: Stack(
                        children: [
                          Positioned(
                              top: widget.cardSize.width * 0.03,
                              right: widget.cardSize.width * 0.03,
                              child: NeumorphicText(
                                'Unick Co.',
                                style: const NeumorphicStyle(
                                  depth: .3,
                                  intensity: 1,
                                  // color: Colors.white,
                                  color: config.hardCard,
                                ),
                                textStyle: NeumorphicTextStyle(
                                  fontSize: widget.cardSize.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Opacity(
                                opacity: 0.0766,
                                child: Image.asset(
                                  'assets/images/noise.png',
                                  fit: BoxFit.cover,
                                  color: Colors.brown.withOpacity(0.2),
                                  colorBlendMode: BlendMode.multiply,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }

  Widget _buildCard() {
    return buildPlaceCard();
  }

  Widget buildPlaceCard() {
    return Card(
      color: config.hardCardYellow.withOpacity(0),
      // color: config.hardCardYellow,

      shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(9))),
      child: SizedBox(
          width: widget.cardSize.width * 0.8,
          height: widget.cardSize.height * 0.85,
          child: Stack(
            children: [
              ClipPath(
                clipper: CustomBeveledClipper(),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            config.hardCardYellowDark,
                            config.hardCardYellow,
                            // config.hardCardYellowLight,
                            // config.hardCardYellow,
                            config.hardCardYellowDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.0766,
                        child: Image.asset(
                          'assets/images/noise.png',
                          fit: BoxFit.cover,
                          color: Colors.brown.withOpacity(0.2),
                          colorBlendMode: BlendMode.multiply,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: widget.cardSize.height * 0.02,
                    ),
                    buildFakeHole(size: widget.cardSize.height * 0.03),
                    buildNeumorphicTitle(
                        text: 'GLIMPSE',
                        // textColor: config.hardCardYellow,
                        textColor: config.hardCardYellowDark,
                        fontSize: widget.cardSize.height * 0.06,
                        depth: 0.3,
                        intensity: 0.66,
                        fontWeight: FontWeight.bold,
                        // fontFamily: 'Anton'
                        fontFamily: 'Lucida'),
                    Divider(
                        thickness: 1.5,
                        indent: widget.cardSize.width * 0.05,
                        endIndent: widget.cardSize.width * 0.05),
                    cardSection(
                        hint: 'Location:',
                        hintColor: config.hardCardBlue.withOpacity(.66),
                        hintSize: widget.cardSize.width * 0.03,
                        hintAngle: -0.1,
                        title: 'YOKOHAMA ENGLISH GARDEN',
                        titleColor: config.hardCardBlue.withOpacity(0.66),
                        titleSize: widget.cardSize.width * 0.05,
                        titleAngle: 1.0,
                        titleFontFamily: 'Anton'),
                    Divider(
                        thickness: 1.5,
                        indent: widget.cardSize.width * 0.05,
                        endIndent: widget.cardSize.width * 0.05),
                    cardSection(
                        hint: 'Date:',
                        hintColor: config.hardCardRed.withOpacity(.8),
                        hintSize: widget.cardSize.width * 0.03,
                        hintAngle: -0.2,
                        title: '2025-05-10',
                        titleColor: config.hardCardRed.withOpacity(.66),
                        titleSize: widget.cardSize.width * 0.05,
                        titleAngle: -2,
                        titleFontFamily: 'Anton'),
                    Divider(
                        thickness: 1.5,
                        indent: widget.cardSize.width * 0.05,
                        endIndent: widget.cardSize.width * 0.05),
                    cardSection(
                        hint: 'Note:',
                        hintColor: config.backLightB.withOpacity(.6),
                        hintSize: widget.cardSize.width * 0.03,
                        hintAngle: -0.2,
                        title:
                            ' It\'s a new dawn. It\'s a new day. It\'s a new life for me. And I\'m feeling good.',
                        titleColor: config.backLightB.withOpacity(.6),
                        titleSize: widget.cardSize.width * 0.033,
                        titleAngle: 0.5,
                        titleFontFamily: 'sacramento'),
                    Divider(
                        thickness: 1.5,
                        indent: widget.cardSize.width * 0.05,
                        endIndent: widget.cardSize.width * 0.05),
                    cardSection(
                        hint: 'No:',
                        hintColor: config.backLightB.withOpacity(.6),
                        hintSize: widget.cardSize.width * 0.03,
                        hintAngle: -0.2,
                        title: '08-1688-888',
                        titleColor: config.hardCardRed.withOpacity(.6),
                        titleSize: widget.cardSize.width * 0.03,
                        titleAngle: 3,
                        titleFontFamily: 'Anton'),
                  ],
                ),
              ),
              Positioned(
                  right: 0,
                  top: widget.cardSize.height * 0.15,
                  child: CircularTextDemo(
                      text: 'UNICK Co. CONFIRMED',
                      color: config.hardCardRed,
                      fontSize: 18,
                      radius: widget.cardSize.height * 0.11,
                      size: 180,
                      opacity: 0.3)),
            ],
          )),
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      child: Stack(
        children: [
          Container(
            width: widget.cardSize.width * 0.5,
            height: widget.cardSize.height * 0.5,
            color: config.receipt,
          ),
          Container(
              width: widget.cardSize.width * 0.5,
              child: Column(
                children: [
                  // Container(
                  //   width: widget.cardSize.width * 0.5,
                  //   height: widget.cardSize.height * 0.5,
                  //   color: config.receipt,
                  // ),
                  Container(
                    margin: EdgeInsets.only(top: widget.cardSize.height*0.02),
                    width: widget.cardSize.width * 0.5,
                    child: Row(
                      children: [
                        const Spacer(),
                        Center(
                          // color: Colors.red,
                          // width: widget.cardSize.width * 0.3,
                          // height: widget.cardSize.height * 0.5 * 0.1,
                          child: Text(
                            'Receipt',
                            style: TextStyle(
                              fontFamily: 'Ds-Digi',
                              fontSize: widget.cardSize.width * 0.5 * 0.1,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  Container(
                    // color: Colors.red,
                    width: widget.cardSize.width * 0.5,
                    child:  Divider(
                      color: Colors.black,
                      endIndent: widget.cardSize.width * 0.5 * 0.1,
                      indent: widget.cardSize.width * 0.5 * 0.1,
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }

  Widget buildFakeHole({
    double size = 10,
    Color colorHole = Colors.white,
    Color colorRim = config.hardCardRed,
    Widget? child,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colorRim,
            shape: BoxShape.circle,
          ),
          child: child != null ? Center(child: child) : null,
        ),
        Container(
          width: size * 0.75,
          height: size * 0.75,
          decoration: BoxDecoration(
            color: colorHole,
            shape: BoxShape.circle,
          ),
          child: child != null ? Center(child: child) : null,
        )
      ],
    );
  }

  Widget cardSection(
      {required String hint,
      required Color hintColor,
      required double hintSize,
      required double hintAngle,
      required String title,
      required Color titleColor,
      required double titleSize,
      required double titleAngle,
      required String titleFontFamily}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: widget.cardSize.width * 0.06,
            ),
            Transform.rotate(
              angle: hintAngle * pi / 180,
              child: Text(
                hint,
                style: TextStyle(
                    fontFamily: 'Anton', fontSize: hintSize, color: hintColor),
              ),
            )
          ],
        ),
        Transform.rotate(
          angle: titleAngle * pi / 180,
          child: Padding(
            padding: EdgeInsets.only(
                left: widget.cardSize.width * 0.1,
                right: widget.cardSize.width * 0.1),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: titleFontFamily,
                fontSize: titleSize,
                color: titleColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNeumorphicTitle(
      {required String text,
      required Color textColor,
      required double fontSize,
      required double depth,
      required double intensity,
      required FontWeight fontWeight,
      required String fontFamily}) {
    return NeumorphicText(
      text,
      style: NeumorphicStyle(
        depth: depth, // 正值為凸起，負值為凹陷
        intensity: intensity,
        color: textColor, // 字的顏色
      ),
      textStyle: NeumorphicTextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
      ),
    );
  }

  Widget sticker() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            width: widget.cardSize.width * 0.25,
            // height: widget.cardSize.height * 0.1,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: widget.cardSize.width * 0.06,
                  left: widget.cardSize.width * 0.02,
                  right: widget.cardSize.width * 0.02,
                  bottom: widget.cardSize.width * 0.03,
                ),
                child: Transform.rotate(
                  angle: 3.5 * pi / 180,
                  child: Text(
                    'Glimpse\nPack.',
                    style: TextStyle(
                        fontFamily: 'Jura',
                        fontSize: widget.cardSize.width * 0.035,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: widget.cardSize.width * 0.25,
            child: Divider(
              endIndent: 5,
              indent: 5,
              color: Colors.black.withOpacity(0.3), // 調整顏色
              thickness: 0.66,
            ),
          ),
          Text(
            'Limited',
            style: TextStyle(
                fontFamily: 'Jura',
                fontSize: widget.cardSize.width * 0.03,
                color: Colors.black),
          )
        ],
      ),
    );
  }
}

class CustomBeveledClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const topLeftCut = 20.0;
    const topRightCut = 20.0;
    const bottomRightCut = 9.0;

    final path = Path();

    // 起點在左上切角後的點
    path.moveTo(0, topLeftCut);
    path.lineTo(topLeftCut, 0); // top-left 斜角

    path.lineTo(size.width - topRightCut, 0);
    path.lineTo(size.width, topRightCut); // top-right 斜角

    path.lineTo(size.width, size.height - bottomRightCut);
    path.lineTo(size.width - bottomRightCut, size.height); // bottom-right 斜角

    path.lineTo(0, size.height); // bottom-left 保持直角
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
