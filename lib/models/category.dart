// lib/models/category.dart
// هذا الملف يعرّف نموذج الفئة التي تُستخدم لتصنيف المنتجات.

class Category {
  int? id;          // المعرف الفريد للفئة
  String name;      // اسم الفئة
  String imagePath; // صورة الفئة

  Category({
    this.id,
    required this.name,
    required this.imagePath,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'],
      imagePath: map['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }
}
