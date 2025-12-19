import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Fungsi untuk menghapus seluruh data di SharedPreferences
  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data berhasil dihapus!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Versi Aplikasi"),
            subtitle: Text("v1.0.0"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Reset Database", style: TextStyle(color: Colors.red)),
            subtitle: const Text("Hapus semua produk, transaksi, dan pengeluaran"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Hapus Semua Data?"),
                  content: const Text("Tindakan ini tidak dapat dibatalkan. Semua data inventori dan laporan akan hilang."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("BATAL"),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearAllData();
                        Navigator.pop(context);
                      },
                      child: const Text("HAPUS", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}