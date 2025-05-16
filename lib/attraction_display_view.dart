import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/attraction_edit_view.dart';
import './config.dart' as config;
import 'dart:math' as math;

import 'database_sqlite/attraction.dart';
import 'database_sqlite/attraction_db.dart';

class AttractionDisplayView extends StatefulWidget {
  final Attraction attraction;
  final double widgetHeight;
  final double widgetWidth;
  final Function() displaySaveButton;
  final Function() swipeLeft;
  final Function() swipeRight;
  final Function() toggleAttractionMode;
  final Function() fetchAttractions;

  AttractionDisplayView(
      {Key? key,
      required this.attraction,
      required this.widgetHeight,
      required this.widgetWidth,
      required this.displaySaveButton,
      required this.swipeLeft,
      required this.swipeRight,
      required this.toggleAttractionMode,
      required this.fetchAttractions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AttractionDisplayViewState();
  }
}

class _AttractionDisplayViewState extends State<AttractionDisplayView> {
  final AttractionDatabaseHelper attractionDatabaseHelper =
      AttractionDatabaseHelper();
  bool isEditMode = false;
  late Attraction _updatedAttraction;

  static List<Widget> _generateBarcode(double cardWidth) {
    List<Widget> barcode = [];
    double barcodeWidth = 0;

    while (barcodeWidth < 0.9) {
      double widthPercentage = math.Random().nextInt(10) * 0.006;
      barcodeWidth += widthPercentage;
      barcode.add(
        VerticalDivider(
          thickness: cardWidth *
              0.4 *
              widthPercentage *
              math.Random().nextInt(10) *
              0.1,
          width: cardWidth * 0.4 * widthPercentage,
          color: Colors.black,
        ),
      );
    }

    return barcode;
  }

  late List<Widget> barcode;

  @override
  void initState() {
    super.initState();
    barcode = _generateBarcode(widget.widgetWidth);
  }

  void updateUpdatedAttraction(Attraction updatedAttraction) {
    setState(() {
      _updatedAttraction = updatedAttraction;

      // refresh attractions
    });
  }

  void showNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Down drag detected!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  double _dragOffsetY = 0;
  DateTime? _dragStartTime;
  var backgroundColorOfCard = Colors.red;

  void _handleVerticalDragStart(DragStartDetails details) {
    setState(() {
      _dragStartTime = DateTime.now(); // Record start time
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _dragOffsetY = 0;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    double dragThresholdForDelete = widget.widgetHeight * 0.6;
    double dragThresholdForEdit = -widget.widgetHeight * 0.6;

    changeBackgroundColorOfCard(details);

    setState(() {
      _dragOffsetY += details.primaryDelta ?? 0;
      if (_dragStartTime != null) {
        if (_dragOffsetY > dragThresholdForDelete) {
          if (isEditMode) {
            _showCancelDialog();
          } else {
            _showDeleteDialog();
          }
          _dragOffsetY = 0;
        } else if (_dragOffsetY < dragThresholdForEdit) {
          if (isEditMode) {
            _showSaveDialog();
          } else {
            _showEditDialog();
          }
          _dragOffsetY = 0;
        }
      }
    });
  }

  void changeBackgroundColorOfCard(DragUpdateDetails details) {
    setState(() {
      if (details.primaryDelta! > 0 && _dragOffsetY >= 0) {
        backgroundColorOfCard = Colors.red;
      } else if (details.primaryDelta! < 0 && _dragOffsetY <= 0) {
        backgroundColorOfCard = Colors.green;
      }
    });
  }

  void _showEditDialog() async {
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('編輯？'),
        content: const Text(''),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditMode = true;
              });
              Navigator.of(context).pop(true);
            },
            // Close the app
            child: const Text('編輯'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (shouldEdit == true) {
      setState(() {
        // _canPop = true;
      }); // Close the app after setting canPop to true
    }
  }

