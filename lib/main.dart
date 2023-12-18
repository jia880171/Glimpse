import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;


import './config.dart' as config;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final List<String> usernames = [
    '淺草雷門',
    '晴空塔',
    '麻布',
    'The bellwoods',
    'User5',
    'User6',
    'User7',
    'User8',
    'User9',
    'User10',
  ];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Dark status bar icons (like time, battery)
      ),
      child: Scaffold(
        // appBar: AppBar(
        //   // Here we take the value from the MyHomePage object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   title: Text(widget.title),
        // ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CenterTopText(),
            ChasingView(screenHeight, screenWidth, screenHeight * 0.45, 20, 10),
            BottomTouristList(screenHeight, screenWidth, usernames),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class CenterTopText extends StatelessWidget {
  static const double topFontSize = 40;

  const CenterTopText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        // Filling the entire screen
        SizedBox(
          // color: Colors.red, // Background color
          width: screenWidth,
          height: screenHeight * 0.2,
        ),
        // Aligning the text to the middle-top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align text to top
              children: <Widget>[
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    //center this row horizontally
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        'Japan',
                        style: TextStyle(
                            fontSize: topFontSize, fontFamily: 'Open-Sans'),
                      ),
                      SizedBox(width: 8.0), // Add some space between texts
                      Text(',', style: TextStyle(fontSize: topFontSize)),
                      Text(
                        'Tokyo',
                        style: TextStyle(
                            fontSize: topFontSize,
                            fontFamily: 'Open-Sans',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('新宿御苑',
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Open-Sans',
                                fontWeight: FontWeight.w300)),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChasingView extends StatelessWidget {
  final double ChasingViewHeight;
  final double screenWidth;
  final double screenHeight;
  final double sensorDegree;
  final double heading;

  const ChasingView(this.screenHeight, this.screenWidth,
      this.ChasingViewHeight, this.sensorDegree, this.heading,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LightSource neumorphiclightSource = LightSource.topLeft;
    double sensorRadius = screenHeight * 0.17;
    double smallSensorRadius = screenHeight * 0.027;

    List<Widget> targets = [];

    // targets
    List<DisplayBottle> bottles =  [
      DisplayBottle(
        -10.0,
        100
      ),
      DisplayBottle(
        80.0,
        150
      ),
      // Add more DisplayBottle instances as needed
    ];

    // display subsequent two items.
    for (int i = 0; i < bottles.length; i++) {
        //base
        // targets.add(Positioned(
        //   left: (screenWidth / 2) +
        //       AngleCalculator()
        //           .radiusProjector(
        //               bottles[i].bearingAngle + heading, sensorRadius)
        //           .dx -
        //       smallSensorRadius * 1.1,
        //   top: ChasingViewHeight * 0.5 -
        //       AngleCalculator()
        //           .radiusProjector(
        //               bottles[i].bearingAngle + heading, sensorRadius)
        //           .dy -
        //       smallSensorRadius * 1.1,
        //   child: Neumorphic(
        //       style: NeumorphicStyle(
        //         shape: NeumorphicShape.flat,
        //         boxShape: const NeumorphicBoxShape.circle(),
        //         intensity: 0.6,
        //         depth: 4,
        //         lightSource: neumorphiclightSource,
        //       ),
        //       child: Container(
        //         color: config.bottomPlateFont,
        //         width: smallSensorRadius * 2.2,
        //         height: smallSensorRadius * 2.2,
        //       )),
        // ));

        //dent
        targets.add(Positioned(
          left: (screenWidth / 2) +
              AngleCalculator()
                  .radiusProjector(
                      bottles[i].bearingAngle + heading, sensorRadius)
                  .dx -
              smallSensorRadius * 1,
          top: ChasingViewHeight * 0.5 -
              AngleCalculator()
                  .radiusProjector(
                      bottles[i].bearingAngle + heading, sensorRadius)
                  .dy -
              smallSensorRadius * 1,
          child: Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: const NeumorphicBoxShape.circle(),
                intensity: 1,
                surfaceIntensity: 1,
                depth: 3,
                lightSource: neumorphiclightSource,
              ),
              child: Container(
                  color: config.bottomPlateFont,
                  width: smallSensorRadius * 2,
                  height: smallSensorRadius * 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: NeumorphicText('${bottles[i].distance}M️',
                        style: const NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          color: config.bottleDistanceFont,
                          intensity: 0.8,
                          depth: 1,
                        ),
                        textStyle: NeumorphicTextStyle(
                            fontSize:
                                0.8 * smallSensorRadius,
                            fontWeight: FontWeight.bold)),
                  ))),
        ));

        print('target: $targets');
      }
    // }

    return SizedBox(
      height: screenHeight * 0.45,
      child: Stack(
        children: [
          // background
          Align(
            alignment: Alignment.center,
            child: Neumorphic(
                style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: const NeumorphicBoxShape.circle(),
                    intensity: 0.8,
                    // lightSource: neumorphiclightSource,
                    // color: config.themeColor,
                    depth: -10,
                    border: NeumorphicBorder(
                      color: config.redJP,
                      width: 250,
                    )),
                child: Container(
                  color: config.themeColor,
                  height: (sensorRadius * 2) + smallSensorRadius*2,
                )),
          ),

          // rim
          // Align(
          //   alignment: Alignment.center,
          //   child: Neumorphic(
          //       style: NeumorphicStyle(
          //         shape: NeumorphicShape.convex,
          //         boxShape: const NeumorphicBoxShape.circle(),
          //         intensity: 0.6,
          //         lightSource: neumorphiclightSource,
          //         color: config.themeColor,
          //         depth: 0,
          //       ),
          //       child: Container(
          //         color: config.themeColor,
          //         height: screenHeight * 0.415 - smallSensorRadius * 2,
          //       )),
          // ),

          // dent
          // Align(
          //   alignment: Alignment.center,
          //   child: Neumorphic(
          //       style: NeumorphicStyle(
          //         shape: NeumorphicShape.convex,
          //         boxShape: const NeumorphicBoxShape.circle(),
          //         intensity: 0.6,
          //         lightSource: neumorphiclightSource,
          //         // surfaceIntensity: 0.7,
          //         color: config.themeColor,
          //         depth: -3.5,
          //       ),
          //       child: Container(
          //         color: config.themeColor,
          //         height: screenHeight * 0.4 - smallSensorRadius * 2,
          //       )),
          // ),

          // rotated N
          Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: 30,
                child: Container(
                  height: screenHeight * 0.4 - smallSensorRadius * 2,
                  width: screenHeight * 0.4 - smallSensorRadius * 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: NeumorphicText('N',
                            style: const NeumorphicStyle(
                              shape: NeumorphicShape.flat,
                              color: config.themeGrey,
                              intensity: 0.8,
                              depth: 0.5,
                            ),
                            textStyle: NeumorphicTextStyle(
                                fontSize: screenHeight * 0.035,
                                fontWeight: FontWeight.bold)),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            NeumorphicText('—',
                                style: const NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  color: config.themeGrey,
                                  intensity: 0.8,
                                  depth: 0.5,
                                ),
                                textStyle: NeumorphicTextStyle(
                                    fontSize: screenHeight * 0.035)),
                            const Spacer(),
                            NeumorphicText('—',
                                style: const NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  color: config.themeGrey,
                                  intensity: 0.8,
                                  depth: 0.5,
                                ),
                                textStyle: NeumorphicTextStyle(
                                    fontSize: screenHeight * 0.035)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          // hint
          Align(
            alignment: Alignment.center,
            child: NeumorphicButton(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: const NeumorphicBoxShape.circle(),
                  intensity: 0.6,
                  // surfaceIntensity: 0.35,
                  lightSource: neumorphiclightSource,
                  color: config.themeColor,
                  depth: 6,
                  // border: NeumorphicBorder(
                  //   color: config.themeColorDent,
                  //   width: 1,
                  // )
                ),
                onPressed: () => {
                      // context
                      //     .read<CollectorBloc>()
                      //     .add(const ChasingModeStarted())
                    },
                child: Container(
                  height: (sensorRadius - smallSensorRadius * 2) * 2,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '還有５KM',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ),

          Stack(children: targets),

        ],
      ),
    );
  }
}

