import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _collection(String carId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return _firestore.collection('users').doc(uid).collection('cars').doc(carId).collection('payments');
  }

  static Stream<List<Expense>> watchPayments(String carId) => _collection(carId).orderBy('date', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Expense.fromMap(doc.data(), doc.id)).toList());

  static Future<List<Expense>> getPayments(String carId) async {
    try {
      final snapshot = await _collection(carId).orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => Expense.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      throw Exception('Não foi possível carregar os gastos.');
    }
  }

  static Future<String> createPayment(String carId, Expense payment) async {
    try {
      final reference = _collection(carId).doc();
      await reference.set({...payment.toMap(), 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      return reference.id;
    } catch (_) {
      throw Exception('Não foi possível salvar o gasto.');
    }
  }

  static Future<void> updatePayment(String carId, Expense payment) async {
    try {
      await _collection(carId).doc(payment.id).update({...payment.toMap(), 'updatedAt': FieldValue.serverTimestamp()});
    } catch (_) {
      throw Exception('Não foi possível atualizar o gasto.');
    }
  }

  static Future<void> deletePayment(String carId, String paymentId) async {
    try {
      await _collection(carId).doc(paymentId).delete();
    } catch (_) {
      throw Exception('Não foi possível excluir o gasto.');
    }
  }
}
