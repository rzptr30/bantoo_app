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
      version: 1,
      onCreate: _createDB,
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
        status TEXT NOT NULL,
        adminFeedback TEXT,
        registeredAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRegistration(VolunteerRegistration reg) async {
    final db = await instance.database;
    return await db.insert('volunteer_registrations', reg.toMap());
  }

  Future<List<VolunteerRegistration>> getRegistrationsByCampaign(int campaignId) async {
    final db = await instance.database;
    final res = await db.query(
      'volunteer_registrations',
      where: 'campaignId = ?',
      whereArgs: [campaignId],
      orderBy: 'registeredAt DESC',
    );
    return res.map((m) => VolunteerRegistration.fromMap(m)).toList();
  }

  Future<List<VolunteerRegistration>> getRegistrationsByUser(String user) async {
    final db = await instance.database;
    final res = await db.query(
      'volunteer_registrations',
      where: 'user = ?',
      whereArgs: [user],
      orderBy: 'registeredAt DESC',
    );
    return res.map((m) => VolunteerRegistration.fromMap(m)).toList();
  }

  Future<List<VolunteerRegistration>> getPendingRegistrations() async {
    final db = await instance.database;
    final res = await db.query(
      'volunteer_registrations',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'registeredAt DESC',
    );
    return res.map((m) => VolunteerRegistration.fromMap(m)).toList();
  }

  Future<int> updateRegistrationStatus(int id, String status, {String? adminFeedback}) async {
    final db = await instance.database;
    return await db.update(
      'volunteer_registrations',
      {
        'status': status,
        'adminFeedback': adminFeedback,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRegistration(int id) async {
    final db = await instance.database;
    return await db.delete(
      'volunteer_registrations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRegistrations() async {
    final db = await instance.database;
    await db.delete('volunteer_registrations');
  }
}