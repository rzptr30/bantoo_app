import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/volunteer.dart';

class VolunteerDB {
  static final VolunteerDB _instance = VolunteerDB._internal();
  factory VolunteerDB() => _instance;
  VolunteerDB._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'volunteer.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE volunteers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image TEXT,
            agency TEXT,
            location TEXT,
            description TEXT,
            expired TEXT,
            fee TEXT,
            quota INTEGER
          )
        ''');
      },
    );
  }

  Future<List<Volunteer>> getVolunteers({int offset = 0, int limit = 10}) async {
    final db = await database;
    final res = await db.query('volunteers', limit: limit, offset: offset);
    return res.map((e) => Volunteer.fromMap(e)).toList();
  }

  Future<int> addVolunteer(Volunteer v) async {
    final db = await database;
    return db.insert('volunteers', v.toMap());
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}