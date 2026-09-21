class Expense {
  Expense({
    required this.id,
    this.carId,
    required this.category,
    required this.description,
    required this.date,
    required this.value,
    required this.odometer,
    required this.observation,
    this.dueDate,
    this.paidDate,
    this.status = 'Pendente',
  });

  final String id;
  final String? carId;
  final String category;
  final String description;
  final DateTime date;
  final double value;
  final int odometer;
  final String observation;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String status;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      carId: json['carId'] as String?,
      category: json['category'] ?? 'Outros',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      value: (json['value'] ?? 0).toDouble(),
      odometer: (json['odometer'] ?? 0) as int,
      observation: json['observation'] ?? '',
      status: json['status'] ?? 'Pendente',
    );
  }

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    DateTime readDate(dynamic value) => value is String ? DateTime.tryParse(value) ?? DateTime.now() : value?.toDate() ?? DateTime.now();
    DateTime? readOptionalDate(dynamic value) => value == null ? null : value is String ? DateTime.tryParse(value) : value.toDate();
    return Expense(
      id: id,
      carId: map['carId'] as String?,
      category: map['category'] ?? map['type'] ?? 'Outros',
      description: map['description'] ?? '',
      date: readDate(map['date']),
      value: (map['value'] ?? 0).toDouble(),
      odometer: (map['odometer'] ?? 0) as int,
      observation: map['observation'] ?? map['notes'] ?? '',
      dueDate: readOptionalDate(map['dueDate']),
      paidDate: readOptionalDate(map['paidDate']),
      status: map['status'] ?? 'Pendente',
    );
  }

  Map<String, dynamic> toMap() => {
      'carId': carId,
        'type': category,
        'category': category,
        'description': description,
        'value': value,
        'date': date,
        'dueDate': dueDate,
        'paidDate': paidDate,
        'status': status,
        'odometer': odometer,
        'notes': observation,
      };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'value': value,
      'odometer': odometer,
      'observation': observation,
    };
  }
}
