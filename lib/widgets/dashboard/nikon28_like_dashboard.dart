import 'dart:ui';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/widgets/dashboard/semi_circle_point_gauge.dart';

import '../../config.dart' as config;
import 'cirle_point_gauge.dart';

const List<String> shutterSpeeds = [
  '1/8000',
  '1/4000',
  '1/2000',
  '1/1000',
  '1/500',
  '1/250',
  '1/125',
  '1/60',
  '1/30',
  '1/15',
  '1/8',
  '1/4',
  '1/2',
  '1"',
  '2"',
  '4"',
  '8"',
  '15"',
  '30"'
];

const List<String> shutterSpeedsToDisplay = [
  '8000',
  '4000',
  '2000',
  '1000',
  '500',
  '250',
  '125',
  '60',
  '30',
  '15',
  '8',
  '4',
  '2',
  '1"',
  '2"',
  '4"',
  '8"',
  '15"',
  '30"'
];

const List<String> apertures = [
  'f/1.2',
  'f/1.4',
  'f/2',
  'f/2.8',
  'f/4',
  'f/5.6',
  'f/8',
  'f/11',
  'f/16',
  'f/22',
  'f/32'
];

class Nikon28TiDashboard extends StatelessWidget {
  final Color backgroundColor;
  final Size widgetSize;
  final int imagesWithDummiesPointer;
  final int imagesLength;
  final String shutterSpeed;
  final String aperture;
  final String iso;

  const Nikon28TiDashboard({
    super.key,
    required this.widgetSize,
    required this.imagesWithDummiesPointer,
    required this.imagesLength,
    required this.backgroundColor,
    required this.shutterSpeed,
    required this.aperture,
    required this.iso,
  });

  @override
  Widget build(BuildContext context) {
    double blur = 0.3;

    double dashboardHeight = widgetSize.height * 0.9;
    double semiRadius = dashboardHeight * 0.5;
    double circleRadius = widgetSize.height * 0.38;
    double dashboardWidth = semiRadius * 2.3 + circleRadius * 2;

    return Container(
      // color: Colors.red,
      width: dashboardWidth,
      height: dashboardHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              lightSource: LightSource.topRight,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(dashboardHeight),
              ),
              intensity: 1,
              depth: -1,
            ),
            child: Container(
              width: dashboardWidth,
              height: dashboardHeight,
              color: backgroundColor,
              child: Stack(
                children: [
                  Center(
                    child: SemiCirclePointerGauge(
                      currentValue: shutterSpeed,
                      items: shutterSpeeds,
                      radius: semiRadius,
                      backgroundColor: backgroundColor,
                      isRight: false,
                      itemsToDisplay: shutterSpeedsToDisplay,
                    ),
                  ),
                  Center(
                      child: Container(
                    // color: Colors.red,
                    width: circleRadius * 2,
                    height: widgetSize.height,
                    child: Column(
                      children: [
                        CirclePointerGauge(
                          currentIndex: imagesWithDummiesPointer - 1, // remove header
                          itemLength: imagesLength - 2, // dummies header and tail
                          radius: circleRadius,
                          backgroundColor: backgroundColor,
                        ),
                      ],
                    ),
                  )),
                  Center(
                    child: SemiCirclePointerGauge(
                      currentValue: aperture,
                      items: apertures,
                      radius: semiRadius,
                      backgroundColor: backgroundColor,
                      isRight: true,
                      itemsToDisplay: apertures,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(dashboardHeight),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Stack(
                    children: [
                      // inner light
                      Container(
                        decoration: BoxDecoration(
                          color: config.nikonRadioBackLight.withOpacity(0.1),
                          gradient: LinearGradient(
                            colors: [
                              // Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.3)
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                      ),

                      // subtle orange
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return RadialGradient(
                            center: Alignment.bottomCenter,
                            radius: 1,
                            colors: [
                              config.nikonRadioBackLight.withOpacity(0.02),
                              config.nikonRadioBackLight.withOpacity(0.01),
                              config.nikonRadioBackLight.withOpacity(0.005),
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.softLight,
                        child: Container(
                          color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                        ),
                      ),

                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(widgetSize.height * 0.5),
                          child: Opacity(
                            opacity: 0.168,
                            child: Image.asset(
                              'assets/images/glass2.png',
                              fit: BoxFit.cover,
                              colorBlendMode: BlendMode.screen,
                              color: Colors.white.withOpacity(0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
