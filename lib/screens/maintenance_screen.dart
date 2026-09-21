import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/maintenance.dart';
import '../services/maintenance_service.dart';

const _maintenanceTypes = [
  'Troca de óleo',
  'Filtros',
  'Freios',
  'Suspensão',
  'Pneus',
  'Motor',
  'Câmbio',
  'Elétrica',
  'Ar-condicionado',
  'Revisão',
  'Alinhamento',
  'Balanceamento',
  'Outro',
];

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({
    super.key,
    required this.carId,
    required this.cars,
    required this.onRefresh,
  });

  final String? carId;
  final List<Car> cars;
  final VoidCallback onRefresh;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  late Future<List<Maintenance>> _maintenancesFuture;

  @override
  void initState() {
    super.initState();
    _loadMaintenances();
  }

  void _loadMaintenances() {
    final carIds = widget.cars
        .where((car) => car.id != null && car.id!.isNotEmpty)
        .map((car) => car.id!)
        .toList();

    _maintenancesFuture = _getAllMaintenances(carIds);
  }

  Future<List<Maintenance>> _getAllMaintenances(
    List<String> carIds,
  ) async {
    final results = <Maintenance>[];

    for (final carId in carIds) {
      final items = await MaintenanceService.getMaintenances(carId);
      results.addAll(items);
    }

    results.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return results;
  }

  Future<void> _refreshScreen() async {
    setState(() {
      _loadMaintenances();
    });

    await _maintenancesFuture;
  }

  String _carName(String? carId) {
    if (carId == null) return 'Carro não informado';

    for (final car in widget.cars) {
      if (car.id == carId) {
        return car.displayName;
      }
    }

    return 'Carro não encontrado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manutenções'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshScreen,
        child: FutureBuilder<List<Maintenance>>(
          future: _maintenancesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: Text(
                      'Não foi possível carregar as manutenções.',
                    ),
                  ),
                ],
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final items = snapshot.data!;

            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: Text(
                      'Nenhuma manutenção cadastrada.',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.build_outlined),
                    ),
                    title: Text(
                      item.description.isEmpty
                          ? item.type
                          : item.description,
                    ),
                    subtitle: Text(
                      '${_carName(item.carId)}\n'
                      '${item.type} • ${_formatDate(item.date)} • '
                      '${item.odometer} km\n'
                      '${item.workshop.isEmpty ? 'Oficina não informada' : item.workshop}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _openForm(context, item);
                        }

                        if (action == 'delete') {
                          _delete(context, item);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Excluir'),
                        ),
                      ],
                    ),
                    onTap: () => _showDetails(context, item),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Manutenção'),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, [
    Maintenance? item,
  ]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MaintenanceFormScreen(
          carId: widget.carId ??
              (widget.cars.isNotEmpty
                  ? widget.cars.first.id!
                  : ''),
          cars: widget.cars,
          item: item,
        ),
      ),
    );

    if (saved == true && context.mounted) {
      await _refreshScreen();

      widget.onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item == null
                  ? 'Manutenção cadastrada com sucesso.'
                  : 'Manutenção atualizada com sucesso.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    Maintenance item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir manutenção?'),
        content: const Text(
          'Tem certeza que deseja excluir esta manutenção? '
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    if (item.carId == null || item.carId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o carro.'),
        ),
      );
      return;
    }

    try {
      await MaintenanceService.deleteMaintenance(
        item.carId!,
        item.id,
      );

      await _refreshScreen();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Manutenção excluída com sucesso.',
            ),
          ),
        );
      }
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
      }
    }
  }

  void _showDetails(
    BuildContext context,
    Maintenance item,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          item.description.isEmpty
              ? item.type
              : item.description,
        ),
        content: Text(
          'Carro: ${_carName(item.carId)}\n'
          'Tipo: ${item.type}\n'
          'Data: ${_formatDate(item.date)}\n'
          'Quilometragem: ${item.odometer} km\n'
          'Valor: ${_money(item.value)}\n'
          'Oficina: ${item.workshop}\n'
          'Peças: ${item.partsUsed}\n'
          'Observações: ${item.notes}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({
    super.key,
    required this.carId,
    required this.cars,
    this.item,
  });

  final String carId;
  final List<Car> cars;
  final Maintenance? item;

  @override
  State<MaintenanceFormScreen> createState() =>
      _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState
    extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _description;
  late final TextEditingController _workshop;
  late final TextEditingController _odometer;
  late final TextEditingController _parts;
  late final TextEditingController _value;
  late final TextEditingController _notes;

  late String _type;

  String? _selectedCarId;

  late DateTime _date;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _selectedCarId =
        item?.carId ?? widget.carId;

    _type =
        item?.type ?? _maintenanceTypes.first;

    _date =
        item?.date ?? DateTime.now();

    _description =
        TextEditingController(
      text: item?.description ?? '',
    );

    _workshop =
        TextEditingController(
      text: item?.workshop ?? '',
    );

    _odometer =
        TextEditingController(
      text: item?.odometer.toString() ?? '',
    );

    _parts =
        TextEditingController(
      text: item?.partsUsed ?? '',
    );

    _value =
        TextEditingController(
      text: item?.value.toString() ?? '',
    );

    _notes =
        TextEditingController(
      text: item?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _workshop.dispose();
    _odometer.dispose();
    _parts.dispose();
    _value.dispose();
    _notes.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCarId == null ||
        _selectedCarId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um carro antes de salvar.',
          ),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ??
        false)) {
      return;
    }

    setState(() => _saving = true);

    final item = Maintenance(
      id: widget.item?.id ?? '',
      carId: _selectedCarId,
      type: _type,
      description: _description.text.trim(),
      date: _date,
      odometer:
          int.tryParse(_odometer.text) ?? 0,
      workshop: _workshop.text.trim(),
      partsUsed: _parts.text.trim(),
      value: _parseMoney(_value.text),
      notes: _notes.text.trim(),
    );

    try {
      if (widget.item == null) {
        await MaintenanceService.createMaintenance(
          _selectedCarId!,
          item,
        );
      } else if (_selectedCarId != widget.carId) {
        await MaintenanceService.createMaintenance(
          _selectedCarId!,
          item,
        );

        await MaintenanceService.deleteMaintenance(
          widget.carId,
          item.id,
        );
      } else {
        await MaintenanceService.updateMaintenance(
          _selectedCarId!,
          item,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null
              ? 'Adicionar manutenção'
              : 'Editar manutenção',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCarId,
              decoration: const InputDecoration(
                labelText: 'Carro',
              ),
              items: widget.cars
                  .where((car) => car.id != null)
                  .map(
                    (car) => DropdownMenuItem(
                      value: car.id,
                      child: Text(
                        car.displayName,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(
                        () => _selectedCarId = value,
                      );
                    },
              validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Selecione um carro antes de salvar.'
                      : null,
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo de manutenção',
              ),
              items: _maintenanceTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(
                        () => _type =
                            value ??
                                _maintenanceTypes.first,
                      );
                    },
            ),

            const SizedBox(height: 12),

            _field(
              _description,
              'Descrição',
              required: true,
            ),

            _field(
              _workshop,
              'Oficina',
            ),

            _field(
              _odometer,
              'Quilometragem',
              keyboardType:
                  TextInputType.number,
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data'),
              subtitle: Text(
                _formatDate(_date),
              ),
              trailing: const Icon(
                Icons.calendar_today,
              ),
              onTap: _saving
                  ? null
                  : () async {
                      final picked =
                          await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate:
                            DateTime(2000),
                        lastDate:
                            DateTime(2100),
                      );

                      if (picked != null) {
                        setState(
                          () => _date = picked,
                        );
                      }
                    },
            ),

            _field(
              _parts,
              'Peças',
            ),

            _field(
              _value,
              'Valor',
              keyboardType:
                  TextInputType.number,
              required: true,
            ),

            _field(
              _notes,
              'Observações',
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () =>
                            Navigator.pop(
                              context,
                            ),
                    child:
                        const Text('Cancelar'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed:
                        _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType =
        TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
        validator: required
            ? (value) =>
                value == null ||
                        value.trim().isEmpty
                    ? 'Informe $label.'
                    : null
            : null,
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

String _money(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

double _parseMoney(String value) =>
    double.tryParse(
      value
          .trim()
          .replaceAll('.', '')
          .replaceAll(',', '.'),
    ) ??
    0;