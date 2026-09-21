import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/maintenance.dart';
import '../services/car_service.dart';
import '../services/maintenance_service.dart';
import '../services/storage_service.dart';
import 'no_car_screen.dart' as vehicle;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.cars, required this.onRefresh});

  final List<Car> cars;
  final VoidCallback onRefresh;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Maintenance> _maintenances = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Maintenance> maint = [];
    final currentCar = widget.cars.isNotEmpty ? widget.cars.first : null;
    try {
      if (currentCar?.id != null) {
        maint = await MaintenanceService.getMaintenances(currentCar!.id!);
      } else {
        throw Exception();
      }
    } catch (_) {
      maint = await StorageService.getMaintenances();
    }

    if (!mounted) return;
    setState(() {
      _maintenances = maint;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final vehicles = widget.cars;

    return Scaffold(
      appBar: AppBar(
  title: RichText(
    text: const TextSpan(
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(
          text: 'Auto',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        TextSpan(
          text: 'Hub',
          style: TextStyle(
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    ),
  ),
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('Visão geral', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: _openCarForm, icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Veículos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (vehicles.isEmpty)
            _emptyVehicleState()
          else
            ...vehicles.map(_vehicleCard),
          
        
          const SizedBox(height: 20),
          const Text('Última manutenção', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (_maintenances.isEmpty)
            const Card(child: ListTile(title: Text('Ainda não há manutenções cadastradas')))
          else
            Builder(builder: (context) {
              final latest = _maintenances.reduce((current, item) => item.date.isAfter(current.date) ? item : current);
              return Card(
                child: ListTile(
                  title: Text(latest.description.isEmpty ? latest.type : latest.description),
                  subtitle: Text('${_formatDate(latest.date)} • ${latest.type} • ${latest.odometer} km'),
                  trailing: Text('R\$ ${latest.totalValue.toStringAsFixed(2).replaceAll('.', ',')}'),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _openCarForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const vehicle.CarFormScreen()),
    );
    if (result == true) widget.onRefresh();
  }

  Widget _emptyVehicleState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined, size: 52, color: Color(0xFF1976D2)),
            const SizedBox(height: 12),
            const Text('Você ainda não possui um carro cadastrado.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _openCarForm, icon: const Icon(Icons.add), label: const Text('Adicionar meu carro')),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard(Car car) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 17, 82, 129),
                      borderRadius: BorderRadius.circular(16),
                      image: car.hasPhoto
                          ? DecorationImage(image: MemoryImage(base64Decode(car.photoBase64!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: !car.hasPhoto ? const Icon(Icons.directions_car, size: 34, color: Color(0xFF1976D2)) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${car.brand} ${car.model}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Ano: ${car.year}'),
                        Text('Placa: ${car.plate.toUpperCase()}'),
                        Text('Quilometragem: ${_formatNumber(car.currentMileage)} km'),
                        Text('Combustível: ${car.fuelType.isEmpty ? 'Não informado' : car.fuelType}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showCarDetails(car),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Ver informações do carro'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                  ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openEditCar(car),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    ),
                  
                  OutlinedButton.icon(
                    onPressed: () => _deleteCar(car),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditCar(Car car) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => vehicle.CarFormScreen(car: car)),
    );
    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veículo atualizado com sucesso.')));
      }
      widget.onRefresh();
    }
  }

  Future<void> _deleteCar(Car car) async {
    if (car.id == null || car.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veículo sem identificador para exclusão.')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir veículo?'),
        content: const Text('Tem certeza que deseja excluir este veículo? Essa ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await CarService.deleteCar(car.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veículo excluído com sucesso.')));
      }
      widget.onRefresh();
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
      }
    }
  }

  void _showCarDetails(Car car) {
    final fields = [
      _DetailRow('Marca', car.brand),
      _DetailRow('Modelo', car.model),
      _DetailRow('Versão', car.version),
      _DetailRow('Ano', car.year.toString()),
      _DetailRow('Ano modelo', car.modelYear.toString()),
      _DetailRow('Placa', car.plate),
      _DetailRow('Chassi', car.chassis),
      _DetailRow('Cor', car.color),
      _DetailRow('Quilometragem', '${_formatNumber(car.currentMileage)} km'),
      _DetailRow('Combustível', car.fuelType),
      _DetailRow('Potência', car.power),
      _DetailRow('Cilindrada', car.displacement),
      _DetailRow('Data de compra', _formatDate(car.purchaseDate)),
      _DetailRow('Observações', car.observations),
    ];

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Informações do carro'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${field.label}: ${field.value}', style: const TextStyle(height: 1.5)),
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }


  String _formatNumber(int value) => value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _DetailRow {
  _DetailRow(this.label, String? value)
    : value = value == null || value.trim().isEmpty ? 'Não informado' : value;

  final String label;
  final String value;
}

