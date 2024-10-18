import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './config.dart' as config;
import 'dart:math' as math;

import 'database/attraction.dart';

class AttractionEditView extends StatefulWidget {
  final Attraction attraction;
  final double widgetHeight;
  final double widgetWidth;
  final Function() displaySaveButton;
  final Function(Attraction) updateAttraction;
  final Function() fetchAttractions;


  AttractionEditView({
    Key? key,
    required this.attraction,
    required this.widgetHeight,
    required this.widgetWidth,
    required this.displaySaveButton,
    required this.updateAttraction,
    required this.fetchAttractions
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AttractionEditViewState();
  }
}

class _AttractionEditViewState extends State<AttractionEditView> {
  late TextEditingController nameController;
  late TextEditingController memoController;
  late TextEditingController locationController;

  late TextEditingController dateController;
  late TextEditingController departureTimeController;
  late TextEditingController arrivalTimeController;

  late TextEditingController departureStationController;
  late TextEditingController arrivalStationController;

  late TextEditingController trainNameController;
  late TextEditingController trainNumberController;

  late TextEditingController carNumberController;
  late TextEditingController rowNumberController;
  late TextEditingController seatNumberController;

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
    nameController = TextEditingController();
    memoController = TextEditingController();
    locationController = TextEditingController();

    dateController = TextEditingController();
    departureTimeController = TextEditingController();
    arrivalTimeController = TextEditingController();

    departureStationController = TextEditingController();
    arrivalStationController = TextEditingController();

    trainNameController = TextEditingController();
    trainNumberController = TextEditingController();

    carNumberController = TextEditingController();
    rowNumberController = TextEditingController();
    seatNumberController = TextEditingController();
    setText();
  }

  void setText() {
    memoController.text = widget.attraction.memo;
    dateController.text = widget.attraction.date;
    // widget.locationController.text = widget.attraction.latitude;

    arrivalTimeController.text = widget.attraction.arrivalTime;
    departureTimeController.text = widget.attraction.departureTime;
    departureStationController.text = widget.attraction.departureStation; //最近車站
    nameController.text = widget.attraction.name;
  }

  void _updateAttraction() {
    double? latitude;
    double? longitude;

    final locationText = locationController.text;
    final locationValues = locationText.split(',');
    if (locationValues.length == 2) {
      latitude = double.tryParse(locationValues[0].trim());
      longitude = double.tryParse(locationValues[1].trim());
    }

    final updatedAttraction = widget.attraction.copyWith(
      name: nameController.text,
      memo: memoController.text,
      date: dateController.text,
      departureTime: departureTimeController.text,
      arrivalTime: arrivalTimeController.text,
      departureStation: departureStationController.text,
      arrivalStation: arrivalStationController.text,
      latitude: latitude,
      longitude: longitude,
    );
    widget.updateAttraction(updatedAttraction);
  }

