import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class AnimatedNeumorphicText extends StatelessWidget {
  final String text;
  final double prevDepth;
  final double depth;
  final VoidCallback onTap;
  final double fontSize;
  final Color color;
  final Duration depthInDuration;
  final Duration depthOutDuration;

  const AnimatedNeumorphicText({
    super.key,
    required this.text,
    required this.prevDepth,
    required this.depth,
    required this.onTap,
    required this.fontSize,
    required this.color,
    required this.depthInDuration,
    required this.depthOutDuration,
  });

  Duration get animationDuration {
    if (depth == 0) return depthOutDuration;
    if (depth == 0.5) return depthInDuration;
    return const Duration(milliseconds: 100);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$text-$prevDepth-$depth'),
      tween: Tween(begin: prevDepth, end: depth),
      duration: animationDuration,
      builder: (context, animatedDepth, _) {
        return IgnorePointer(
          ignoring: depth == 0,
          child: GestureDetector(
            onTap: onTap,
            child: NeumorphicText(
              '$text',
              style: NeumorphicStyle(
                depth: animatedDepth,
                color: depth == 0 ? color.withOpacity(0) : color,
                intensity: 0.6,
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: fontSize,
                fontFamily: 'Jura',
              ),
            ),
          ),
        );
      },
    );
  }
}
