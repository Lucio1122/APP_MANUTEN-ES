import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/document.dart';
import '../services/document_service.dart';

const _documentTypes = <String>[
  'IPVA',
  'Licenciamento',
  'Seguro',
  'Manual',
  'Laudo',
  'Outro',
];

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({
    super.key,
    required this.carId,
    required this.cars,
    required this.onRefresh,
  });

  final String? carId;
  final List<Car> cars;
  final VoidCallback onRefresh;

  @override
  State<DocumentsScreen> createState() =>
      _DocumentsScreenState();
}

class _DocumentsScreenState
    extends State<DocumentsScreen> {
  late Future<List<VehicleDocument>>
      _documentsFuture;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    final carIds = widget.cars
        .where(
          (car) =>
              car.id != null &&
              car.id!.isNotEmpty,
        )
        .map((car) => car.id!)
        .toList();

    _documentsFuture =
        _getAllDocuments(carIds);
  }

  Future<List<VehicleDocument>>
      _getAllDocuments(
    List<String> carIds,
  ) async {
    final results =
        <VehicleDocument>[];

    for (final carId in carIds) {
      final items =
          await DocumentService.getDocuments(
        carId,
      );

      results.addAll(items);
    }

    results.sort(
      (a, b) => b.dueDate.compareTo(a.dueDate),
    );

    return results;
  }

  Future<void> _refreshScreen() async {
    setState(() {
      _loadDocuments();
    });

    await _documentsFuture;
  }

  String _carName(String? carId) {
    if (carId == null) {
      return 'Carro não informado';
    }

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
        title: const Text('Documentos'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshScreen,
        child: FutureBuilder<
            List<VehicleDocument>>(
          future: _documentsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: Text(
                      'Não foi possível carregar os documentos.',
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
                      'Nenhum documento cadastrado.',
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
                      child: Icon(
                        Icons.description_outlined,
                      ),
                    ),
                    title: Text(item.type),
                    subtitle: Text(
                      '${_carName(item.carId)}\n'
                      'Vencimento: '
                      '${_formatDate(item.dueDate)}',
                    ),
                    isThreeLine: true,
                    trailing:
                        PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _openForm(
                            context,
                            item,
                          );
                        }

                        if (action == 'delete') {
                          _delete(
                            context,
                            item,
                          );
                        }
                      },
                      itemBuilder: (_) =>
                          const [
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
                    onTap: () =>
                        _showDetails(
                      context,
                      item,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () =>
            _openForm(context),
        icon: const Icon(Icons.add),
        label:
            const Text('Adicionar Documento'),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, [
    VehicleDocument? item,
  ]) async {
    final saved =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DocumentFormScreen(
          carId: widget.carId ??
              (widget.cars.isNotEmpty
                  ? widget.cars.first.id!
                  : ''),
          cars: widget.cars,
          item: item,
        ),
      ),
    );

    if (saved == true &&
        context.mounted) {
      await _refreshScreen();

      widget.onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              item == null
                  ? 'Documento cadastrado com sucesso.'
                  : 'Documento atualizado com sucesso.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    VehicleDocument item,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Excluir documento?',
        ),
        content: const Text(
          'Tem certeza que deseja excluir este documento?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child:
                const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            child:
                const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    if (item.carId == null ||
        item.carId!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível identificar o carro.',
          ),
        ),
      );
      return;
    }

    try {
      await DocumentService
          .deleteDocument(
        item.carId!,
        item.id,
      );

      await _refreshScreen();

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Documento excluído com sucesso.',
            ),
          ),
        );
      }
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              error
                  .toString()
                  .replaceFirst(
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
    VehicleDocument item,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.type),
        content: Text(
          'Carro: ${_carName(item.carId)}\n'
          'Descrição: ${item.description}\n'
          'Valor: ${_money(item.value)}\n'
          'Emissão: '
          '${item.issueDate == null ? 'Não informada' : _formatDate(item.issueDate!)}\n'
          'Vencimento: ${_formatDate(item.dueDate)}\n'
          'Observações: ${item.notes}',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child:
                const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class DocumentFormScreen
    extends StatefulWidget {
  const DocumentFormScreen({
    super.key,
    required this.carId,
    required this.cars,
    this.item,
  });

  final String carId;
  final List<Car> cars;
  final VehicleDocument? item;

  @override
  State<DocumentFormScreen> createState() =>
      _DocumentFormScreenState();
}

class _DocumentFormScreenState
    extends State<DocumentFormScreen> {
  final _formKey =
      GlobalKey<FormState>();

  late String _type;

  String? _selectedCarId;

  DateTime? _issueDate;
  DateTime? _dueDate;

  late final TextEditingController
      _value;

  late final TextEditingController
      _description;

  late final TextEditingController
      _notes;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _selectedCarId =
        item?.carId ?? widget.carId;

    _type =
        item?.type ?? _documentTypes.first;

    _issueDate =
        item?.issueDate;

    _dueDate =
        item?.dueDate;

    _value =
        TextEditingController(
      text: item?.value.toString() ?? '',
    );

    _description =
        TextEditingController(
      text: item?.description ?? '',
    );

    _notes =
        TextEditingController(
      text: item?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _value.dispose();
    _description.dispose();
    _notes.dispose();

    super.dispose();
  }

  Future<void> _pickDate(
    bool issue,
  ) async {
    final current =
        issue ? _issueDate : _dueDate;

    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          current ?? DateTime.now(),
      firstDate:
          DateTime(2000),
      lastDate:
          DateTime(2100),
    );

    if (picked == null ||
        !mounted) {
      return;
    }

    setState(() {
      if (issue) {
        _issueDate = picked;
      } else {
        _dueDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_selectedCarId == null ||
        _selectedCarId!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um carro antes de salvar.',
          ),
        ),
      );
      return;
    }

    if (!(_formKey.currentState
            ?.validate() ??
        false)) {
      return;
    }

    setState(() => _saving = true);

    final item = VehicleDocument(
      id: widget.item?.id ?? '',
      carId: _selectedCarId,
      type: _type,
      dueDate:
          _dueDate ?? DateTime.now(),
      value: double.tryParse(
            _value.text
                .trim()
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0,
      status: 'Pendente',
      notes: _notes.text.trim(),
      description:
          _description.text.trim(),
      issueDate: _issueDate,
    );

    try {
      if (widget.item == null) {
        await DocumentService
            .createDocument(
          _selectedCarId!,
          item,
        );
      } else if (_selectedCarId !=
          widget.carId) {
        await DocumentService
            .createDocument(
          _selectedCarId!,
          item,
        );

        await DocumentService
            .deleteDocument(
          widget.carId,
          item.id,
        );
      } else {
        await DocumentService
            .updateDocument(
          _selectedCarId!,
          item,
        );
      }

      if (mounted) {
        Navigator.pop(
          context,
          true,
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              error
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _saving = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null
              ? 'Adicionar documento'
              : 'Editar documento',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue:
                  _selectedCarId,
              decoration:
                  const InputDecoration(
                labelText: 'Carro',
              ),
              items: widget.cars
                  .where(
                    (car) =>
                        car.id != null,
                  )
                  .map(
                    (car) =>
                        DropdownMenuItem(
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
                        () =>
                            _selectedCarId =
                                value,
                      );
                    },
              validator: (value) =>
                  value == null ||
                          value.isEmpty
                      ? 'Selecione um carro antes de salvar.'
                      : null,
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration:
                  const InputDecoration(
                labelText:
                    'Tipo do documento',
              ),
              items: _documentTypes
                  .map(
                    (e) =>
                        DropdownMenuItem(
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
                                _documentTypes
                                    .first,
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
              _value,
              'Valor',
              keyboardType:
                  TextInputType.number,
            ),

            _dateTile(
              'Data de emissão',
              _issueDate,
              () => _pickDate(true),
            ),

            _dateTile(
              'Data de vencimento',
              _dueDate,
              () => _pickDate(false),
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
                  child:
                      OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () =>
                            Navigator.pop(
                              context,
                            ),
                    child: const Text(
                      'Cancelar',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed:
                        _saving
                            ? null
                            : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Salvar',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        date == null
            ? 'Não informado'
            : _formatDate(date),
      ),
      trailing: const Icon(
        Icons.calendar_today,
      ),
      onTap:
          _saving ? null : onTap,
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration:
            InputDecoration(
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