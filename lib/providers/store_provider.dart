// lib/providers/store_provider.dart
// هذا الكلاس هو مزود الحالة الرئيسي للتطبيق.
// يدير: الثيم (نهاري/ليلي)، المستخدم الحالي، المنتجات، الفئات، السلة، البحث.
// يستخدم DBHelper للتعامل مع قاعدة البيانات، و SharedPreferences لحفظ بعض البيانات محلياً.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaser_project/models/product.dart';
import 'package:yaser_project/models/user.dart';
import 'package:yaser_project/models/category.dart';
import 'package:yaser_project/services/db_helper.dart';

class StoreProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper(); // كائن مساعد قاعدة البيانات

  // الحالة العامة
  bool _isLoading = true;                // مؤشر التحميل
  ThemeMode _themeMode = ThemeMode.light; // وضع الثيم الحالي

  // المستخدم الحالي
  AppUser? _currentUser;           // المستخدم الحالي (إن وجد)
  UserRole _userRole = UserRole.guest; // دور المستخدم الحالي

  // البيانات الرئيسية
  List<Product> _products = [];    // قائمة المنتجات
  List<AppUser> _users = [];       // قائمة المستخدمين
  List<ReservationItem> _reservations = []; // عناصر السلة
  List<Category> _categories = []; // قائمة الفئات

  // البحث
  String _searchQuery = '';        // نص البحث الحالي

  // المُنشئ: يبدأ التهيئة
  StoreProvider() {
    _init();
  }

  // ---------------------------
  // التهيئة: تحميل كل البيانات
  // ---------------------------
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await _loadTheme();           // تحميل الثيم من SharedPreferences
    await _loadUserFromPrefs();   // تحميل المستخدم الحالي من SharedPreferences
    await _loadProducts();        // تحميل المنتجات من قاعدة البيانات
    await _loadUsers();           // تحميل المستخدمين من قاعدة البيانات
    await _loadCategories();      // تحميل الفئات من قاعدة البيانات
    await _loadCartFromDB();      // تحميل السلة من قاعدة البيانات
    await _loadCartFromPrefs();   // دمج السلة مع المحفوظة في SharedPreferences

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------
  // إدارة الثيم (نهاري/ليلي)
  // ---------------------------
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'light';
    _themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  // ---------------------------
  // إدارة المستخدم الحالي
  // ---------------------------
  AppUser? get currentUser => _currentUser;
  UserRole get userRole => _userRole;

  Future<void> _saveUserToPrefs(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id ?? -1);
    await prefs.setString('username', user.username);
    await prefs.setString('password', user.password);
    await prefs.setString('role', user.role.name);
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    final roleStr = prefs.getString('role');
    final id = prefs.getInt('userId');
    if (username != null && password != null && roleStr != null) {
      _currentUser = AppUser(
        id: id,
        username: username,
        password: password,
        role: UserRole.values.firstWhere((r) => r.name == roleStr),
      );
      _userRole = _currentUser!.role;
    }
  }

  Future<void> _clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('role');
  }

  // تسجيل الدخول
  Future<bool> login(String username, String password) async {
    final row = await _db.findUser(username);
    if (row == null) return false;
    if (row['password'] != password) return false;
    _currentUser = AppUser.fromMap(row);
    _userRole = _currentUser!.role;
    await _saveUserToPrefs(_currentUser!);
    notifyListeners();
    return true;
  }

  // تسجيل الخروج
  void logout() {
    _currentUser = null;
    _userRole = UserRole.guest;
    _clearUserPrefs();
    notifyListeners();
  }

  // تغيير كلمة مرور المستخدم الحالي
  Future<bool> changeCurrentUserPassword(String newPassword) async {
    if (_currentUser == null) return false;
    final updated = AppUser(
      id: _currentUser!.id,
      username: _currentUser!.username,
      password: newPassword,
      role: _currentUser!.role,
    );
    final res = await _db.updateUser(updated.toMap());
    if (res > 0) {
      _currentUser = updated;
      await _saveUserToPrefs(updated);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ---------------------------
  // تحميل البيانات من قاعدة البيانات
  // ---------------------------
  bool get isLoading => _isLoading;

  List<Product> get products {
    final list = [..._products];
    if (_searchQuery.isEmpty) return list;
    return list.where((p) =>
    p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.category).toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<AppUser> get users => [..._users];
  List<Category> get categories => [..._categories];
  String get searchQuery => _searchQuery;

  Future<void> _loadProducts() async {
    final rows = await _db.getProducts();
    _products = rows.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> _loadUsers() async {
    final rows = await _db.getUsers();
    _users = rows.map((e) => AppUser.fromMap(e)).toList();
  }

  Future<void> _loadCategories() async {
    final rows = await _db.getCategories();
    _categories = rows.map((e) => Category.fromMap(e)).toList();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // ---------------------------
  // إدارة السلة
  // ---------------------------
  List<ReservationItem> get reservations => [..._reservations];
  double get cartTotal => _reservations.fold(0.0, (sum, i) => sum + i.total);

  Future<void> _loadCartFromDB() async {
    final rows = await _db.getCartItems();
    _reservations = rows.map((e) => ReservationItem.fromMap(e)).toList();
  }

  Future<void> _saveCartToDB() async {
    for (final item in _reservations) {
      await _db.upsertCartItem(item.toMap());
    }
  }

  Future<void> _clearCartInDB() async {
    await _db.clearCart();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _reservations.map((e) => e.toMap()).toList();
    await prefs.setString('cart', jsonEncode(jsonList));
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cart');
    if (jsonStr == null) return;
    final List<dynamic> list = jsonDecode(jsonStr);
    final items = list.map((e) => ReservationItem.fromMap(Map<String, dynamic>.from(e))).toList();
    for (final it in items) {
      final idx = _reservations.indexWhere((r) => r.id == it.id);
      if (idx >= 0) {
        _reservations[idx] = it;
      } else {
        _reservations.add(it);
      }
    }
    notifyListeners();
  }

  // ... تكملة الكود السابق

  // إضافة/تحديث عنصر في السلة
  Future<void> makeReservation(Product product, int quantity) async {
    if (quantity <= 0 || quantity > product.stockQuantity) return; // تحقق من الكمية
    final id = product.id; // نستخدم معرف المنتج كمفتاح
    final idx = _reservations.indexWhere((i) => i.productId == id);
    final unitPrice = product.finalPrice; // السعر النهائي للوحدة

    if (idx >= 0) {
      // إذا كان العنصر موجود مسبقاً → تحديث الكمية والسعر
      _reservations[idx].quantity = quantity;
      _reservations[idx].unitPrice = unitPrice;
    } else {
      // إذا لم يكن موجود → إضافة عنصر جديد
      _reservations.add(ReservationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        quantity: quantity,
        unitPrice: unitPrice,
        productName: product.name,
        productImage: product.imagePath,
      ));
    }
    await _saveCartToDB();    // حفظ السلة في قاعدة البيانات
    await _saveCartToPrefs(); // حفظ نسخة في SharedPreferences
    notifyListeners();        // تحديث الواجهة
  }

  // حذف عنصر من السلة
  Future<void> cancelReservation(String productId) async {
    final idx = _reservations.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      final removed = _reservations.removeAt(idx);
      await _db.deleteCartItem(removed.id); // حذف من قاعدة البيانات
      await _saveCartToPrefs();             // تحديث SharedPreferences
      notifyListeners();
    }
  }

  // إتمام الشراء: خصم المخزون من المنتجات وتفريغ السلة
  Future<void> checkout() async {
    for (final item in _reservations) {
      final pIdx = _products.indexWhere((p) => p.id == item.productId);
      if (pIdx >= 0) {
        final p = _products[pIdx];
        if (p.stockQuantity >= item.quantity) {
          p.stockQuantity -= item.quantity; // خصم الكمية
          await _db.updateProduct(p.toMap()); // تحديث المنتج في قاعدة البيانات
        }
      }
    }
    await _loadProducts();   // إعادة تحميل المنتجات
    _reservations.clear();   // تفريغ السلة
    await _clearCartInDB();  // تفريغ السلة من قاعدة البيانات
    await _saveCartToPrefs();// تحديث SharedPreferences
    notifyListeners();
  }

  // ---------------------------
  // الفئات
  // ---------------------------
  // جلب المنتجات حسب اسم الفئة
  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((p) => p.category == categoryName).toList();
  }

  // إضافة فئة جديدة
  Future<String?> addCategory(Category category) async {
    try {
      await _db.insertCategory(category.toMap());
      await _loadCategories();
      notifyListeners();
      return null;
    } catch (e) {
      return 'اسم الفئة موجود بالفعل';
    }
  }

  // تحديث فئة
  Future<void> updateCategory(Category category) async {
    await _db.updateCategory(category.toMap());
    await _loadCategories();
    notifyListeners();
  }

  // حذف فئة
  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await _loadCategories();
    notifyListeners();
  }

  // ---------------------------
  // صلاحيات المدير: CRUD للمنتجات
  // ---------------------------
  Future<void> addProduct(Product product) async {
    await _db.insertProduct(product.toMap());
    await _loadProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await _db.updateProduct(updatedProduct.toMap());
    await _loadProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    await _db.deleteProduct(productId);
    await _loadProducts();
    notifyListeners();
  }

  // ---------------------------
  // صلاحيات المدير: CRUD للمستخدمين
  // ---------------------------
  Future<String?> addUser(AppUser user) async {
    try {
      await _db.insertUser(user.toMap());
      await _loadUsers();
      notifyListeners();
      return null;
    } catch (e) {
      return 'اسم المستخدم موجود بالفعل';
    }
  }

  Future<void> updateUser(AppUser user) async {
    await _db.updateUser(user.toMap());
    await _loadUsers();
    // تحديث المستخدم الحالي إن كان نفس الاسم
    if (_currentUser != null && _currentUser!.username == user.username) {
      _currentUser = user;
      await _saveUserToPrefs(user);
    }
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    await _db.deleteUser(id);
    await _loadUsers();
    notifyListeners();
  }
}
