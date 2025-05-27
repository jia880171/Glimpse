import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import './config.dart' as config;


class TrashView extends StatefulWidget {
  @override
  _TrashViewState createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  final ScrollController _dayController = ScrollController();
  final ScrollController _typeController = ScrollController();
  final ScrollController _hourController = ScrollController();
  final ScrollController _minController = ScrollController();
  final ScrollController _secController = ScrollController();

  late int selectedWeekdayIndex;
  late int selectedHour;
  int selectedGarbageIndex = 0;

  final int bufferCount = 3;
  final int timeDivider = 10;

  List<String> garbage = [
    '月 可燃',
    '火 なし',
    '水 資源',
    '木 可燃',
    '金 なし',
    '土 なし',
    '日 なし'
  ];
  late List<String> displayGarbageList;

  List<String> weekdaysList = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"];
  late List<String> displayWeekdaysList;

  List<int> hoursList = List.generate(24, (index) => index);
  late List<int> displayHoursList;

  double get redLineOffset => MediaQuery.of(context).size.height / 3;

  double get weekdayItemHeight => MediaQuery.of(context).size.height / 4;

  double get garbageItemHeight => MediaQuery.of(context).size.height / 3;

  double get hourItemHeight => MediaQuery.of(context).size.height / 4;

  double get minItemHeight => MediaQuery.of(context).size.height / 4;

  double get secondItemHeight => MediaQuery.of(context).size.height / 8;

  double verticalLineWidth = 2.0;
  double horizontalLineWidth = 2.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  int getSelectedWeekdayIndex(
      ScrollController controller, List<dynamic> weekdays) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double offset = controller.offset +
        redLineOffset -
        statusBarHeight; // 計算 redLineOffset 的實際位置
    int index = (offset / weekdayItemHeight).floor(); // 計算對應的星期索引

    // 確保 index 在有效範圍內
    index = index.clamp(0, weekdays.length - 1);

