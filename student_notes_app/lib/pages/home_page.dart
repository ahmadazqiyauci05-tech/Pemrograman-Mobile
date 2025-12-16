import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'add_edit_note_page.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const HomePage({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NoteService _noteService = NoteService();
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Muat catatan dari SharedPreferences
  void _loadNotes() async {
    final notes = await _noteService.loadNotes();
    setState(() {
      _allNotes = notes;
      _applyFilter();
    });
  }

  // Simpan catatan ke SharedPreferences
  void _saveNotes() {
    _noteService.saveNotes(_allNotes);
  }

  // Logika Filter
  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'Semua') {
        _filteredNotes = List.from(_allNotes);
      } else {
        _filteredNotes = _allNotes
            .where((note) => note.category == _selectedFilter)
            .toList();
      }
    });
  }

  // Navigasi & Logika CRUD
  void _navigateToAddEdit(Note? note) async {
    // Navigator.push
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNotePage(note: note),
      ),
    );

    if (result != null && result is Note) {
      if (note == null) {
        // Tambah Baru
        result.id = DateTime.now().millisecondsSinceEpoch; // ID sederhana
        _allNotes.add(result);
      } else {
        // Edit
        final index = _allNotes.indexWhere((n) => n.id == result.id);
        if (index != -1) {
          _allNotes[index] = result;
        }
      }
      _saveNotes();
      _applyFilter(); // Panggil setState di sini
    }
  }

  void _deleteNote(int id) {
    setState(() {
      _allNotes.removeWhere((note) => note.id == id);
      _saveNotes();
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Tugas Mahasiswa'),
        actions: <Widget>[
          // Dark Mode Toggle (BONUS)
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
            activeColor: Colors.yellow,
          ),
          
          // Dropdown Filter Kategori
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              underline: const SizedBox(),
              items: ['Semua', ...availableCategories].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _selectedFilter = newValue;
                  _applyFilter(); // Menerapkan filter dan memanggil setState
                }
              },
            ),
          ),
        ],
      ),
      body: _filteredNotes.isEmpty
          ? Center(child: Text(_selectedFilter == 'Semua' ? 'Belum ada catatan.' : 'Tidak ada catatan di kategori ini.'))
          // Wajib menggunakan ListView.builder
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                final style = getCategoryStyle(note.category);
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  child: ListTile(
                    // Ikon berbeda untuk setiap kategori
                    leading: Icon(style['icon'] as IconData, color: style['color'] as Color),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${note.category}'),
                        // Tanggal catatan dibuat
                        Text('Dibuat: ${DateFormat('dd MMMM yyyy, HH:mm').format(note.dateCreated)}'),
                      ],
                    ),
                    onTap: () => _navigateToAddEdit(note), // Edit catatan
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(null), // Tambah catatan baru
        child: const Icon(Icons.add),
      ),
    );
  }
}