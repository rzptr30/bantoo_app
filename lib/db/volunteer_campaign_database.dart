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
      version: 1,
      onCreate: _createDB,
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
        createdAt TEXT NOT NULL
      )
    ''');
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

  Future<int> updateCampaign(VolunteerCampaign campaign) async {
    final db = await instance.database;
    return await db.update(
      'volunteer_campaigns',
      campaign.toMap(),
      where: 'id = ?',
      whereArgs: [campaign.id],
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
}