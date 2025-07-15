import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/widgets/dashboard/semi_circle_point_gauge.dart';

import '../../config.dart' as config;
import '../grey_glass.dart';
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
  final bool isReset;
  final VoidCallback onImagesResetEnd;

  const Nikon28TiDashboard({
    super.key,
    required this.widgetSize,
    required this.imagesWithDummiesPointer,
    required this.imagesLength,
    required this.backgroundColor,
    required this.shutterSpeed,
    required this.aperture,
    required this.iso,
    required this.isReset,
    required this.onImagesResetEnd,
  });

  @override
  Widget build(BuildContext context) {
    double innerDashboardHeight = widgetSize.height * 0.85;
    double semiRadius = innerDashboardHeight * 0.5;
    double middleSectionWidth = widgetSize.height * 0.38 * 2;
    double circleInMiddleRadius = widgetSize.height * 0.28;
    double dashboardWidth = widgetSize.width;

    if (widgetSize.height.isNaN ||
        widgetSize.height.isInfinite ||
        widgetSize.height <= 0) {
      debugPrint("======Invalid widgetSize.height: ${widgetSize.height}");
      return const SizedBox.shrink();
    }


    return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.withOpacity(0.8), width: 1.2),
          borderRadius: BorderRadius.circular(innerDashboardHeight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
            )
          ],
        ),
        child: SizedBox(
          width: dashboardWidth,
          height: innerDashboardHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Neumorphic(
                style: NeumorphicStyle(
                  lightSource: LightSource.topRight,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(innerDashboardHeight),
                  ),
                  intensity: 1,
                  depth: -1,
                ),
                child: Container(
                  color: config.dashBoardW,
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
                            // color: config.hardCardYellowLight,
                            width: middleSectionWidth,
                            height: widgetSize.height,
                            child: Column(
                              children: [
                                CirclePointerGauge(
                                  currentIndex: imagesWithDummiesPointer - 1,
                                  // remove header
                                  itemLength: imagesLength - 2,
                                  // dummies header and tail
                                  radius: circleInMiddleRadius,
                                  backgroundColor: backgroundColor,
                                  isReset: isReset,
                                  onResetEnd: onImagesResetEnd,
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
                  borderRadius: BorderRadius.circular(innerDashboardHeight),
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset(
                      'assets/images/noise.png',
                      fit: BoxFit.cover,
                      color: Colors.white.withOpacity(0.28),
                      colorBlendMode: BlendMode.multiply,
                    ),
                  ),
                ),
              ),

              // OrangeGlass(
              //   lightRadius: 8,
              //   blur: 0.3,
              //   borderRadiusCircular: dashboardHeight,
              // )
              GreyGlass(
                lightRadius: 8,
                blur: 0.2,
                borderRadiusCircular: innerDashboardHeight,
              )
            ],
          ),
        ));
  }
}
