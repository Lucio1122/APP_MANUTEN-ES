import 'package:flutter/material.dart';

import '../models/document.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.document});

  final VehicleDocument document;

  @override
  Widget build(BuildContext context) {
    final dueInDays = document.dueDate.difference(DateTime.now()).inDays;
    Color color = Colors.green;
    if (dueInDays <= 30 && dueInDays >= 0) {
      color = const Color(0xFF1976D2);
    }
    if (dueInDays < 0) {
      color = Colors.red;
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.description, color: color),
        ),
        title: Text(document.type),
        subtitle: Text('${_formatDate(document.dueDate)} • ${document.status}'),
        trailing: Text(
          'R\$ ${document.value.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
