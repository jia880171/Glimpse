import 'dart:math';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/models/glimpse.dart';

import '../../config.dart' as config;
import '../cirvular_text.dart';
import 'rotatable_card/rotatable_Glimpse_card_back_view.dart';

class ExifCard extends StatelessWidget {
  final Glimpse glimpse;
  final Size cardSize;

  const ExifCard({
    super.key,
    required this.glimpse,
    required this.cardSize,
  });

  @override
  Widget build(BuildContext context) {
    double sectionHeight = cardSize.height * 0.1;
    return Card(
      color: config.hardCardYellow.withOpacity(0),
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(9),
        ),
      ),
      child: SizedBox(
        width: cardSize.width,
        height: cardSize.height,
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
                          config.hardCardPaperWDarker,
                          config.hardCardPaperW,
                          config.hardCardPaperWDarker,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.0066,
                      child: Image.asset(
                        'assets/images/noise.png',
                        fit: BoxFit.cover,
                        color: config.hardCardPaperWDarker.withOpacity(0.12),
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
                  // title
                  SizedBox(
                    height: cardSize.height * 0.2,
                    child: Column(
                      children: [
                        SizedBox(height: cardSize.height * 0.02),
                        buildFakeHole(size: cardSize.height * 0.03),
                        buildNeumorphicTitle(
                          text: 'EXIF DATA',
                          textColor: Colors.grey.withOpacity(0.9),
                          fontSize: cardSize.height * 0.06,
                          depth: 0.3,
                          intensity: 0.66,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lucida',
                        ),
                        Divider(
                          thickness: 1.5,
                          indent: cardSize.width * 0.05,
                          endIndent: cardSize.width * 0.05,
                        ),
                      ],
                    ),
                  ),

                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'Make:',
                    value: glimpse.imageMake,
                    color: config.hardCardBlue,
                  ),

                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'Model:',
                    value: glimpse.cameraModel,
                    color: config.hardCardBlue,
                  ),

                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'Lens:',
                    value: glimpse.lensModel,
                    color: config.hardCardRed,
                  ),
                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'Shutter:',
                    value: glimpse.shutterSpeed,
                    color: config.backLightB,
                  ),
                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'Aperture:',
                    value: glimpse.aperture,
                    color: config.backLightB,
                  ),
                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'ISO:',
                    value: glimpse.iso,
                    color: config.backLightB,
                  ),
                  _buildExifSection(
                    sectionHeight: sectionHeight,
                    hint: 'Taken on:',
                    value: glimpse.exifDateTime?.toIso8601String() ?? 'N/A',
                    color: config.hardCardRed,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: cardSize.height * 0.15,
              child: CircularTextDemo(
                text: 'E X I F',
                color: config.hardCardRed,
                fontSize: 18,
                radius: cardSize.height * 0.11,
                size: 180,
                opacity: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExifSection({
    required String hint,
    required String? value,
    required Color color,
    required double sectionHeight,
  }) {
    return Container(
      // color: Colors.red,
      height: sectionHeight,
      child: Column(
        children: [
          hintAndTitle(
            widgetHeight: sectionHeight * 0.8,
            hint: hint,
            hintColor: color.withOpacity(.66),
            hintSize: sectionHeight*0.8 * 0.2,
            hintAngle: -0.2,
            title: value ?? 'N/A',
            titleColor: color.withOpacity(.66),
            titleSize: sectionHeight*0.8 * 0.2,
            titleAngle: 0.3,
            titleFontFamily: 'Anton',
          ),
          SizedBox(
            height:  sectionHeight * 0.2,
            child: Divider(
              thickness: 1,
              indent: sectionHeight * 0.05,
              endIndent: sectionHeight * 0.05,
            ),
          )
          ,
        ],
      ),
    );
  }

  Widget hintAndTitle(
      {required double widgetHeight,
      required String hint,
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
        Container(
          height: widgetHeight*0.3,
          // color: Colors.green,
          child: Row(
            children: [
              SizedBox(
                width: cardSize.width * 0.06,
              ),
              Transform.rotate(
                angle: hintAngle * pi / 180,
                child: Text(
                  hint,
                  style: TextStyle(
                      fontFamily: 'Anton',
                      fontSize: hintSize,
                      color: hintColor),
                ),
              )
            ],
          ),
        ),
        Container(
          height: widgetHeight*0.7,
          child: Transform.rotate(
            angle: titleAngle * pi / 180,
            child: Padding(
              padding: EdgeInsets.only(
                  left: cardSize.width * 0.1, right: cardSize.width * 0.1),
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

        )
        ,
      ],
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
}
