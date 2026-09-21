import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/maintenance.dart';

class MaintenanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _collection(String carId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return _firestore.collection('users').doc(uid).collection('cars').doc(carId).collection('maintenances');
  }

  static Stream<List<Maintenance>> watchMaintenances(String carId) => _collection(carId).orderBy('date', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Maintenance.fromMap(doc.data(), doc.id)).toList());

  static Future<List<Maintenance>> getMaintenances(String carId) async {
    try {
      final snapshot = await _collection(carId).orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => Maintenance.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      throw Exception('Não foi possível carregar as manutenções.');
    }
  }

  static Future<String> createMaintenance(String carId, Maintenance maintenance) async {
    try {
      final reference = _collection(carId).doc();
      await reference.set({...maintenance.toMap(), 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      return reference.id;
    } catch (_) {
      throw Exception('Não foi possível salvar a manutenção.');
    }
  }

  static Future<void> updateMaintenance(String carId, Maintenance maintenance) async {
    try {
      await _collection(carId).doc(maintenance.id).update({...maintenance.toMap(), 'updatedAt': FieldValue.serverTimestamp()});
    } catch (_) {
      throw Exception('Não foi possível atualizar a manutenção.');
    }
  }

  static Future<void> deleteMaintenance(String carId, String maintenanceId) async {
    try {
      await _collection(carId).doc(maintenanceId).delete();
    } catch (_) {
      throw Exception('Não foi possível excluir a manutenção.');
    }
  }
}
