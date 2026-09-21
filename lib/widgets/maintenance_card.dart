import 'package:flutter/material.dart';

import '../models/maintenance.dart';

class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({super.key, required this.maintenance});

  final Maintenance maintenance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.build_outlined, color: Colors.green),
        ),
        title: Text(maintenance.description),
        subtitle: Text('${maintenance.type} • ${_formatDate(maintenance.date)} • ${maintenance.odometer} km'),
        trailing: Text(
          'R\$ ${maintenance.totalValue.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