class BottomTouristList extends StatelessWidget {
  final List<String> usernames;
  final double screenWidth;
  final double screenHeight;

  const BottomTouristList(this.screenHeight, this.screenWidth, this.usernames,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.3,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: usernames.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: index == 0
                    ? BorderSide(
                        color: Colors.grey, // Customize the color as needed
                        width: 0.5, // Customize the width as needed
                      )
                    : BorderSide.none,
                bottom: BorderSide(
                  color: Colors.grey, // Customize the color as needed
                  width: 0.5, // Customize the width as needed
                ),
              ),
            ),
            child: ListTile(
              title: Text(usernames[index]),
              // You can customize the ListTile or add more widgets here
            ),
          );
        },
      ),
    );
  }
}

class AngleCalculator {
  Offset radiusProjector(double degree, double radius) {
    print('radius: $radius');
    degree = 2 * math.pi * (degree / 360);
    double x = radius * math.cos(degree);
    double y = radius * math.sin(degree);
    print('====== x: $x');
    print('====== y: $y');

    return Offset(x, y);
  }

  double calculateRotateAngleForContainer(double degree) {
    return -(2 * math.pi * ((degree) / 360));
  }
}

class DisplayBottle {
  double bearingAngle;
  int distance;

  DisplayBottle(this.bearingAngle, this.distance);
}
