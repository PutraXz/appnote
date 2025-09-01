import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String databaseName = "note.db";
  final int databaseVersion = 1;

  final String createUserTable = '''
    CREATE TABLE users (
      userId INTEGER PRIMARY KEY AUTOINCREMENT,
      userName TEXT UNIQUE NOT NULL,
      userPassword TEXT NOT NULL
    )
  ''';

  final String createNoteTable = '''
    CREATE TABLE notes (
      noteId INTEGER PRIMARY KEY AUTOINCREMENT,
      noteTitle TEXT NOT NULL,
      noteContent TEXT NOT NULL,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await db.execute(createUserTable);
        await db.execute(createNoteTable);
      },
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<bool> login(UserModel user) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'userName = ? AND userPassword = ?',
      whereArgs: [user.userName, user.userPassword],
    );
    return result.isNotEmpty;
  }

  Future<int> createAccount(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }
}
