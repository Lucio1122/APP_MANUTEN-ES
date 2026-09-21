import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/car.dart';
import '../services/car_service.dart';
import '../services/storage_service.dart';

class NoCarScreen extends StatelessWidget {
  const NoCarScreen({super.key, required this.onSaved});

  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_rounded, size: 52, color: Color(0xFF1976D2)),
              const SizedBox(height: 20),
              const Text(
                'Você ainda não cadastrou nenhum veículo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CarFormScreen()),
                    );
                    if (result == true) onSaved();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar meu carro'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarFormScreen extends StatefulWidget {
  const CarFormScreen({super.key, this.car});

  final Car? car;

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _versionController;
  late final TextEditingController _yearController;
  late final TextEditingController _modelYearController;
  late final TextEditingController _plateController;
  late final TextEditingController _chassisController;
  late final TextEditingController _colorController;
  late final TextEditingController _mileageController;
  late final TextEditingController _powerController;
  late final TextEditingController _displacementController;
  late final TextEditingController _observationsController;

  String _fuelType = 'Gasolina';
  DateTime _purchaseDate = DateTime.now();
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    final car = widget.car ?? Car.empty();
    _brandController = TextEditingController(text: car.brand);
    _modelController = TextEditingController(text: car.model);
    _versionController = TextEditingController(text: car.version);
    _yearController = TextEditingController(text: car.year.toString());
    _modelYearController = TextEditingController(text: car.modelYear.toString());
    _plateController = TextEditingController(text: car.plate);
    _chassisController = TextEditingController(text: car.chassis ?? '');
    _colorController = TextEditingController(text: car.color);
    _mileageController = TextEditingController(text: car.currentMileage.toString());
    _powerController = TextEditingController(text: car.power);
    _displacementController = TextEditingController(text: car.displacement);
    _observationsController = TextEditingController(text: car.observations);
    _fuelType = car.fuelType.isEmpty ? 'Gasolina' : car.fuelType;
    _purchaseDate = car.purchaseDate;
    _photoBase64 = car.photoBase64;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _versionController.dispose();
    _yearController.dispose();
    _modelYearController.dispose();
    _plateController.dispose();
    _chassisController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    _powerController.dispose();
    _displacementController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _photoBase64 = base64Encode(bytes);
    });
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final car = Car(
      id: widget.car?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      version: _versionController.text.trim(),
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      modelYear: int.tryParse(_modelYearController.text) ?? DateTime.now().year,
      plate: _plateController.text.trim(),
      chassis: _chassisController.text.trim().isEmpty ? null : _chassisController.text.trim(),
      color: _colorController.text.trim(),
      currentMileage: int.tryParse(_mileageController.text) ?? 0,
      fuelType: _fuelType,
      power: _powerController.text.trim(),
      displacement: _displacementController.text.trim(),
      purchaseDate: _purchaseDate,
      observations: _observationsController.text.trim(),
      photoBase64: _photoBase64,
    );

    try {
      if (widget.car == null) {
        final id = await CarService.addCar(car);
        await StorageService.saveCar(Car.fromJson({...car.toJson(), 'id': id}));
      } else {
        await CarService.updateCar(car);
        await StorageService.saveCar(car);
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.car == null ? 'Cadastrar veículo' : 'Editar veículo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  image: _photoBase64 != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_photoBase64!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoBase64 == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 36),
                            Text('Adicionar foto do carro'),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _field('Marca', _brandController),
            _field('Modelo', _modelController),
            _field('Versão', _versionController),
            Row(
              children: [
                Expanded(child: _field('Ano', _yearController, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _field('Ano modelo', _modelYearController, keyboardType: TextInputType.number)),
              ],
            ),
            _field('Placa', _plateController),
            _field('Chassi', _chassisController, required: false),
            _field('Cor', _colorController),
            Row(
              children: [
                Expanded(child: _field('Quilometragem', _mileageController, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _fuelType,
                    decoration: const InputDecoration(labelText: 'Combustível'),
                    items: const ['Gasolina', 'Etanol', 'Diesel', 'Flex', 'Elétrico', 'Híbrido', 'Outro']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _fuelType = value ?? 'Gasolina'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field('Potência', _powerController)),
                const SizedBox(width: 12),
                Expanded(child: _field('Cilindrada', _displacementController)),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de compra'),
              subtitle: Text('${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _purchaseDate = picked);
              },
            ),
            _field('Observações', _observationsController, maxLines: 3, required: false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCar,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Salvar veículo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (!required || label == 'Observações') return null;
          if (value == null || value.trim().isEmpty) {
            return 'Informe $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
