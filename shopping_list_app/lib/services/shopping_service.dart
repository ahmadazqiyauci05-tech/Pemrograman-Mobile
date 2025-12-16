// lib/services/shopping_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class ShoppingService {
  static const String _key = 'shoppingList';

  // Menyimpan daftar item
  Future<void> saveList(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Objek List<ShoppingItem> -> List<String> JSON
    final List<String> jsonList = items.map((item) => jsonEncode(item.toMap())).toList();
    
    await prefs.setStringList(_key, jsonList);
  }

  // Mengambil daftar item
  Future<List<ShoppingItem>> loadList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);

    if (jsonList == null) {
      return [];
    }

    // List<String> JSON -> List<ShoppingItem> Objek
    return jsonList.map((jsonString) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return ShoppingItem.fromMap(map);
    }).toList();
  }
}