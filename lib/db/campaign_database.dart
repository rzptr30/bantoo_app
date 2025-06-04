import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/campaign.dart';
import '../models/donation.dart';
import '../models/doa.dart';

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

    return await openDatabase(
      path,
      version: 4, // Naikkan versi jika ada perubahan tabel
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
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

    await db.execute('''
      CREATE TABLE donations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campaignId INTEGER NOT NULL,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        time TEXT NOT NULL,
        paymentMethod TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campaignId INTEGER NOT NULL,
        name TEXT NOT NULL,
        message TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE campaigns ADD COLUMN status TEXT NOT NULL DEFAULT "pending";');
      await db.execute('ALTER TABLE campaigns ADD COLUMN creator TEXT NOT NULL DEFAULT "";');
    }
    if (oldVersion < 3) {
      // Tambah tabel donations & doas jika update dari versi lama
      await db.execute('''
        CREATE TABLE IF NOT EXISTS donations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          campaignId INTEGER NOT NULL,
          name TEXT NOT NULL,
          amount INTEGER NOT NULL,
          time TEXT NOT NULL,
          paymentMethod TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS doas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          campaignId INTEGER NOT NULL,
          name TEXT NOT NULL,
          message TEXT NOT NULL,
          time TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      // Tambah kolom paymentMethod jika belum ada
      try {
        await db.execute('ALTER TABLE donations ADD COLUMN paymentMethod TEXT NOT NULL DEFAULT "";');
      } catch (_) {}
    }
  }

  // === CAMPAIGN ===

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

  Future<int> updateCampaignStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('campaigns', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCampaign(Campaign campaign) async {
    final db = await instance.database;
    return await db.update('campaigns', campaign.toMap(), where: 'id = ?', whereArgs: [campaign.id]);
  }

  Future<int> deleteCampaign(int id) async {
    final db = await instance.database;
    return await db.delete('campaigns', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllCampaigns() async {
    final db = await instance.database;
    await db.delete('campaigns');
  }

  /// Ambil satu campaign berdasarkan id
  Future<Campaign?> getCampaignById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'campaigns',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Campaign.fromMap(result.first);
    } else {
      return null;
    }
  }

  // === DONATION ===

  Future<int> insertDonation(Donation donation) async {
    final db = await instance.database;
    return await db.insert('donations', donation.toMap());
  }

  Future<List<Donation>> getDonationsByCampaign(int campaignId) async {
    final db = await instance.database;
    final result = await db.query('donations', where: 'campaignId = ?', whereArgs: [campaignId], orderBy: 'id DESC');
    return result.map((map) => Donation.fromMap(map)).toList();
  }

  Future<List<Donation>> getDonationsByUser(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'donations',
      where: 'name = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
    return result.map((map) => Donation.fromMap(map)).toList();
  }

  // === DOA ===

  Future<int> insertDoa(Doa doa) async {
    final db = await instance.database;
    return await db.insert('doas', doa.toMap());
  }

  Future<List<Doa>> getDoasByCampaign(int campaignId) async {
    final db = await instance.database;
    final result = await db.query('doas', where: 'campaignId = ?', whereArgs: [campaignId], orderBy: 'id DESC');
    return result.map((map) => Doa.fromMap(map)).toList();
  }
}