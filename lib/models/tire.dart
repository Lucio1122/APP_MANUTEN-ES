class Tire {
  Tire({
    required this.id,
    required this.brand,
    required this.model,
    required this.measure,
    required this.purchaseDate,
    required this.installationMileage,
    required this.value,
    required this.position,
    required this.observations,
  });

  final String id;
  final String brand;
  final String model;
  final String measure;
  final DateTime purchaseDate;
  final int installationMileage;
  final double value;
  final String position;
  final String observations;

  factory Tire.fromJson(Map<String, dynamic> json) {
    return Tire(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      measure: json['measure'] ?? '',
      purchaseDate: DateTime.tryParse(json['purchaseDate'] ?? '') ?? DateTime.now(),
      installationMileage: (json['installationMileage'] ?? 0) as int,
      value: (json['value'] ?? 0).toDouble(),
      position: json['position'] ?? 'Dianteiro esquerdo',
      observations: json['observations'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'measure': measure,
      'purchaseDate': purchaseDate.toIso8601String(),
      'installationMileage': installationMileage,
      'value': value,
      'position': position,
      'observations': observations,
    };
  }
}
