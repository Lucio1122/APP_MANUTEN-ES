class Car {
  Car({
    this.id,
    required this.brand,
    required this.model,
    required this.version,
    required this.year,
    required this.modelYear,
    required this.plate,
    required this.chassis,
    required this.color,
    required this.currentMileage,
    required this.fuelType,
    required this.power,
    required this.displacement,
    required this.purchaseDate,
    required this.observations,
    this.photoBase64,
  });

  final String? id;
  final String brand;
  final String model;
  final String version;
  final int year;
  final int modelYear;
  final String plate;
  final String? chassis;
  final String color;
  final int currentMileage;
  final String fuelType;
  final String power;
  final String displacement;
  final DateTime purchaseDate;
  final String observations;
  final String? photoBase64;

  factory Car.empty() {
    return Car(
      id: null,
      brand: '',
      model: '',
      version: '',
      year: DateTime.now().year,
      modelYear: DateTime.now().year,
      plate: '',
      chassis: null,
      color: '',
      currentMileage: 0,
      fuelType: 'Gasolina',
      power: '',
      displacement: '',
      purchaseDate: DateTime.now(),
      observations: '',
      photoBase64: null,
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) => Car.fromMap(json, id: json['id'] as String?);

  factory Car.fromMap(Map<String, dynamic> map, {String? id}) {
    String readString(List<String> keys, [String fallback = '']) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) return value.toString();
      }
      return fallback;
    }

    int readInt(List<String> keys, [int fallback = 0]) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        if (value is int) return value;
        if (value is num) return value.toInt();
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final purchaseRaw = map['dataCompra'] ?? map['purchaseDate'];

    return Car(
      id: id ?? map['id'] as String?,
      brand: readString(['marca', 'brand']),
      model: readString(['modelo', 'model']),
      version: readString(['versao', 'version']),
      year: readInt(['ano', 'year'], DateTime.now().year),
      modelYear: readInt(['anoModelo', 'modelYear'], DateTime.now().year),
      plate: readString(['placa', 'plate']).toUpperCase(),
      chassis: map['chassi'] ?? map['chassis'] as String?,
      color: readString(['cor', 'color']),
      currentMileage: readInt(['quilometragem', 'currentMileage'], 0),
      fuelType: readString(['combustivel', 'fuelType'], 'Gasolina'),
      power: readString(['potencia', 'power']),
      displacement: readString(['cilindrada', 'displacement']),
      purchaseDate: DateTime.tryParse(purchaseRaw?.toString() ?? '') ?? DateTime.now(),
      observations: readString(['observacoes', 'observations']),
      photoBase64: map['photoBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'marca': brand,
      'modelo': model,
      'versao': version,
      'ano': year,
      'anoModelo': modelYear,
      'placa': plate,
      'chassi': chassis,
      'cor': color,
      'quilometragem': currentMileage,
      'combustivel': fuelType,
      'potencia': power,
      'cilindrada': displacement,
      'dataCompra': purchaseDate.toIso8601String(),
      'observacoes': observations,
      'photoBase64': photoBase64,
      'id': id,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'id': id,
      'model': model,
      'version': version,
      'year': year,
      'modelYear': modelYear,
      'plate': plate,
      'chassis': chassis,
      'color': color,
      'currentMileage': currentMileage,
      'fuelType': fuelType,
      'power': power,
      'displacement': displacement,
      'purchaseDate': purchaseDate.toIso8601String(),
      'observations': observations,
      'photoBase64': photoBase64,
    };
  }

  bool get hasPhoto => photoBase64 != null && photoBase64!.isNotEmpty;

  String get displayName => '$brand $model';
}
