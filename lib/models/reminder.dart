class Reminder {
  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.odometer,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int odometer;
  final String status;

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      odometer: (json['odometer'] ?? 0) as int,
      status: json['status'] ?? 'Ativo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'status': status,
    };
  }
}
