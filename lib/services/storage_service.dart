import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car.dart';
import '../models/document.dart';
import '../models/expense.dart';
import '../models/fine.dart';
import '../models/fuel.dart';
import '../models/insurance.dart';
import '../models/maintenance.dart';
import '../models/reminder.dart';
import '../models/tire.dart';

class StorageService {
  static const String _carKey = 'autocare_car';
  static const String _maintenanceKey = 'autocare_maintenances';
  static const String _expensesKey = 'autocare_expenses';
  static const String _fuelsKey = 'autocare_fuels';
  static const String _documentsKey = 'autocare_documents';
  static const String _insuranceKey = 'autocare_insurance';
  static const String _tiresKey = 'autocare_tires';
  static const String _finesKey = 'autocare_fines';
  static const String _remindersKey = 'autocare_reminders';
  static const String _profilePhotoKey = 'autohub_profile_photo';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<void> saveProfilePhoto(String? photoBase64) async {
    final prefs = await _prefs;
    if (photoBase64 == null || photoBase64.isEmpty) {
      await prefs.remove(_profilePhotoKey);
    } else {
      await prefs.setString(_profilePhotoKey, photoBase64);
    }
  }

  static Future<String?> getProfilePhoto() async {
    final prefs = await _prefs;
    return prefs.getString(_profilePhotoKey);
  }

  static Future<void> saveCar(Car car) async {
    final prefs = await _prefs;
    final data = car.id == null
        ? car.toJson()
        : {...car.toJson(), 'id': car.id};
    await prefs.setString(_carKey, jsonEncode(data));
  }

  static Future<Car?> getCar() async {
    final prefs = await _prefs;
    final data = prefs.getString(_carKey);
    if (data == null || data.isEmpty) return null;
    try {
      return Car.fromJson(jsonDecode(data));
    } catch (e) {
      debugPrint('Erro ao ler carro: $e');
      return null;
    }
  }

  static Future<void> saveMaintenances(List<Maintenance> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_maintenanceKey, data);
  }

  static Future<List<Maintenance>> getMaintenances() async {
    final prefs = await _prefs;
    final data = prefs.getString(_maintenanceKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Maintenance.fromJson(e)).toList();
  }

  static Future<void> saveExpenses(List<Expense> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_expensesKey, data);
  }

  static Future<List<Expense>> getExpenses() async {
    final prefs = await _prefs;
    final data = prefs.getString(_expensesKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Expense.fromJson(e)).toList();
  }

  static Future<void> saveFuels(List<Fuel> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_fuelsKey, data);
  }

  static Future<List<Fuel>> getFuels() async {
    final prefs = await _prefs;
    final data = prefs.getString(_fuelsKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Fuel.fromJson(e)).toList();
  }

  static Future<void> saveDocuments(List<VehicleDocument> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_documentsKey, data);
  }

  static Future<List<VehicleDocument>> getDocuments() async {
    final prefs = await _prefs;
    final data = prefs.getString(_documentsKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => VehicleDocument.fromJson(e)).toList();
  }

  static Future<void> saveInsurance(Insurance? insurance) async {
    final prefs = await _prefs;
    if (insurance == null) {
      await prefs.remove(_insuranceKey);
      return;
    }
    await prefs.setString(_insuranceKey, jsonEncode(insurance.toJson()));
  }

  static Future<Insurance?> getInsurance() async {
    final prefs = await _prefs;
    final data = prefs.getString(_insuranceKey);
    if (data == null || data.isEmpty) return null;
    try {
      return Insurance.fromJson(jsonDecode(data));
    } catch (e) {
      debugPrint('Erro ao ler seguro: $e');
      return null;
    }
  }

  static Future<void> saveTires(List<Tire> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_tiresKey, data);
  }

  static Future<List<Tire>> getTires() async {
    final prefs = await _prefs;
    final data = prefs.getString(_tiresKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Tire.fromJson(e)).toList();
  }

  static Future<void> saveFines(List<Fine> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_finesKey, data);
  }

  static Future<List<Fine>> getFines() async {
    final prefs = await _prefs;
    final data = prefs.getString(_finesKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Fine.fromJson(e)).toList();
  }

  static Future<void> saveReminders(List<Reminder> items) async {
    final prefs = await _prefs;
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_remindersKey, data);
  }

  static Future<List<Reminder>> getReminders() async {
    final prefs = await _prefs;
    final data = prefs.getString(_remindersKey);
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Reminder.fromJson(e)).toList();
  }
}
