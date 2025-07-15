import 'package:flutter/material.dart';

import '../../config.dart' as config;
import '../../models/film_profile.dart';
import '../../views/create_or_edit_film_profile_view.dart';
import '../film_canister/film_canister.dart';

class PopupMenu extends StatelessWidget {
  final Map<String, FilmProfile> dbAlbumMap;
  final List<String> systemAlbumsNames;
  final double screenWidth;

  final Function updateAlbums;

  final ValueChanged<String> onSelected;

  const PopupMenu({
    super.key,
    required this.systemAlbumsNames,
    required this.onSelected,
    required this.screenWidth,
    required this.dbAlbumMap,
    required this.updateAlbums,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == '創建底片分類') {
          // ⏩ 導航到新頁面
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateOrEditFilmProfilePage(
                      allAlbums: systemAlbumsNames,
                    )),
          );
        } else {
          // 📌 正常處理
          onSelected(value);
        }
      },
      itemBuilder: (BuildContext context) {
        // 建立一個新的清單，第一項是「創建」
        final List<PopupMenuEntry<String>> menuItems = [
          const PopupMenuItem<String>(
            value: '創建底片分類',
            child: Row(
              children: [
                // Icon(Icons.create_new_folder, size: 20, color: Colors.black54),
                FilmCanisterWidget(
                  width: 20,
                  bodyColor: config.dashboardBackGroundMainTheme,
                  iso: '200',
                  filmFormat: '135mm',
                  filmMaker: 'Koka',
                  filmName: 'Gold',
                ),
                SizedBox(width: 8),
                Text('創建底片分類'),
              ],
            ),
          ),
          const PopupMenuDivider(),
        ];

        // 加入其他項目
        menuItems.addAll(dbAlbumMap.keys.toList().map((choice) {
          final profile = dbAlbumMap[choice];
          final selectedAlbumNames =
              profile?.albums.map((album) => album.name).toList();

          return PopupMenuItem<String>(
            value: choice,
            child: Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
                  // 或其他你想要的最大寬度
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(choice, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.edit,
                      size: screenWidth * 0.05, color: Colors.grey),
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrEditFilmProfilePage(
                          allAlbums: systemAlbumsNames,
                          initialSelectedAlbums: selectedAlbumNames,
                          filmProfile: profile,
                        ),
                      ),
                    ).then((_) async {
                      // ⏮️ 使用者從編輯頁返回後執行 callback
                      await updateAlbums(); // 🔁 你要執行的 callback
                    });
                  },
                ),
              ],
            ),
          );
        }));

        menuItems.addAll(systemAlbumsNames.map((choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(choice),
              ],
            ),
          );
        }));

        return menuItems;
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }
}
