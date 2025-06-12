import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/volunteer_campaign.dart';

class VolunteerCampaignDatabase {
  static final VolunteerCampaignDatabase instance = VolunteerCampaignDatabase._init();
  static Database? _database;

  VolunteerCampaignDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('volunteer_campaigns.db');
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
      CREATE TABLE volunteer_campaigns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        quota TEXT NOT NULL,
        fee TEXT NOT NULL,
        eventDate TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        creator TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        registrationStart TEXT NOT NULL,
        registrationEnd TEXT NOT NULL,
        terms TEXT,
        disclaimer TEXT,
        adminFeedback TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE volunteer_campaigns ADD COLUMN terms TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE volunteer_campaigns ADD COLUMN disclaimer TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE volunteer_campaigns ADD COLUMN adminFeedback TEXT;');
      } catch (_) {}
    }
  }

  Future<int> insert(VolunteerCampaign campaign) async {
    final db = await instance.database;
    return await db.insert('volunteer_campaigns', campaign.toMap());
  }

  Future<List<VolunteerCampaign>> getPendingCampaigns() async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_campaigns',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id DESC',
    );
    return result.map((map) => VolunteerCampaign.fromMap(map)).toList();
  }

  Future<List<VolunteerCampaign>> getAllCampaigns() async {
    final db = await instance.database;
    final result = await db.query('volunteer_campaigns', orderBy: 'id DESC');
    return result.map((map) => VolunteerCampaign.fromMap(map)).toList();
  }

  Future<List<VolunteerCampaign>> getCampaignsByStatus(String status) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_campaigns',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC',
    );
    return result.map((map) => VolunteerCampaign.fromMap(map)).toList();
  }

  Future<List<VolunteerCampaign>> getCampaignsByCreator(String creator) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_campaigns',
      where: 'creator = ?',
      whereArgs: [creator],
      orderBy: 'id DESC',
    );
    return result.map((map) => VolunteerCampaign.fromMap(map)).toList();
  }

  Future<VolunteerCampaign?> getCampaignById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_campaigns',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return VolunteerCampaign.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> update(VolunteerCampaign campaign) async {
    final db = await instance.database;
    return await db.update(
      'volunteer_campaigns',
      campaign.toMap(),
      where: 'id = ?',
      whereArgs: [campaign.id],
    );
  }

  Future<int> updateCampaign(VolunteerCampaign campaign) async {
    final db = await instance.database;
    return await db.update(
      'volunteer_campaigns',
      campaign.toMap(),
      where: 'id = ?',
      whereArgs: [campaign.id],
    );
  }

  Future<int> updateFeedback(int id, String feedback) async {
    final db = await instance.database;
    return await db.update(
      'volunteer_campaigns',
      {'adminFeedback': feedback},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'volunteer_campaigns',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCampaign(int id) async {
    final db = await instance.database;
    return await db.delete(
      'volunteer_campaigns',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllCampaigns() async {
    final db = await instance.database;
    await db.delete('volunteer_campaigns');
  }

  Future<List<VolunteerCampaign>> getActiveOprecVolunteerCampaigns() async {
    final db = await instance.database;
    final todayIso = DateTime.now().toIso8601String();
    final result = await db.query(
      'volunteer_campaigns',
      where: 'status = ? AND registrationStart <= ? AND registrationEnd >= ?',
      whereArgs: ['approved', todayIso, todayIso],
      orderBy: 'id DESC',
    );
    return result.map((map) => VolunteerCampaign.fromMap(map)).toList();
  }

  // Tambahan untuk arsip volunteer
  Future<List<VolunteerCampaign>> getArchivedVolunteerCampaigns() async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_campaigns',
      where: 'status = ? OR status = ?',
      whereArgs: ['approved', 'rejected'],
      orderBy: 'id DESC',
    );
    return result.map((map) => VolunteerCampaign.fromMap(map)).toList();
  }
}