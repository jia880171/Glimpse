import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../config.dart' as config;
import '../grey_glass.dart';
import 'horizontal_date_timeline.dart';

const modeYear = 0;
const modeMonth = 1;
const modeDate = 2;

class TimelineGroup extends StatefulWidget {
  final double widgetWidth;
  final double widgetHeight;
  final double blur;
  final Color radioBackLightColor;
  final Color radioGlassColor;

  final DateTime selectedDate;
  final Map<DateTime, int> photosCountPerDay;

  const TimelineGroup({
    super.key,
    required this.widgetWidth,
    required this.widgetHeight,
    required this.blur,
    required this.radioBackLightColor,
    required this.radioGlassColor,
    required this.selectedDate,
    required this.photosCountPerDay,
  });

  @override
  State<TimelineGroup> createState() => _TimelineGroupState();
}

class _TimelineGroupState extends State<TimelineGroup> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        timelineGroup(),

        const GreyGlass(lightRadius: 2, blur: 0.2, borderRadiusCircular: 5),

        // Positioned.fill(
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(5),
        //     child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        //         child: Stack(
        //           children: [
        //             // inner light
        //             Container(
        //               decoration: BoxDecoration(
        //                 color: config.nikonRadioBackLight.withOpacity(0.1),
        //                 gradient: LinearGradient(
        //                   colors: [
        //                     // Colors.white.withOpacity(0.5),
        //                     Colors.white.withOpacity(0.1),
        //                     Colors.white.withOpacity(0.2),
        //                     Colors.white.withOpacity(0.3)
        //                   ],
        //                   begin: Alignment.topRight,
        //                   end: Alignment.bottomLeft,
        //                 ),
        //               ),
        //             ),
        //
        //             // subtle orange
        //             ShaderMask(
        //               shaderCallback: (bounds) {
        //                 return RadialGradient(
        //                   center: const Alignment(0, 1),
        //                   radius: 2,
        //                   colors: [
        //                     config.nikonRadioBackLight.withOpacity(0.3),
        //                     config.nikonRadioBackLight.withOpacity(0.15),
        //                     config.nikonRadioBackLight.withOpacity(0.05),
        //                   ],
        //                 ).createShader(bounds);
        //               },
        //               blendMode: BlendMode.softLight,
        //               child: Container(
        //                 color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
        //               ),
        //             ),
        //
        //             // red light
        //             ShaderMask(
        //               shaderCallback: (bounds) {
        //                 return RadialGradient(
        //                   center: const Alignment(0, -1),
        //                   radius: 2,
        //                   colors: [
        //                     Colors.red.withOpacity(0.08),
        //                     Colors.red.withOpacity(0.02),
        //                   ],
        //                 ).createShader(bounds);
        //               },
        //               blendMode: BlendMode.softLight,
        //               child: Container(
        //                 color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
        //               ),
        //             ),
        //
        //             // white light
        //             ShaderMask(
        //               shaderCallback: (bounds) {
        //                 return RadialGradient(
        //                   center: const Alignment(0, 1),
        //                   radius: 3,
        //                   colors: [
        //                     Colors.white.withOpacity(0.1),
        //                     Colors.white.withOpacity(0.05),
        //                     Colors.white.withOpacity(0.01),
        //                   ],
        //                 ).createShader(bounds);
        //               },
        //               blendMode: BlendMode.softLight,
        //               child: Container(
        //                 color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
        //               ),
        //             ),
        //
        //             // black shadow
        //             ShaderMask(
        //               shaderCallback: (bounds) {
        //                 return RadialGradient(
        //                     center: const Alignment(0, 0),
        //                     radius: 1.68,
        //                     colors: [
        //                       Colors.black.withOpacity(0.0),
        //                       Colors.black.withOpacity(0.068),
        //                       Colors.black.withOpacity(0.268),
        //                     ],
        //                     stops: const [
        //                       0,
        //                       0.5,
        //                       0.9
        //                     ]).createShader(bounds);
        //               },
        //               blendMode: BlendMode.softLight,
        //               child: Container(
        //                 color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
        //               ),
        //             ),
        //
        //             Positioned.fill(
        //               child: ClipRRect(
        //                 borderRadius: BorderRadius.circular(5),
        //                 child: Opacity(
        //                   opacity: 0.068,
        //                   child: Image.asset(
        //                     'assets/images/glass2.png',
        //                     fit: BoxFit.cover,
        //                     colorBlendMode: BlendMode.screen,
        //                     color: Colors.white.withOpacity(0),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         )),
        //   ),
        // ),
      ],
    );
  }

  Widget timelineGroup() {
    double outerPadding = widget.widgetWidth * 0.003;

    double innerWidth = widget.widgetWidth-outerPadding*2;
    double innerHeight = widget.widgetHeight * 0.95;

    double padding = innerWidth * 0.0168;

    double dateHeight = innerHeight * 0.3;
    double monthHeight = innerHeight * 0.3 - padding;
    double yearHeight = innerHeight * 0.3 - padding;
    double gapHeight = innerHeight * 0.05; // * 2

    return Container(
      decoration: BoxDecoration(
        color: config.mainBackGroundWhite,
        borderRadius: BorderRadius.circular(6)
      ),
      child: Padding(
        padding: EdgeInsets.all(outerPadding), // 外層 padding
        child: Neumorphic(
          style: NeumorphicStyle(
            color: config.mainBackGroundWhite,
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(6)),
            intensity: 1,
            depth: -1,
          ),
          child: Padding(
            padding: EdgeInsets.all(padding), // 內層 padding
            child: Column(
              children: [
                _buildTimelineItem(innerWidth, dateHeight, padding, modeDate),
                SizedBox(height: gapHeight),
                _buildTimelineItem(innerWidth, monthHeight, padding, modeMonth),
                SizedBox(height: gapHeight),
                _buildTimelineItem(innerWidth, yearHeight, padding, modeYear),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      double width, double height, double paddingW, int modeType) {
    return Neumorphic(
      style: NeumorphicStyle(
        color: config.mainBackGroundWhite,
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(2)),
        intensity: 1,
        depth: -2.68,
      ),
      child: HorizontalDateTimeline(
        size: Size(width - paddingW * 2, height),
        selectedDate: widget.selectedDate,
        photosCountPerDay: widget.photosCountPerDay,
        modeType: modeType,
      ),
    );
  }
}
