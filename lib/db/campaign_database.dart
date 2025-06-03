import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/campaign.dart';

class CampaignDatabase {
  static final CampaignDatabase instance = CampaignDatabase._init();
  static Database? _database;

  CampaignDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campaigns.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE campaigns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        targetFund INTEGER NOT NULL,
        collectedFund INTEGER NOT NULL,
        endDate TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        status TEXT NOT NULL,
        creator TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE campaigns ADD COLUMN status TEXT NOT NULL DEFAULT "pending";');
      await db.execute('ALTER TABLE campaigns ADD COLUMN creator TEXT NOT NULL DEFAULT "";');
    }
  }

  Future<int> insertCampaign(Campaign campaign) async {
    final db = await instance.database;
    return await db.insert('campaigns', campaign.toMap());
  }

  Future<List<Campaign>> getAllCampaigns() async {
    final db = await instance.database;
    final result = await db.query('campaigns', orderBy: 'id DESC');
    return result.map((map) => Campaign.fromMap(map)).toList();
  }

  Future<List<Campaign>> getCampaignsByStatus(String status) async {
    final db = await instance.database;
    final result = await db.query('campaigns', where: 'status = ?', whereArgs: [status], orderBy: 'id DESC');
    return result.map((map) => Campaign.fromMap(map)).toList();
  }

  Future<List<Campaign>> getCampaignsByCreator(String creator) async {
    final db = await instance.database;
    final result = await db.query('campaigns', where: 'creator = ?', whereArgs: [creator], orderBy: 'id DESC');
    return result.map((map) => Campaign.fromMap(map)).toList();
  }

  // Update status (approve/reject)
  Future<int> updateCampaignStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('campaigns', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  // Update campaign (edit oleh user, status kembalikan ke pending)
  Future<int> updateCampaign(Campaign campaign) async {
    final db = await instance.database;
    return await db.update('campaigns', campaign.toMap(), where: 'id = ?', whereArgs: [campaign.id]);
  }

  // Delete campaign (opsional, jika dibutuhkan user bisa hapus sebelum di-ACC)
  Future<int> deleteCampaign(int id) async {
    final db = await instance.database;
    return await db.delete('campaigns', where: 'id = ?', whereArgs: [id]);
  }

  // Reset campaign (sudah ada sebelumnya)
  Future<void> deleteAllCampaigns() async {
    final db = await instance.database;
    await db.delete('campaigns');
  }
}