// lib/widgets/category_icon_design.dart
// هذا الودجت يعرض أيقونة دائرية للفئة مع صورة ونص.
// يدعم الصور من الأصول (assets) أو من المعرض (File).

import 'dart:io';
import 'package:flutter/material.dart';

class CategoryIconDesign extends StatelessWidget {
  final String categoryName; // اسم الفئة
  final String imagePath;    // صورة الفئة
  final VoidCallback onTap;  // حدث الضغط

  const CategoryIconDesign({
    super.key,
    required this.categoryName,
    required this.imagePath,
    required this.onTap,
  });

  ImageProvider _resolveImage(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/placeholder_category.png'); // صورة افتراضية
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final img = _resolveImage(imagePath);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: img,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Center(
            child: Text(
              categoryName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
