import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton responsável por toda interação com o banco de dados.
/// Usa SQLite em mobile/desktop e armazenamento em memória na web.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;
  static final List<Map<String, dynamic>> _webData = [];
  static int _webIdCounter = 1;

  /// Getter com inicialização lazy
  Future<Database> get database async {
    if (kIsWeb) {
      // Web não suporta SQLite - retorna um stub que nunca será usado
      return _createStubDatabase();
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados (apenas mobile/desktop)
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cadastro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Cria tabela
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dados (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo      TEXT    NOT NULL,
        descricao   TEXT,
        data        TEXT
      )
    ''');
  }

  /// Stub para web (nunca é realmente usado)
  Database _createStubDatabase() {
    throw UnsupportedError('SQLite not supported on web');
  }

  /// CREATE – Insere novo item
  Future<int> insertItem(Map<String, dynamic> item) async {
    if (kIsWeb) {
      final newItem = {...item, 'id': _webIdCounter};
      _webData.add(newItem);
      return _webIdCounter++;
    }
    final db = await database;
    return await db.insert(
      'dados',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ – Busca todos os itens ordenados por título
  Future<List<Map<String, dynamic>>> getAllItems() async {
    if (kIsWeb) {
      final sorted = [..._webData];
      sorted.sort((a, b) => (a['titulo'] ?? '').compareTo(b['titulo'] ?? ''));
      return sorted;
    }
    final db = await database;
    return await db.query(
      'dados',
      orderBy: 'titulo ASC',
    );
  }

  /// UPDATE – Atualiza item pelo ID
  Future<int> updateItem(int id, Map<String, dynamic> item) async {
    if (kIsWeb) {
      final index = _webData.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        _webData[index] = {...item, 'id': id};
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(
      'dados',
      item,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE – Remove item pelo ID
  Future<int> deleteItem(int id) async {
    if (kIsWeb) {
      final initialLength = _webData.length;
      _webData.removeWhere((e) => e['id'] == id);
      return initialLength != _webData.length ? 1 : 0;
    }
    final db = await database;
    return await db.delete(
      'dados',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
