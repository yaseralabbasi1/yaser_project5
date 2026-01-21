// lib/services/db_helper.dart
// هذا الكلاس مسؤول عن إنشاء وإدارة قاعدة البيانات باستخدام مكتبة Sqflite.
// يحتوي على جداول: المستخدمين، المنتجات، السلة، الفئات.
// ويوفر دوال CRUD (إضافة، تعديل، حذف، جلب) لكل جدول.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // تطبيق نمط Singleton لضمان وجود نسخة واحدة فقط من DBHelper
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db; // كائن قاعدة البيانات

  // دالة عامة للحصول على قاعدة البيانات (تفتح/تنشئ عند الحاجة)
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('store.db');
    return _db!;
  }

  // تهيئة قاعدة البيانات: تحديد المسار وفتحها مع onCreate/onUpgrade
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath(); // مسار قواعد البيانات على الجهاز
    final path = join(dbPath, fileName);     // دمج المسار مع اسم الملف
    return await openDatabase(
      path,
      version: 2,          // رقم الإصدار الحالي
      onCreate: _onCreate, // تُستدعى عند إنشاء قاعدة جديدة
      onUpgrade: _onUpgrade, // تُستدعى عند ترقية الإصدار
    );
  }

  // دالة الترقية: تُستخدم لإضافة جداول جديدة عند تغيير الإصدار
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCategoriesTable(db); // إضافة جدول الفئات
    }
  }

  // إنشاء جدول الفئات
  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        imagePath TEXT
      )
    ''');
  }

  // دالة الإنشاء الأولى: إنشاء جميع الجداول وإدخال بيانات افتراضية
  Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT,
        price REAL NOT NULL,
        imagePath TEXT,
        description TEXT,
        category TEXT,
        stockQuantity INTEGER NOT NULL,
        discountPercentage REAL NOT NULL
      )
    ''');

    // جدول السلة
    await db.execute('''
      CREATE TABLE cart (
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        productName TEXT NOT NULL,
        productImage TEXT NOT NULL
      )
    ''');

    // جدول الفئات
    await _createCategoriesTable(db);

    // إدخال مستخدم مدير افتراضي
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'manager',
    });

    // إدخال مستخدم عادي افتراضي
    await db.insert('users', {
      'username': 'user',
      'password': 'user123',
      'role': 'user',
    });

    // إدخال منتجات افتراضية
    await db.insert('products', {
      'id': 'p1',
      'name': 'كمبيوتر محمول',
      'type': 'HP Elite',
      'price': 1500.0,
      'imagePath': '',
      'description': 'جهاز ذو مواصفات عالية للعمل والألعاب.',
      'category': 'كمبيوتر',
      'stockQuantity': 5,
      'discountPercentage': 0.10,
    });
    await db.insert('products', {
      'id': 'p2',
      'name': 'هاتف ذكي',
      'type': 'Samsung S22',
      'price': 1000.0,
      'imagePath': '',
      'description': 'هاتف بأداء وكاميرا ممتازين.',
      'category': 'هاتف',
      'stockQuantity': 20,
      'discountPercentage': 0.0,
    });
    await db.insert('products', {
      'id': 'p3',
      'name': 'سماعات بلوتوث',
      'type': 'Sony WH-1000XM4',
      'price': 350.0,
      'imagePath': '',
      'description': 'سماعات إلغاء ضوضاء ممتازة.',
      'category': 'السماعات',
      'stockQuantity': 12,
      'discountPercentage': 0.25,
    });

    // إدخال فئات افتراضية
    await db.insert('categories', {'name': 'كمبيوتر', 'imagePath': ''});
    await db.insert('categories', {'name': 'هاتف', 'imagePath': ''});
    await db.insert('categories', {'name': 'السماعات', 'imagePath': ''});
    await db.insert('categories', {'name': 'الكابيلات', 'imagePath': ''});
    await db.insert('categories', {'name': 'الغلافات', 'imagePath': ''});
  }

  // ---------------------------
  // عمليات المستخدمين (CRUD)
  // ---------------------------
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'id DESC');
  }

  Future<Map<String, dynamic>?> findUser(String username) async {
    final db = await database;
    final res = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------
  // عمليات المنتجات (CRUD)
  // ---------------------------
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return db.query('products', orderBy: 'name ASC');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await database;
    return db.update('products', product, where: 'id = ?', whereArgs: [product['id']]);
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------
  // عمليات السلة (CRUD)
  // ---------------------------
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return db.query('cart', orderBy: 'id DESC');
  }

  Future<int> upsertCartItem(Map<String, dynamic> item) async {
    final db = await database;
    return db.insert('cart', item, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteCartItem(String id) async {
    final db = await database;
    return db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearCart() async {
    final db = await database;
    return db.delete('cart');
  }

  // ---------------------------
  // عمليات الفئات (CRUD)
  // ---------------------------
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query('categories', orderBy: 'name ASC');
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await database;
    return db.update('categories', category, where: 'id = ?', whereArgs: [category['id']]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
