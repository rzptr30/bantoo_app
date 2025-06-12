import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_item.dart';

class NotificationDatabase {
  static final NotificationDatabase instance = NotificationDatabase._init();
  static Database? _database;

  NotificationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
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
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT,
        relatedId TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE notifications ADD COLUMN type TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE notifications ADD COLUMN relatedId TEXT;');
      } catch (_) {}
    }
  }

  Future<int> insertNotification(NotificationItem notif) async {
    final db = await instance.database;
    return await db.insert('notifications', notif.toMap());
  }

  Future<List<NotificationItem>> getNotificationsForUser(String user) async {
    final db = await instance.database;
    final result = await db.query(
      'notifications',
      where: 'user = ?',
      whereArgs: [user],
      orderBy: 'date DESC',
    );
    return result.map((map) => NotificationItem.fromMap(map)).toList();
  }

  Future<List<NotificationItem>> getNotificationsForUserByType(String user, String type) async {
    final db = await instance.database;
    final result = await db.query(
      'notifications',
      where: 'user = ? AND type = ?',
      whereArgs: [user, type],
      orderBy: 'date DESC',
    );
    return result.map((map) => NotificationItem.fromMap(map)).toList();
  }

  Future<void> deleteAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }
}