import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dispatch.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dispatches.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dispatches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate TEXT NOT NULL,
        destination TEXT NOT NULL,
        estimatedPrice REAL NOT NULL,
        dispatchDate TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertDispatch(Dispatch dispatch) async {
    Database db = await database;
    return await db.insert('dispatches', dispatch.toMap());
  }

  Future<List<Dispatch>> getAllDispatches() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dispatches');
    return List.generate(maps.length, (i) {
      return Dispatch.fromMap(maps[i]);
    });
  }

  Future<void> deleteDispatch(int id) async {
    Database db = await database;
    await db.delete('dispatches', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllDispatches() async {
    Database db = await database;
    await db.delete('dispatches');
  }
}