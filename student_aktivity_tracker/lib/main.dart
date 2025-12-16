import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const StudentActivityTrackerApp());
}

class StudentActivityTrackerApp extends StatelessWidget {
  const StudentActivityTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Activity Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5), // ubah jika mau warna lain
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF4F46E5), brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
