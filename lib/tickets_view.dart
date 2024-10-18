import 'dart:async';
import 'dart:developer';
import 'package:dotted_line/dotted_line.dart';
import 'dart:math' as math;
import './config.dart' as config;
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'database/ticket.dart';
import 'database/ticket_db.dart';

class TicketsView extends StatefulWidget {
  bool isHideUsedTickets;

  final double screenWidth;
  final double widgetHeight;
  final double cardWidth;

  // all tickets
  List<Ticket> tickets;

  // tickets to display
  late List<Ticket> ticketsToDisplay;

  TicketsView(
    this.isHideUsedTickets,
    this.widgetHeight,
    this.screenWidth,
    this.cardWidth,
    this.tickets, {
    Key? key,
  })  : ticketsToDisplay = getTicketsToDisplay(tickets),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TicketsViewState createState() => _TicketsViewState();

  static List<Ticket> getTicketsToDisplay(List<Ticket> tickets,
      [bool isHideUsedTickets = false]) {
    List<Ticket> ticketsToDisplay = isHideUsedTickets
        ? tickets.where((ticket) => ticket.isUsed == false).toList()
        : tickets;

    return ticketsToDisplay;
  }

  // Print all Ticket objects in the list
  static void printTickets(List<Ticket> tickets) {
    for (Ticket ticket in tickets) {
      print(
          'Ticket ID: ${ticket.id}, departureStation: ${ticket.departureStation}');
    }
  }
}

class _TicketsViewState extends State<TicketsView> {
  List<Widget> barcode = [];
  final StreamController<String> controller = StreamController<String>();

