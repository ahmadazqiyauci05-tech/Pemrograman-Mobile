import 'package:flutter/material.dart';

// --- Main Function ---
void main() {
  runApp(const MyApp());
}

// --- App Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Mahasiswa Validasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MultiStepForm(),
    );
  }
}

// --- Multi-Step Form Widget ---
class MultiStepForm extends StatefulWidget {
  const MultiStepForm({super.key});

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  // State untuk Stepper
  int _currentStep = 0;

  // GlobalKey untuk validasi Form. Kita punya 3 langkah (steps).
  final _formKeys = List.generate(3, (index) => GlobalKey<FormState>());

  // State untuk data form
  String _nama = '';
  String _email = '';
  String _nomorHp = ''; // Dipindahkan ke Step 1
  String? _jurusan;
  double _semester = 1;
  final Map<String, bool> _hobi = {
    'Coding': false,
    'Membaca': false,
    'Olahraga': false,
  };
  bool _setuju = false;

  final List<String> _listJurusan = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Manajemen',
    'Akuntansi'
  ];

  // --- Fungsi Navigasi Stepper ---
  void _lanjut() {
    // Validasi form di langkah saat ini
    if (_formKeys[_currentStep].currentState!.validate()) {
      // Khusus untuk langkah 3, cek validasi kustom (hobi dan persetujuan)
      if (_currentStep == 2) {
        if (!_hobi.containsValue(true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih minimal satu hobi.')),
          );
          return;
        }
        if (!_setuju) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda harus menyetujui syarat dan ketentuan.')),
          );
          return;
        }
      }
      
      _formKeys[_currentStep].currentState!.save();
      
      if (_currentStep < 2) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        // Logika saat form selesai (langkah terakhir)
        _tampilkanRingkasan();
      }
    }
  }

  void _kembali() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _tampilkanRingkasan() {
    final hobiTerpilih = _hobi.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Data Pendaftaran Mahasiswa'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Divider(),
              _buildSummaryText('Nama', _nama),
              _buildSummaryText('Email', _email),
              _buildSummaryText('Nomor HP', _nomorHp), // Tampilkan di sini
              _buildSummaryText('Jurusan', _jurusan ?? 'Belum Dipilih'),
              _buildSummaryText('Semester', _semester.round().toString()),
              _buildSummaryText('Hobi', hobiTerpilih.isEmpty ? 'Tidak Ada' : hobiTerpilih),
              _buildSummaryText('Persetujuan', _setuju ? 'Disetujui' : 'Tidak Disetujui'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentStep = 0; // Reset ke langkah pertama setelah selesai
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '**$label:** $value',
        style: const TextStyle(height: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Daftar Steps (Langkah) pada Stepper ---
  List<Step> _buildSteps() {
    return [
      // STEP 1: Informasi Dasar (Nama, Email, Nomor HP)
      Step(
        title: const Text('1. Data Pribadi'),
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: <Widget>[
              // Field Nama
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _nama = value!,
                initialValue: _nama,
              ),
              // Field Email
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
                initialValue: _email,
              ),
              // Field Nomor HP (DITAMBAHKAN DI SINI)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nomor HP'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP tidak boleh kosong';
                  }
                  if (value.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Nomor HP tidak valid (minimal 10 angka)';
                  }
                  return null;
                },
                onSaved: (value) => _nomorHp = value!,
                initialValue: _nomorHp,
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),

      // STEP 2: Detail Akademik (Jurusan, Semester)
      Step(
        title: const Text('2. Detail Akademik'),
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: <Widget>[
              // Field Jurusan (Dropdown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                value: _jurusan,
                hint: const Text('Pilih Jurusan'),
                items: _listJurusan.map((String jurusan) {
                  return DropdownMenuItem<String>(
                    value: jurusan,
                    child: Text(jurusan),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _jurusan = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Jurusan harus dipilih';
                  }
                  return null;
                },
                onSaved: (value) => _jurusan = value,
              ),
              const SizedBox(height: 20),

              // Field Semester (Slider)
              Row(
                children: [
                  const Text('Semester:'),
                  Expanded(
                    child: Slider(
                      value: _semester,
                      min: 1,
                      max: 8,
                      divisions: 7,
                      label: _semester.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _semester = value;
                        });
                      },
                    ),
                  ),
                  Text(_semester.round().toString()),
                ],
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),

      // STEP 3: Preferensi & Konfirmasi (Hobi, Persetujuan)
      Step(
        title: const Text('3. Preferensi & Konfirmasi'),
        content: Form(
          key: _formKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Field Hobi (CheckboxListTile)
              const Text('Pilih Hobi (Wajib minimal 1):', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._hobi.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _hobi[key],
                  onChanged: (bool? value) {
                    setState(() {
                      _hobi[key] = value!;
                    });
                  },
                );
              }).toList(),
               if (!_hobi.containsValue(true) && _currentStep == 2) 
                   const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 10),
                    child: Text('Pilih minimal satu hobi.', style: TextStyle(color: Colors.red, fontSize: 12)),
                   ),
              
              const SizedBox(height: 10),

              // Field Persetujuan (Switch)
              SwitchListTile(
                title: const Text('Saya menyetujui syarat dan ketentuan (Wajib)'),
                value: _setuju,
                onChanged: (bool value) {
                  setState(() {
                    _setuju = value;
                  });
                },
              ),
              if (!_setuju && _currentStep == 2) 
                   const Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Text('Anda harus menyetujui syarat dan ketentuan.', style: TextStyle(color: Colors.red, fontSize: 12)),
                   ),
              
              const SizedBox(height: 10),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  // --- Metode build utama ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pendaftaran Multi-Step'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        steps: _buildSteps(),
        onStepContinue: _lanjut, 
        onStepCancel: _kembali,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == _buildSteps().length - 1 ? 'KIRIM DATA' : 'LANJUT'),
                ),
                if (_currentStep != 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('KEMBALI'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}