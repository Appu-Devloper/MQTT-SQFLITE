import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'connectionmodel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'connections.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE connections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId TEXT,
        host TEXT,
        port TEXT,
        user TEXT,
        password TEXT,
        certificatePath TEXT
      )
    ''');
  }


Future<int> insertConnection(Connection connection) async {
  Database db = await database;
  
  // Check if a connection with the same host already exists
  List<Map<String, dynamic>> existingConnections = await db.query('connections',
      where: 'host = ?', whereArgs: [connection.host]);

  if (existingConnections.isNotEmpty) {
    // Host already exists, handle the case (e.g., update or skip)
    // For now, let's just skip the insertion
    return -1; // Return a flag indicating that insertion was skipped
  } else {
    // Host doesn't exist, proceed with the insertion
    return await db.insert('connections', connection.toMap());
  }
}

  Future<List<Connection>> getConnections() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('connections');
    return List.generate(maps.length, (i) {
      return Connection(
        clientId: maps[i]['clientId'],
        host: maps[i]['host'],
        port: maps[i]['port'],
        user: maps[i]['user'],
        password: maps[i]['password'],
        certificatePath: maps[i]['certificatePath'],
      );
    });
  }
}
