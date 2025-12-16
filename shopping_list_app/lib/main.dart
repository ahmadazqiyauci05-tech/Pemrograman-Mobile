// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'screens/shopping_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List App',
      theme: ThemeData(
        // Skema warna modern (Hijau sebagai Primary, Oranye sebagai Aksen)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), 
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFF5722), 
          background: const Color(0xFFF7F9FC), // Background yang sangat terang
        ),
        useMaterial3: true, // Mengaktifkan Material 3
        // Menggunakan Google Fonts untuk seluruh teks
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9FC), 
          elevation: 0, // App bar tanpa bayangan
          foregroundColor: Colors.black87,
        ),
      ),
      home: const ShoppingListScreen(),
    );
  }
}