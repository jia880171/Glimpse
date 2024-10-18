import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import './config.dart' as config;



class AddAttractionView extends StatelessWidget {
  final double widgetHeight;
  final double screenWidth;
  final double cardWidth;
  final List<Widget> barcode;

  final TextEditingController nameController;
  final TextEditingController memoController;

  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController departureTimeController;
  final TextEditingController arrivalTimeController;

  final TextEditingController departureStationController;
  final TextEditingController arrivalStationController;

  AddAttractionView({
    Key? key,
    required this.widgetHeight,
    required this.screenWidth,
    required this.cardWidth,
  })  : nameController = TextEditingController(),
        memoController = TextEditingController(),
        locationController = TextEditingController(),
        dateController = TextEditingController(
          text:
              '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
        ),
        departureTimeController = TextEditingController(),
        arrivalTimeController = TextEditingController(),
        departureStationController = TextEditingController(),
        arrivalStationController = TextEditingController(),
        barcode = _generateBarcode(cardWidth),
        super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
          elevation: 2.5,
          color: config.ticketBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: widgetHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  // memo
                  Card(
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10.5),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            color: config.memoWhite,
                            borderRadius: BorderRadius.circular(10.5)),
                        width: cardWidth,
                        height: widgetHeight * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Column(
                            children: [
                              Container(
                                  height: widgetHeight * 0.25,
                                  child: SingleChildScrollView(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 15, 5),
                                    child: TextField(
                                      controller: memoController,
                                      decoration: const InputDecoration(
                                        hintText: 'Leave your memo here',
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) {
                                        // Handle the input text change here if needed
                                      },
                                    ),
                                  ))),
                              Spacer(),

                              // date
                              Container(
                                height: widgetHeight * 0.05,
                                width: cardWidth,
                                // color: Colors.green,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Container(
                                      width: cardWidth * 0.8,
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
                                        },
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),

                              // location
                              Container(
                                height: widgetHeight * 0.05,
                                width: cardWidth,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Container(
                                      width: cardWidth * 0.8,
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
                                          // Handle the input text change here if needed
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
                    height: widgetHeight * 0.13,
                    width: cardWidth,
                    child: Row(
                      children: [
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
                              // setState(() {
                              departureTimeController.text = formattedTime;
                              // });
                            }
                          },
                          child: Container(
                            // color: Colors.green,
                            width: cardWidth * 0.2,
                            height: widgetHeight * 0.13,
                            child: Column(
                              children: [
                                Container(
                                  height: widgetHeight * 0.08,
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      Text(
                                        '到',
                                        style: TextStyle(
                                          fontSize: widgetHeight * 0.05,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                Container(
                                  width: cardWidth * 0.2,
                                  height: widgetHeight * 0.03,
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
                                      fontSize: widgetHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      // Handle the input text change here if needed
                                    },
                                  ))
                                      // TextField(
                                      //   controller: departureTimeController,
                                      //   textAlign: TextAlign.center,
                                      //   decoration: const InputDecoration(
                                      //     hintText: '07:36',
                                      //     border: InputBorder.none,
                                      //   ),
                                      //   style: TextStyle(
                                      //     fontFamily: 'Ds-Digi',
                                      //     fontSize: widgetHeight * 0.02,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      //   onChanged: (value) {
                                      //     // Handle the input text change here if needed
                                      //   },
                                      // ),Ï
                                      ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                            child: Column(
                          children: [
                            SizedBox(height: widgetHeight * 0.03),
                            Container(
                              height: widgetHeight * 0.06,
                              // color: Colors.green,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // Center horizontally
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // Center vertically
                                  children: [
                                    Container(
                                      width: cardWidth * 0.4,
                                      // height: widgetHeight * 0.05,
                                      // color: Colors.red,
                                      child: TextField(
                                        controller: departureStationController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '最近車站',
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                            height: 1,
                                            fontSize: widgetHeight * 0.03,
                                            fontWeight: FontWeight.bold),
                                        onChanged: (value) {
                                          // Handle the input text change here if needed
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: widgetHeight * 0.005,
                              child: Center(
                                child: Divider(
                                  indent: cardWidth * 0.05,
                                  endIndent: cardWidth * 0.05,
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

                        // Arrival
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
                              // setState(() {

                              arrivalTimeController.text = formattedTime;
                              // });
                            }
                          },
                          child: Container(
                            // color: Colors.green,
                            width: cardWidth * 0.2,
                            height: widgetHeight * 0.13,
                            child: Column(
                              children: [
                                Container(
                                  height: widgetHeight * 0.08,
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      Text(
                                        '離',
                                        style: TextStyle(
                                          fontSize: widgetHeight * 0.05,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                                const Spacer(),

                                Container(
                                  width: cardWidth * 0.2,
                                  height: widgetHeight * 0.03,
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
                                          fontSize: widgetHeight * 0.02,
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
                    height: widgetHeight * 0.015,
                  ),

                  // location --- location
                  Container(
                    width: cardWidth,
                    // color: Colors.red,
                    height: widgetHeight * 0.1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Center horizontally
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Center vertically
                        children: [
                          Container(
                            width: cardWidth * 0.5,
                            height: widgetHeight * 0.1,
                            // color: Colors.green,
                            child: TextField(
                              controller: nameController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '景點名',
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                  height: 1,
                                  fontSize: widgetHeight * 0.05,
                                  fontWeight: FontWeight.bold),
                              onChanged: (value) {
                                // Handle the input text change here if needed
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  SizedBox(
                    width: cardWidth,
                    height: widgetHeight * 0.012,
                    child: Divider(
                      thickness:
                      widgetHeight * 0.002,
                      indent: cardWidth * 0.02,
                      endIndent:
                      cardWidth * 0.02,
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
                    height: widgetHeight * 0.02,
                  ),

                  Container(
                    height: widgetHeight * 0.14,
                    width: cardWidth,
                    child: Container(
                      // color: Colors.green,
                      child: Row(
                        // mainAxisAlignment: ,
                        children: [
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.25,
                            child: RotatedBox(
                                quarterTurns: 3,
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text('JAPAN',
                                          style: TextStyle(
                                              fontSize: widgetHeight * 0.03,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                )),
                          ),
                          const Spacer(),
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.4,
                            height: widgetHeight * 0.14,
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
    );
  }
}