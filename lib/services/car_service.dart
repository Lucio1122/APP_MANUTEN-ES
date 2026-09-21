import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/car.dart';

class CarService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _cars() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return _firestore.collection('users').doc(uid).collection('cars');
  }

  static Future<List<Car>> getCars() async {
    try {
      final snapshot = await _cars().get();
      return snapshot.docs.map((doc) => Car.fromJson({...doc.data(), 'id': doc.id})).toList();
    } on FirebaseException catch (error) {
      debugPrint('ERRO AO CARREGAR VEÍCULOS: $error');
      debugPrint('Firebase error code: ${error.code}');
      debugPrint('Firebase error message: ${error.message}');
      throw Exception('Não foi possível carregar os veículos.');
    } catch (_) {
      throw Exception('Não foi possível carregar os veículos.');
    }
  }

  static Future<String> addCar(Car car) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Faça login novamente para cadastrar o veículo.');

    try {
      final doc = _firestore.collection('users').doc(uid).collection('cars').doc();
      final data = car.toJson()
        ..remove('id')
        ..removeWhere((key, value) => value == null);
      await doc.set({...data, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      return doc.id;
    } on FirebaseException catch (error) {
      debugPrint('ERRO AO SALVAR VEÍCULO: $error');
      debugPrint('Firebase error code: ${error.code}');
      debugPrint('Firebase error message: ${error.message}');
      throw Exception('Não foi possível salvar o veículo.');
    } catch (_) {
      throw Exception('Não foi possível salvar o veículo.');
    }
  }

  static Future<void> updateCar(Car car) async {
    if (car.id == null || car.id!.isEmpty) throw Exception('Veículo sem identificador.');
    try {
      final data = car.toMap()
        ..remove('id')
        ..removeWhere((key, value) => value == null);
      await _cars().doc(car.id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (error) {
      debugPrint('ERRO AO ATUALIZAR VEÍCULO: $error');
      debugPrint('Firebase error code: ${error.code}');
      debugPrint('Firebase error message: ${error.message}');
      throw Exception('Não foi possível atualizar o veículo.');
    } catch (_) {
      throw Exception('Não foi possível atualizar o veículo.');
    }
  }

  static Future<void> deleteCar(String carId) async {
    try {
      await _cars().doc(carId).delete();
    } on FirebaseException catch (error) {
      debugPrint('ERRO AO EXCLUIR VEÍCULO: $error');
      debugPrint('Firebase error code: ${error.code}');
      debugPrint('Firebase error message: ${error.message}');
      throw Exception('Não foi possível excluir o veículo.');
    } catch (_) {
      throw Exception('Não foi possível excluir o veículo.');
    }
  }
}
