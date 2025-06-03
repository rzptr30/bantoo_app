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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertNotification(NotificationItem notif) async {
    final db = await instance.database;
    return await db.insert('notifications', notif.toMap());
  }

  Future<List<NotificationItem>> getNotificationsForUser(String user) async {
    final db = await instance.database;
    final result = await db.query('notifications', where: 'user = ?', whereArgs: [user], orderBy: 'date DESC');
    return result.map((map) => NotificationItem.fromMap(map)).toList();
  }

  Future<void> deleteAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }
}