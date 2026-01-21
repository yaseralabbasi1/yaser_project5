// lib/screens/product_reservation_screen.dart
// هذه الشاشة تعرض تفاصيل المنتج المختار.
// يمكن للمستخدم رؤية الصورة، الاسم، النوعية، السعر الأصلي والنهائي، الوصف، الكمية المتوفرة.
// كما يمكنه تحديد الكمية المطلوبة وإضافتها إلى السلة.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaser_project/models/product.dart';
import 'package:yaser_project/providers/store_provider.dart';

class ProductReservationScreen extends StatefulWidget {
  final Product product; // المنتج الذي سيتم عرضه

  const ProductReservationScreen({super.key, required this.product});

  @override
  State<ProductReservationScreen> createState() => _ProductReservationScreenState();
}

class _ProductReservationScreenState extends State<ProductReservationScreen> {
  int _quantity = 1; // الكمية المطلوبة (افتراضياً 1)

  // دالة لتحديث الكمية عند الضغط على زر + أو -
  void _updateQuantity(int delta) {
    setState(() {
      final newQuantity = _quantity + delta;
      if (newQuantity >= 1 && newQuantity <= widget.product.stockQuantity) {
        // إذا كانت الكمية ضمن المتوفر → تحديثها
        _quantity = newQuantity;
      } else if (newQuantity > widget.product.stockQuantity) {
        // إذا تجاوزت الكمية المتوفرة → رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('عفواً، الكمية المتوفرة هي ${widget.product.stockQuantity} فقط!'), backgroundColor: Colors.red),
        );
      } else {
        // إذا كانت أقل من 1 → إعادة إلى 1
        _quantity = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreProvider>(); // الوصول إلى الحالة
    final double currentPrice = widget.product.finalPrice * _quantity; // السعر الإجمالي للطلب

    // بناء صورة المنتج
    Widget imageWidget;
    if (widget.product.imagePath.isEmpty) {
      imageWidget = Container(
        height: 250,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image, size: 80, color: Colors.grey),
      );
    } else if (widget.product.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(widget.product.imagePath, height: 250, fit: BoxFit.cover);
    } else {
      imageWidget = Image.file(File(widget.product.imagePath), height: 250, fit: BoxFit.cover);
    }

    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه النص يمين
      child: Scaffold(
        appBar: AppBar(title: Text(widget.product.name)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المنتج
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
              ),
              // بطاقة تفاصيل المنتج
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // اسم المنتج
                      Center(child: Text(widget.product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 10),
                      // النوعية
                      Text("النوعية: ${widget.product.type}", style: const TextStyle(fontSize: 18, color: Colors.blue)),
                      // السعر الأصلي + الخصم
                      Row(children: [
                        Text(
                          "السعر الأصلي: RS ${widget.product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: widget.product.discountPercentage > 0 ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (widget.product.discountPercentage > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Chip(
                              label: Text("خصم ${(widget.product.discountPercentage * 100).toStringAsFixed(0)}%"),
                              backgroundColor: Colors.red.shade100,
                            ),
                          ),
                      ]),
                      // السعر النهائي للوحدة
                      Text("السعر النهائي للوحدة: RS ${widget.product.finalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                      const Divider(),
                      // الوصف
                      const Text("الوصف:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.product.description, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      // الكمية المتوفرة
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("الكمية المتوفرة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text("${widget.product.stockQuantity}", style: const TextStyle(fontSize: 16, color: Colors.orange)),
                      ]),
                      const SizedBox(height: 10),
                      // الكمية المطلوبة
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("الكمية المطلوبة:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(children: [
                          IconButton(icon: const Icon(Icons.remove_circle, size: 30, color: Colors.red), onPressed: () => _updateQuantity(-1)),
                          Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add_circle, size: 30, color: Colors.green), onPressed: () => _updateQuantity(1)),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      // السعر الإجمالي للطلب
                      Center(
                        child: Text("السعر الإجمالي للطلب: RS ${currentPrice.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                      ),
                      const SizedBox(height: 16),
                      // زر إضافة إلى السلة
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                          label: Text("إضافة $_quantity إلى السلة", style: const TextStyle(fontSize: 18, color: Colors.white)),
                          onPressed: widget.product.stockQuantity == 0
                              ? null
                              : () async {
                            await store.makeReservation(widget.product, _quantity); // إضافة إلى السلة
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم إضافة ${widget.product.name} (×$_quantity) إلى السلة')),
                            );
                            Navigator.pop(context); // العودة للشاشة السابقة
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
