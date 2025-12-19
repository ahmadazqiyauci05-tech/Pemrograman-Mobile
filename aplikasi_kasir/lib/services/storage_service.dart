import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _productKey = 'products_data';
  static const String _transactionKey = 'transactions_data';
  static const String _expenseKey = 'expenses_data';

  // Pastikan TIDAK ADA fungsi showCustomSnackBar di file ini

  static Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_productKey);
    if (data == null) return [];
    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Product.fromJson(e)).toList();
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(products.map((e) => e.toJson()).toList());
    await prefs.setString(_productKey, data);
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_transactionKey);
    if (data == null) return [];
    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
  }

  static Future<void> saveTransaction(TransactionModel transaction) async {
    final prefs = await SharedPreferences.getInstance();
    List<TransactionModel> currentList = await getTransactions();
    currentList.add(transaction);
    final String data = jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(_transactionKey, data);
  }

  static Future<List<ExpenseModel>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_expenseKey);
    if (data == null) return [];
    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  static Future<void> saveExpense(ExpenseModel expense) async {
    final prefs = await SharedPreferences.getInstance();
    List<ExpenseModel> currentList = await getExpenses();
    currentList.add(expense);
    final String data = jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(_expenseKey, data);
  }
}