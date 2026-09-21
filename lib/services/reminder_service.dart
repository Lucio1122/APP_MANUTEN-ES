import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> _collection(String carId) { final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) throw Exception('Usuário não autenticado.'); return _db.collection('users').doc(uid).collection('cars').doc(carId).collection('reminders'); }
  static Future<String> addReminder(String carId, Map<String, dynamic> data) async { final doc = _collection(carId).doc(); await doc.set({...data, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}); return doc.id; }
  static Future<List<Map<String, dynamic>>> getReminders(String carId) async => (await _collection(carId).get()).docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  static Future<Map<String, dynamic>?> getReminder(String carId, String id) async { final doc = await _collection(carId).doc(id).get(); return doc.exists ? {'id': doc.id, ...doc.data()!} : null; }
  static Future<void> updateReminder(String carId, String id, Map<String, dynamic> data) => _collection(carId).doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  static Future<void> deleteReminder(String carId, String id) => _collection(carId).doc(id).delete();
}
