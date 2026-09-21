class Fuel {
  Fuel({
    required this.id,
    required this.date,
    required this.station,
    required this.fuelType,
    required this.liters,
    required this.pricePerLiter,
    required this.totalValue,
    required this.odometer,
    required this.observation,
  });

  final String id;
  final DateTime date;
  final String station;
  final String fuelType;
  final double liters;
  final double pricePerLiter;
  final double totalValue;
  final int odometer;
  final String observation;

  factory Fuel.fromJson(Map<String, dynamic> json) {
    return Fuel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      station: json['station'] ?? '',
      fuelType: json['fuelType'] ?? 'Gasolina',
      liters: (json['liters'] ?? 0).toDouble(),
      pricePerLiter: (json['pricePerLiter'] ?? 0).toDouble(),
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      odometer: (json['odometer'] ?? 0) as int,
      observation: json['observation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'station': station,
      'fuelType': fuelType,
      'liters': liters,
      'pricePerLiter': pricePerLiter,
      'totalValue': totalValue,
      'odometer': odometer,
      'observation': observation,
    };
  }
}
