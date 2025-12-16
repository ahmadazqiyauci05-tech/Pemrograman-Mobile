// lib/models/shopping_item.dart

import 'package:uuid/uuid.dart';

enum ItemCategory {
  food,
  drink,
  electronic,
  other,
}

class ShoppingItem {
  final String id;
  String name;
  int quantity;
  ItemCategory category;
  bool isBought;

  ShoppingItem({
    required this.name,
    required this.quantity,
    this.category = ItemCategory.other,
    this.isBought = false,
  }) : id = const Uuid().v4(); 

  // Konversi dari Map (JSON) ke Objek
  ShoppingItem.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        quantity = map['quantity'],
        category = ItemCategory.values.byName(map['category']),
        isBought = map['isBought'];

  // Konversi dari Objek ke Map (untuk disimpan)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category.name, 
      'isBought': isBought,
    };
  }
}