// lib/services/todo_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoStorageService {
  static const String _key = 'todoList';

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error decoding JSON: $e');
      return [];
    }
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = 
        todos.map((todo) => todo.toJson()).toList();
        
    final String jsonString = json.encode(jsonList);
    await prefs.setString(_key, jsonString);
  }
}