// lib/screens/shopping_list_screen.dart

import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _shoppingList = [];
  final ShoppingService _service = ShoppingService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  // --- Fungsi Data Persisten ---
  Future<void> _loadShoppingList() async {
    _shoppingList = await _service.loadList();
    setState(() {
      _sortList(); 
      _isLoading = false;
    });
  }

  void _saveShoppingList() {
    _service.saveList(_shoppingList);
  }

  // --- Fungsi CRUD dan State Management ---
  void _addItem(ShoppingItem item) {
    setState(() {
      _shoppingList.add(item);
      _sortList(); 
    });
    _saveShoppingList();
  }

  void _toggleBoughtStatus(ShoppingItem item) {
    setState(() {
      item.isBought = !item.isBought;
      _sortList(); 
    });
    _saveShoppingList();
  }
  
  void _sortList() {
     // Mengurutkan item yang belum dibeli di atas, dan yang sudah dibeli di bawah.
      _shoppingList.sort((a, b) {
        if (a.isBought == b.isBought) return 0;
        return a.isBought ? 1 : -1;
      });
  }

  void _deleteItem(String id) {
    setState(() {
      _shoppingList.removeWhere((item) => item.id == id);
    });
    _saveShoppingList();
  }

  // --- Fungsi UI Pembantu dan Statistik ---
  
  int get _itemsRemaining => _shoppingList.where((item) => !item.isBought).length;
  int get _itemsBought => _shoppingList.where((item) => item.isBought).length;

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.food: return 'Makanan';
      case ItemCategory.drink: return 'Minuman';
      case ItemCategory.electronic: return 'Elektronik';
      case ItemCategory.other: return 'Lain-lain';
    }
  }

  // --- Dialog Tambah/Edit Item ---
  void _showAddItemDialog({ShoppingItem? itemToEdit}) {
    final bool isEditing = itemToEdit != null;
    final TextEditingController nameController = TextEditingController(text: isEditing ? itemToEdit.name : '');
    final TextEditingController quantityController = TextEditingController(text: isEditing ? itemToEdit.quantity.toString() : '1');
    ItemCategory selectedCategory = isEditing ? itemToEdit.category : ItemCategory.food;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Item' : 'Tambah Item Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Item'),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<ItemCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: ItemCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }).toList(),
                      onChanged: (ItemCategory? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String name = nameController.text.trim();
                    final int? quantity = int.tryParse(quantityController.text);

                    if (name.isNotEmpty && quantity != null && quantity > 0) {
                      if (isEditing) {
                        itemToEdit.name = name;
                        itemToEdit.quantity = quantity;
                        itemToEdit.category = selectedCategory;
                        _saveShoppingList();
                      } else {
                        final newItem = ShoppingItem(
                          name: name,
                          quantity: quantity,
                          category: selectedCategory,
                        );
                        _addItem(newItem);
                      }
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(isEditing ? 'Simpan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Widget Pembantu untuk Kartu Status (Desain Modern)
  Widget _buildStatusCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        elevation: 2, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Build Utama ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Belanja')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Belanja Modern', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Bagian Statistik Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCard('Belum Dibeli', _itemsRemaining, colorScheme.error),
                const SizedBox(width: 12),
                _buildStatusCard('Sudah Dibeli', _itemsBought, colorScheme.primary),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Item Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Daftar Item Belanja (List)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _shoppingList.length,
              itemBuilder: (context, index) {
                final item = _shoppingList[index];
                
                // Menggunakan Card untuk setiap item agar lebih menonjol
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    // Border jika item sudah dibeli
                    side: item.isBought 
                        ? BorderSide(color: colorScheme.primary.withOpacity(0.5), width: 1.5)
                        : BorderSide.none,
                  ),
                  child: Dismissible( // Fitur Hapus dengan Geser
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                    ),
                    onDismissed: (direction) {
                      _deleteItem(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name} dihapus')),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onTap: () => _toggleBoughtStatus(item), 
                      onLongPress: () => _showAddItemDialog(itemToEdit: item),
                      leading: Checkbox(
                        value: item.isBought,
                        onChanged: (_) => _toggleBoughtStatus(item),
                        activeColor: colorScheme.primary,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: item.isBought ? TextDecoration.lineThrough : TextDecoration.none,
                          color: item.isBought ? Colors.grey : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${item.quantity} | Kategori: ${_getCategoryName(item.category)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          decoration: item.isBought ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      trailing: item.isBought
                          ? Icon(Icons.shopping_bag_rounded, color: colorScheme.primary)
                          : Icon(Icons.add_shopping_cart, color: colorScheme.secondary),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Tombol Tambah yang Modern (Extended FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(),
        backgroundColor: colorScheme.secondary, 
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('Tambah Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}