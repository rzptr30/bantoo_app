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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
        imagePath TEXT NOT NULL
      )
    ''');
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

  // Tambahkan update, delete jika perlu
}