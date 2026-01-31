// lib/screens/manager_dashboard_screen.dart
// شاشة لوحة تحكم المدير بثلاث تبويبات:
// المنتجات – الفئات – المستخدمون
// كل تبويب يحتوي على زر مستقل لإضافة عنصر جديد.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yaser_project/providers/store_provider.dart';
import 'package:yaser_project/models/product.dart';
import 'package:yaser_project/models/user.dart';
import 'package:yaser_project/models/category.dart';
import 'login_screen.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Center(child: const Text('لوحة تحكم المدير        '+"yaser     ")),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<StoreProvider>().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              },
            ),
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.inventory,color: Colors.white,),child: Text("المنتجات",style:TextStyle(color: Colors.white)),),
              Tab(icon: Icon(Icons.category,color: Colors.white,), child: Text("الفئات",style:TextStyle(color: Colors.white)),),
              Tab(icon: Icon(Icons.people,color: Colors.white,),child: Text("المستخدمون",style:TextStyle(color: Colors.white)),),
            ]),
            Text("ddddddddddddddddd")
          ),
          body: const TabBarView(
            children: [
              _ProductsTab(),
              _CategoriesTab(),
              _UsersTab(),
            ],
          ),
        ),
      ),
    );
  }

  // أداة عامة لبناء صورة
  static Widget _buildImage(String path, double w, double h, BoxFit fit) {
    if (path.isEmpty) {
      return Container(width: w, height: h, color: Colors.grey.shade300, child: const Icon(Icons.image));
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: w, height: h, fit: fit);
    }
    return Image.file(File(path), width: w, height: h, fit: fit);
  }

  // نافذة إضافة/تعديل منتج
  void _showEditProductDialog(BuildContext context, {Product? product}) async {
    final isNew = product == null;
    final TextEditingController nameController = TextEditingController(text: product?.name);
    final TextEditingController typeController = TextEditingController(text: product?.type);
    final TextEditingController priceController = TextEditingController(text: product?.price.toString());
    final TextEditingController stockController = TextEditingController(text: product?.stockQuantity.toString());
    final TextEditingController discountController = TextEditingController(text: ((product?.discountPercentage ?? 0.0) * 100).toStringAsFixed(0));
    final TextEditingController descriptionController = TextEditingController(text: product?.description);
    String imagePath = product?.imagePath ?? '';
    String categoryName = product?.category ?? '';

    final categories = context.read<StoreProvider>().categories;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isNew ? 'إضافة منتج جديد' : 'تعديل المنتج: ${product!.name}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) setState(() => imagePath = picked.path);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(imagePath, 120, 120, BoxFit.cover),
                  ),
                ),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المنتج')),
                TextField(controller: typeController, decoration: const InputDecoration(labelText: 'النوعية')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر', suffixText: 'RS'), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'الكمية المتوفرة'), keyboardType: TextInputType.number),
                TextField(controller: discountController, decoration: const InputDecoration(labelText: 'نسبة الخصم', suffixText: '%'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: categoryName.isEmpty ? null : categoryName,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => categoryName = val ?? ''),
                ),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'الوصف')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final newProduct = Product(
                  id: product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: typeController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imagePath: imagePath,
                  description: descriptionController.text,
                  category: categoryName.isEmpty ? 'غير مصنف' : categoryName,
                  stockQuantity: int.tryParse(stockController.text) ?? 0,
                  discountPercentage: (double.tryParse(discountController.text) ?? 0.0) / 100.0,
                );
                final provider = context.read<StoreProvider>();
                if (isNew) {
                  await provider.addProduct(newProduct);
                } else {
                  await provider.updateProduct(newProduct);
                }
                Navigator.of(ctx).pop();
              },
              child: Text(isNew ? 'إضافة المنتج' : 'حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة إضافة/تعديل فئة
  void _showEditCategoryDialog(BuildContext context, {Category? category}) async {
    final isNew = category == null;
    final TextEditingController nameController = TextEditingController(text: category?.name);
    String imagePath = category?.imagePath ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isNew ? 'إضافة فئة جديدة' : 'تعديل الفئة: ${category!.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (picked != null) setState(() => imagePath = picked.path);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(imagePath, 120, 120, BoxFit.cover),
                ),
              ),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الفئة')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final newCategory = Category(
                  id: category?.id,
                  name: nameController.text,
                  imagePath: imagePath,
                );
                final provider = context.read<StoreProvider>();
                if (isNew) {
                  await provider.addCategory(newCategory);
                } else {
                  await provider.updateCategory(newCategory);
                }
                Navigator.of(ctx).pop();
              },
              child: Text(isNew ? 'إضافة الفئة' : 'حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة إضافة مستخدم جديد
  void _showAddUserDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    UserRole _role = UserRole.user;

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('إضافة مستخدم جديد'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
            DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'الدور'),
                items: const [
                  DropdownMenuItem(value: UserRole.user, child: Text('مستخدم')),
                  DropdownMenuItem(value: UserRole.manager, child: Text('مدير')),
                ],
              onChanged: (val) => _role = val ?? UserRole.user,
            ),
                ],
            ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) return;
                final error = await context.read<StoreProvider>().addUser(
                  AppUser(username: usernameController.text.trim(), password: passwordController.text, role: _role),
                );
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
    );
  }
}

