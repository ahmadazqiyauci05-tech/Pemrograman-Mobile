import 'package:flutter/material.dart';
import 'activity_model.dart';
import 'add_activity_page.dart';
import 'activity_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ActivityModel> _activities = [];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Activity Tracker'),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _activities.isEmpty
            ? _emptyState()
            : isWide
                ? _buildGrid()
                : _buildList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<ActivityModel?>(
            context,
            MaterialPageRoute(builder: (_) => const AddActivityPage()),
          );

          // guard mounted before using context / setState after await
          if (!mounted) return;

          if (result != null) {
            setState(() => _activities.add(result));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aktivitas berhasil ditambahkan')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final a = _activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(child: Icon(_iconForCategory(a.category))),
            title: Text(a.name),
            subtitle: Text('${a.durationHours} jam • ${a.category}'),
            trailing: Icon(a.isDone ? Icons.check_circle : Icons.circle_outlined,
                color: a.isDone ? Colors.green : null),
            onTap: () async {
              final deleted = await Navigator.push<bool?>(
                context,
                MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: a)),
              );

              if (!mounted) return;
              if (deleted == true) {
                setState(() => _activities.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aktivitas dihapus')),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    final cross = MediaQuery.of(context).size.width >= 1000 ? 3 : 2;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisExtent: 110,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final a = _activities[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final deleted = await Navigator.push<bool?>(
                context,
                MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: a)),
              );

              if (!mounted) return;
              if (deleted == true) setState(() => _activities.removeAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(child: Icon(_iconForCategory(a.category))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text('${a.category} • ${a.durationHours} jam', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(label: Text(a.isDone ? 'Selesai' : 'Belum')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    final c = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note, size: 96, color: c.primaryContainer),
          const SizedBox(height: 12),
          Text('Belum ada aktivitas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Tekan tombol tambah untuk menambahkan aktivitas baru.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final result = await Navigator.push<ActivityModel?>(
                context,
                MaterialPageRoute(builder: (_) => const AddActivityPage()),
              );
              if (!mounted) return;
              if (result != null) setState(() => _activities.add(result));
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Aktivitas'),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'belajar':
        return Icons.school;
      case 'ibadah':
        return Icons.self_improvement;
      case 'olahraga':
        return Icons.fitness_center;
      case 'hiburan':
        return Icons.movie;
      default:
        return Icons.task;
    }
  }
}
