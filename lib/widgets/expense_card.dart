import 'package:flutter/material.dart';

import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F2FD),
          child: const Icon(Icons.payments_outlined, color: Color(0xFF1976D2)),
        ),
        title: Text(expense.description),
        subtitle: Text('${expense.category} • ${_formatDate(expense.date)}'),
        trailing: Text(
          'R\$ ${expense.value.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
