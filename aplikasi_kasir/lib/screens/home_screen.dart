import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'pos_screen.dart'; // <--- PASTIKAN BARIS INI ADA
import 'stock_screen.dart';
import 'report_screen.dart';
import 'expense_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel data statistik dengan inisialisasi default
  double totalSales = 0;
  double totalExpenses = 0;
  double netIncome = 0;
  int totalProducts = 0;
  int lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fungsi memuat data tanpa memanggil notifikasi
  Future<void> _loadDashboardData() async {
    try {
      final products = await StorageService.getProducts();
      final transactions = await StorageService.getTransactions();
      final expenses = await StorageService.getExpenses();

      if (mounted) {
        setState(() {
          totalSales = transactions.fold(0, (sum, item) => sum + item.total);
          totalExpenses = expenses.fold(0, (sum, item) => sum + item.amount);
          netIncome = totalSales - totalExpenses;
          totalProducts = products.length;
          lowStockCount = products.where((p) => p.stock <= p.minStock).length;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("DASHBOARD KASIR", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboardData,
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainBalanceCard(),
              const SizedBox(height: 25),
              const Text("Statistik Toko", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              _buildStatGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
        ),
        boxShadow: [
          BoxShadow(
            // Solusi error 'withOpacity' is deprecated
            color: Colors.blue.withAlpha(77), 
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sisa Saldo Kas", 
            style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text("Rp ${netIncome.toStringAsFixed(0)}", 
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildGridCard("Penjualan", "Rp ${totalSales.toStringAsFixed(0)}", 
            Icons.trending_up, Colors.green),
        _buildGridCard("Pengeluaran", "Rp ${totalExpenses.toStringAsFixed(0)}", 
            Icons.trending_down, Colors.redAccent),
        _buildGridCard("Total Produk", "$totalProducts Item", 
            Icons.inventory_2_rounded, Colors.purple),
        _buildGridCard("Stok Menipis", "$lowStockCount", 
            Icons.report_problem_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildGridCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                overflow: TextOverflow.ellipsis),
            ],
          )
        ],
      ),
    );
  }

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        const UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          accountName: Text("Admin Toko"),
          accountEmail: Text("Kasir 1"),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white, 
            child: Icon(Icons.person, color: Colors.blue, size: 40)
          ),
        ),
        _drawerListTile(Icons.dashboard_rounded, "Beranda", null, context),
        _drawerListTile(Icons.shopping_cart_rounded, "Transaksi POS", const POSScreen(), context), // Sudah tidak merah
        _drawerListTile(Icons.inventory_2_rounded, "Inventori Stok", const StockScreen(), context),
        _drawerListTile(Icons.money_off_rounded, "Pengeluaran", const ExpenseScreen(), context),
        _drawerListTile(Icons.bar_chart_rounded, "Laporan Keuangan", const ReportScreen(), context),
        const Spacer(),
        _drawerListTile(Icons.settings_rounded, "Pengaturan", const SettingsScreen(), context),
        const SizedBox(height: 10),
      ],
    ),
  );
}

  Widget _drawerListTile(IconData icon, String title, Widget? page, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); 
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => page))
              .then((_) => _loadDashboardData()); 
        }
      },
    );
  }
}