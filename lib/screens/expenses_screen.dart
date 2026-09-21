import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/expense.dart';
import '../services/payment_service.dart';

const _paymentTypes = <String>[
  'Combustível', 'Multa', 'Estacionamento', 'Lavagem', 'Peças', 'Acessórios', 'Outros',
];

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key, required this.carId, required this.cars, required this.onRefresh});
  final String? carId;
  final List<Car> cars;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (carId == null) {
      return Scaffold(appBar: AppBar(title: const Text('Gastos')), body: const Center(child: Text('Selecione um veículo para continuar.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: StreamBuilder<List<Expense>>(
        stream: PaymentService.watchPayments(carId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Não foi possível carregar os gastos.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('Nenhum gasto cadastrado.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Total: ${_money(items.fold<double>(0, (sum, item) => sum + item.value))}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...items.map((item) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
                      title: Text(item.description),
                      subtitle: Text('${item.category} • ${_formatDate(item.date)} • ${item.status}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'edit') _openForm(context, item);
                          if (action == 'delete') _delete(context, item);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        ],
                      ),
                      onTap: () => _showDetails(context, item),
                    ),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('Adicionar Gasto')),
    );
  }

  Future<void> _openForm(BuildContext context, [Expense? item]) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ExpenseFormScreen(carId: carId!, cars: cars, item: item)));
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item == null ? 'Gasto cadastrado com sucesso.' : 'Gasto atualizado com sucesso.')));
      onRefresh();
    }
  }

  Future<void> _delete(BuildContext context, Expense item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir gasto?'),
        content: const Text('Tem certeza que deseja excluir este gasto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await PaymentService.deletePayment(carId!, item.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gasto excluído com sucesso.')));
    } on Exception catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    }
  }

  void _showDetails(BuildContext context, Expense item) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.description),
        content: Text(
  'Tipo: ${item.category}\n'
  'Valor: ${_money(item.value)}\n'
  'Data: ${_formatDate(item.date)}\n'
  'Observações: ${item.observation}',
),


        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
      ),
    );
  }
}

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, required this.carId, required this.cars, this.item});
  final String carId;
  final List<Car> cars;
  final Expense? item;
  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  String? _selectedCarId;
  late DateTime _date;
  late final TextEditingController _description;
  late final TextEditingController _value;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _selectedCarId = item?.carId ?? widget.carId;
    _type = item?.category ?? _paymentTypes.first;
    _date = item?.date ?? DateTime.now();
    _description = TextEditingController(text: item?.description ?? '');
    _value = TextEditingController(text: item?.value.toString() ?? '');
    _notes = TextEditingController(text: item?.observation ?? '');
  }

  @override
  void dispose() {
    _description.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _date,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (picked == null || !mounted) return;

  setState(() {
    _date = picked;
  });
}

  Future<void> _save() async {
    if (_selectedCarId == null || _selectedCarId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um carro antes de salvar.')));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    
    final item = Expense(
  id: widget.item?.id ?? '',
  carId: _selectedCarId,
  category: _type,
  description: _description.text.trim(),
  date: _date,
  value: _parseMoney(_value.text),
  odometer: 0,
  observation: _notes.text.trim(),
  dueDate: null,
  paidDate: null,
  status: 'Pendente',
);
    try {
      if (widget.item == null) {
        await PaymentService.createPayment(_selectedCarId!, item);
      } else if (_selectedCarId != widget.carId) {
        await PaymentService.createPayment(_selectedCarId!, item);
        await PaymentService.deletePayment(widget.carId, item.id);
      } else {
        await PaymentService.updatePayment(_selectedCarId!, item);
      }
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? 'Adicionar gasto' : 'Editar gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCarId,
              decoration: const InputDecoration(labelText: 'Carro'),
              items: widget.cars.where((car) => car.id != null).map((car) => DropdownMenuItem(value: car.id, child: Text(car.displayName))).toList(),
              onChanged: _saving ? null : (value) => setState(() => _selectedCarId = value),
              validator: (value) => value == null || value.isEmpty ? 'Selecione um carro antes de salvar.' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Tipo'), items: _paymentTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: _saving ? null : (value) => setState(() => _type = value ?? _paymentTypes.last)),
            const SizedBox(height: 12),
            _field(_description, 'Descrição', required: true),
            _field(_value, 'Valor', required: true, keyboardType: TextInputType.number),
            _dateTile('Data', _date, _pickDate),
            _field(_notes, 'Observações', maxLines: 3),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: OutlinedButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancelar'))), const SizedBox(width: 12), Expanded(child: FilledButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar')))]),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, VoidCallback onTap) => ListTile(contentPadding: EdgeInsets.zero, title: Text(label), subtitle: Text(date == null ? 'Não informado' : _formatDate(date)), trailing: const Icon(Icons.calendar_today), onTap: _saving ? null : onTap);

  Widget _field(TextEditingController controller, String label, {bool required = false, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (value) {
          if (value == null || value.trim().isEmpty) return 'Informe $label.';
          if (label == 'Valor' && _parseMoney(value) <= 0) return 'Informe um valor válido.';
          return null;
        } : null,
      ),
    );
  }
}

String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
double _parseMoney(String value) => double.tryParse(value.trim().replaceAll('.', '').replaceAll(',', '.')) ?? 0;
