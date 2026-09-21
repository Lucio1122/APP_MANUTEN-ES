class VehicleDocument {
  VehicleDocument({
    required this.id,
    this.carId,
    required this.type,
    required this.dueDate,
    required this.value,
    required this.status,
    required this.notes,
    this.description = '',
    this.number = '',
    this.issueDate,
  });

  final String id;
  final String? carId;
  final String type;
  final DateTime dueDate;
  final double value;
  final String status;
  final String notes;
  final String description;
  final String number;
  final DateTime? issueDate;

  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      carId: json['carId'] as String?,
      type: json['type'] ?? 'Outros documentos',
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      value: (json['value'] ?? 0).toDouble(),
      status: json['status'] ?? 'Em dia',
      notes: json['notes'] ?? '',
      description: json['description'] ?? '',
      number: json['number'] ?? '',
    );
  }

  factory VehicleDocument.fromMap(Map<String, dynamic> map, String id) {
    DateTime? readDate(dynamic value) => value == null ? null : value is String ? DateTime.tryParse(value) : value.toDate();
    return VehicleDocument(
      id: id,
      carId: map['carId'] as String?,
      type: map['type'] ?? 'Outro',
      dueDate: readDate(map['dueDate']) ?? DateTime.now(),
      value: (map['value'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pendente',
      notes: map['notes'] ?? '',
      description: map['description'] ?? '',
      number: map['number'] ?? '',
      issueDate: readDate(map['issueDate']),
    );
  }

  Map<String, dynamic> toMap() => {
      'carId': carId,
        'type': type,
        'description': description,
        'number': number,
        'issueDate': issueDate,
        'dueDate': dueDate,
        'value': value,
        'status': status,
        'notes': notes,
      };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'dueDate': dueDate.toIso8601String(),
      'value': value,
      'status': status,
      'notes': notes,
    };
  }
}
