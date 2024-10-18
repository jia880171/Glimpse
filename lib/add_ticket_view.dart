import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import './config.dart' as config;

class AddTicketView extends StatelessWidget {
  final double widgetHeight;
  final double screenWidth;
  final double cardWidth;
  final List<Widget> barcode;

  // memo
  final TextEditingController memoController;

  // date
  final TextEditingController dateController;
  final TextEditingController departureTimeController;
  final TextEditingController arrivalTimeController;

  final TextEditingController departureStationController;
  final TextEditingController arrivalStationController;

  final TextEditingController trainNameController;
  final TextEditingController trainNumberController;

  final TextEditingController carNumberController;
  final TextEditingController rowNumberController;
  final TextEditingController seatNumberController;

  AddTicketView({
    Key? key,
    required this.widgetHeight,
    required this.screenWidth,
    required this.cardWidth,
  })  : memoController = TextEditingController(),
        dateController = TextEditingController(
          text:
              '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
        ),
        departureTimeController = TextEditingController(),
        arrivalTimeController = TextEditingController(),
        departureStationController = TextEditingController(),
        arrivalStationController = TextEditingController(),
        trainNameController = TextEditingController(),
        trainNumberController = TextEditingController(),
        carNumberController = TextEditingController(),
        rowNumberController = TextEditingController(),
        seatNumberController = TextEditingController(),
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
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
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
                                  height: widgetHeight * 0.3,
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
                              const Spacer(),

                              // date
                              Container(
                                width: cardWidth,
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0, 0, cardWidth * 0.05, 0),
                                        child: SizedBox(
                                          width: cardWidth * 0.35,
                                          child: TextField(
                                            controller: dateController,
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
                                        ))
                                  ],
                                ),
                              )
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
                            TimeOfDay? selectedTime = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());

                            if (selectedTime != null) {
                              final String formattedTime =
                                  selectedTime.format(context);
                              departureTimeController.text = formattedTime;
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
                                        '発',
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
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                            // color: Colors.red,
                            // width: cardWidth * 0.5,
                            child: Column(
                          children: [
                            Container(
                              height: widgetHeight * 0.06,
                              // color: Colors.green,
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      // color: Colors.red,
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: trainNameController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: 'のぞみ',
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
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('-'),
                                    ),
                                    Expanded(
                                        child: SizedBox(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: trainNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '12',
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
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('号'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: widgetHeight * 0.01,
                              child: Center(
                                child: Divider(
                                  indent: cardWidth * 0.05,
                                  endIndent: cardWidth * 0.05,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              height: widgetHeight * 0.06,
                              // color: Colors.green,
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      // color: Colors.red,
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: carNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '8',
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
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('号車'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: rowNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: '8',
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
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('番'),
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: widgetHeight * 0.06,
                                      child: TextField(
                                        controller: seatNumberController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: 'A',
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
                                    )),
                                    Container(
                                      height: widgetHeight * 0.06,
                                      child: const Text('席'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),

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
                                          '着',
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
                                  const Spacer(),
                                ],
                              ),
                            )),
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
                          Expanded(
                              child: Center(
                            child: Container(
                              height: widgetHeight * 0.1,
                              // color: Colors.green,
                              child: TextField(
                                controller: departureStationController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: '東京',
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
                          )),
                          Text(
                            '---',
                            style: TextStyle(
                                height: 1,
                                fontSize: widgetHeight * 0.06,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                              child: Center(
                            child: Container(
                              height: widgetHeight * 0.1,
                              child: TextField(
                                controller: arrivalStationController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: '秋田',
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
                          )),
                        ],
                      ),
                    ),
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  DottedLine(
                    direction: Axis.horizontal,
                    lineLength: cardWidth * 0.9,
                    lineThickness: cardWidth * 0.012,
                    dashLength: cardWidth * 0.012,
                    dashColor: Colors.black,
                    // dashGradient: const [Colors.red, Colors.blue],
                    dashRadius: 100.0,
                    // dashGapLength: 0.003,
                    // dashGapColor: Colors.transparent,
                    // dashGapGradient: const [Colors.red, Colors.blue],
                    // dashGapRadius: 0.0,
                  ),

                  // spacer
                  Container(
                    height: widgetHeight * 0.02,
                  ),

                  Container(
                    // color: config.bottom,
                    height: widgetHeight * 0.14,
                    width: cardWidth,
                    child: Container(
                      // color: Colors.green,
                      child: Row(
                        // mainAxisAlignment: ,
                        children: [
                          Container(
                            // color: Colors.red,
                            width: cardWidth * 0.15,
                            child: RotatedBox(
                                quarterTurns: 3,
                                child: Column(
                                  children: [
                                    // ## bottle location
                                    Text('JAPAN',
                                        style: TextStyle(
                                            fontSize: widgetHeight * 0.03,
                                            fontWeight: FontWeight.bold)),
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