// تبويب المنتجات مع زر إضافة منتج
class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<StoreProvider>(builder: (context, store, child) {
          if (store.isLoading) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: store.products.length,
            itemBuilder: (ctx, i) {
              final product = store.products[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: ManagerDashboardScreen._buildImage(product.imagePath, 50, 50, BoxFit.cover),
                  title: Text('${product.name} | RS ${product.finalPrice.toStringAsFixed(0)}'),
                  subtitle: Text('الفئة: ${product.category} | المخزون: ${product.stockQuantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
                        ManagerDashboardScreen()._showEditProductDialog(ctx, product: product);
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                        context.read<StoreProvider>().deleteProduct(product.id);
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              ManagerDashboardScreen()._showEditProductDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

// تبويب الفئات مع زر إضافة فئة
class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<StoreProvider>(builder: (context, store, child) {
          if (store.isLoading) return const Center(child: CircularProgressIndicator());
          final categories = store.categories;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: ManagerDashboardScreen._buildImage(cat.imagePath, 50, 50, BoxFit.cover),
                  title: Text(cat.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
                        ManagerDashboardScreen()._showEditCategoryDialog(ctx, category: cat);
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                        if (cat.id != null) {
                          context.read<StoreProvider>().deleteCategory(cat.id!);
                        }
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              ManagerDashboardScreen()._showEditCategoryDialog(context);
            },
            child: const Icon(Icons.add_photo_alternate),
          ),
        ),
      ],
    );
  }
}

// تبويب المستخدمين مع زر إضافة مستخدم
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<StoreProvider>(builder: (context, store, child) {
          if (store.isLoading) return const Center(child: CircularProgressIndicator());
          final users = store.users;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final user = users[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.person, color: user.role == UserRole.manager ? Colors.amber : Colors.blue),
                  title: Text(user.username),
                  subtitle: Text('الدور: ${user.role.name}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
                        _showEditUserDialog(ctx, user);
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                        context.read<StoreProvider>().deleteUser(user.id!);
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              ManagerDashboardScreen()._showAddUserDialog(context);
            },
            child: const Icon(Icons.person_add),
          ),
        ),
      ],
    );
  }

  // نافذة تعديل مستخدم
  void _showEditUserDialog(BuildContext context, AppUser user) {
    final TextEditingController passwordController = TextEditingController(text: user.password);
    UserRole _role = user.role;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل المستخدم: ${user.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'), obscureText: true),
            DropdownButtonFormField<UserRole>(
              value: _role,
              decoration: const InputDecoration(labelText: 'الدور'),
              items: const [
                DropdownMenuItem(value: UserRole.user, child: Text('مستخدم')),
                DropdownMenuItem(value: UserRole.manager, child: Text('مدير')),
              ],
              onChanged: (val) => _role = val ?? UserRole.user,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final updated = AppUser(
                id: user.id,
                username: user.username,
                password: passwordController.text,
                role: _role,
              );
              await context.read<StoreProvider>().updateUser(updated);
              Navigator.of(ctx).pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
