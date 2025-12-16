import 'package:flutter/material.dart';
import '../models/dosen.dart';
import 'dosen_detail_page.dart';

class DosenListPage extends StatelessWidget {
  final List<Dosen> dosenList = [
    Dosen(
      nama: "Wahyu Anggoro, M.Kom",
      nip: "1571082309960021",
      mk: "dosen mata kuliah manajemen resiko",
      email: "WahyuAnggoro@uinjambi.ac.id",
      foto: "assets/images/dosen.jpg",
    ),
    Dosen(
      nama: "POL METRA, M.Kom",
      nip: "19910615010122045",
      mk: "dosen mata kuliah Multimedia",
      email: "POLMETRA@uinjambi.ac.id",
      foto: "assets/images/dosen.jpg",
    ),
    Dosen(
      nama: "AHMAD NASUKHA, S.Hum., M.S.I",
      nip: "1988072220171009",
      mk: "dosen mata kuliah Pemrograman Mobile",
      email: "AHMADNASUKHA@uinjambi.ac.id",
      foto: "assets/images/dosen.jpg",
    ),
    Dosen(
      nama: "DILA NURLAILA, M.Kom",
      nip: "1571015201960020",
      mk: "dosen mata kuliah Rekayasa Perangkat Lunak",
      email: "DILANURLAILA@uinjambi.ac.id",
      foto: "assets/images/dosen2.jpg",
    ),
    Dosen(
      nama: "M. YUSUF, S.Kom., M.S.I",
      nip: "1988021420191007",
      mk: "dosen mata kuliah Technopreneurship",
      email: "MYUSUF@uinjambi.ac.id",
      foto: "assets/images/dosen.jpg",
    ),
    Dosen(
      nama: "Fatima Felawati, S.Kom.,M.Kom",
      nip: "19930511 202505 2 004",
      mk: "dosen mata kuliah Testing dan Implementasi System",
      email: "FatimaFelawati@uinjambi.ac.id",
      foto: "assets/images/dosen2.jpg",
    ),
  ];

  DosenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      appBar: AppBar(
        title: const Text(
          "Daftar Dosen",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A6EA5),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: dosenList.length,
          itemBuilder: (context, index) {
            final dosen = dosenList[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(dosen.foto),
                ),
                title: Text(
                  dosen.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  dosen.mk,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DosenDetailPage(dosen: dosen),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
