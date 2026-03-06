import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config.dart' as config;
import '../../models/glimpse.dart';
import '../../services/database_service.dart';
import '../../services/glimpse_service.dart';

class JournalsView extends StatefulWidget {
  final DateTime selectedGlimpseDay;

  const JournalsView({super.key, required this.selectedGlimpseDay});

  @override
  State<StatefulWidget> createState() {
    return _JournalsViewState();
  }
}

List<Color> cardColors = [
  config.journalCard1,
  config.journalCard2,
  config.journalCard3,
  config.journalCard4
];

class _JournalsViewState extends State<JournalsView> {
  bool _isLoadingImages = true;
  late GlimpseService _glimpseService;
  List<Glimpse> _glimpses = <Glimpse>[];
  List<Uint8List?> _images = <Uint8List?>[];

  late Size cardSize;
  late Size tSize;
  late double marginTopForThumbnail;

  late double locationFontSize;
  late double locationFontHeight;

  late double titleFontSize;
  late double titleFontHeight;

  late double secondaryFontSize;
  late double secondaryFontHeight;

  // 長文高度
  final lineHeight = 16.0;

  // 可用高度
  late double availableHeight;

  late double bottomSectionHeight;

  @override
  void initState() {
    super.initState();

    _glimpseService = GlimpseService(DatabaseService.isar);

    // Kick off initial load for the selected day.
    // Always check mounted before setState inside async flow later.
    _loadDayGlimpses();
  }

  @override
  Widget build(BuildContext context) {
    cardSize = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 0.68);

    // 0.5
    tSize = Size(cardSize.width * 0.9, cardSize.height * 0.5);

    // 0.05
    locationFontHeight = cardSize.height * 0.03;
    locationFontSize = locationFontHeight / 1.8;

    // 0.05
    titleFontHeight = cardSize.height * 0.05;
    titleFontSize = titleFontHeight / 1.8;

    secondaryFontHeight = cardSize.height * 0.025;
    secondaryFontSize = secondaryFontHeight / 1.8;

    // card 0.03
    marginTopForThumbnail = cardSize.height * 0.03;

    // 0.05  0.68
    bottomSectionHeight = cardSize.height * 0.1;

    availableHeight = cardSize.height -
        (tSize.height + // 0.5
            locationFontHeight + // 0.05
            titleFontHeight + // 0.05
            secondaryFontHeight + // 0.03
            marginTopForThumbnail + // 0.03
            bottomSectionHeight + // 0.05
            cardSize.height * 0.001 * 2);

