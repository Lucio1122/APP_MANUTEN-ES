import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/document.dart';

class DocumentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _collection(String carId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return _firestore.collection('users').doc(uid).collection('cars').doc(carId).collection('documents');
  }

  static Stream<List<VehicleDocument>> watchDocuments(String carId) => _collection(carId).orderBy('dueDate').snapshots().map((snapshot) => snapshot.docs.map((doc) => VehicleDocument.fromMap(doc.data(), doc.id)).toList());

  static Future<List<VehicleDocument>> getDocuments(String carId) async {
    try {
      final snapshot = await _collection(carId).orderBy('dueDate').get();
      return snapshot.docs.map((doc) => VehicleDocument.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      throw Exception('Não foi possível carregar os documentos.');
    }
  }

  static Future<String> createDocument(String carId, VehicleDocument document) async {
    try {
      final reference = _collection(carId).doc();
      await reference.set({...document.toMap(), 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      return reference.id;
    } catch (_) {
      throw Exception('Não foi possível salvar o documento.');
    }
  }

  static Future<void> updateDocument(String carId, VehicleDocument document) async {
    try {
      await _collection(carId).doc(document.id).update({...document.toMap(), 'updatedAt': FieldValue.serverTimestamp()});
    } catch (_) {
      throw Exception('Não foi possível atualizar o documento.');
    }
  }

  static Future<void> deleteDocument(String carId, String documentId) async {
    try {
      await _collection(carId).doc(documentId).delete();
    } catch (_) {
      throw Exception('Não foi possível excluir o documento.');
    }
  }
}