  void _showDeleteDialog() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除？'),
        content: const Text(''),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await attractionDatabaseHelper
                  .deleteAttraction(widget.attraction.id as int);
              setState(() {
                widget.fetchAttractions();
              });
              // call refresh
            },
            // Close the app
            child: const Text('刪除'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        // _canPop = true;
      }); // Close the app after setting canPop to true
    }
  }

  void _showCancelDialog() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('離開編輯？'),
        content: const Text(''),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              setState(() {
                isEditMode = false;
                widget.fetchAttractions();
              });
              // call refresh
            },
            // Close the app
            child: const Text('離開'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('儲存編輯？'),
        content: const Text(''),
        actions: [
          TextButton(
            onPressed: () async {
              await attractionDatabaseHelper
                  .updateAttraction(_updatedAttraction);

              setState(() {
                isEditMode = false;
                widget.fetchAttractions();
              });

              Navigator.of(context).pop(true);
            },
            // Close the app
            child: const Text('儲存'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    print('======attraction_display_view');
    print('======updateAttraction, arr: ${widget.attraction.arrivalTime}');
    print('======updateAttraction, dep: ${widget.attraction.departureTime}');


    return Stack(
      children: [

        // Background below card (edit delete ...)
        Card(
          color: backgroundColorOfCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: widget.widgetHeight,
            width: widget.widgetWidth,
            child: Column(
              children: [
                Container(
                  child:
                      isEditMode ? const Text('cancel') : const Text('delete'),
                ),
                const Spacer(),
                Container(
                  child: isEditMode ? const Text('save') : const Text('edit'),
                )
              ],
            ),
          ),
        ),

        // display mode
        if (!isEditMode) ...[
          Transform.translate(
              offset: Offset(0, _dragOffsetY),
              child: GestureDetector(
                onVerticalDragStart: _handleVerticalDragStart,
                onVerticalDragUpdate: _handleVerticalDragUpdate,
                onVerticalDragEnd: _handleVerticalDragEnd,
                child: Card(
                    elevation: 1,
                    // color: config.ticketBackground,
                    // color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: SizedBox(
                      // color: Colors.red,
                      height: widget.widgetHeight,
                      width: widget.widgetWidth,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        // padding: const EdgeInsets.only(top: 0.0),

                        child: Column(
                          children: [
                            SizedBox(
                              height: widget.widgetHeight * 0.02,
                            ),

                            // Upper Memo Card
                            Container(
                                decoration: BoxDecoration(
                                    color: config.memoWhite,
                                    borderRadius: BorderRadius.circular(10.0)),
                                width: widget.widgetWidth -
                                    widget.widgetHeight * 0.04,
                                height: widget.widgetHeight * 0.5,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  child: Column(
                                    children: [
                                      // meme
                                      Container(
                                          height: widget.widgetHeight * 0.25,
                                          child: SingleChildScrollView(
                                              child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 5, 15, 5),
                                            child: Text(widget.attraction.memo),
                                          ))),

                                      const Spacer(),

                                      // date
                                      Container(
                                        height: widget.widgetHeight * 0.05,
                                        width: widget.widgetWidth,
                                        // color: Colors.green,
                                        child: Row(
                                          children: [
                                            const Spacer(),
                                            Container(
                                              width: widget.widgetWidth * 0.8,
                                              // color: Colors.red,
                                              alignment: Alignment.bottomCenter,
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                    widget.attraction.date,
                                                    style: const TextStyle(
                                                        fontFamily: 'Ds-Digi',
                                                        fontSize: 16)),
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),

                                      // location
                                      Container(
                                        height: widget.widgetHeight * 0.05,
                                        width: widget.widgetWidth,
                                        child: Row(
                                          children: [
                                            const Spacer(),
                                            Container(
                                              width: widget.widgetWidth * 0.8,
                                              // color: Colors.green,
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                    (widget.attraction.longitude
                                                            .toString() +
                                                        ',' +
                                                        widget
                                                            .attraction.latitude
                                                            .toString()),
                                                    style: const TextStyle(
                                                        fontFamily: 'Ds-Digi',
                                                        fontSize: 16)),
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                            // Departure Time --- Arrival Time
                            Container(
                              // color: Colors.green,
                              height: widget.widgetHeight * 0.13,
                              width: widget.widgetWidth,
                              child: Row(
                                children: [

                                  // arrival
                                  GestureDetector(
                                    onTap: () async {},
                                    child: Container(
                                      // color: Colors.green,
                                      width: widget.widgetWidth * 0.2,
                                      height: widget.widgetHeight * 0.13,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: widget.widgetHeight * 0.08,
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Text(
                                                  '到',
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.05,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: widget.widgetWidth * 0.2,
                                            height: widget.widgetHeight * 0.03,
                                            // color: Colors.red,
                                            child: Center(
                                                child: AbsorbPointer(
                                                    child: Text(
                                              widget.attraction.arrivalTime,
                                              style: TextStyle(
                                                fontFamily: 'Ds-Digi',
                                                fontSize:
                                                    widget.widgetHeight * 0.02,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ))),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                      child: Column(
                                    children: [
                                      SizedBox(
                                          height: widget.widgetHeight * 0.03),
                                      Container(
                                        height: widget.widgetHeight * 0.06,
                                        // color: Colors.green,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            // Center horizontally
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            // Center vertically
                                            children: [
                                              Container(
                                                width: widget.widgetWidth * 0.4,
                                                // height: widgetHeight * 0.05,
                                                // color: Colors.red,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      widget.attraction
                                                          .departureStation,
                                                      style: TextStyle(
                                                          height: 1,
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.03,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: widget.widgetHeight * 0.005,
                                        child: Center(
                                          child: Divider(
                                            indent: widget.widgetWidth * 0.05,
                                            endIndent:
                                                widget.widgetWidth * 0.05,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          // height: widgetHeight * 0.03,
                                          // // color: Colors.green,
                                          // child: Center(),
                                          ),
                                    ],
                                  )),

                                  // departure
                                  GestureDetector(
                                    onTap: () async {},
                                    child: Container(
                                      // color: Colors.green,
                                      width: widget.widgetWidth * 0.2,
                                      height: widget.widgetHeight * 0.13,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: widget.widgetHeight * 0.08,
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Text(
                                                  '離',
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.05,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: widget.widgetWidth * 0.2,
                                            height: widget.widgetHeight * 0.03,
                                            // color: Colors.red,
                                            child: Center(
                                              child: AbsorbPointer(
                                                child: Text(
                                                    widget.attraction
                                                        .departureTime,
                                                    style: TextStyle(
                                                      fontFamily: 'Ds-Digi',
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                    ),
                                  ) // Arrival
                                ],
                              ),
                            ),

                            Container(
                              height: widget.widgetHeight * 0.015,
                            ),

                            // location --- location
                            Container(
                              width: widget.widgetWidth,
                              // color: Colors.red,
                              height: widget.widgetHeight * 0.1,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // Center horizontally
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // Center vertically
                                  children: [
                                    Container(
                                      width: widget.widgetWidth * 0.5,
                                      height: widget.widgetHeight * 0.1,
                                      // color: Colors.green,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(widget.attraction.name,
                                            style: TextStyle(
                                                height: 1,
                                                fontSize:
                                                    widget.widgetHeight * 0.05,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // spacer
                            Container(
                              height: widget.widgetHeight * 0.02,
                            ),

                            SizedBox(
                              width: widget.widgetWidth,
                              height: widget.widgetHeight * 0.012,
                              child: Divider(
                                thickness: widget.widgetHeight * 0.002,
                                indent: widget.widgetWidth * 0.02,
                                endIndent: widget.widgetWidth * 0.02,
                                // color: Colors.white,
                                color: Colors.black,
                              ),
                            ),

                            Container(
                              height: widget.widgetHeight * 0.02,
                            ),

                            Spacer(),

                            Container(
                              height: widget.widgetHeight * 0.14,
                              width: widget.widgetWidth,
                              // color: Colors.green,
                              child: Container(
                                child: Row(
                                  // mainAxisAlignment: ,
                                  children: [
                                    SizedBox(
                                      width: widget.widgetWidth * 0.03,
                                    ),
                                    Container(
                                      // color: Colors.red,
                                      width: widget.widgetWidth * 0.25,
                                      child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Text('JAPAN',
                                                    style: TextStyle(
                                                        fontSize: widget
                                                                .widgetHeight *
                                                            0.03,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              )
                                            ],
                                          )),
                                    ),
                                    Text(widget.attraction.id.toString()),
                                    const Spacer(),
                                    SizedBox(
                                      // color: Colors.red,
                                      width: widget.widgetWidth * 0.4,
                                      height: widget.widgetHeight * 0.14,
                                      child: Row(children: barcode),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ))
        ]
          // edit mode
        else ...[
          Transform.translate(
            offset: Offset(0, _dragOffsetY),
            child: GestureDetector(
                onVerticalDragStart: _handleVerticalDragStart,
                onVerticalDragUpdate: _handleVerticalDragUpdate,
                onVerticalDragEnd: _handleVerticalDragEnd,
                child: AttractionEditView(
                    attraction: widget.attraction,
                    widgetHeight: widget.widgetHeight,
                    widgetWidth: widget.widgetWidth,
                    displaySaveButton: widget.displaySaveButton,
                    updateAttraction: updateUpdatedAttraction,
                    fetchAttractions: widget.fetchAttractions,
                )),
          )
        ]
      ],
    );
  }
}
