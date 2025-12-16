import 'package:flutter/material.dart';
import 'activity_model.dart';

class ActivityDetailPage extends StatelessWidget {
  final ActivityModel activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Aktivitas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Kategori: ${activity.category}'),
            const SizedBox(height: 4),
            Text('Durasi: ${activity.durationHours} jam'),
            const SizedBox(height: 4),
            Text('Status: ${activity.isDone ? 'Selesai' : 'Belum'}'),
            const SizedBox(height: 12),
            if (activity.notes != null && activity.notes!.isNotEmpty)
              Text('Catatan: ${activity.notes}'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Hapus Aktivitas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Aktivitas'),
                          content: const Text('Yakin ingin menghapus aktivitas ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        // return true ke halaman sebelumnya sebagai perintah delete
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
