import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/note_service.dart';

void main() {
  // Pastikan binding inisialisasi sebelum SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final NoteService _noteService = NoteService();

  @override
  void initState() {
    super.initState();
    _loadThemeStatus();
  }

  void _loadThemeStatus() async {
    final isDark = await _noteService.loadDarkModeStatus();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    // Simpan status Dark Mode ke SharedPreferences
    _noteService.saveDarkModeStatus(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      // Tema aplikasi
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        onThemeChanged: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}