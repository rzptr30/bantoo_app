import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/volunteer_applicant.dart';

class VolunteerApplicantDatabase {
  static final VolunteerApplicantDatabase instance = VolunteerApplicantDatabase._init();
  static Database? _database;

  VolunteerApplicantDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('volunteer_applicant.db');
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
      CREATE TABLE volunteer_applicants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campaignId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        appliedAt TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<VolunteerApplicant> insertApplicant(VolunteerApplicant applicant) async {
    final db = await instance.database;
    final id = await db.insert('volunteer_applicants', applicant.toMap());
    return applicant.copyWith(id: id);
  }

  Future<List<VolunteerApplicant>> getApplicantsByCampaign(int campaignId) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_applicants',
      where: 'campaignId = ?',
      whereArgs: [campaignId],
      orderBy: 'appliedAt DESC',
    );
    return result.map((json) => VolunteerApplicant.fromMap(json)).toList();
  }

  Future<List<VolunteerApplicant>> getApplicantsByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_applicants',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'appliedAt DESC',
    );
    return result.map((json) => VolunteerApplicant.fromMap(json)).toList();
  }

  Future<VolunteerApplicant?> getApplicant(int campaignId, String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_applicants',
      where: 'campaignId = ? AND userId = ?',
      whereArgs: [campaignId, userId],
    );
    if (result.isNotEmpty) {
      return VolunteerApplicant.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateApplicant(VolunteerApplicant applicant) async {
    final db = await instance.database;
    return db.update(
      'volunteer_applicants',
      applicant.toMap(),
      where: 'id = ?',
      whereArgs: [applicant.id],
    );
  }

  Future<int> deleteApplicant(int id) async {
    final db = await instance.database;
    return await db.delete(
      'volunteer_applicants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future<void> deleteAllApplicants() async {
  final db = await instance.database;
  await db.delete('volunteer_applicants');
}
}