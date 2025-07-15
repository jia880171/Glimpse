import 'dart:ui';

import 'package:flutter/material.dart';

class GreyGlass extends StatefulWidget {
  final double lightRadius;
  final double blur;
  final double borderRadiusCircular;

  const GreyGlass(
      {Key? key,
        required this.lightRadius,
        required this.blur,
        required this.borderRadiusCircular})
      : super(key: key);

  @override
  GreyGlassState createState() => GreyGlassState();
}

class GreyGlassState extends State<GreyGlass> {
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
    return Positioned.fill(
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
                    center: lightAliment,
                    radius: widget.lightRadius,
                    colors: [
                      radioBackLightColor.withOpacity(0.03),
                      radioBackLightColor.withOpacity(0.01),
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.softLight,
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),

              // black shadow
              ShaderMask(
                shaderCallback: (bounds) {
                  return RadialGradient(
                      center: blackLightAliment,
                      radius: widget.lightRadius * 0.5,
                      colors: [
                        Colors.black.withOpacity(0.001),
                        Colors.black.withOpacity(0.03),
                        Colors.black.withOpacity(0.04),
                        Colors.black.withOpacity(0.05),
                      ],
                      stops: const [
                        0.0,
                        0.9,
                        0.95,
                        0.99
                      ]).createShader(bounds);
                },
                blendMode: BlendMode.softLight,
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),

              // texture overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Opacity(
                    opacity: 0.0168,
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
          ),
        ),
      ),
    );
  }
}
