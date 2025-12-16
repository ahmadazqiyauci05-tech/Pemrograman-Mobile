import 'package:flutter/material.dart';
import '../models/note.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note; // Jika null, berarti Tambah Baru

  const AddEditNotePage({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Inisialisasi state dari Note yang ada atau nilai default
    _title = widget.note?.title ?? '';
    _description = widget.note?.description ?? '';
    // Set kategori default jika catatan baru, atau kategori yang sudah ada
    _selectedCategory = widget.note?.category ?? availableCategories.first;
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Membuat objek Note baru/diperbarui
      final resultNote = Note(
        id: widget.note?.id, // Pertahankan ID jika Edit
        title: _title,
        description: _description,
        category: _selectedCategory,
        // Gunakan tanggal yang sudah ada jika Edit, atau tanggal sekarang jika Baru
        dateCreated: widget.note?.dateCreated ?? DateTime.now(), 
      );
      
      // Menggunakan Navigator.pop untuk kembali dan mengirim data hasil
      Navigator.pop(context, resultNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Tambah Catatan Baru' : 'Edit Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // 1. TextFormField untuk Judul
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Judul Catatan'),
                validator: (value) {
                  // Wajib menerapkan validator
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),

              // 2. Dropdown untuk Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: availableCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori';
                  }
                  return null;
                },
                onSaved: (value) => _selectedCategory = value!,
              ),
              const SizedBox(height: 20),

              // 3. TextFormField untuk Deskripsi
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Deskripsi Detail'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}