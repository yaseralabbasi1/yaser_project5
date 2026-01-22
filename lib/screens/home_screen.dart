// lib/screens/home_screen.dart
// هذه الشاشة تعرض الصفحة الرئيسية للمستخدم.
// تحتوي على شريط بحث، صف الفئات، قائمة المنتجات.
// كما تحتوي على قائمة جانبية (Drawer) لإجراءات مثل السلة، تغيير كلمة المرور، لوحة المدير، تسجيل الخروج.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaser_project/models/user.dart';
import 'package:yaser_project/providers/store_provider.dart';
import 'package:yaser_project/widgets/product_card_design.dart';
import 'package:yaser_project/widgets/category_icon_design.dart';
import 'product_reservation_screen.dart';
import 'category_products_screen.dart';
import 'reservation_cart_screen.dart';
import 'login_screen.dart';
import 'manager_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(builder: (context, store, child) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('متجر الالكترونيات'),
            actions: [
              // زر تبديل الثيم
              IconButton(
                tooltip: store.themeMode == ThemeMode.light ? 'الوضع الليلي' : 'الوضع النهاري',
                icon: Icon(
                  store.themeMode == ThemeMode.light ? Icons.wb_sunny : Icons.nights_stay,
                  color: Colors.white,
                ),
                onPressed: store.toggleTheme,
              ),
              // زر السلة مع عدّاد
              IconButton(
                icon: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    if (store.reservations.isNotEmpty)
                      CircleAvatar(
                        radius: 7,
                        backgroundColor: Colors.red,
                        child: Text(
                          store.reservations.length.toString(),
                          style: const TextStyle(fontSize: 8, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservationCartScreen()));
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context, store),
          body: store.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              // شريط البحث
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: store.setSearchQuery,
                  decoration: InputDecoration(
                    labelText: 'البحث عن منتج أو فئة',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              // صف الفئات
              _buildCategoriesRow(context, store),
              const Divider(),
              // عرض المنتجات
              Wrap(
                children: store.products.map((product) {
                  return ProductCardDesign(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductReservationScreen(product: product)),
                      );
                    },
                  );
                }).toList(),
              ),
              // رسائل عند عدم وجود نتائج
              if (store.products.isEmpty && store.searchQuery.isNotEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('لا يوجد منتجات مطابقة للبحث', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                )
              else if (store.products.isEmpty && !store.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('لا يوجد منتجات متاحة حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                )
            ],
          ),
        ),
      );
    });
  }

  // القائمة الجانبية
  Widget _buildDrawer(BuildContext context, StoreProvider store) {
    final roleName = store.userRole == UserRole.manager ? 'المدير' : 'المستخدم العادي';

    return Drawer(
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              color: Colors.deepPurple,
              child: Column(
                  children: [
                  UserAccountsDrawerHeader(
                  accountName: Text(roleName, style: const TextStyle(fontSize: 20, color: Colors.black)),
              accountEmail: Text(store.userRole.name, style: const TextStyle(fontSize: 15, color: Colors.black)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: const BoxDecoration(color: Colors.white),
            ),
            if (store.userRole == UserRole.manager)
        ListTile(
        leading: const Icon(Icons.settings, color: Colors.white),
    title: const Text("لوحة تحكم المدير", style: TextStyle(color: Colors.white, fontSize: 20)),
    onTap: () {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()));
    },
    ),
// ... تكملة الكود السابق

                    if (store.userRole == UserRole.user)
                      ListTile(
                        leading: const Icon(Icons.lock, color: Colors.orange),
                        title: const Text("تغيير كلمة المرور", style: TextStyle(color: Colors.white, fontSize: 20)),
                        onTap: () {
                          Navigator.pop(context);
                          _showChangePasswordDialog(context, store);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.shopping_basket, color: Colors.yellow),
                      title: const Text("سلة المشتريات", style: TextStyle(color: Colors.white, fontSize: 20)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservationCartScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app, color: Colors.red),
                      title: const Text("تسجيل الخروج", style: TextStyle(color: Colors.white, fontSize: 20)),
                      onTap: () {
                        store.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
              ),
            ),
        ),
    );
  }

  // نافذة تغيير كلمة المرور للمستخدم العادي
  void _showChangePasswordDialog(BuildContext context, StoreProvider store) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تغيير كلمة المرور"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "كلمة المرور الجديدة"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.trim().isEmpty) return;
              final ok = await store.changeCurrentUserPassword(passwordController.text.trim());
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح")));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // صف الفئات: يعرض الفئات من قاعدة البيانات مع صورها
  Widget _buildCategoriesRow(BuildContext context, StoreProvider store) {
    final categories = store.categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          return CategoryIconDesign(
            categoryName: "قسم\n${cat.name}",
            imagePath: cat.imagePath,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: cat.name)));
            },
          );
        }).toList(),
      ),
    );
  }
}
