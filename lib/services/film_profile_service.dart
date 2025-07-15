import 'package:isar/isar.dart';
import '../models/film_profile.dart';
import 'database_service.dart';

class FilmProfileService {
  final Isar _isar = DatabaseService.isar;

  /// 確保指定相簿名稱都在資料庫中，如無則自動建立。
  Future<List<Album>> ensureAlbumsExistByNames(List<String> names) async {
    final List<Album> result = [];

    await _isar.writeTxn(() async {
      for (final name in names) {
        final existing = await _isar.albums.filter().nameEqualTo(name).findFirst();
        if (existing != null) {
          result.add(existing);
        } else {
          final newAlbum = Album()..name = name;
          final id = await _isar.albums.put(newAlbum);
          final inserted = await _isar.albums.get(id);
          if (inserted != null) {
            result.add(inserted);
          }
        }
      }
    });

    return result;
  }

  /// 新增 FilmProfile 並關聯相簿
  Future<void> createFilmProfile({
    required String iso,
    required String filmFormat,
    required String filmMaker,
    required String filmName,
    required int colorHex,
    required List<Album> albums,
  }) async {
    final newProfile = FilmProfile()
      ..iso = iso
      ..filmFormat = filmFormat
      ..filmMaker = filmMaker
      ..filmName = filmName
      ..colorHex = colorHex;

    await _isar.writeTxn(() async {
      await _isar.filmProfiles.put(newProfile);
      newProfile.albums.addAll(albums);
      await newProfile.albums.save();
    });
  }

  /// 更新既有 FilmProfile
  Future<void> updateFilmProfile({
    required FilmProfile profile,
    required String iso,
    required String filmFormat,
    required String filmMaker,
    required String filmName,
    required int colorHex,
    required List<Album> albums,
  }) async {
    await _isar.writeTxn(() async {
      final id = profile.id;

      // 1. 刪除原 profile（會自動清 links）
      await _isar.filmProfiles.delete(id);

      // 2. 建立新 profile（用同樣 id）
      final newProfile = FilmProfile()
        ..id = id
        ..iso = iso
        ..filmFormat = filmFormat
        ..filmMaker = filmMaker
        ..filmName = filmName
        ..colorHex = colorHex;

      await _isar.filmProfiles.put(newProfile);
      newProfile.albums.addAll(albums);
      await newProfile.albums.save();
    });
  }





  /// 查找符合條件的既有 FilmProfile（for 編輯模式）
  Future<FilmProfile?> findExistingProfile({
    required String iso,
    required String filmFormat,
    required String filmMaker,
    required String filmName,
  }) async {
    return await _isar.filmProfiles
        .filter()
        .isoEqualTo(iso)
        .and()
        .filmFormatEqualTo(filmFormat)
        .and()
        .filmMakerEqualTo(filmMaker)
        .and()
        .filmNameEqualTo(filmName)
        .findFirst();
  }

  Future<List<FilmProfile>> getAllFilmProfiles() async {
    final profiles = await _isar.filmProfiles.where().findAll();
    for(final profile in profiles){
      await profile.albums.load();
    }
    return profiles;
  }

  String formatLabel(FilmProfile profile) {
    return '${profile.filmMaker}${profile.filmName}${profile.iso}-${profile.filmFormat}';
  }

  List<String> formatLabels(List<FilmProfile> profiles) {
    return profiles.map(formatLabel).toList();
  }

  Map<String, FilmProfile> formatLabelMap(List<FilmProfile> profiles) {
    return {
      for (var profile in profiles)
        '${profile.filmMaker}${profile.filmName}${profile.iso}${profile.filmFormat}': profile
    };
  }
}
