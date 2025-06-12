import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class ClickableNeumorphicIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  const ClickableNeumorphicIcon({
    Key? key,
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  ClickableNeumorphicIconState createState() =>
      ClickableNeumorphicIconState();
}

class ClickableNeumorphicIconState extends State<ClickableNeumorphicIcon> {
  final double depthMax = 1.5;
  late double _depth = depthMax;

  void _handleTap() {
    setState(() {
      _depth = 0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _depth = depthMax;
        });
      }
    });

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: NeumorphicIcon(
        widget.icon,
        size: widget.size,
        style: NeumorphicStyle(
          depth: _depth,
          color: widget.color,
        ),
      ),
    );
  }
}
