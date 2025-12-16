import 'package:flutter/material.dart';
import 'activity_model.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _category = 'Belajar';
  double _duration = 1;
  bool _isDone = false;

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Nama kosong'),
          content: const Text('Nama aktivitas wajib diisi.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final newActivity = ActivityModel(
      name: name,
      category: _category,
      durationHours: _duration.round(),
      isDone: _isDone,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Aktivitas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Aktivitas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Kategori
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: const [
                DropdownMenuItem(value: 'Belajar', child: Text('Belajar')),
                DropdownMenuItem(value: 'Ibadah', child: Text('Ibadah')),
                DropdownMenuItem(value: 'Olahraga', child: Text('Olahraga')),
                DropdownMenuItem(value: 'Hiburan', child: Text('Hiburan')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'Belajar'),
              decoration: const InputDecoration(labelText: 'Kategori Aktivitas', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // Durasi (Slider.adaptive untuk mengurangi warning)
            Text('Durasi: ${_duration.round()} jam'),
            Slider.adaptive(
              value: _duration,
              min: 1,
              max: 8,
              divisions: 7,
              label: '${_duration.round()} jam',
              onChanged: (v) => setState(() => _duration = v),
            ),
            const SizedBox(height: 12),

            // Status
            SwitchListTile(
              title: const Text('Sudah Selesai'),
              value: _isDone,
              onChanged: (v) => setState(() => _isDone = v),
            ),
            const SizedBox(height: 12),

            // Catatan (multiline)
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan Tambahan (opsional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
