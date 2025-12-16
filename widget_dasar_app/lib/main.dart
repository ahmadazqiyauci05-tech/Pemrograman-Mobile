import 'package:flutter/material.dart';

void main() {
  runApp(const BiodataApp());
}

class BiodataApp extends StatelessWidget {
  const BiodataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biodata App',
      debugShowCheckedModeBanner: false,
      home: const BiodataScreen(),
    );
  }
}

class BiodataScreen extends StatelessWidget {
  const BiodataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: const Text('Biodata Diri'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FOTO PROFIL (CIRCLE AVATAR)
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://cdn.discordapp.com/attachments/1346452454908362753/1425492893434384414/foto.png?ex=68ea6c36&is=68e91ab6&hm=a67b684c0fa2369444e90574ff8b846642b47da3d251e0c46859301e9ba4e725',
                ),
              ),
              const SizedBox(height: 20),

              // NAMA LENGKAP
              const Text(
                'Aditya Rahmattullah',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // DESKRIPSI SINGKAT
              const Text(
                'Mahasiswa sistem informasi yang menyukai pemrograman, '
                'membangun aplikasi, dan terus belajar hal baru di dunia digital.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // TOMBOL AKSI
              ElevatedButton(
                onPressed: () {
                  // Menampilkan pesan snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Halo! Ini adalah biodata saya 😄'),
                      duration: Duration(seconds: 4),
                    ),
                  );

                  // Menampilkan pesan di konsol
                  debugPrint('Tombol ditekan! Halo dari Aditya Rahmattullah 👋');

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Tampilkan Pesan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
