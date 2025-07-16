import 'package:flutter/cupertino.dart';
import '../../config.dart' as config;

class FilmRowLeftSide extends StatelessWidget {
  final double height; // Total height (including spacing) passed as a parameter
  final double width;
  final double holeHeight; // The height of each hole
  final Color backLight;
  final int index;

  const FilmRowLeftSide({
    super.key,
    required this.height,
    required this.holeHeight,
    required this.backLight,
    required this.width,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final gapWidthBetweenHole = holeHeight;
    // Calculate the number of rectangles that can fit within the total height
    final numberOfRectangles =
    (height / (holeHeight + gapWidthBetweenHole)).floor();

    return Container(
      // color: Colors.green,
        width: width,
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: RotatedBox(
                quarterTurns: 1, // 90 degrees clockwise
                child: Container(
                  width: height,
                  height: width * 0.3,
                  // color: Colors.red,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        '${index}',
                        style: TextStyle(
                            color: config.dateColor,
                            // fontSize: width * 0.3 * 0.36,
                            fontSize: width * 0.3 * 0.6,
                            fontFamily: 'Anton'),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: List.generate(
                numberOfRectangles,
                    (index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: width * 0.25,
                        height: holeHeight,
                      ),
                      Container(
                        width: width * 0.5,
                        height: holeHeight,
                        margin: EdgeInsets.only(
                            top: gapWidthBetweenHole / 2,
                            bottom: gapWidthBetweenHole / 2),
                        decoration: BoxDecoration(
                          color: backLight,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.25,
                        height: holeHeight,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }
}
