// lib/screens/login_screen.dart
// هذه الشاشة مسؤولة عن تسجيل الدخول.
// تحتوي على حقول إدخال لاسم المستخدم وكلمة المرور.
// عند الضغط على زر الدخول يتم التحقق من البيانات عبر StoreProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/store_provider.dart';
import 'home_screen.dart';
import 'manager_dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  // متحكمات النص لحقول الإدخال
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // دالة تسجيل الدخول
  Future<void> _login(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final storeProvider = context.read<StoreProvider>();

    final ok = await storeProvider.login(username, password);
    if (!ok) {
      // إذا كانت البيانات خاطئة → رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم المستخدم أو كلمة المرور غير صحيحة'), backgroundColor: Colors.red),
      );
      return;
    }

    // تحديد الوجهة حسب الدور
    final role = storeProvider.userRole;
    final destination = role == UserRole.manager ? const ManagerDashboardScreen() : const HomeScreen();

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه النص يمين
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متدرجة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade300],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            // بطاقة تسجيل الدخول
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // شعار بسيط
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: const Icon(Icons.storefront, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text('مرحباً بك في متجر الإلكترونيات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        // حقل اسم المستخدم
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم المستخدم',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // حقل كلمة المرور
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // زر الدخول
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            label: const Text('دخول'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _login(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
