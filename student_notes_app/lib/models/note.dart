import 'package:flutter/material.dart'; // Solusi untuk Icons dan Colors
import 'dart:convert';

class Note {
  int? id;
  String title;
  String description;
  String category;
  DateTime dateCreated;

  // Ganti super.key dengan Key? key jika diperlukan, atau hapus jika tidak perlu.
  // Untuk model data seperti ini, constructor sederhana sudah cukup.
  Note({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateCreated,
  });

  // Konversi dari Map (JSON)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );
  }

  // Konversi ke Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dateCreated': dateCreated.toIso8601String(), 
    };
  }
}

const List<String> availableCategories = [
  'Kuliah', 
  'Organisasi', 
  'Pribadi', 
  'Lain-lain'
];

// Helper untuk ikon dan warna (Sekarang bekerja setelah import)
Map<String, dynamic> getCategoryStyle(String category) {
  switch (category) {
    case 'Kuliah':
      return {'icon': Icons.book, 'color': Colors.blue};
    case 'Organisasi':
      return {'icon': Icons.group, 'color': Colors.green};
    case 'Pribadi':
      return {'icon': Icons.person, 'color': Colors.orange};
    default:
      return {'icon': Icons.more_horiz, 'color': Colors.grey};
  }
}