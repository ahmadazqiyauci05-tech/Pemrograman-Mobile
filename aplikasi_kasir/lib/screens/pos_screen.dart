import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/notifications.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});
  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  Map<String, Map<String, dynamic>> cart = {}; 
  double totalBayar = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final data = await StorageService.getProducts(); // Mengambil data produk
    setState(() {
      products = data;
      filteredProducts = data;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateTotal() {
    setState(() {
      totalBayar = cart.values.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
    });
  }

  void _addToCart(Product p) {
    if (p.stock <= 0) return;
    setState(() {
      p.stock -= 1;
      if (cart.containsKey(p.id)) {
        cart[p.id]!['qty'] += 1;
      } else {
        cart[p.id] = {
          'id': p.id,
          'name': p.name,
          'price': p.price,
          'qty': 1,
        };
      }
      _updateTotal();
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      final product = products.firstWhere((p) => p.id == id);
      product.stock += 1;
      if (cart[id]!['qty'] > 1) {
        cart[id]!['qty'] -= 1;
      } else {
        cart.remove(id);
      }
      _updateTotal();
    });
  }

  void _showCheckoutSheet() {
    final TextEditingController bayarCtrl = TextEditingController();
    double kembalian = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 25, right: 25, top: 25
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("PEMBAYARAN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
              const Divider(height: 30),
              
              // Rincian List di Checkout
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
                child: ListView(
                  shrinkWrap: true,
                  children: cart.values.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item['name']} x${item['qty']}"),
                        Text("Rp ${(item['price'] * item['qty']).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL TAGIHAN", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("Rp ${totalBayar.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: bayarCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Uang Tunai Diterima",
                  prefixText: "Rp ",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setModalState(() {
                    double input = double.tryParse(val) ?? 0;
                    kembalian = input - totalBayar;
                  });
                },
              ),
              const SizedBox(height: 15),
              Text(
                kembalian < 0 ? "Kurang: Rp ${kembalian.abs().toStringAsFixed(0)}" : "Kembalian: Rp ${kembalian.toStringAsFixed(0)}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kembalian < 0 ? Colors.red : Colors.green),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: (double.tryParse(bayarCtrl.text) ?? 0) < totalBayar 
                    ? null 
                    : () async {
                        final tx = TransactionModel(
                          id: "TX${DateTime.now().millisecondsSinceEpoch}",
                          items: cart.values.toList(),
                          total: totalBayar,
                          date: DateTime.now(),
                        );
                        await StorageService.saveTransaction(tx); // Simpan transaksi
                        await StorageService.saveProducts(products); // Update stok produk
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() { cart.clear(); totalBayar = 0; });
                          _loadInitialData();
                          showCustomSnackBar(context, "Transaksi Berhasil Disimpan!");
                        }
                      },
                  child: const Text("PROSES PEMBAYARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("KASIR PRO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar Modern
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                decoration: const InputDecoration(
                  hintText: "Cari produk kasir...",
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          
          // List Produk
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredProducts.length,
              itemBuilder: (context, i) {
                final p = filteredProducts[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Stok: ${p.stock} | Rp ${p.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.grey)),
                    trailing: Material(
                      color: p.stock > 0 ? Colors.blueAccent.withAlpha(30) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: p.stock > 0 ? () => _addToCart(p) : null,
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.add, color: p.stock > 0 ? Colors.blueAccent : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Ringkasan Keranjang (Data ke isi ke bawah)
          if (cart.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 10),
                  const Center(child: Text("KERANJANG BELANJA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2))),
                  ...cart.values.map((item) => ListTile(
                    dense: true,
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("x${item['qty']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Rp ${(item['price'] * item['qty']).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20), onPressed: () => _removeFromCart(item['id'])),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),

          // Footer Total & Checkout
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Rp ${totalBayar.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: cart.isEmpty ? null : _showCheckoutSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                    ),
                    child: const Text("BAYAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}