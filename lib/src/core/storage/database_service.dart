import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';


class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

  static const String _dbName = 'food_bill_tracker.db';
  static const int _dbVersion = 1;

  static const String tableFoodEntries = 'food_entries';
  static const String colId = 'id';
  static const String colDate = 'date'; // stored as ISO-8601 string
  static const String colMorningMeal = 'morning_meal';
  static const String colMorningPrice = 'morning_price';
  static const String colAfternoonMeal = 'afternoon_meal';
  static const String colAfternoonPrice = 'afternoon_price';
  static const String colNightMeal = 'night_meal';
  static const String colNightPrice = 'night_price';
  static const String colNotes = 'notes';

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFoodEntries (
        $colId TEXT PRIMARY KEY,
        $colDate TEXT NOT NULL,
        $colMorningMeal TEXT NOT NULL,
        $colMorningPrice REAL NOT NULL,
        $colAfternoonMeal TEXT NOT NULL,
        $colAfternoonPrice REAL NOT NULL,
        $colNightMeal TEXT NOT NULL,
        $colNightPrice REAL NOT NULL,
        $colNotes TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