    // Use a Cupertino scaffold since you imported Cupertino.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_titleForDay(widget.selectedGlimpseDay)),
      ),
      child: SafeArea(
          child: Container(
        color: Colors.black,
        child: _buildBody(),
      )),
    );
  }

  /// Build the body based on loading/data states.
  Widget _buildBody() {
    if (_isLoadingImages == true) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_glimpses.isEmpty == true) {
      return Center(
        child: Text(
          'No glimpses on ${_formatYmd(widget.selectedGlimpseDay)}',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    // Render list of glimpses for the day.
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _glimpses.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (BuildContext context, int index) {
        return Align(
          alignment: Alignment.center, // or center, centerRight
          child: SizedBox(
            // width: MediaQuery.of(context).size.width * 0.5,
            child: _buildGlimpseColumn(index), // your Container
          ),
        );

        // return _buildGlimpseColumn(index);
      },
    );
  }

  /// Build a single row with a thumbnail (if any) and basic info text.
  Widget _buildGlimpseColumn(int index) {
    final Glimpse g = _glimpses[index];
    final Uint8List? imgBytes = _images.length > index ? _images[index] : null;
    final String location = _locationOf(g);

    final random = Random();

    return Container(
        height: cardSize.height,
        width: cardSize.width,
        decoration: BoxDecoration(
          color: cardColors[index % cardColors.length],
          borderRadius: BorderRadius.circular(cardSize.width * 0.058),
        ),
        padding: EdgeInsets.only(top: marginTopForThumbnail),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: <Widget>[
                _buildThumbnail(imgBytes),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // set width of texts
                    SizedBox(
                      width: cardSize.width * 0.85,
                      height: cardSize.height * 0.001,
                    ),

                    SizedBox(
                      height: titleFontHeight,
                      child: Text(
                        '標題測試',
                        maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: titleFontSize,
                          decoration: TextDecoration.none,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Title line: fallback to path if there is no title field available.
                    SizedBox(
                      height: locationFontHeight,
                      child: Text(
                        location,
                        maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: locationFontSize,
                          decoration: TextDecoration.none,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: cardSize.height * 0.001),

                    // Secondary line: indicate index and day for simple context.
                    SizedBox(
                        height: secondaryFontHeight,
                        child: Text(
                          'Item #${index + 1} • ${_formatYmd(widget.selectedGlimpseDay)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: secondaryFontSize,
                            color: CupertinoColors.inactiveGray,
                            decoration: TextDecoration.none,
                          ),
                        )),

                    // Dynamic text area
                    SizedBox(
                      // color: Colors.red,
                      height: availableHeight,
                      width: cardSize.width * 0.85,
                      child: SingleChildScrollView(
                        child: Text(
                          testStrings[random.nextInt(4)], // 你的大量文字
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: bottomSectionHeight,
                child: Column(
                  children: [
                    const Divider(
                      thickness: 0.6,
                      color: Colors.grey,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: cardSize.width * 0.03,
                        ),
                        ...buildFriends(['W', 'H', 'J', 'D', 'T', 'L'],
                            bottomSectionHeight * 0.3, index),
                        const Spacer(),
                        const Icon(CupertinoIcons.right_chevron, size: 18),
                        SizedBox(
                          width: cardSize.width * 0.03,
                        )
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  /// Build thumbnail box; shows image if available, otherwise a placeholder.
  Widget _buildThumbnail(Uint8List? bytes) {
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(cardSize.width * 0.058),
        child: Image.memory(
          bytes,
          width: tSize.width,
          height: tSize.height,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true, // Prevent flicker on rebuilds.
        ),
      );
    } else {
      return Container(
        width: tSize.width,
        height: tSize.height,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey4,
          borderRadius: BorderRadius.circular(cardSize.width * 0.058),
        ),
        child: const Icon(
          CupertinoIcons.photo_on_rectangle,
          size: 24,
          color: CupertinoColors.white,
        ),
      );
    }
  }

  /// Load all glimpses for the target day and cache their images.
  Future<void> _loadDayGlimpses() async {
    // Fixed the log tag typo to match the method name.
    print('====== _loadDayGlimpses');

    _isLoadingImages = true;

    try {
      print('====== widget.selectedGlimpseDay: ${widget.selectedGlimpseDay}');
      final List<Glimpse> results = await _glimpseService
          .getGlimpsesByExifTimeOnDay(widget.selectedGlimpseDay);

      print('====== results: $results');

      final List<Uint8List?> imgs = <Uint8List?>[];

      for (int i = 0; i < results.length; i++) {
        final String? path = _imagePathOf(results[i]);
        if (path == null) {
          imgs.add(null);
        } else {
          imgs.add(await _readImageBytes(path));
        }
      }

      if (mounted == true) {
        setState(() {
          _glimpses = results;
          _images = imgs;
          _isLoadingImages = false;
        });
      } else {
        _isLoadingImages = false;
      }
    } catch (e) {
      if (mounted == true) {
        setState(() {
          _glimpses = <Glimpse>[];
          _images = <Uint8List?>[];
          _isLoadingImages = false;
        });
      } else {
        _isLoadingImages = false;
      }
    }
  }

  /// Extract the primary image path from a Glimpse.
  String? _imagePathOf(Glimpse g) {
    // TODO: adjust this to your model. Use the correct field that stores the main image path.
    // Example assumption:
    if (g.photoPath.isNotEmpty == true) {
      return g.photoPath;
    } else {
      return null;
    }
  }

  String _locationOf(Glimpse g) {
    // Collect parts safely
    final parts = <String>[
      if (g.addressCountry != null && g.addressCountry!.isNotEmpty)
        g.addressCountry!,
      if (g.addressPrefecture != null && g.addressPrefecture!.isNotEmpty)
        g.addressPrefecture!,
      if (g.addressCity != null && g.addressCity!.isNotEmpty) g.addressCity!,
    ];

    if (parts.isEmpty) {
      return 'Unknown Place';
    } else {
      return parts.join(',');
    }
  }

  /// Read image bytes from filesystem safely.
  Future<Uint8List?> _readImageBytes(String path) async {
    try {
      final File f = File(path);
      if (await f.exists() == true) {
        return await f.readAsBytes();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Format page title based on the selected day.
  String _titleForDay(DateTime day) {
    return 'Journals • ${_formatYmd(day)}';
  }

  /// Format YYYY-MM-DD without importing intl.
  String _formatYmd(DateTime dt) {
    // Do not import extra packages here; keep it simple and predictable.
    final String iso = dt.toIso8601String(); // e.g., 2025-09-04T10:12:00.000
    final List<String> parts = iso.split('T');
    if (parts.isNotEmpty == true) {
      return parts.first;
    } else {
      return iso;
    }
  }

  List<Widget> buildFriends(
      List<String> friends, double radius, int outerIndex) {
    List<Widget> friendWidgets = [];
    int offset = 0;
    for (int i = 0; i < friends.length; i++) {
      outerIndex = outerIndex % cardColors.length;
      int colorIndex = (i + offset) % cardColors.length;

      Color color;
      if (outerIndex == colorIndex) {
        colorIndex++;
        offset++;
      }
      color = cardColors[colorIndex % cardColors.length];

      friendWidgets.add(
        circularTap(
          radius: radius,
          label: friends[i],
          color: color,
          onTap: () {
            // TODO: 點擊事件
            debugPrint('Clicked: ${friends[i]}');
          },
        ),
      );

      if (i < friends.length - 1) {
        friendWidgets.add(SizedBox(width: radius * 0.3)); // 你要的間隔
      }
    }

    return friendWidgets;
  }

  Widget circularTap({
    required double radius,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    // 依底色自動選擇黑/白字，確保對比
    final Color textColor =
        (color.computeLuminance() > 0.5) ? Colors.black : Colors.white;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias, // 讓水波紋被裁成圓形
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              // 用 FittedBox 讓不同字數也能優雅縮放
              child: Padding(
                padding: EdgeInsets.all(radius * 0.18),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: radius * 0.9,
                      // 基準字級，FittedBox 會視需要縮小
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<String> testStrings = [
  '我錯過了末班飛機，臨行又有人改變了計畫，一連串的荒謬讓我和另外四個人搭上同一部車，車在蜿蜒山路失控，垂掛懸崖邊。駕駛駱大海掉下去了，老闆的兒子胖子與滿口股票經的黃君機伶地逃生了。車上只剩我與右邊那個戴著軟塌塌帽子的男人，高中時代與我爭奪雪，雪後來成為我的妻。我錯過了末班飛機，臨行又有人改變了計畫，一連串的荒謬讓我和另外四個人搭上同一部車，車在蜿蜒山路失控，垂掛懸崖邊。駕駛駱大海掉下去了，老闆的兒子胖子與滿口股票經的黃君機伶地逃生了。車上只剩我與右邊那個戴著軟塌塌帽子的男人，高中時代與我爭奪雪，雪後來成為我的妻。',
  '一個窮途潦倒的青年大學畢業後返鄉，心儀的女子已嫁給富商，曾想尋死，卻被村長撞見。某日，有企業來鎮上募工，村長領著老闆進屋時，他正在睡覺，沒睜開眼，卻認得那個聲音，一個好賭而跑路的人，已經遺忘兒子的父親。他還是進了那家企業，發現父親改名為「杜思妥」，在舊書攤向杜思妥也夫斯基借來的名字，而他要做的，是寫下杜思妥的傳記。我錯過了末班飛機，臨行又有人改變了計畫，一連串的荒謬讓我和另外四個人搭上同一部車，車在蜿蜒山路失控，垂掛懸崖邊。駕駛駱大海掉下去了，老闆的兒子胖子與滿口股票經的黃君機伶地逃生了。車上只剩我與右邊那個戴著軟塌塌帽子的男人，高中時代與我爭奪雪，雪後來成為我的妻。',
  '早年嗜賭背債而跑路的蔡恭晚，在外漂泊二十年後終於回家，迎接他的是老妻蔡歐陽晴美的冷言語，原來被兒子耍了，事業有成的兒子蔡紫式只是要一段家庭錄影畫面，父慈子孝，上電視用的。蔡紫式有特殊的性癖好，身旁女伴一個換過一個，妻子蔡瑟芬只能把心力投注於插花的教學上。第三代阿莫被父親安排到一家飯店當門房，卻被指控綁架一位前來投宿的少女。我錯過了末班飛機，臨行又有人改變了計畫，一連串的荒謬讓我和另外四個人搭上同一部車，車在蜿蜒山路失控，垂掛懸崖邊。駕駛駱大海掉下去了，老闆的兒子胖子與滿口股票經的黃君機伶地逃生了。車上只剩我與右邊那個戴著軟塌塌帽子的男人，高中時代與我爭奪雪，雪後來成為我的妻。',
  '특별한 의미는 없어도… 그래도 살아야 해. 버티고 나면, 네가 생각한 것보다 훨씬 강한 사람이라는 걸 알게 될 거야.',
  '특별한 의미는 없어도… 그래도 살아야 해. 버티고 나면, 네가 생각한 것보다 훨씬 강한 사람이라는 걸 알게 될 거야. 사람이 견딜 수 있는 한계는, 본인이 생각하는 것보다 훨씬 많아.',
  '그럼 다른 사람이랑 같이 버텨.혼자 말고, 누구랑 같이 있으면… 하루 더 살 수 있어.',
  '사람이 견딜 수 있는 한계는, 본인이 생각하는 것보다 훨씬 많아.',
  '특별한 의미는 없어도… 그래도 살아야 해. 버티고 나면, 네가 생각한 것보다 훨씬 강한 사람이라는 걸 알게 될 거야. 사람이 견딜 수 있는 한계는, 본인이 생각하는 것보다 훨씬 많아.'
];
