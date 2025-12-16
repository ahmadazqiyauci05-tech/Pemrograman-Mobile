// lib/main.dart
import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'services/todo_storage_service.dart';
import 'widgets/todo_item.dart';

const Color primaryColor = Color(0xFF6C63FF); 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo App',
      theme: ThemeData(
        // Light Theme
        primaryColor: primaryColor,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          color: primaryColor, // AppBar menggunakan warna primer
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      darkTheme: ThemeData(
        // Dark Theme
        primaryColor: primaryColor,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, 
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoStorageService _storageService = TodoStorageService();
  List<Todo> _allTodos = [];
  String _currentFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // --- PERSISTENCE & STATUS MANAGEMENT ---
  
  Future<void> _loadTodos() async {
    final loadedTodos = await _storageService.loadTodos();
    setState(() {
      _allTodos = loadedTodos;
    });
  }

  Future<void> _saveAndRefresh() async {
    await _storageService.saveTodos(_allTodos);
    setState(() {}); 
  }

  // --- LOGIKA CRUD ---

  void _addTodo(String title) {
    if (title.isEmpty) return;
    final newTodo = Todo.create(title);
    setState(() {
      _allTodos.add(newTodo);
    });
    _saveAndRefresh();
  }

  void _toggleComplete(Todo todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;
    });
    _saveAndRefresh();
  }
  
  void _editTodo(String id, String newTitle) {
    if (newTitle.isEmpty) return;
    setState(() {
      _allTodos.firstWhere((todo) => todo.id == id).title = newTitle;
    });
    _saveAndRefresh();
  }

  void _deleteTodo(String id) {
    setState(() {
      _allTodos.removeWhere((todo) => todo.id == id);
    });
    _saveAndRefresh();
  }

  // --- FILTERING ---

  List<Todo> get _filteredTodos {
    if (_currentFilter == 'Selesai') {
      return _allTodos.where((todo) => todo.isCompleted).toList();
    } else if (_currentFilter == 'Belum Selesai') {
      return _allTodos.where((todo) => !todo.isCompleted).toList();
    }
    return _allTodos; 
  }

  // --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Tugas Harian',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
            ),
            backgroundColor: primaryColor,
            floating: true,
            pinned: true,
            toolbarHeight: 90,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                child: _buildFilterSegmentedButton(context),
              ),
            ),
          ),
          
          if (_allTodos.isEmpty && _currentFilter == 'Semua')
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    Text(
                      '🎉 Tidak ada tugas hari ini. Santai!',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final todo = _filteredTodos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: TodoItem(
                      todo: todo,
                      onToggle: _toggleComplete,
                      onDelete: _deleteTodo,
                      onEdit: (newTitle) => _editTodo(todo.id, newTitle),
                    ),
                  );
                },
                childCount: _filteredTodos.length,
              ),
            ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildFilterSegmentedButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), 
        borderRadius: BorderRadius.circular(10),
      ),
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(
            value: 'Semua',
            label: Text('Semua', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ButtonSegment<String>(
            value: 'Belum Selesai',
            label: Text('Belum Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ButtonSegment<String>(
            value: 'Selesai',
            label: Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        selected: <String>{_currentFilter},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _currentFilter = newSelection.first;
          });
        },
        style: SegmentedButton.styleFrom(
          foregroundColor: Colors.white, 
          selectedForegroundColor: primaryColor, 
          selectedBackgroundColor: Colors.white, 
          side: BorderSide.none, 
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Misal: Beli bahan makanan'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addTodo(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}