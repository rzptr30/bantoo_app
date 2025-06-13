import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/volunteer_notification.dart';

class VolunteerNotificationDatabase {
  static final VolunteerNotificationDatabase instance = VolunteerNotificationDatabase._init();
  static Database? _database;

  VolunteerNotificationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('volunteer_notifications.db');
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
      CREATE TABLE volunteer_notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        campaignId INTEGER NOT NULL,
        creator TEXT NOT NULL,
        registrant TEXT NOT NULL,
        registrantName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(VolunteerNotification notif) async {
    final db = await instance.database;
    return await db.insert('volunteer_notifications', notif.toMap());
  }

  Future<List<VolunteerNotification>> getUnreadNotifications(String creator) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_notifications',
      where: 'creator = ? AND isRead = 0',
      whereArgs: [creator],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => VolunteerNotification.fromMap(map)).toList();
  }

  Future<List<VolunteerNotification>> getAllNotifications(String creator) async {
    final db = await instance.database;
    final result = await db.query(
      'volunteer_notifications',
      where: 'creator = ?',
      whereArgs: [creator],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => VolunteerNotification.fromMap(map)).toList();
  }

  Future<void> markAsRead(int id) async {
    final db = await instance.database;
    await db.update(
      'volunteer_notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deleteAllNotifications() async {
  final db = await instance.database;
  await db.delete('volunteer_notifications');
}
}