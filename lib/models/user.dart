// lib/models/user.dart
// هذا الملف يعرّف نموذج المستخدم مع الدور الخاص به.

enum UserRole {
  guest,   // زائر
  user,    // مستخدم عادي
  manager, // مدير
}

// كيان المستخدم للتخزين في قاعدة البيانات
class AppUser {
  int? id;           // المعرف الفريد للمستخدم
  String username;   // اسم المستخدم
  String password;   // كلمة المرور
  UserRole role;     // الدور (مستخدم/مدير)

  AppUser({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // تحويل من Map (صف قاعدة البيانات) إلى كائن
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      username: map['username'],
      password: map['password'],
      role: UserRole.values.firstWhere((r) => r.name == map['role']),
    );
  }

  // تحويل إلى Map للتخزين في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.name,
    };
  }
}
