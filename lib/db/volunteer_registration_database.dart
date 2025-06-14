import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/volunteer_registration.dart';

class VolunteerRegistrationDatabase {
  static final VolunteerRegistrationDatabase instance = VolunteerRegistrationDatabase._init();
  static Database? _database;

  VolunteerRegistrationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('volunteer_registrations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE volunteer_registrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campaignId INTEGER NOT NULL,
        user TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        gender TEXT,
        umur INTEGER,
        experience TEXT,
        status TEXT NOT NULL,
        adminFeedback TEXT,
        registeredAt TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE volunteer_registrations ADD COLUMN email TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE volunteer_registrations ADD COLUMN gender TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE volunteer_registrations ADD COLUMN umur INTEGER;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE volunteer_registrations ADD COLUMN experience TEXT;');
      } catch (_) {}
    }
  }

  Future<int> insertRegistration(VolunteerRegistration reg) async {
    final db = await instance.database;
    return await db.insert('volunteer_registrations', reg.toMap());
  }

  Future<List<VolunteerRegistration>> getRegistrationsByUser(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_registrations',
      where: 'user = ?',
      whereArgs: [username],
      orderBy: 'registeredAt DESC',
    );
    return result.map((map) => VolunteerRegistration.fromMap(map)).toList();
  }

  Future<List<VolunteerRegistration>> getRegistrationsByCampaign(int campaignId) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_registrations',
      where: 'campaignId = ?',
      whereArgs: [campaignId],
      orderBy: 'registeredAt DESC',
    );
    return result.map((map) => VolunteerRegistration.fromMap(map)).toList();
  }
    Future<void> deleteAllRegistrations() async {
    final db = await instance.database;
    await db.delete('volunteer_registrations');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
    
  }
}