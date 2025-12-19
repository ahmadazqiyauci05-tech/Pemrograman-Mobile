import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/notifications.dart'; // Import helper notifikasi

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<ExpenseModel> expenses = [];
  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String selectedCategory = 'Operasional';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  _loadExpenses() async {
    final data = await StorageService.getExpenses();
    setState(() {
      expenses = data.reversed.toList();
    });
  }

  // --- FORM INPUT PENGELUARAN ---
  void _showAddExpenseForm() {
    descCtrl.clear();
    amountCtrl.clear();
    selectedCategory = 'Operasional';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 25, right: 25, top: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Tambah Pengeluaran", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent)),
              const SizedBox(height: 20),
              _buildInput(descCtrl, "Keterangan", Icons.description_outlined),
              const SizedBox(height: 15),
              _buildInput(amountCtrl, "Nominal (Rp)", Icons.payments_outlined, isNumber: true),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: const Icon(Icons.category_outlined, color: Colors.redAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: ['Operasional', 'Gaji', 'Listrik/Air', 'Sewa', 'Lainnya']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  if (descCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                    showCustomSnackBar(context, "Lengkapi semua data!", isError: true);
                    return;
                  }
                  
                  final ex = ExpenseModel(
                    id: "EXP-${DateTime.now().millisecondsSinceEpoch}",
                    description: descCtrl.text,
                    category: selectedCategory,
                    amount: double.parse(amountCtrl.text),
                    date: DateTime.now(),
                  );

                  await StorageService.saveExpense(ex);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _loadExpenses();
                    // NOTIFIKASI MUNCUL DI ATAS (SESUAI HELPER)
                    showCustomSnackBar(context, "Pengeluaran '${ex.description}' berhasil dicatat!");
                  }
                },
                child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.redAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalEx = expenses.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("PENGELUARAN", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: () {
              _loadExpenses();
              showCustomSnackBar(context, "Data pengeluaran diperbarui");
            }
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Keluar:", style: TextStyle(color: Colors.white70)),
                Text("Rp ${totalEx.toStringAsFixed(0)}", 
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: expenses.isEmpty
              ? const Center(child: Text("Belum ada catatan pengeluaran"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: expenses.length,
                  itemBuilder: (context, i) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade50,
                        child: const Icon(Icons.outbox, color: Colors.redAccent),
                      ),
                      title: Text(expenses[i].description, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(expenses[i].category),
                      trailing: Text("-Rp ${expenses[i].amount.toStringAsFixed(0)}", 
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseForm,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("TAMBAH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}