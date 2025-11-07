// ARQUIVO: lib/helpers/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/anuncio.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('anuncios_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE anuncios (
      id TEXT PRIMARY KEY,
      titulo TEXT NOT NULL,
      descricao TEXT NOT NULL,
      preco REAL NOT NULL,
      imagemPath TEXT
    )
    ''');
  }

  Future<int> create(Anunc anunc) async {
    final db = await instance.database;
    return await db.insert('anuncios', anunc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Anunc>> readAll() async {
    final db = await instance.database;
    final result = await db.query('anuncios', orderBy: 'id DESC');
    return result.map((json) => Anunc.fromMap(json)).toList();
  }

  Future<int> update(Anunc anunc) async {
    final db = await instance.database;
    return await db.update(
      'anuncios',
      anunc.toMap(),
      where: 'id = ?',
      whereArgs: [anunc.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'anuncios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}