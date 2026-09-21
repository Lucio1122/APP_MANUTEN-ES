import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'reports_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.onRefresh, this.carId});

  final VoidCallback onRefresh;
  final String? carId;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Perfil', 'icon': Icons.person, 'screen': const ProfileScreen()},
      {'label': 'Relatórios', 'icon': Icons.bar_chart, 'screen': ReportsScreen(carId: carId)},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: Icon(item['icon'] as IconData, color: const Color(0xFF1976D2)),
              title: Text(item['label'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget));
              },
            ),
          );
        },
      ),
    );
  }
}
