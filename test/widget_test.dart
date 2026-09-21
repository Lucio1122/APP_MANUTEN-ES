import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:autocare/main.dart';
import 'package:autocare/models/car.dart';

void main() {
  testWidgets('App starts at login when user is not authenticated', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AutoHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Olá!'), findsOneWidget);
  });

  test('Car map conversion supports compatibility fields for vehicle data', () {
    final car = Car.fromMap({
      'marca': 'Hyundai',
      'modelo': 'Tucson',
      'versao': 'GLS',
      'ano': 2020,
      'anoModelo': 2020,
      'placa': 'FEG54EHY65',
      'chassi': 'XXXXXXXX',
      'cor': 'Prata',
      'quilometragem': 470002,
      'combustivel': 'Gasolina',
      'potencia': '140 cv',
      'cilindrada': '2.0',
      'dataCompra': '2024-03-15T00:00:00.000',
      'observacoes': 'Veículo utilizado diariamente.',
    });

    expect(car.brand, 'Hyundai');
    expect(car.model, 'Tucson');
    expect(car.version, 'GLS');
    expect(car.toMap()['marca'], 'Hyundai');
    expect(car.toMap()['placa'], 'FEG54EHY65');
  });
}
