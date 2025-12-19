class TransactionModel {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
  });

  // Fungsi untuk mengubah JSON dari Storage menjadi Objek Dart
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'],
        // Mengonversi data list dari JSON kembali ke format Map
        items: List<Map<String, dynamic>>.from(json['items']),
        total: json['total'].toDouble(),
        date: DateTime.parse(json['date']),
      );

  // Fungsi untuk mengubah Objek Dart menjadi JSON untuk disimpan ke Storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items,
        'total': total,
        'date': date.toIso8601String(), // Simpan tanggal dalam format teks ISO
      };
}

class ExpenseModel {
  final String id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Fungsi untuk mengubah JSON dari Storage menjadi Objek Dart
  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'],
        description: json['description'],
        category: json['category'],
        amount: json['amount'].toDouble(),
        date: DateTime.parse(json['date']),
      );

  // Fungsi untuk mengubah Objek Dart menjadi JSON untuk disimpan ke Storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}