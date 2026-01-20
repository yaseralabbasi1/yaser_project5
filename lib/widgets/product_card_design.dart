// lib/widgets/product_card_design.dart
// هذا الودجت يعرض بطاقة المنتج في واجهة المستخدم.
// يحتوي على صورة المنتج، الاسم، النوعية، السعر، والكمية المتوفرة.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yaser_project/models/product.dart';

class ProductCardDesign extends StatelessWidget {
  final Product product;   // المنتج
  final VoidCallback onTap; // حدث الضغط

  const ProductCardDesign({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discounted = product.discountPercentage > 0; // هل هناك خصم؟

    // بناء صورة المنتج
    Widget imageWidget;
    if (product.imagePath.isEmpty) {
      imageWidget = Container(height: 115, width: double.infinity, color: Colors.grey.shade300, child: const Icon(Icons.image));
    } else if (product.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(product.imagePath, height: 115, width: double.infinity, fit: BoxFit.fill);
    } else {
      imageWidget = Image.file(File(product.imagePath), height: 115, width: double.infinity, fit: BoxFit.fill);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 163,
        height: 240,
        child: Card(
          color: Theme.of(context).cardColor,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Column(
                children: [
                  ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: imageWidget),
                  const Divider(height: 1),
                ],
              ),
              const Positioned(top: 120, right: 10, child: Text("الاسم:", style: TextStyle(fontSize: 13, color: Colors.grey))),
              Positioned(top: 120, left: 10, child: Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
              const Positioned(top: 140, right: 10, child: Text("النوعية:", style: TextStyle(fontSize: 13, color: Colors.grey))),
              Positioned(top: 140, left: 10, child: Text(product.type, style: const TextStyle(fontSize: 13, color: Colors.blue))),
              const Positioned(top: 160, right: 10, child: Text("السعر:", style: TextStyle(fontSize: 13, color: Colors.grey))),
              Positioned(
                top: 160,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (discounted)
                      Text(
                        "${product.price.toStringAsFixed(0)} RS",
                        style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
                      ),
                    Text(
                      "${product.finalPrice.toStringAsFixed(0)} RS",
                      style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 200,
                right: 10,
                child: Text(
                  "المتوفر: ${product.stockQuantity}",
                  style: TextStyle(fontSize: 12, color: product.stockQuantity > 0 ? Colors.orange : Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
