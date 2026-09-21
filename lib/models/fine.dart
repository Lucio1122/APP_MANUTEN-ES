class Fine {
  Fine({
    required this.id,
    required this.date,
    required this.description,
    required this.location,
    required this.value,
    required this.points,
    required this.status,
    required this.observations,
  });

  final String id;
  final DateTime date;
  final String description;
  final String location;
  final double value;
  final int points;
  final String status;
  final String observations;

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      points: (json['points'] ?? 0) as int,
      status: json['status'] ?? 'Pendente',
      observations: json['observations'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'location': location,
      'value': value,
      'points': points,
      'status': status,
      'observations': observations,
    };
  }
}
