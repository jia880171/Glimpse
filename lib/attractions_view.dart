import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/attraction_display_view.dart';
import 'database/attraction.dart';
import 'database/attraction_db.dart';

class AttractionsView extends StatefulWidget {
  final Attraction currentAttraction;
  final Function(Attraction? attraction) toggleDisplayAttractionsView;
  final List<Attraction> attractions;
  final Function() fetchAttractions;

  const AttractionsView(
      this.currentAttraction,
      this.toggleDisplayAttractionsView,
      this.attractions,
      this.fetchAttractions,
      {Key? key})
      : super(key: key);

  @override
  _AttractionsState createState() {
    return _AttractionsState();
  }
}

class _AttractionsState extends State<AttractionsView> {
  final AttractionDatabaseHelper attractionDatabaseHelper =
      AttractionDatabaseHelper();
  var isDisplaySaveButton = false;
  late Attraction _currentAttraction;
  bool isEditingMode = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    // TODO: implement build
    return Container(
        color: Colors.white.withOpacity(0.95),
        // margin: EdgeInsets.only(top: screenHeight * 0.0),
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            // Background?
            SizedBox(
              height: screenHeight,
            ),

            // BackButton
            Container(
                // color: Colors.red,
                width: screenWidth,
                height: screenHeight * 0.1,
                margin: EdgeInsets.only(top: screenHeight * 0.05),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(
                    onPressed: () => {
                      widget.toggleDisplayAttractionsView(
                          widget.currentAttraction)
                    },
                  ),
                )),

            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.15),
              child: widget.attractions.isNotEmpty
                  ? Container(
                      width: screenWidth  ,
                      height: screenHeight * 0.52,
                      child: ListView.builder(
                        itemCount: widget.attractions.length,
                        itemBuilder: (context, index) {
                          return AttractionDisplayView(
                              attraction: widget.attractions[index],
                              widgetHeight: screenHeight * 0.5,
                              widgetWidth: screenWidth * 0.8,
                              displaySaveButton: displaySaveButton,
                              swipeLeft: swipeLeft,
                              swipeRight: swipeRight,
                              toggleAttractionMode: toggleAttractionMode,
                              fetchAttractions: widget.fetchAttractions,
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    )
                  : const Center(child: Text('No Attraction')),
            ),
          ],
        ));
  }

  void displaySaveButton() {
    setState(() {
      isDisplaySaveButton = true;
    });
  }

  void toggleAttractionMode() {
    setState(() {
      isEditingMode = !isEditingMode;
    });
  }

  void swipeLeft() {
    int index = findIndexInAttractionById(_currentAttraction.id as int);
    if (index < widget.attractions.length - 1) {
      index++;

      setState(() {
        _currentAttraction = widget.attractions[index];
      });
    }
  }

  void swipeRight() {
    int index = findIndexInAttractionById(_currentAttraction.id as int);
    print('====== B index:${index}');
    print('====== B id:${_currentAttraction.id}');

    if (index > 0) {
      index--;
      print('====== A index: ${index}');

      setState(() {
        _currentAttraction = widget.attractions[index];
        print('====== A id${_currentAttraction.id}');
        print('====== A name${_currentAttraction.name}');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentAttraction = widget.currentAttraction;
  }

  int findIndexInAttractionById(int currentCardId) {
    int index = 0;
    widget.attractions.asMap().forEach((key, value) {
      print('key: $key, id${value.id}, dep station: ${value.departureStation}');
      if (value.id == currentCardId) {
        index = key;
      }
    });
    return index;
  }
}

// class _AttractionsState extends State<AttractionsView> {
//   final AttractionDatabaseHelper attractionDatabaseHelper =
//       AttractionDatabaseHelper();
//   var isDisplaySaveButton = false;
//
//   late Attraction _updatedAttraction;
//   late Attraction _currentAttraction;
//
//   void displaySaveButton() {
//     setState(() {
//       isDisplaySaveButton = true;
//     });
//   }
//
//   void updateCurrentAttractionInAttractionsView(Attraction updatedAttraction) {
//     setState(() {
//       _updatedAttraction = updatedAttraction;
//     });
//   }
//
//   bool isEditingMode = false;
//
//   void toggleAttractionMode() {
//     setState(() {
//       isEditingMode = !isEditingMode;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _currentAttraction = widget.currentAttraction;
//   }
//
//   int findIndexInAttractionById(int currentCardId) {
//     int index = 0;
//     widget.attractions.asMap().forEach((key, value) {
//       print('key: $key, id${value.id}, dep station: ${value.departureStation}');
//       if (value.id == currentCardId) {
//         index = key;
//       }
//     });
//     return index;
//   }
//
//   void swipeLeft() {
//     int index = findIndexInAttractionById(_currentAttraction.id as int);
//     if (index < widget.attractions.length - 1) {
//       index++;
//
//       setState(() {
//         _currentAttraction = widget.attractions[index];
//       });
//     }
//   }
//
//   void swipeRight() {
//     int index = findIndexInAttractionById(_currentAttraction.id as int);
//     print('====== B index:${index}');
//     print('====== B id:${_currentAttraction.id}');
//
//     if (index > 0) {
//       index--;
//       print('====== A index: ${index}');
//
//       setState(() {
//         _currentAttraction = widget.attractions[index];
//         print('====== A id${_currentAttraction.id}');
//         print('====== A name${_currentAttraction.name}');
//       });
//     }
//   }
//
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Positioned(
//       left: 0,
//       right: 0,
//       child: Container(
//           width: screenWidth,
//           height: screenHeight,
//           color: Colors.white.withOpacity(0.95),
//
//           // color: Colors.white70.withOpacity(0.9),
//           child: Column(
//             children: [
//               SizedBox(
//                 height: screenHeight * 0.08,
//               ),
//               SizedBox(
//                   // color: Colors.red,
//                   width: screenWidth,
//                   height: screenHeight * 0.05,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: BackButton(
//                       onPressed: () => {
//                         widget.toggleDisplayAttractionsView(
//                             widget.currentAttraction)
//                       },
//                     ),
//                   )),
//               if (!isEditingMode) ...[
//                 AttractionDisplayView(
//                   displaySaveButton: displaySaveButton,
//                   attraction: _currentAttraction,
//                   widgetHeight: screenHeight * 0.7,
//                   widgetWidth: screenWidth * 0.85,
//                   swipeLeft: swipeLeft,
//                   swipeRight: swipeRight,
//                   toggleAttractionMode: toggleAttractionMode,
//                 ),
//               ] else ...[
//                 AttractionEditView(
//                   displaySaveButton: displaySaveButton,
//                   attraction: _currentAttraction,
//                   widgetHeight: screenHeight * 0.7,
//                   widgetWidth: screenWidth * 0.85,
//                   onAttractionChanged: updateCurrentAttractionInAttractionsView,
//                 )
//               ],
//               const Spacer(),
//               if (isDisplaySaveButton) ...[
//                 GestureDetector(
//                   onTap: () async {
//                     print('====== about to update the attraction in db, name: ${widget.currentAttraction.name}');
//                     await attractionDatabaseHelper
//                         .updateAttraction(_updatedAttraction);
//                     setState(() {
//                       widget.fetchAttractions();
//                       widget.toggleDisplayAttractionsView(
//                           _updatedAttraction);
//                     });
//                   },
//                   child: Container(
//                     // color: Colors.green.withOpacity(0.3),
//                     height: screenHeight * 0.1,
//                     width: screenWidth,
//                     child: const Row(
//                       children: [
//                         Spacer(),
//                         Text('✔️ 儲存更改'),
//                         Spacer(),
//                       ],
//                     ),
//                   ),
//                 )
//               ] else ...[
//                 GestureDetector(
//                   onTap: () async {
//                     bool? confirmDelete = await showDialog<bool>(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           title: const Text('Confirm Deletion'),
//                           content: const Text(
//                               'Are you sure you want to delete this attraction?'),
//                           actions: <Widget>[
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context)
//                                     .pop(false); // User canceled the deletion
//                               },
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context)
//                                     .pop(true); // User confirmed the deletion
//                               },
//                               child: const Text('Delete'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//
//                     if (confirmDelete == true) {
//                       await attractionDatabaseHelper
//                           .deleteAttraction(widget.currentAttraction.id as int);
//
//                       setState(() {
//                         widget.fetchAttractions();
//                         widget.toggleDisplayAttractionsView(
//                             widget.currentAttraction);
//                       });
//                     }
//                   },
//                   child: Container(
//                     // color: Colors.green.withOpacity(0.3),
//                     height: screenHeight * 0.1,
//                     width: screenWidth,
//                     child: const Row(
//                       children: [
//                         Spacer(),
//                         Text('X 刪除'),
//                         Spacer(),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//               const Spacer()
//             ],
//           )),
//     );
//   }
// }
