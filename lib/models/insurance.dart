class Insurance {
  Insurance({
    required this.id,
    required this.insurer,
    required this.policyNumber,
    required this.startDate,
    required this.expirationDate,
    required this.value,
    required this.broker,
    required this.phone,
    required this.observations,
  });

  final String id;
  final String insurer;
  final String policyNumber;
  final DateTime startDate;
  final DateTime expirationDate;
  final double value;
  final String broker;
  final String phone;
  final String observations;

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      insurer: json['insurer'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      expirationDate: DateTime.tryParse(json['expirationDate'] ?? '') ?? DateTime.now(),
      value: (json['value'] ?? 0).toDouble(),
      broker: json['broker'] ?? '',
      phone: json['phone'] ?? '',
      observations: json['observations'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insurer': insurer,
      'policyNumber': policyNumber,
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'value': value,
      'broker': broker,
      'phone': phone,
      'observations': observations,
    };
  }
}
