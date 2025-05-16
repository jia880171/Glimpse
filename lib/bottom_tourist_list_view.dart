import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import './config.dart' as config;

import 'database_sqlite/attraction.dart';
import 'database_sqlite/attraction_db.dart';

class BottomTouristList extends StatefulWidget {
  final List<Attraction> attractions;
  final double screenWidth;
  final double screenHeight;

  final AttractionDatabaseHelper attractionDatabaseHelper;
  final Attraction visitingAttraction;
  final Function(Attraction) updateVisitingAttraction;
  final Function(Attraction) toggleDisplayAttractionsView;

  const BottomTouristList(
    this.screenHeight,
    this.screenWidth,
    this.attractions,
    this.attractionDatabaseHelper,
    this.visitingAttraction,
    this.updateVisitingAttraction,
    this.toggleDisplayAttractionsView, {
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BottomTouristListState createState() => _BottomTouristListState();
}

class _BottomTouristListState extends State<BottomTouristList> {
  Attraction home = Attraction(
      sequenceNumber: 0,
      name: 'Taiwan',
      memo: 'Default',
      date: '19930312',
      longitude: 121.597366,
      latitude: 25.105497,
      arrivalTime: '199303121',
      departureTime: '19931312',
      arrivalStation: 'tokyo',
      departureStation: 'tokyo',
      isVisited: false,
      isNavigating: false,
      isVisiting: false);

  Attraction findLastVisitedItem(List<Attraction> attractions) {
    var lastVisitedAttraction = home;

    for (Attraction attraction in attractions) {
      if (attraction.isVisited == true) {
        lastVisitedAttraction = attraction;
      }
    }

    return lastVisitedAttraction;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight * 0.3,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: widget.attractions.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: index == 0
                    ? const BorderSide(
                        color: Colors.grey, // Customize the color as needed
                        width: 0.5, // Customize the width as needed
                      )
                    : BorderSide.none,
                bottom: const BorderSide(
                  color: Colors.grey, // Customize the color as needed
                  width: 0.5, // Customize the width as needed
                ),
              ),
            ),
            child: ListTile(
              title: GestureDetector(
                onTap: () async {
                  // widget.attractions[index].isVisiting =
                  //     !widget.attractions[index].isVisiting;
                  //
                  // widget.updateVisitingAttraction(widget.attractions[index]);
                  setState(() {
                    widget.toggleDisplayAttractionsView(
                        widget.attractions[index]
                    );
                  });
                },
                child: Text(widget.attractions[index].name,
                    style: TextStyle(
                        fontFamily: 'Lucida',
                        fontSize: widget.screenWidth * 0.05,
                        fontWeight: FontWeight.normal)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // flag(visited) icon
                  SizedBox(
                    height: widget.screenHeight * 0.05,
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        depth: widget.attractions[index].isVisited ? -1.5 : 1.5,
                        color: config.backGroundWhite,
                      ),
                      onPressed: () async {
                        // Toggle the icon
                        widget.attractions[index].isVisited =
                            !widget.attractions[index].isVisited;
                        var lastVisitedAttraction =
                            findLastVisitedItem(widget.attractions);

                        setState(() {
                          widget
                              .updateVisitingAttraction(lastVisitedAttraction);
                        });

                        // Update DB
                        await widget.attractionDatabaseHelper
                            .updateAttraction(widget.attractions[index]);
                      },
                      child: Center(
                        child: NeumorphicIcon(
                          style: const NeumorphicStyle(
                            depth: 1,
                            color: config.flagRed,
                          ),
                          Icons.flag_circle,
                          size: widget.screenHeight * 0.03,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widget.screenWidth * 0.03,
                  ),

                  // Navigation icon
                  // when the button is clicked the item will be set to navigation target
                  // SizedBox(
                  //   height: widget.screenHeight * 0.05,
                  //   child: NeumorphicButton(
                  //     style: NeumorphicStyle(
                  //       depth:
                  //           widget.attractions[index].isNavigating ? -1.5 : 1.5,
                  //       color: config.backGroundWhite,
                  //     ),
                  //     onPressed: () async {
                  //       for (int i = 0; i < widget.attractions.length; i++) {
                  //         widget.attractions[i].isNavigating = false;
                  //         await widget.attractionDatabaseHelper
                  //             .updateAttraction(widget.attractions[i]);
                  //       }
                  //       widget.attractions[index].isNavigating = true;
                  //       await widget.attractionDatabaseHelper
                  //           .updateAttraction(widget.attractions[index]);
                  //
                  //       setState(() {
                  //         widget.updateTargetAttraction(
                  //             widget.attractions[index]);
                  //         // for (int i = 0; i < widget.attractions.length; i++) {
                  //         //   widget
                  //         //       .updateTargetAttraction(widget.attractions[i]);
                  //         // }
                  //       });
                  //     },
                  //     child: Center(
                  //       child: NeumorphicIcon(
                  //         style: const NeumorphicStyle(
                  //           depth: 1,
                  //           color: Colors.grey,
                  //         ),
                  //         Icons.navigation,
                  //         size: widget.screenHeight * 0.03,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
