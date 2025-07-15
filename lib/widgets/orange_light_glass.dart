import 'dart:ui';

import 'package:flutter/material.dart';

class OrangeGlass extends StatefulWidget {
  final double lightRadius;
  final double blur;
  final double borderRadiusCircular;

  const OrangeGlass(
      {Key? key,
      required this.lightRadius,
      required this.blur,
      required this.borderRadiusCircular})
      : super(key: key);

  @override
  _OrangeGlassState createState() => _OrangeGlassState();
}

class _OrangeGlassState extends State<OrangeGlass> {
  late Color radioGlassColor;
  late Color radioBackLightColor;

  Alignment lightAliment = Alignment.topCenter;
  Alignment blackLightAliment = Alignment.center;

  @override
  void initState() {
    super.initState();
    radioGlassColor = Colors.white.withOpacity(0.9);
    radioBackLightColor = Colors.orange;
  }

  @override
  Widget build(BuildContext context) {

    return
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadiusCircular),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: Stack(
                children: [

                  // subtle orange
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return RadialGradient(
                        center: const Alignment(0, 1),
                        radius: widget.lightRadius*0.6,
                        colors: [
                          radioBackLightColor.withOpacity(0.15),
                          radioBackLightColor.withOpacity(0.15),
                          radioBackLightColor.withOpacity(0.05),
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.softLight,
                    child: Container(
                      color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                    ),
                  ),

                  // red light
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return RadialGradient(
                        center: const Alignment(0, -1),
                        radius: widget.lightRadius*0.3,
                        colors: [
                          Colors.red.withOpacity(0.02),
                          Colors.red.withOpacity(0.01),
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.softLight,
                    child: Container(
                      color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                    ),
                  ),

                  // black shadow
                  // ShaderMask(
                  //   shaderCallback: (bounds) {
                  //     return RadialGradient(
                  //         center: Alignment.topCenter,
                  //         radius: widget.lightRadius*0.1,
                  //
                  //         colors: [
                  //           Colors.black.withOpacity(0.0),
                  //           Colors.black.withOpacity(0.1),
                  //           Colors.black.withOpacity(0.1),
                  //         ],
                  //         stops: const [
                  //           0,
                  //           0.5,
                  //           0.8
                  //         ]).createShader(bounds);
                  //   },
                  //   blendMode: BlendMode.softLight,
                  //   child: Container(
                  //     color: Colors.white.withOpacity(0.05), // 光感混合用 base 色
                  //   ),
                  // ),

                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadiusCircular),
                      child: Opacity(
                        opacity: 0.09,
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
      );

  }
}
