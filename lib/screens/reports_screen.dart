import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.carId});

  // Pode receber um carro específico quando necessário.
  // Quando for null, o relatório considera todos os carros do usuário.
  final String? carId;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _maintenanceTotal = 0;
  double _expenseTotal = 0;
  double _documentTotal = 0;

  bool _loading = true;
  String? _error;

  double get _generalTotal =>
      _maintenanceTotal + _expenseTotal + _documentTotal;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = AuthService.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final firestore = FirebaseFirestore.instance;

      final carsReference = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cars');

      double maintenanceTotal = 0;
      double expenseTotal = 0;
      double documentTotal = 0;

      List<DocumentSnapshot<Map<String, dynamic>>> cars;

      if (widget.carId != null) {
        final car = await carsReference.doc(widget.carId).get();

        if (car.exists) {
          cars = [car];
        } else {
          cars = [];
        }
      } else {
        final carsSnapshot = await carsReference.get();
        cars = carsSnapshot.docs;
      }

      for (final car in cars) {
        final carReference = car.reference;

        // ==========================================
        // MANUTENÇÕES
        // ==========================================

        final maintenanceSnapshot =
            await carReference.collection('maintenances').get();

        for (final maintenance in maintenanceSnapshot.docs) {
  final data = maintenance.data();

  maintenanceTotal += _getValue(
    data['value'],
  );
}

        // ==========================================
        // GASTOS
        // ==========================================

        final expenseSnapshot =
            await carReference.collection('payments').get();

        for (final expense in expenseSnapshot.docs) {
  final data = expense.data();

  expenseTotal += _getValue(
    data['value'],
  );
}

        // ==========================================
        // DOCUMENTOS
        // ==========================================

        final documentSnapshot =
            await carReference.collection('documents').get();

        for (final document in documentSnapshot.docs) {
  final data = document.data();

  documentTotal += _getValue(data['value']);
}
      }

      if (!mounted) return;

      setState(() {
        _maintenanceTotal = maintenanceTotal;
        _expenseTotal = expenseTotal;
        _documentTotal = documentTotal;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double _getValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      String text = value.trim();

      text = text.replaceAll('R\$', '');
      text = text.replaceAll(' ', '');

      // Trata valores no formato brasileiro:
      // 1.250,50 -> 1250.50
      if (text.contains(',')) {
        text = text.replaceAll('.', '');
        text = text.replaceAll(',', '.');
      }

      return double.tryParse(text) ?? 0;
    }

    return 0;
  }

  String _currency(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');

    String integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      final positionFromEnd = integerPart.length - i;

      buffer.write(integerPart[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'R\$ ${buffer.toString()},$decimalPart';
  }

  Widget _reportCard({
    required IconData icon,
    required String title,
    required double value,
    bool highlight = false,
  }) {
    return Card(
      elevation: highlight ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1976D2),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: highlight ? 17 : 15,
                      fontWeight: highlight
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _currency(value),
                    style: TextStyle(
                      fontSize: highlight ? 25 : 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 56,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Não foi possível carregar o relatório.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _loadReport,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReport,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Resumo financeiro',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Valores registrados em todos os seus carros.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _reportCard(
                        icon: Icons.build_outlined,
                        title: 'Manutenções',
                        value: _maintenanceTotal,
                      ),

                      const SizedBox(height: 12),

                      _reportCard(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Gastos',
                        value: _expenseTotal,
                      ),

                      const SizedBox(height: 12),

                      _reportCard(
                        icon: Icons.description_outlined,
                        title: 'Documentos',
                        value: _documentTotal,
                      ),

                      const SizedBox(height: 20),

                      _reportCard(
                        icon: Icons.calculate_outlined,
                        title: 'TOTAL GERAL',
                        value: _generalTotal,
                        highlight: true,
                      ),
                    ],
                  ),
                ),
    );
  }
}