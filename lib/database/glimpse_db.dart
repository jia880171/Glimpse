import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'glimpse.dart';

class GlimpseDatabaseHelper {
  static Database? _database;
  static const String tableName = 'glimpse';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'glimpse_database.db');
    return openDatabase(
      path,
      version: 1, // Increment the version number to trigger an update
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            imgPaths TEXT,  -- Change imgPath to imgPaths and use TEXT to store JSON string
            content TEXT,
            GType INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations when upgrading database version
        if (oldVersion < 2) {
          // Add the "memo" column if the old version is less than 2
          await db.execute('ALTER TABLE $tableName ADD COLUMN memo TEXT');
        }
        // You can add more migration logic for different versions if needed
      },
    );
  }

  Future<int> updateGlimpse(Glimpse glimpse) async {
    final db = await database;
    return await db.update(
      tableName,
      glimpse.toMap(),
      where: 'id = ?',
      whereArgs: [glimpse.id],
    );
  }

  Future<int> insertGlimpse(Glimpse glimpse) async {
    final db = await database;
    final id = await db.insert(tableName, glimpse.toMap());
    print('Inserted Glimpse with id: $id');
    return id;
  }

  Future<List<Glimpse>> getGlimpses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Glimpse.fromMap(maps[i]);
    });
  }
}
