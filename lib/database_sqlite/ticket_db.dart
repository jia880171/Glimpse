import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'ticket.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'tickets';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'ticket_database.db');
    return openDatabase(
      path,
      version: 1, // Increment the version number to trigger an update
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            memo TEXT,
            date TEXT,
            departureTime TEXT,
            arrivalTime TEXT,
            trainName TEXT,
            trainNumber TEXT,
            carNumber TEXT,
            row TEXT,
            seat TEXT,
            departureStation TEXT,
            arrivalStation TEXT,
            isUsed INTEGER DEFAULT 0
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

  Future<int> updateTicket(Ticket ticket) async {
    final db = await database;
    return await db.update(
      tableName,
      ticket.toMap(),
      where: 'id = ?',
      whereArgs: [ticket.id],
    );
  }

  Future<int> insertTicket(Ticket ticket) async {
    final db = await database;
    return await db.insert(tableName, ticket.toMap());
  }

  Future<List<Ticket>> getTickets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Ticket(
        id: maps[i]['id'],
        memo: maps[i]['memo'],
        date: maps[i]['date'],
        departureTime: maps[i]['departureTime'],
        arrivalTime: maps[i]['arrivalTime'],
        trainName: maps[i]['trainName'],
        trainNumber: maps[i]['trainNumber'],
        carNumber: maps[i]['carNumber'],
        row: maps[i]['row'],
        seat: maps[i]['seat'],
        departureStation: maps[i]['departureStation'],
        arrivalStation: maps[i]['arrivalStation'],
        isUsed: maps[i]['isUsed'] == 1,

      );
    });
  }
}
