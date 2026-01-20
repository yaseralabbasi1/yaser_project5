// lib/main.dart
// هذا هو الملف الرئيسي للتطبيق، نقطة البداية.
// هنا نهيئ Flutter ونشغل التطبيق باستخدام MyApp.
//asd
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manager_dashboard_screen.dart';
import 'models/user.dart';

void main() {
  // تأكد من تهيئة Flutter قبل أي عمليات غير متزامنة
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// كلاس MyApp يمثل التطبيق ككل
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Provider لإدارة الحالة العامة للتطبيق
    return ChangeNotifierProvider(
      create: (_) => StoreProvider(),
      child: Consumer<StoreProvider>(
        builder: (context, store, _) {
          // تحديد الشاشة التي ستظهر عند البداية
          Widget startScreen;
          if (store.currentUser == null) {
            // إذا لم يكن هناك مستخدم مسجل الدخول → شاشة الدخول
            startScreen = LoginScreen();
          } else {
            // إذا كان هناك مستخدم مسجل الدخول → حسب الدور
            startScreen = store.userRole == UserRole.manager
                ? const ManagerDashboardScreen()
                : const HomeScreen();
          }

          // بناء التطبيق مع الثيم النهاري/الليلي
          return MaterialApp(
            title: 'متجر الالكترونيات',
            themeMode: store.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.deepPurple,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.deepPurple,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
            ),
            home: startScreen,
          );
        },
      ),
    );
  }
}
