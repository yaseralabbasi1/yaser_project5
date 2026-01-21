// lib/screens/category_products_screen.dart
// هذه الشاشة تعرض المنتجات الخاصة بفئة معينة.
// تستقبل اسم الفئة وتستخدم StoreProvider لجلب المنتجات المطابقة.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaser_project/providers/store_provider.dart';
import 'package:yaser_project/widgets/product_card_design.dart';
import 'product_reservation_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category; // اسم الفئة
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(builder: (context, store, child) {
      final products = store.getProductsByCategory(category); // جلب المنتجات حسب الفئة
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(category)),
          body: store.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              Wrap(
                children: products.map((product) {
                  return ProductCardDesign(
                    product: product,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductReservationScreen(product: product)));
                    },
                  );
                }).toList(),
              ),
              if (products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('لا يوجد منتجات في هذا القسم حالياً.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}
