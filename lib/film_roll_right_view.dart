import 'package:flutter/cupertino.dart';
import './config.dart' as config;

class FilmRowRightSide extends StatefulWidget {
  final double height; // Total height (including spacing) passed as a parameter
  final double width;
  final double holeHeight; // The height of each hole
  final Color backLight;
  final String filmMaker;
  final String filmDate;

  const FilmRowRightSide({
    super.key,
    required this.height,
    required this.holeHeight,
    required this.backLight,
    required this.width,
    required this.filmMaker,
    required this.filmDate,
  });

  @override
  State<FilmRowRightSide> createState() => _FilmRowRightSideState();
}

class _FilmRowRightSideState extends State<FilmRowRightSide> {
  late int numberOfRectangles;
  late double gapWidthBetweenHole;

  @override
  void initState() {
    super.initState();
    gapWidthBetweenHole = widget.holeHeight;
    numberOfRectangles =
        (widget.height / (widget.holeHeight + gapWidthBetweenHole)).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                width: widget.height,
                height: widget.width * 0.3,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      widget.filmMaker,
                      style: TextStyle(
                        fontSize: widget.width * 0.3 * 0.5,
                        color: config.dateColor,
                        fontFamily: 'DS-DIGI',
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    const Spacer(),
                    Text(
                      widget.filmDate.split(' ')[0],
                      style: TextStyle(
                        fontSize: widget.width * 0.3 * 0.5,
                        color: config.dateColor,
                        fontFamily: 'DS-DIGI',
                      ),
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
                      width: widget.width * 0.25,
                      height: widget.holeHeight,
                    ),
                    Container(
                      width: widget.width * 0.5,
                      height: widget.holeHeight,
                      margin: EdgeInsets.only(
                        top: gapWidthBetweenHole / 2,
                        bottom: gapWidthBetweenHole / 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.backLight,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    SizedBox(
                      width: widget.width * 0.25,
                      height: widget.holeHeight,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