    return index;
  }

  int getSelectedHour(ScrollController controller, List<dynamic> hours) {
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    double offset = controller.offset +
        redLineOffset -
        statusBarHeight; // 計算 redLineOffset 的實際位置

    int index = (offset / hourItemHeight).floor(); // 計算對應的星期索引

    // 確保 index 在有效範圍內
    index = index.clamp(0, hours.length - 1);

    return hours[index]; // 回傳對應的星期
  }

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    // init the time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // weekday
      _scrollToCurrentWeekday(weekdayItemHeight, now.weekday, redLineOffset);
      // hour
      _scrollToCurrentHour(
          hourItemHeight, now.hour, redLineOffset, _hourController);

      //garbage
      _scrollToGarbage();

      // min
      _scrollToCurrentTimeSlot(
          minItemHeight, now.minute, redLineOffset, _minController);
      // second
      _scrollToCurrentTimeSlot(
          secondItemHeight, now.second, redLineOffset, _secController);
    });

    setDisplayLists();

    // update weekday, hour and min every minute
    Timer.periodic(const Duration(hours: 1), (timer) {
      if (mounted) {
        _scrollToCurrentWeekday(
            weekdayItemHeight, DateTime.now().weekday, redLineOffset);
        _scrollToCurrentHour(hourItemHeight, DateTime.now().hour, redLineOffset,
            _hourController);
      }
    });

    // update second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _scrollToCurrentTimeSlot(minItemHeight, DateTime.now().minute,
            redLineOffset, _minController);
        _scrollToCurrentTimeSlot(secondItemHeight, DateTime.now().second,
            redLineOffset, _secController);
      }
    });
  }

  void setDisplayLists() {
    setDisplayWeekdayList();
    setDisplayGarbageList();
    setDisplayHourList();
  }

  void setDisplayGarbageList() {
    List<String> firstFive = garbage.sublist(0, 5);
    List<String> lastThree = garbage.sublist(garbage.length - bufferCount);
    displayGarbageList = [
      ...lastThree,
      ...garbage,
      ...firstFive
    ]; // must have more elements than displayWeekdaysList
  }

  void setDisplayHourList() {
    List<int> firstThree = hoursList.sublist(0, bufferCount);
    List<int> lastThree = hoursList.sublist(hoursList.length - bufferCount);
    displayHoursList = [...lastThree, ...hoursList, ...firstThree];
  }

  void setDisplayWeekdayList() {
    List<String> firstThree = weekdaysList.sublist(0, bufferCount);
    List<String> lastThree =
        weekdaysList.sublist(weekdaysList.length - bufferCount);
    displayWeekdaysList = [...lastThree, ...weekdaysList, ...firstThree];
  }

  void _scrollToCurrentTimeSlot(double itemHeight, int currentTime,
      double redLineOffset, ScrollController controller) {
    double targetOffset = (itemHeight * 3) +
        (currentTime * itemHeight) -
        redLineOffset +
        (itemHeight / 2);

    if (controller.hasClients) {
      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToCurrentHour(double itemHeight, int currentHour,
      double redLineOffset, ScrollController controller) {
    double targetOffset = (itemHeight * 3) +
        (currentHour * itemHeight) -
        redLineOffset +
        (itemHeight / 2);

    if (controller.hasClients) {
      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }

    if (_dayController.hasClients) {
      selectedHour = getSelectedHour(_dayController, hoursList);
    }
  }

  void _scrollToCurrentWeekday(
      double itemHeight, int currentWeekday, double redLineOffset) {
    currentWeekday = currentWeekday - 1;

    double targetOffset = (itemHeight * 3) +
        (currentWeekday * itemHeight) -
        redLineOffset +
        (itemHeight / 2);

    if (_dayController.hasClients) {
      _dayController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );

      selectedWeekdayIndex =
          getSelectedWeekdayIndex(_dayController, weekdaysList);
    }
  }

  void _scrollToGarbage() {
    setState(() {
      selectedGarbageIndex = selectedWeekdayIndex;

      if (selectedHour >= timeDivider) {
        selectedGarbageIndex = (selectedGarbageIndex + 1);
      }
    });

    double targetOffset = (selectedGarbageIndex * garbageItemHeight) -
        redLineOffset +
        (garbageItemHeight / 2);

    if (_typeController.hasClients) {
      _typeController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double redLinePosition = screenHeight / 3; // 紅線固定位置

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  buildWeekdayColumn(displayWeekdaysList, _dayController, 0.15),

                  buildTrashColumn(displayGarbageList, _typeController, 0.25),

                  buildHourColumn(
                      displayHoursList, _hourController, 0.08 // 0 ~ 24 小時
                      ),

                  buildMinColumn(
                      [57, 58, 59] +
                          List.generate(60, (index) => index) +
                          [
                            0,
                            1,
                            2,
                            3,
                            4,
                            5,
                            6,
                            7,
                            8,
                            9,
                          ],
                      _minController,
                      0.05),

                  buildSecondColumn(
                      [57, 58, 59] +
                          List.generate(60, (index) => index) +
                          [
                            0,
                            1,
                            2,
                            3,
                            4,
                            5,
                            6,
                            7,
                            8,
                            9,
                          ],
                      _secController,
                      0.05),
                  // buildRedColumn(
                  //     List.generate(120, (index) => index + 1), // min
                  //     _hourController,
                  //     0.02),
                ],
              ),
            ),
            Positioned(
              top: redLinePosition,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                color: config.trashPointerRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColumn(List<dynamic> items, double screenHeight,
      ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(), // 根據佔比來設定 flex
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: ListView(
          controller: controller,
          children: items
              .map((item) => Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.black, width: 1), // 上邊框
                        bottom:
                            BorderSide(color: Colors.black, width: 1), // 下邊框
                      ),
                    ),
                    height: weekdayItemHeight, // 使用螢幕高的 1/2 作為項目的高度
                    child: ListTile(
                      title: Center(child: Text(item.toString())),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget buildWeekdayColumn(
      List<dynamic> items, ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(), // 根據佔比來設定 flex
      child: Container(
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      color: Colors.black.withOpacity(0.3),
                      width: verticalLineWidth))),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              // 滾動結束後，取得當前星期
              int weekday = getSelectedWeekdayIndex(controller, items);
              selectedWeekdayIndex = weekday;
              _scrollToGarbage();
              return true; // 返回 true 表示已處理事件
            },
            child:

            ListView(
              controller: controller,
              children: items
                  .map((item) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Colors.black.withOpacity(0.3),
                        width: horizontalLineWidth), // 上邊框
                  ),
                ),
                height: weekdayItemHeight,
                child:
                    Center(
                      child: Text(
                        item.toString().split('').join('\n'),
                        style: TextStyle(
                            color: (item.toString()[0] == '土' ||
                                item.toString()[0] == '日')
                                ? config.trashPointerRed.withOpacity(0.8)
                                : Colors.black.withOpacity(0.6),
                            fontFamily: 'asa',
                            fontSize: weekdayItemHeight * 0.15),
                      ),
                    )
                ,
              ))
                  .toList(),
            )
            ,
          )),
    );
  }

  Widget buildTrashColumn(
      List<dynamic> items, ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(), // 根據佔比來設定 flex
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                right: BorderSide(
                    color: Colors.black.withOpacity(0.3),
                    width: verticalLineWidth))),
        child: ListView(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          children: items
              .asMap()
              .map((index, item) => MapEntry(
                  index,
                  Container(
                    decoration: BoxDecoration(
                      color: index == selectedGarbageIndex
                          ? Colors.grey.withOpacity(0.15)
                          : null,
                      border: Border(
                        top: BorderSide(
                            color: Colors.black.withOpacity(0.3),
                            width: horizontalLineWidth), // 上邊框// 下邊框
                      ),
                    ),
                    height: garbageItemHeight,
                    child: ListTile(
                      title: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: item.toString()[0],
                                style: TextStyle(
                                  fontFamily: 'asa',
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: garbageItemHeight * 0.1,
                                ),
                              ),
                              TextSpan(
                                text: '\n',
                                style: TextStyle(
                                  fontFamily: 'asa',
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: garbageItemHeight * 0.1,
                                ),
                              ),
                              TextSpan(
                                text: item
                                    .toString()
                                    .substring(1)
                                    .split('')
                                    .join('\n'), // 剩下的字
                                style: TextStyle(
                                  fontFamily: 'asa',
                                  color: item.toString().split(' ')[1] == 'なし'
                                      ? Colors.black.withOpacity(0.6)
                                      : config.trashPointerRed.withOpacity(0.8),
                                  fontSize: garbageItemHeight * 0.16,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )))
              .values
              .toList(),
        ),
      ),
    );
  }

  Widget buildHourColumn(
      List<dynamic> items, ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(),
      child: Container(
          decoration: BoxDecoration(
              border: Border(
            right: BorderSide(color: Colors.grey, width: verticalLineWidth),
          )),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              selectedHour = getSelectedHour(controller, items);
              _scrollToGarbage();
              return true; // 返回 true 表示已處理事件
            },
            child: ListView(
              controller: controller,
              children: items
                  .map((item) => SizedBox(
                      height: hourItemHeight,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (4 * (widthFraction / 5) * 100).toInt(),
                            child: Center(
                                child: Text(item.toString(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black.withOpacity(0.5)))),
                          ),
                          Expanded(
                              flex: ((widthFraction / 5) * 100).toInt(),
                              child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                        bottom: BorderSide(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            width: horizontalLineWidth),
                                      )),
                                      height: hourItemHeight),
                                ],
                              ))
                        ],
                      )))
                  .toList(),
            ),
          )),
    );
  }

  Widget buildMinColumn(
      List<dynamic> items, ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(), // 根據佔比來設定 flex
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          right: BorderSide(color: Colors.grey, width: verticalLineWidth),
        )),
        child: ListView(
          controller: controller,
          children: items
              .map((item) => SizedBox(
                  height: hourItemHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (4 * (widthFraction / 5) * 100).toInt(),
                        child: Center(
                            child: Text(item.toString(),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black.withOpacity(0.55)))),
                      ),
                      Expanded(
                          flex: ((widthFraction / 5) * 100).toInt(),
                          child: Column(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.3),
                                        width: horizontalLineWidth),
                                  )),
                                  height: hourItemHeight),
                            ],
                          ))
                    ],
                  )))
              .toList(),
        ),
      ),
    );
  }

  Widget buildSecondColumn(
      List<dynamic> items, ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(),
      child: Container(
        decoration: const BoxDecoration(
            border: Border(
          right: BorderSide(color: Colors.grey, width: 1),
        )),
        child: ListView(
          controller: controller,
          children: items
              .map((item) => SizedBox(
                  height: secondItemHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (2 * (widthFraction / 3) * 100).toInt(),
                        child: Center(
                            child: Text(item.toString(),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: config.trashPointerRed.withOpacity(0.5)))),
                      ),
                      Expanded(
                          flex: ((widthFraction / 3) * 100).toInt(),
                          child: Column(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    left: BorderSide(
                                        color: config.trashPointerRed.withOpacity(0.5),
                                        width: verticalLineWidth),
                                    right: BorderSide(
                                        color: config.trashPointerRed.withOpacity(0.5),
                                        width: verticalLineWidth),
                                  )),
                                  height: secondItemHeight / 4),
                              Container(
                                height: secondItemHeight / 2,
                                color: config.trashPointerRed.withOpacity(0.5),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                    left: BorderSide(
                                        color: config.trashPointerRed.withOpacity(0.5),
                                        width: verticalLineWidth),
                                    right: BorderSide(
                                        color: config.trashPointerRed.withOpacity(0.5),
                                        width: verticalLineWidth),
                                  )),
                                  height: secondItemHeight / 4),
                            ],
                          ))
                    ],
                  )))
              .toList(),
        ),
      ),
    );
  }

  Widget buildUnscrollableColumn(List<dynamic> items, double screenHeight,
      ScrollController controller, double widthFraction) {
    return Expanded(
      flex: (widthFraction * 100).toInt(), // 根據佔比來設定 flex
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: ListView(
          controller: controller,
          physics: NeverScrollableScrollPhysics(), // 禁用滑動
          children: items
              .map((item) => Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.black, width: 1), // 上邊框
                        bottom:
                            BorderSide(color: Colors.black, width: 1), // 下邊框
                      ),
                    ),
                    height: weekdayItemHeight, // 使用螢幕高的 1/2 作為項目的高度
                    child: ListTile(
                      title: Center(child: Text(item.toString())),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _typeController.dispose();
    _hourController.dispose();
    super.dispose();
  }
}
