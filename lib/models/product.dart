// lib/models/product.dart
// هذا الملف يعرّف نموذج المنتج ونموذج عنصر السلة.

class Product {
  String id;                 // معرف المنتج
  String name;               // اسم المنتج
  String type;               // النوعية
  double price;              // السعر الأصلي
  String imagePath;          // مسار الصورة
  String description;        // وصف المنتج
  String category;           // اسم الفئة
  int stockQuantity;         // الكمية المتوفرة
  double discountPercentage; // نسبة الخصم (0.0 إلى 1.0)

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.category,
    this.stockQuantity = 0,
    this.discountPercentage = 0.0,
  });

  // السعر النهائي بعد الخصم
  double get finalPrice => price * (1.0 - discountPercentage);

  // من Map إلى كائن
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      price: (map['price'] as num).toDouble(),
      imagePath: map['imagePath'],
      description: map['description'],
      category: map['category'],
      stockQuantity: map['stockQuantity'],
      discountPercentage: (map['discountPercentage'] as num).toDouble(),
    );
  }

  // إلى Map للتخزين
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'imagePath': imagePath,
      'description': description,
      'category': category,
      'stockQuantity': stockQuantity,
      'discountPercentage': discountPercentage,
    };
  }
}

// نموذج عنصر السلة
class ReservationItem {
  String id;           // معرف العنصر
  String productId;    // معرف المنتج
  int quantity;        // الكمية المطلوبة
  double unitPrice;    // السعر النهائي للوحدة
  String productName;  // اسم المنتج
  String productImage; // صورة المنتج

  ReservationItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.productName,
    required this.productImage,
  });

  // السعر الكلي للعنصر
  double get total => unitPrice * quantity;

  factory ReservationItem.fromMap(Map<String, dynamic> map) {
    return ReservationItem(
      id: map['id'],
      productId: map['productId'],
      quantity: map['quantity'],
      unitPrice: (map['unitPrice'] as num).toDouble(),
      productName: map['productName'],
      productImage: map['productImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'productName': productName,
      'productImage': productImage,
    };
  }
}