  void setText(value) {
    controller.add(value);
  }

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Ticket'),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ScalableOCR(
                    paintboxCustom: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4.0
                      ..color = const Color.fromARGB(153, 102, 160, 241),
                    boxLeftOff: 5,
                    boxBottomOff: 2.5,
                    boxRightOff: 5,
                    boxTopOff: 2.5,
                    boxHeight: MediaQuery.of(context).size.height / 3,
                    getRawData: (value) {
                      inspect(value);
                    },
                    getScannedText: (value) {
                      setText(value);
                    }),
                StreamBuilder<String>(
                  stream: controller.stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Result(
                        text: snapshot.data != null ? snapshot.data! : "");
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            // close button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            // create button
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String backgroundHint = '車票列表，可在此快速查看起迄時間並翻閱備忘。';
    generateBarcode(barcode);

    return Container(
        // color: Colors.white,
        height: widget.widgetHeight,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(widget.cardWidth * 0.1),
              child: SizedBox(
                width: widget.cardWidth * 0.6,
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      backgroundHint,
                      style: TextStyle(
                          fontSize: widget.cardWidth * 0.05,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            widget.ticketsToDisplay.isNotEmpty
                ? ListView.builder(
                    // shrinkWrap: true,
                    itemCount: widget.ticketsToDisplay.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                              widget.cardWidth * 0.7, 0, 0, 0),
                          child: Row(
                            children: [
                              Card(
                                  elevation: 2.5,
                                  color: config.ticketBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // side: const BorderSide(color: Colors.black, width: 0)
                                  ),
                                  child: Container(
                                    height: widget.widgetHeight,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Column(
                                        children: [
                                          Card(
                                            shape: BeveledRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.5),
                                              // side: const BorderSide(
                                              //     color: Colors.black, width: 0.15),
                                            ),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: config.memoWhite,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.5)),
                                                // color: Colors.blueGrey,
                                                width: widget.cardWidth,
                                                height:
                                                    widget.widgetHeight * 0.5,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 5, 5, 5),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                          height: widget
                                                                  .widgetHeight *
                                                              0.39,
                                                          child:
                                                              SingleChildScrollView(
                                                                  child:
                                                                      Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    5,
                                                                    15,
                                                                    5),
                                                            child: Text(
                                                              widget
                                                                  .ticketsToDisplay[
                                                                      index]
                                                                  .memo,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                          ))),
                                                      Spacer(),

                                                      // date
                                                      Container(
                                                        width: widget.cardWidth,
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      widget.cardWidth *
                                                                          0.05,
                                                                      0),
                                                              child: Text(
                                                                widget
                                                                    .ticketsToDisplay[
                                                                        index]
                                                                    .date,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Ds-Digi'),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                          ),

                                          // Departure Time --- Arrival Time
                                          Container(
                                            // color: Colors.red,
                                            height: widget.widgetHeight * 0.13,
                                            width: widget.cardWidth,
                                            child: Row(
                                              children: [
                                                // Departure
                                                TimeContainer(
                                                    widgetHeight:
                                                        widget.widgetHeight,
                                                    cardWidth: widget.cardWidth,
                                                    label: '発',
                                                    time: widget
                                                        .ticketsToDisplay[index]
                                                        .departureTime),

                                                Expanded(
                                                    // color: Colors.red,
                                                    // width: widget.cardWidth * 0.6,
                                                    child: Column(
                                                  children: [
                                                    Text(
                                                      '${widget.ticketsToDisplay[index].trainName}   -   ${widget.ticketsToDisplay[index].trainNumber}   号',
                                                      style: TextStyle(
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Ds-digi'),
                                                    ),
                                                    Divider(
                                                      indent: widget.cardWidth *
                                                          0.05,
                                                      endIndent:
                                                          widget.cardWidth *
                                                              0.05,
                                                      color: Colors.black,
                                                    ),
                                                    Text(
                                                      '${widget.ticketsToDisplay[index].carNumber}   号車   ${widget.ticketsToDisplay[index].row}   番   ${widget.ticketsToDisplay[index].seat}   席',
                                                      style: TextStyle(
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Ds-digi'),
                                                    ),
                                                  ],
                                                )),

                                                // Arrival
                                                TimeContainer(
                                                    widgetHeight:
                                                        widget.widgetHeight,
                                                    cardWidth: widget.cardWidth,
                                                    label: '着',
                                                    time: widget
                                                        .ticketsToDisplay[index]
                                                        .arrivalTime), // Arrival
                                              ],
                                            ),
                                          ),

                                          Container(
                                            height: widget.widgetHeight * 0.015,
                                          ),

                                          // location --- location
                                          Container(
                                            width: widget.cardWidth,
                                            // color: Colors.red,
                                            height: widget.widgetHeight * 0.1,
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Container(
                                                  // color: Colors.red,
                                                  width:
                                                      widget.cardWidth * 0.35,
                                                  height:
                                                      widget.widgetHeight * 0.1,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                        widget
                                                            .ticketsToDisplay[
                                                                index]
                                                            .departureStation
                                                            .toString(),
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontSize: widget
                                                                    .widgetHeight *
                                                                0.06,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  // color: Colors.red,
                                                  height:
                                                      widget.widgetHeight * 0.1,
                                                  child: Text('---',
                                                      style: TextStyle(
                                                          height: 1,
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.06,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Container(
                                                  // color: Colors.red,
                                                  width:
                                                      widget.cardWidth * 0.35,
                                                  height:
                                                      widget.widgetHeight * 0.1,
                                                  child: SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                          widget
                                                              .ticketsToDisplay[
                                                                  index]
                                                              .arrivalStation
                                                              .toString(),
                                                          style: TextStyle(
                                                              height: 1,
                                                              fontSize: widget
                                                                      .widgetHeight *
                                                                  0.06,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                ),
                                                Spacer()
                                              ],
                                            ),
                                          ),

                                          // spacer
                                          Container(
                                            height: widget.widgetHeight * 0.02,
                                          ),

                                          // Divider(
                                          //   height: 1,
                                          //   thickness: 1,
                                          //   indent: widget.cardWidth * 0.05,
                                          //   endIndent: widget.cardWidth * 0.05,
                                          //   color: Colors.black,
                                          // ),

                                          SizedBox(
                                            width: widget.cardWidth,
                                            height: widget.widgetHeight * 0.012,
                                            child: Divider(
                                              thickness:
                                                  widget.widgetHeight * 0.002,
                                              indent: widget.cardWidth * 0.01,
                                              endIndent:
                                                  widget.cardWidth * 0.01,
                                              // color: Colors.white,
                                              color: Colors.black,
                                            ),
                                          ),

                                          // DottedLine(
                                          //   direction: Axis.horizontal,
                                          //   lineLength: widget.cardWidth * 0.9,
                                          //   lineThickness:
                                          //       widget.widgetHeight * 0.012,
                                          //   dashLength:
                                          //       widget.widgetHeight * 0.012,
                                          //   dashColor: Colors.black,
                                          //   dashRadius: 100.0,
                                          // ),

                                          // spacer
                                          Container(
                                            height: widget.widgetHeight * 0.02,
                                          ),

                                          Container(
                                            // color: config.bottom,
                                            height: widget.widgetHeight * 0.14,
                                            width: widget.cardWidth,
                                            child: Container(
                                              // color: Colors.green,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        widget.cardWidth * 0.15,
                                                    child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: Column(
                                                          children: [
                                                            // ## bottle location
                                                            Text('JAPAN',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        widget.widgetHeight *
                                                                            0.03,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        )),
                                                  ),
                                                  Container(
                                                    child: NeumorphicButton(
                                                        style: NeumorphicStyle(
                                                          lightSource:
                                                              LightSource
                                                                  .topLeft,
                                                          shape: NeumorphicShape
                                                              .flat,
                                                          boxShape:
                                                              const NeumorphicBoxShape
                                                                  .circle(),
                                                          intensity: 0.8,
                                                          color: config
                                                              .ticketBackground,
                                                          depth: widget
                                                                  .ticketsToDisplay[
                                                                      index]
                                                                  .isUsed
                                                              ? -2
                                                              : 2,
                                                        ),
                                                        onPressed: () async {
                                                          final ticket = widget
                                                                  .ticketsToDisplay[
                                                              index];
                                                          ticket.isUsed =
                                                              !ticket.isUsed;

                                                          await DatabaseHelper()
                                                              .updateTicket(
                                                                  ticket);

                                                          setState(() {
                                                            widget
                                                                    .ticketsToDisplay[
                                                                        index]
                                                                    .isUsed =
                                                                ticket.isUsed;
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Text(
                                                          '濟',
                                                          style: TextStyle(
                                                            // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                            fontSize: widget
                                                                    .widgetHeight *
                                                                0.02,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ))),
                                                  ),
                                                  Spacer(),
                                                  NeumorphicButton(
                                                      style:
                                                          const NeumorphicStyle(
                                                        lightSource:
                                                            LightSource.topLeft,
                                                        shape: NeumorphicShape
                                                            .flat,
                                                        boxShape:
                                                            NeumorphicBoxShape
                                                                .circle(),
                                                        intensity: 0.6,
                                                        color: config
                                                            .ticketBackground,
                                                        depth: 1,
                                                      ),
                                                      onPressed: () async {},
                                                      child: Center(
                                                          child: Text(
                                                        '修',
                                                        style: TextStyle(
                                                          // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                          fontSize: widget
                                                                  .widgetHeight *
                                                              0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ))),
                                                  Spacer(),
                                                  Container(
                                                    // color: Colors.red,
                                                    width:
                                                        widget.cardWidth * 0.4,
                                                    height:
                                                        widget.widgetHeight *
                                                            0.14,
                                                    child:
                                                        Row(children: barcode),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      } else if (index >= 1) {
                        // ticket
                        return Card(
                            elevation: 2.5,
                            color: config.ticketBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // side: const BorderSide(color: Colors.black, width: 0)
                            ),
                            child: SizedBox(
                              height: widget.widgetHeight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                  children: [
                                    // memo
                                    Card(
                                      shape: BeveledRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.5),
                                        // side: const BorderSide(
                                        //     color: Colors.black, width: 0.15),
                                      ),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: config.memoWhite,
                                              borderRadius:
                                                  BorderRadius.circular(10.5)),
                                          // color: Colors.blueGrey,
                                          width: widget.cardWidth,
                                          height: widget.widgetHeight * 0.5,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            child: Column(
                                              children: [
                                                Container(
                                                    height:
                                                        widget.widgetHeight *
                                                            0.39,
                                                    child:
                                                        SingleChildScrollView(
                                                            child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          20, 5, 15, 5),
                                                      child: Text(
                                                        widget
                                                            .ticketsToDisplay[
                                                                index]
                                                            .memo,
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ))),
                                                Spacer(),

                                                // date
                                                Container(
                                                  width: widget.cardWidth,
                                                  child: Row(
                                                    children: [
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0,
                                                                0,
                                                                widget.cardWidth *
                                                                    0.05,
                                                                0),
                                                        child: Text(
                                                          widget.tickets[index]
                                                              .date,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Ds-Digi'),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),

                                    // Departure Time --- Arrival Time
                                    Container(
                                      // color: Colors.red,
                                      height: widget.widgetHeight * 0.13,
                                      width: widget.cardWidth,
                                      child: Row(
                                        children: [
                                          // Departure
                                          TimeContainer(
                                              widgetHeight: widget.widgetHeight,
                                              cardWidth: widget.cardWidth,
                                              label: '発',
                                              time: widget.tickets[index]
                                                  .departureTime),

                                          Expanded(
                                              // color: Colors.red,
                                              // width: widget.cardWidth * 0.6,
                                              child: Column(
                                            children: [
                                              Text(
                                                '${widget.ticketsToDisplay[index].trainName}   -   ${widget.ticketsToDisplay[index].trainNumber}   号',
                                                style: TextStyle(
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.02,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Ds-digi'),
                                              ),
                                              Divider(
                                                indent: widget.cardWidth * 0.05,
                                                endIndent:
                                                    widget.cardWidth * 0.05,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                '${widget.ticketsToDisplay[index].carNumber}   号車   ${widget.ticketsToDisplay[index].row}   番   ${widget.ticketsToDisplay[index].seat}   席',
                                                style: TextStyle(
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.02,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Ds-digi'),
                                              ),
                                            ],
                                          )),

                                          // Arrival
                                          TimeContainer(
                                              widgetHeight: widget.widgetHeight,
                                              cardWidth: widget.cardWidth,
                                              label: '着',
                                              time: widget
                                                  .ticketsToDisplay[index]
                                                  .arrivalTime), // Arrival
                                        ],
                                      ),
                                    ),

                                    Container(
                                      height: widget.widgetHeight * 0.015,
                                    ),

                                    // location --- location
                                    Container(
                                      width: widget.cardWidth,
                                      // color: Colors.red,
                                      height: widget.widgetHeight * 0.1,
                                      child: Row(
                                        children: [
                                          const Spacer(),
                                          Container(
                                            // color: Colors.red,
                                            width: widget.cardWidth * 0.35,
                                            height: widget.widgetHeight * 0.1,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                  widget.ticketsToDisplay[index]
                                                      .departureStation
                                                      .toString(),
                                                  style: TextStyle(
                                                      height: 1,
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.06,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          SizedBox(
                                            // color: Colors.red,
                                            height: widget.widgetHeight * 0.1,
                                            child: Text('---',
                                                style: TextStyle(
                                                    height: 1,
                                                    fontSize:
                                                        widget.widgetHeight *
                                                            0.06,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Container(
                                            // color: Colors.red,
                                            width: widget.cardWidth * 0.35,
                                            height: widget.widgetHeight * 0.1,
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                    widget
                                                        .ticketsToDisplay[index]
                                                        .arrivalStation
                                                        .toString(),
                                                    style: TextStyle(
                                                        height: 1,
                                                        fontSize: widget
                                                                .widgetHeight *
                                                            0.06,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ),
                                          Spacer()
                                        ],
                                      ),
                                    ),

                                    // spacer
                                    Container(
                                      height: widget.widgetHeight * 0.02,
                                    ),

                                    SizedBox(
                                      width: widget.cardWidth,
                                      height: widget.widgetHeight * 0.012,
                                      child: Divider(
                                        thickness:
                                        widget.widgetHeight * 0.002,
                                        indent: widget.cardWidth * 0.01,
                                        endIndent:
                                        widget.cardWidth * 0.01,
                                        // color: Colors.white,
                                        color: Colors.black,
                                      ),
                                    ),

                                    // DottedLine(
                                    //   direction: Axis.horizontal,
                                    //   lineLength: widget.cardWidth * 0.9,
                                    //   lineThickness:
                                    //       widget.widgetHeight * 0.012,
                                    //   dashLength: widget.widgetHeight * 0.012,
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
                                      // color: config.bottom,
                                      height: widget.widgetHeight * 0.14,
                                      width: widget.cardWidth,
                                      child: Container(
                                        // color: Colors.green,
                                        child: Row(
                                          // mainAxisAlignment: ,
                                          children: [
                                            // Container(
                                            //   color: Colors.red,
                                            //   width: screenWidth * 0.2,
                                            // ),

                                            // 0.15
                                            Container(
                                              // color: Colors.red,
                                              width: widget.cardWidth * 0.15,
                                              child: RotatedBox(
                                                  quarterTurns: 3,
                                                  child: Column(
                                                    children: [
                                                      // ## bottle location
                                                      Text('JAPAN',
                                                          style: TextStyle(
                                                              fontSize: widget
                                                                      .widgetHeight *
                                                                  0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  )),
                                            ),

                                            // 濟
                                            Container(
                                              child: NeumorphicButton(
                                                  style: NeumorphicStyle(
                                                    lightSource:
                                                        LightSource.topLeft,
                                                    shape: NeumorphicShape.flat,
                                                    boxShape:
                                                        const NeumorphicBoxShape
                                                            .circle(),
                                                    intensity: 0.6,
                                                    color:
                                                        config.ticketBackground,
                                                    depth: widget
                                                            .ticketsToDisplay[
                                                                index]
                                                            .isUsed
                                                        ? -1.5
                                                        : 1.5,
                                                  ),
                                                  onPressed: () async {
                                                    final ticket =
                                                        widget.ticketsToDisplay[
                                                            index];
                                                    ticket.isUsed =
                                                        !ticket.isUsed;

                                                    await DatabaseHelper()
                                                        .updateTicket(ticket);

                                                    setState(() {
                                                      widget
                                                              .ticketsToDisplay[
                                                                  index]
                                                              .isUsed =
                                                          ticket.isUsed;
                                                    });
                                                  },
                                                  child: Center(
                                                      child: Text(
                                                    '濟',
                                                    style: TextStyle(
                                                      // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))),
                                            ),
                                            Spacer(),
                                            // 修
                                            Container(
                                              child: NeumorphicButton(
                                                  style: const NeumorphicStyle(
                                                    lightSource:
                                                        LightSource.topLeft,
                                                    shape: NeumorphicShape.flat,
                                                    boxShape: NeumorphicBoxShape
                                                        .circle(),
                                                    intensity: 0.6,
                                                    color:
                                                        config.ticketBackground,
                                                    depth: 1,
                                                  ),
                                                  onPressed: () async {
                                                    // final ticket =
                                                    // widget.tickets[index];
                                                    // ticket.isUsed = !ticket.isUsed;
                                                    //
                                                    // await DatabaseHelper()
                                                    //     .updateTicket(ticket);
                                                    //
                                                    // setState(() {
                                                    //   widget.tickets[index].isUsed =
                                                    //       ticket.isUsed;
                                                    // });
                                                  },
                                                  child: Center(
                                                      child: Text(
                                                    '修',
                                                    style: TextStyle(
                                                      // color: widget.tickets[index].isUsed ? Colors.red: Colors.black,
                                                      fontSize:
                                                          widget.widgetHeight *
                                                              0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))),
                                            ),
                                            Spacer(),

                                            Container(
                                              // color: Colors.red,
                                              width: widget.cardWidth * 0.4,
                                              height:
                                                  widget.widgetHeight * 0.14,
                                              child: Row(children: barcode),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      } else {
                        return const SizedBox();
                      }
                    },
                    scrollDirection: Axis.horizontal,
                  )
                : const Center(
                    child: Text('List is empty'),
                  ),

            Positioned(
              top: widget.widgetHeight * 0.03,
              left: 0,
              right: 0,
              height: widget.widgetHeight * 0.3,
              child: SizedBox(
                  height: widget.widgetHeight * 0.3,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: widget.screenWidth * 0.05,
                          ),
                          Text('隱藏已使用車票',
                              style: TextStyle(
                                  fontSize: widget.screenWidth * 0.02,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(
                        height: widget.widgetHeight * 0.01,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: widget.screenWidth * 0.05,
                          ),
                          Container(
                            height: widget.screenWidth * 0.065,
                            width: widget.screenWidth * 0.15,
                            child: NeumorphicSwitch(
                              value: widget.isHideUsedTickets,
                              style: const NeumorphicSwitchStyle(
                                activeTrackColor: Color(0x0FD36300),
                                thumbShape: NeumorphicShape.concave,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  print('===== setSate hideUsedTickets');
                                  widget.isHideUsedTickets = value;
                                  widget.ticketsToDisplay =
                                      TicketsView.getTicketsToDisplay(
                                          widget.tickets,
                                          widget.isHideUsedTickets);
                                  print(
                                      'HideUsedTickets is ${widget.isHideUsedTickets}');
                                  print(
                                      'ticketsToDisplay: $widget.ticketsToDisplay');
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  )),
            ),

            Positioned(
                top: widget.screenWidth * 0.5,
                child: BackButton(
                  onPressed: () => {show(context)},
                )),
          ],
        ));
  }

  void generateBarcode(List<Widget> barcode) {
    print('====== generatedBarcode is called');
    if (barcode.isEmpty) {
      double barcodeWidth = 0;

      while (barcodeWidth < 0.9) {
        double widthPercentage = math.Random().nextInt(10) * 0.006;
        barcodeWidth += widthPercentage;
        barcode.add(
          VerticalDivider(
            thickness: widget.cardWidth *
                0.4 *
                widthPercentage *
                math.Random().nextInt(10) *
                0.1,
            width: widget.cardWidth * 0.4 * widthPercentage,
            color: Colors.black,
          ),
        );
      }
    }
  }
}

class Result extends StatelessWidget {
  const Result({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text("Readed text: $text");
  }
}

// Create a custom widget named `TimeContainer`
class TimeContainer extends StatelessWidget {
  final String label;
  final String time;
  final double cardWidth;
  final double widgetHeight;

  const TimeContainer({
    super.key,
    required this.widgetHeight,
    required this.cardWidth,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      width: cardWidth * 0.2,
      height: widgetHeight * 0.13,
      child: Column(
        children: [
          Container(
            height: widgetHeight * 0.08,
            child: Row(
              children: [
                Spacer(),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: widgetHeight * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
                fontSize: widgetHeight * 0.02,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ds-digi'),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
