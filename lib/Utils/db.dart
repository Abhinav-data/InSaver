import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final dbHelper = DB.instance;

class DB {
  static final _databaseName = "InstaDB.db";
  static final _databaseVersion = 1;
  static final instaTable = 'InstaDB';
  static final id = '_id';
  static final url = 'url';
  static final fileName = 'fileName';
  static final tag = 'tag';
  static final profile = 'profile';
  static final username = 'username';
  static final savedDir = 'savedDir';
  static final time = 'time';

  DB._privateConstructor();
  static final DB instance = DB._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $instaTable (
            $id INTEGER PRIMARY KEY,
            $url TEXT NOT NULL,
            $fileName TEXT NOT NULL,
            $tag TEXT NOT NULL,
            $profile TEXT NOT NULL,
            $username TEXT NOT NULL,
            $savedDir TEXT NOT NULL,
            $time TEXT NOT NULL)
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(instaTable, row);
  }

  Future<List<Map<String, dynamic>>> query() async {
    Database? db = await instance.database;
    return db!.rawQuery("SELECT * FROM $instaTable ORDER BY $id DESC");
  }

  Future<List<Map<String, dynamic>>> queryByTag(String slug) async {
    Database? db = await instance.database;
    return db!.query(instaTable, where: "$tag = ?", whereArgs: ['$slug']);
  }

  Future<List<Map<String, dynamic>>> countByTag(String slug) async {
    Database? db = await instance.database;
    return db!.rawQuery('SELECT $id FROM $instaTable WHERE $tag = ?', [slug]);
  }

  Future<int> deleteByTag(String slug) async {
    Database? db = await instance.database;
    return db!.delete(instaTable, where: "$tag = ?", whereArgs: ['$slug']);
  }

  Future<List<Map<String, dynamic>>> queryDistinct() async {
    Database? db = await instance.database;
    return db!.rawQuery(
        "SELECT DISTINCT $username,$profile FROM $instaTable ORDER BY $id DESC LIMIT 8");
  }
}
