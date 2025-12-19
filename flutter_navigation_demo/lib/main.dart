import 'package:flutter/material.dart';

// Fungsi utama untuk menjalankan aplikasi Flutter
void main() {
  runApp(const MainApp());
}

// ====================================================================
// 1. WIDGET UTAMA APLIKASI
// ====================================================================

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Nav Demo',
      // Menerapkan Material 3 (Spesifikasi 4)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Mendefinisikan rute (opsional, tapi disarankan untuk aplikasi besar)
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(),
      },
      // Halaman fallback
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const NotFoundScreen());
      },
    );
  }
}

// ====================================================================
// 2. HOMESCREEN (MENGGUNAKAN BOTTOMNAVIGATIONBAR) (Spesifikasi 3)
// ====================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan di BottomNavigationBar
  final List<Widget> _widgetOptions = <Widget>[
    const TabOneScreen(),
    const TabTwoScreen(),
    // Catatan: HomeScreen, DetailScreen, TabOneScreen/TabTwoScreen sudah memenuhi min 3 halaman.
    // BottomNavigationBar hanya menangani tampilan di sini.
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigasi Demo Utama (M3)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Halaman Tab 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Halaman Tab 2',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ====================================================================
// 3. TAB 1 SCREEN (MENUNJUKKAN NAVIGATOR.PUSH()) (Spesifikasi 2)
// ====================================================================

class TabOneScreen extends StatelessWidget {
  const TabOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Halaman Tab 1',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ini adalah halaman pertama dalam Bottom Navigation Bar.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Menavigasi ke DetailScreen menggunakan push()
              // Ini akan menempatkan DetailScreen di atas TabOneScreen
              Navigator.pushNamed(context, '/detail');
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Ke Halaman Detail'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// 4. TAB 2 SCREEN
// ====================================================================

class TabTwoScreen extends StatelessWidget {
  const TabTwoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.settings_suggest, size: 80, color: Colors.blueGrey),
          SizedBox(height: 20),
          Text(
            'Halaman Tab 2',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Ini adalah halaman kedua dalam Bottom Navigation Bar. Tidak ada navigasi dari sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// 5. DETAIL SCREEN (MENUNJUKKAN NAVIGATOR.POP()) (Spesifikasi 2)
// ====================================================================

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Detail'),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.info, size: 80, color: Color.fromARGB(255, 70, 0, 150)),
              const SizedBox(height: 20),
              const Text(
                'DetailScreen',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 150, 82, 0)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Halaman ini didorong (pushed) di atas Halaman Tab 1.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              // Tombol untuk kembali menggunakan Navigator.pop()
              FilledButton.icon(
                onPressed: () {
                  // Kembali ke halaman sebelumnya (Halaman Tab 1)
                  // Pop akan menghapus halaman ini dari tumpukan navigasi.
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali (Navigator.pop())'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// 6. HALAMAN TAMBAHAN (Halaman Minimal 3 sudah terpenuhi: Home/Tab1/Detail)
// ====================================================================

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Tidak Ditemukan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              '404 - Halaman Tidak Ditemukan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                // Kembali ke rute utama
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}
