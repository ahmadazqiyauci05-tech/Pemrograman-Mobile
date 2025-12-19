import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  // Memastikan binding Flutter terinisialisasi sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasir Pro',
      // Menghilangkan label "Debug" di pojok kanan atas
      debugShowCheckedModeBanner: false,
      
      // Mengatur tema aplikasi dengan prinsip Material Design 3
      theme: ThemeData(
        useMaterial3: true,
        // Menentukan warna utama aplikasi secara dinamis
        colorSchemeSeed: Colors.blue,
        
        // Kustomisasi AppBar secara global
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // Kustomisasi desain tombol secara global
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // Kustomisasi desain Input/Form secara global
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      
      // Halaman pertama yang akan dibuka saat aplikasi dijalankan
      home: const HomeScreen(),
    );
  }
}