import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './attraction.dart';

class AttractionDatabaseHelper {
  static Database? _database;
  static const String tableName = 'attractions';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'attraction_database.db');
    return openDatabase(
      path,
      version: 1, // Increment the version number to trigger an update
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sequenceNumber INTEGER,
            name TEXT,
            memo TEXT,
            latitude REAL,
            longitude REAL,
            date TEXT,
            departureTime TEXT,
            arrivalTime TEXT,
            departureStation TEXT,
            arrivalStation TEXT,
            isVisited INTEGER DEFAULT 0,
            isNavigating INTEGER DEFAULT 0
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

  Future<int> updateAttraction(Attraction attraction) async {
    final db = await database;
    return await db.update(
      tableName,
      attraction.toMap(),
      where: 'id = ?',
      whereArgs: [attraction.id],
    );
  }

  Future<int> insertAttraction(Attraction attraction) async {
    final db = await database;

    final List<Map<String, dynamic>> sequenceQuery = await db
        .rawQuery('SELECT MAX(sequenceNumber) as maxSeq FROM $tableName');
    print('===== last?: ${sequenceQuery.first['maxSeq']}');
    int nextSequenceNumber = (sequenceQuery.first['maxSeq'] ?? 0) + 1;

    final attractionWithSequence = Attraction(
      name: attraction.name,
      sequenceNumber: nextSequenceNumber,
      memo: attraction.memo,
      date: attraction.date,
      latitude: attraction.latitude,
      longitude: attraction.longitude,
      arrivalTime: attraction.arrivalTime,
      departureTime: attraction.departureTime,
      arrivalStation: attraction.arrivalStation,
      departureStation: attraction.departureStation,
      isVisited: attraction.isVisited,
      isNavigating: attraction.isNavigating,

    );

    return await db.insert(tableName, attractionWithSequence.toMap());
  }

  Future<List<Attraction>> getAttractions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Attraction(
        id: maps[i]['id'],
        sequenceNumber: maps[i]['sequenceNumber'],
        name: maps[i]['name'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        memo: maps[i]['memo'],
        date: maps[i]['date'],
        departureTime: maps[i]['departureTime'],
        arrivalTime: maps[i]['arrivalTime'],
        departureStation: maps[i]['departureStation'],
        arrivalStation: maps[i]['arrivalStation'],
        isVisited: maps[i]['isVisited'] == 1,
        isNavigating: maps[i]['isNavigating'] == 1,
      );
    });
  }
}
