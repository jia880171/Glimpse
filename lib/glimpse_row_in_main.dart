import 'dart:math';
import 'package:flutter/material.dart';

class GlimpseRowCard extends StatelessWidget {
  final DateTime date;
  final double rowWidth;
  final List<String> dayOfTheWeekList;

  const GlimpseRowCard({
    super.key,
    required this.date,
    required this.rowWidth, required this.dayOfTheWeekList,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: rowWidth * 0.8,
      child: Stack(
        children: [
          Divider(),
          Row(
            children: [
              Text(
                'Date:    ',
                style: TextStyle(
                  fontFamily: 'Jura',
                  fontSize: rowWidth * 0.8 * 0.6 * 0.1,
                  color: Colors.black,
                ),
              ),
              Transform.rotate(
                angle: 3 * pi / 180,
                child: Text(
                  '${date.year} / ${date.month} / ${date.day}',
                  style: TextStyle(
                    fontFamily: 'Meow',
                    fontSize: rowWidth * 0.8 * 0.6 * 0.138,
                    color: Colors.black.withOpacity(0.36),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: 0,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  dayOfTheWeekList[(date.weekday - 1) % 7],
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'asa',
                    fontSize: rowWidth * 0.8 * 0.6 * 0.066,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
