import 'package:glimpse/models/sake.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/film_profile.dart';
import '../models/food.dart';
import '../models/glimpse.dart';
import '../models/place.dart';
import '../models/receipt.dart';

/// A singleton service to initialize and access the Isar database.
class DatabaseService {
  // The single shared Isar instance across the entire app.
  static late final Isar _isar;

  /// Initializes the Isar database with all required schemas.
  /// ====== [[This should be called once in main(), before running the app.]] ======
  static Future<void> init() async {
    // Get the directory where the database file will be stored.
    final dir = await getApplicationDocumentsDirectory();

    // Open the Isar instance with the specified schemas and store location.
    _isar = await Isar.open(
      [
        GlimpseSchema,
        ReceiptSchema,
        PlaceSchema,
        FoodSchema,
        SakeSchema,
        AlbumSchema,
        FilmProfileSchema,
      ],
      directory: dir.path,
    );
  }

  /// Returns the shared Isar instance.
  /// Use this throughout the app to avoid creating multiple database connections.
  static Isar get isar => _isar;
}
