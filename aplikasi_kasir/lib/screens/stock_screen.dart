import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../utils/notifications.dart'; // Import helper notifikasi

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Product> allProducts = []; 
  List<Product> displayedProducts = []; 
  
  final TextEditingController _searchController = TextEditingController();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final minStockCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  _refresh() async {
    final data = await StorageService.getProducts();
    setState(() {
      allProducts = data;
      _filterProducts(_searchController.text);
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedProducts = allProducts;
      } else {
        displayedProducts = allProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
                          p.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showForm(Product? p) {
    if (p != null) {
      nameCtrl.text = p.name;
      priceCtrl.text = p.price.toStringAsFixed(0);
      stockCtrl.text = p.stock.toString();
      categoryCtrl.text = p.category;
      minStockCtrl.text = p.minStock.toString();
    } else {
      nameCtrl.clear(); priceCtrl.clear(); stockCtrl.clear();
      categoryCtrl.text = "Umum";
      minStockCtrl.text = "5";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text(p == null ? "Tambah Produk" : "Edit Detail Produk", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildField(nameCtrl, "Nama Produk", Icons.inventory),
                _buildField(categoryCtrl, "Kategori", Icons.category),
                Row(
                  children: [
                    Expanded(child: _buildField(priceCtrl, "Harga", Icons.payments, isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildField(stockCtrl, "Stok", Icons.numbers, isNumber: true)),
                  ],
                ),
                _buildField(minStockCtrl, "Batas Re-stok", Icons.notification_important, isNumber: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: p == null ? Colors.blue : Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final newP = Product(
                          id: p?.id ?? DateTime.now().toString(),
                          name: nameCtrl.text,
                          category: categoryCtrl.text,
                          price: double.parse(priceCtrl.text),
                          stock: int.parse(stockCtrl.text),
                          minStock: int.parse(minStockCtrl.text),
                        );
                        
                        List<Product> currentList = List.from(allProducts);
                        if (p == null) {
                          currentList.add(newP);
                        } else {
                          int idx = currentList.indexWhere((x) => x.id == p.id);
                          currentList[idx] = newP;
                        }
                        
                        await StorageService.saveProducts(currentList);
                        Navigator.pop(context);
                        _refresh();
                        
                        // NOTIFIKASI SUKSES
                        showCustomSnackBar(
                          context, 
                          p == null ? "Produk ${newP.name} berhasil ditambah!" : "Data ${newP.name} berhasil diupdate!"
                        );
                      } catch (e) {
                        // NOTIFIKASI ERROR
                        showCustomSnackBar(context, "Terjadi kesalahan: $e", isError: true);
                      }
                    }
                  },
                  child: Text(p == null ? "SIMPAN PRODUK" : "UPDATE DATA", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("INVENTORI STOK", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: "Cari nama barang atau kategori...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: displayedProducts.isEmpty 
          ? const Center(child: Text("Produk tidak ditemukan"))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: displayedProducts.length,
              itemBuilder: (context, i) {
                final p = displayedProducts[i];
                bool isOutOfStock = p.stock <= 0;
                bool isLowStock = p.stock <= p.minStock;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isOutOfStock ? Colors.red.shade50 : (isLowStock ? Colors.orange.shade50 : Colors.blue.shade50),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.shopping_bag, color: isOutOfStock ? Colors.red : (isLowStock ? Colors.orange : Colors.blue)),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text("Rp ${p.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOutOfStock ? Colors.red : (isLowStock ? Colors.orange : Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isOutOfStock ? "HABIS" : "STOK: ${p.stock}",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _showForm(p),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.blue,
        label: const Text("TAMBAH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}