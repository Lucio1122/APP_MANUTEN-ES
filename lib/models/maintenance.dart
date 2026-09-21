class Maintenance {
  Maintenance({
    required this.id,
    this.carId,
    required this.type,
    required this.description,
    required this.date,
    required this.odometer,
    required this.workshop,
    required this.partsUsed,
    required this.value,
    required this.notes,
  });

  final String id;
  final String? carId;
  final String type;
  final String description;
  final DateTime date;
  final int odometer;
  final String workshop;
  final String partsUsed;
  final double value;

  double get totalValue => value;
  final String notes;

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      carId: json['carId'] as String?,
      type: json['type'] ?? 'Outros',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      odometer: (json['odometer'] ?? 0) as int,
      workshop: json['workshop'] ?? '',
      partsUsed: json['partsUsed'] ?? '',
      value: (json['value'] ?? json['totalValue'] ?? ((json['laborValue'] ?? 0) + (json['partsValue'] ?? 0))).toDouble(),
      notes: json['notes'] ?? '',
    );
  }

  factory Maintenance.fromMap(Map<String, dynamic> map, String id) {
    DateTime readDate(dynamic value) => value is DateTime
        ? value
        : value is String
            ? DateTime.tryParse(value) ?? DateTime.now()
            : value?.toDate() ?? DateTime.now();

    return Maintenance(
      id: id,
      carId: map['carId'] as String?,
      type: map['type'] ?? 'Outros',
      description: map['description'] ?? '',
      date: readDate(map['date']),
      odometer: (map['odometer'] ?? 0) as int,
      workshop: map['workshop'] ?? '',
      partsUsed: map['partsUsed'] ?? '',
      value: (map['value'] ?? map['totalValue'] ?? ((map['laborValue'] ?? 0) + (map['partsValue'] ?? 0))).toDouble(),
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
      'carId': carId,
        'type': type,
        'description': description,
        'date': date,
        'odometer': odometer,
        'workshop': workshop,
        'partsUsed': partsUsed,
        'value': value,
        'notes': notes,
      };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'workshop': workshop,
      'partsUsed': partsUsed,
      'value': value,
      'notes': notes,
    };
  }
}
