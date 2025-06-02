import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL
    )
    ''');
  }

  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'] as int,
        username: maps.first['username'] as String,
        email: maps.first['email'] as String,
        password: maps.first['password'] as String,
      );
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'] as int,
        username: maps.first['username'] as String,
        email: maps.first['email'] as String,
        password: maps.first['password'] as String,
      );
    }
    return null;
  }
}