  void onAttractionChanged() {
    widget.displaySaveButton();
    _updateAttraction();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {},
        child: Card(
            elevation: 6,
            color: config.ticketBackground,
            // color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              height: widget.widgetHeight,
              width: widget.widgetWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: widget.widgetHeight * 0.02,
                    ),

                    // Upper Memo Card
                    Card(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(10.5),
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                              color: config.memoWhite,
                              borderRadius: BorderRadius.circular(10.5)),
                          width:
                              widget.widgetWidth - widget.widgetHeight * 0.04,
                          height: widget.widgetHeight * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Column(
                              children: [
                                // meme
                                Container(
                                    height: widget.widgetHeight * 0.25,
                                    child: SingleChildScrollView(
                                        child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 5, 15, 5),
                                      child: TextField(
                                        controller: memoController,
                                        decoration: const InputDecoration(
                                          hintText: 'Leave your memo here',
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                          onAttractionChanged();
                                        },
                                      ),
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
                                        child: TextField(
                                          controller: dateController,
                                          textAlign: TextAlign.right,
                                          decoration: const InputDecoration(
                                            hintText: '2024/01/12',
                                            border: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                              fontFamily: 'Ds-Digi',
                                              fontSize: 16),
                                          onChanged: (value) {
                                            // Handle the input text change here if needed
                                            onAttractionChanged();
                                          },
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
                                        child: TextField(
                                          controller: locationController,
                                          textAlign: TextAlign.right,
                                          decoration: const InputDecoration(
                                            hintText: '35.6226077, 139.7210550',
                                            border: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                              fontFamily: 'Ds-Digi',
                                              fontSize: 16),
                                          onChanged: (value) {
                                            onAttractionChanged();
                                          },
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),

                    // Departure Time --- Arrival Time
                    Container(
                      // color: Colors.green,
                      height: widget.widgetHeight * 0.13,
                      width: widget.widgetWidth,
                      child: Row(
                        children: [
                          // Arrival
                          GestureDetector(
                            onTap: () async {
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (selectedTime != null) {
                                final String formattedTime =
                                    selectedTime.format(context);
                                arrivalTimeController.text = formattedTime;
                                onAttractionChanged();
                              }
                            },
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
                                                widget.widgetHeight * 0.05,
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
                                            child: TextField(
                                      controller: arrivalTimeController,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: '07:36',
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Ds-Digi',
                                        fontSize: widget.widgetHeight * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onChanged: (value) {},
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
                              SizedBox(height: widget.widgetHeight * 0.03),
                              Container(
                                height: widget.widgetHeight * 0.06,
                                // color: Colors.green,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // Center horizontally
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    // Center vertically
                                    children: [
                                      Container(
                                        width: widget.widgetWidth * 0.4,
                                        // height: widgetHeight * 0.05,
                                        // color: Colors.red,
                                        child: TextField(
                                          controller:
                                              departureStationController,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: '最近車站',
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                              height: 1,
                                              fontSize:
                                                  widget.widgetHeight * 0.03,
                                              fontWeight: FontWeight.bold),
                                          onChanged: (value) {
                                            onAttractionChanged();
                                          },
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
                                    endIndent: widget.widgetWidth * 0.05,
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

                          // Departure
                          GestureDetector(
                            onTap: () async {
                              print('============ clicked');
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (selectedTime != null) {
                                final String formattedTime =
                                    selectedTime.format(context);
                                departureTimeController.text = formattedTime;
                                onAttractionChanged();
                              }
                            },
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
                                                widget.widgetHeight * 0.05,
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
                                        child: TextField(
                                          controller: departureTimeController,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: '07:36',
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Ds-Digi',
                                            fontSize:
                                                widget.widgetHeight * 0.02,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onChanged: (value) {
                                            // Handle the input text change here if needed
                                          },
                                        ),
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
                              child: TextField(
                                controller: nameController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: '景點名',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                    height: 1,
                                    fontSize: widget.widgetHeight * 0.05,
                                    fontWeight: FontWeight.bold),
                                onChanged: (value) {
                                  onAttractionChanged();
                                },
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

                    // DottedLine(
                    //   direction: Axis.horizontal,
                    //   lineLength: cardWidth * 0.9,
                    //   lineThickness: cardWidth * 0.012,
                    //   dashLength: cardWidth * 0.012,
                    //   dashColor: Colors.black,
                    //   // dashGradient: const [Colors.red, Colors.blue],
                    //   dashRadius: 100.0,
                    //   // dashGapLength: 0.003,
                    //   // dashGapColor: Colors.transparent,
                    //   // dashGapGradient: const [Colors.red, Colors.blue],
                    //   // dashGapRadius: 0.0,
                    // ),

                    // spacer
                    Container(
                      height: widget.widgetHeight * 0.02,
                    ),

                    Container(
                      height: widget.widgetHeight * 0.14,
                      width: widget.widgetWidth,
                      child: Container(
                        // color: Colors.green,
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
                                                fontSize:
                                                    widget.widgetHeight * 0.03,
                                                fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  )),
                            ),
                            Text(widget.attraction.id.toString()),
                            const Spacer(),
                            Container(
                              // color: Colors.red,
                              width: widget.widgetWidth * 0.4,
                              height: widget.widgetHeight * 0.14,
                              child: Row(children: barcode),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
