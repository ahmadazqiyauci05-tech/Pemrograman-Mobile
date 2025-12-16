import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Bagian atas (foto + nama + email)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                // Foto profil
                const CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage('assets/images/gambar.jpg'),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Ahmad azqi yauci',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'ahmadazqiyauci@gmail.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Bagian bawah (NIM & Prodi + Logout)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ListView(
                children: [
                  _buildInfoTile(Icons.badge, 'NIM', '701230072'),
                  const SizedBox(height: 10),
                  _buildInfoTile(Icons.school, 'Program Studi', 'Sistem Informasi'),
                  const SizedBox(height: 10),
                  _buildInfoTile(Icons.email, 'Email studi', '701230072@student.uinjambi.ac.id'),

                  const SizedBox(height: 40),

                  // Tombol Logout
                  ElevatedButton.icon(
                    onPressed: () {
                      // Aksi logout kembali ke halaman login
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
