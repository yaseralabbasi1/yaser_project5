// lib/screens/reservation_cart_screen.dart
// هذه الشاشة تعرض محتويات السلة (المنتجات التي حجزها المستخدم).
// يمكن للمستخدم حذف عنصر من السلة أو إتمام عملية الشراء.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaser_project/providers/store_provider.dart';

class ReservationCartScreen extends StatelessWidget {
  const ReservationCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context); // الوصول إلى الحالة

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سلة المشتريات')),
        body: Column(
          children: [
            Expanded(
              child: store.reservations.isEmpty
                  ? const Center(child: Text('السلة فارغة، يرجى إضافة منتجات!', style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemCount: store.reservations.length,
                itemBuilder: (ctx, i) {
                  final item = store.reservations[i];
                  final imgPath = item.productImage;
                  final imageWidget = imgPath.isEmpty
                      ? Container(width: 70, height: 70, color: Colors.grey.shade300, child: const Icon(Icons.image))
                      : (imgPath.startsWith('assets/')
                      ? Image.asset(imgPath, width: 70, height: 70, fit: BoxFit.cover)
                      : Image.file(File(imgPath), width: 70, height: 70, fit: BoxFit.cover));

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} RS',
                                    style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('RS ${item.total.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await store.cancelReservation(item.productId); // حذف العنصر من السلة
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // شريط الإجمالي وزر إتمام الشراء
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي الكلي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('RS ${store.cartTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, color: Colors.deepPurple, fontWeight: FontWeight.w900)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('إتمام الشراء', style: TextStyle(fontSize: 16, color: Colors.white)),
                    onPressed: store.reservations.isEmpty
                        ? null
                        : () async {
                      await store.checkout(); // تنفيذ عملية الشراء
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت عملية الشراء بنجاح وتحديث المخزون!'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
