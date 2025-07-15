import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../config.dart' as config;
import '../models/film_profile.dart';
import '../services/film_profile_service.dart';
import '../widgets/film_canister/film_canister.dart';

class CreateOrEditFilmProfilePage extends StatefulWidget {
  final List<String> allAlbums; // 所有可選相簿
  final FilmProfile? filmProfile;
  final List<String>? initialSelectedAlbums;

  const CreateOrEditFilmProfilePage({
    super.key,
    required this.allAlbums,
    this.initialSelectedAlbums,
    this.filmProfile,
  });

  @override
  State<CreateOrEditFilmProfilePage> createState() =>
      _CreateOrEditFilmProfilePageState();
}

class _CreateOrEditFilmProfilePageState
    extends State<CreateOrEditFilmProfilePage> {
  late String iso;
  late String filmFormat;
  late String filmMaker;
  late String filmName;

  late TextEditingController isoController;
  late TextEditingController formatController;
  late TextEditingController makerController;
  late TextEditingController nameController;

  Set<String> selectedAlbums = {};

  bool get isEditMode => widget.filmProfile != null;
  int selectedColorIndex = 0;
  final List<Color> availableColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.brown,
  ];

  late Color canColor = availableColors[selectedColorIndex];

  @override
  void initState() {
    super.initState();
    iso = widget.filmProfile?.iso ?? '200';
    filmFormat = widget.filmProfile?.filmFormat ?? '135mm';
    filmMaker = widget.filmProfile?.filmMaker ?? 'KoQoc';
    filmName = widget.filmProfile?.filmName ?? 'Gold';

    isoController = TextEditingController(text: iso);
    formatController = TextEditingController(text: filmFormat);
    makerController = TextEditingController(text: filmMaker);
    nameController = TextEditingController(text: filmName);

    setColor();

    // 清除不存在的選項，避免外部刪除或不合規的資料
    final allAlbumsSet = widget.allAlbums.toSet();
    final initialSet = (widget.initialSelectedAlbums ?? <String>[]).toSet();

    final invalidAlbums = initialSet.difference(allAlbumsSet); // 不存在於手機中的
    final validAlbums = initialSet.intersection(allAlbumsSet);

    if (invalidAlbums.isNotEmpty) {
      for (final album in invalidAlbums) {
        debugPrint('[⚠️警告] 相簿 "$album" 不存在於手機中，可能已被刪除。');
      }
    }

    selectedAlbums = {...validAlbums};
  }

  void setColor() {

    final defaultColor = availableColors[0];

    if (isEditMode) {
      final colorFromProfile = Color(widget.filmProfile!.colorHex);
      final foundIndex = availableColors.indexWhere((c) => c.value == colorFromProfile.value);
      if (foundIndex != -1) {
        selectedColorIndex = foundIndex;
        canColor = availableColors[foundIndex];
      } else {
        selectedColorIndex = 0;
        canColor = defaultColor;
      }
    } else {
      selectedColorIndex = 0;
      canColor = defaultColor;
    }
  }

  @override
  void dispose() {
    isoController.dispose();
    formatController.dispose();
    makerController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double filmCanisterWidth = screenWidth * 0.3;

    final appBar = AppBar(
      title: Text(isEditMode ? '編輯底片分類' : '創建底片分類'),
      backgroundColor: config.dashboardBackGroundMainTheme,
    );

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fullHeight = constraints.maxHeight;
            final filmHeight = fullHeight * 0.3;

            return Column(
              children: [
                SizedBox(
                  height: filmHeight,
                  child: Center(
                    child: FilmCanisterWidget(
                      width: filmCanisterWidth,
                      bodyColor: canColor,
                      iso: iso,
                      filmFormat: filmFormat,
                      filmMaker: filmMaker,
                      filmName: filmName,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          TextField(
                            controller: isoController,
                            onChanged: (value) => iso = value,
                            decoration: const InputDecoration(labelText: 'ISO'),
                          ),

                          TextField(
                            controller: formatController,
                            onChanged: (value) => filmFormat = value,
                            decoration: const InputDecoration(labelText: '尺寸'),
                          ),

                          TextField(
                            controller: makerController,
                            onChanged: (value) => filmMaker = value,
                            decoration: const InputDecoration(labelText: '品牌'),
                          ),

                          TextField(
                            controller: nameController,
                            onChanged: (value) => filmName = value,
                            decoration: const InputDecoration(labelText: '底片名'),
                          ),

                          const SizedBox(height: 20),
                          const Text('選擇顏色', style: TextStyle(fontWeight: FontWeight.bold)),

                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: List.generate(availableColors.length, (index) {
                                final color = availableColors[index];
                                final isSelected = selectedColorIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColorIndex = index;
                                      canColor = color;
                                    });
                                  },
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      depth: isSelected ? -1 : 1,
                                      boxShape: const NeumorphicBoxShape.circle(),
                                      color: color,
                                      border: NeumorphicBorder(
                                        color: isSelected ? Colors.black : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: SizedBox(width: screenWidth * 0.2, height: screenWidth * 0.2),
                                  ),
                                );
                              }),
                            ),
                          ),


                          const SizedBox(height: 30),
                          const Text(
                            '選擇要包含的相簿',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          MultiSelectDialogField<String>(
                            items: widget.allAlbums
                                .map((e) => MultiSelectItem<String>(e, e))
                                .toList(),
                            title: const Text("選擇相簿"),
                            buttonText: const Text("選擇相簿"),
                            initialValue: selectedAlbums.toList(),
                            onConfirm: (values) {
                              setState(() {
                                selectedAlbums
                                  ..clear()
                                  ..addAll(values);
                              });
                            },
                            searchable: true,
                            chipDisplay: MultiSelectChipDisplay(
                              onTap: (value) {
                                setState(() {
                                  selectedAlbums.remove(value);
                                  print(
                                      '======selectedAlbums: ${selectedAlbums}');
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 200),
                          ElevatedButton(
                            onPressed: _submitToDb,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  config.dashboardBackGroundMainTheme,
                            ),
                            child: Text(isEditMode ? '儲存變更' : '建立底片分類'),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitToDb() async {
    print('====== isEdit? ${isEditMode}');

    final filmService = FilmProfileService();

    // ✅ 確保資料庫內有相對應 Album（如無則建立）
    final albums =
        await filmService.ensureAlbumsExistByNames(selectedAlbums.toList());

    // 用 4 個欄位當作組合鍵，查找是否已存在
    final existing = await filmService.findExistingProfile(
      iso: iso,
      filmFormat: filmFormat,
      filmMaker: filmMaker,
      filmName: filmName,
    );

    if (existing != null || isEditMode == true) {
      print('===== updating, albums: ${albums}');

      final profile = widget.filmProfile ?? existing!;

      // 已存在 → 視為更新
      await filmService.updateFilmProfile(
        profile: profile,
        iso: iso,
        filmFormat: filmFormat,
        filmMaker: filmMaker,
        filmName: filmName,
        albums: albums,
        colorHex: canColor.value,
      );
    } else {
      print('===== creating');

      // 不存在 → 新增
      await filmService.createFilmProfile(
        iso: iso,
        filmFormat: filmFormat,
        filmMaker: filmMaker,
        filmName: filmName,
        albums: albums,
        colorHex: canColor.value,
      );
    }

    if (context.mounted) Navigator.pop(context);
  }
}
