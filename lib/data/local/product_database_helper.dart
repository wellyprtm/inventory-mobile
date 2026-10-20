import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

/// SQLite Database Helper for local on-device persistence.
/// Manages SQLite table creation, migrations, and CRUD queries.
/// Includes graceful fallback for Web/Tests to ensure cross-platform safety.
class ProductDatabaseHelper {
  static final ProductDatabaseHelper instance = ProductDatabaseHelper._internal();
  ProductDatabaseHelper._internal();

  static Database? _database;
  static const String _tableName = 'products';
  static const String _dbName = 'inventory.db';
  static const int _dbVersion = 1;

  // In-memory fallback storage for Web / Unit Test environments
  final List<Product> _webMemoryStore = [];

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web uses in-memory store
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            description TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Converts a Product to SQLite row map
  Map<String, dynamic> _toMap(Product p) {
    return {
      'id': p.id,
      'name': p.name,
      'category': p.category,
      'price': p.price,
      'stock': p.stock,
      'description': p.description,
      'updated_at': p.updatedAt.toIso8601String(),
    };
  }

  /// Converts an SQLite row map to a Product
  Product _fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      stock: (map['stock'] as num).toInt(),
      description: map['description'] as String,
      updatedAt: DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now(),
    );
  }

  // ================= CRUD SQL QUERIES =================

  /// SELECT * FROM products with optional search and category filter
  Future<List<Product>> getProducts({String? search, String? category}) async {
    final db = await database;

    if (db == null) {
      // Web / in-memory fallback
      var list = List<Product>.from(_webMemoryStore);
      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where((e) => e.name.toLowerCase().contains(q) || e.description.toLowerCase().contains(q)).toList();
      }
      if (category != null && category.isNotEmpty && category != 'Semua') {
        list = list.where((e) => e.category == category).toList();
      }
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    }

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (search != null && search.trim().isNotEmpty) {
      whereClauses.add('(name LIKE ? OR description LIKE ?)');
      whereArgs.add('%$search%');
      whereArgs.add('%$search%');
    }

    if (category != null && category.isNotEmpty && category != 'Semua') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final results = await db.query(
      _tableName,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'updated_at DESC',
    );

    return results.map(_fromMap).toList();
  }

  /// SELECT * FROM products WHERE id = ?
  Future<Product?> getProductById(String id) async {
    final db = await database;
    if (db == null) {
      return _webMemoryStore.where((e) => e.id == id).firstOrNull;
    }

    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _fromMap(results.first);
  }

  /// INSERT OR REPLACE INTO products
  Future<void> saveProduct(Product product) async {
    final db = await database;
    if (db == null) {
      _webMemoryStore.removeWhere((e) => e.id == product.id);
      _webMemoryStore.insert(0, product);
      return;
    }

    await db.insert(
      _tableName,
      _toMap(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Batch insert products (Cache API response to SQLite)
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    if (db == null) {
      for (final p in products) {
        _webMemoryStore.removeWhere((e) => e.id == p.id);
        _webMemoryStore.add(p);
      }
      return;
    }

    final batch = db.batch();
    for (final product in products) {
      batch.insert(
        _tableName,
        _toMap(product),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// UPDATE products SET ... WHERE id = ?
  Future<void> updateProduct(Product product) async {
    final db = await database;
    if (db == null) {
      final index = _webMemoryStore.indexWhere((e) => e.id == product.id);
      if (index != -1) _webMemoryStore[index] = product;
      return;
    }

    await db.update(
      _tableName,
      _toMap(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// DELETE FROM products WHERE id = ?
  Future<void> deleteProduct(String id) async {
    final db = await database;
    if (db == null) {
      _webMemoryStore.removeWhere((e) => e.id == id);
      return;
    }

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all rows from SQLite table
  Future<void> clearAll() async {
    final db = await database;
    if (db == null) {
      _webMemoryStore.clear();
      return;
    }
    await db.delete(_tableName);
  }
}
