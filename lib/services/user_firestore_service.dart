import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserFirestoreService {
  UserFirestoreService._();

  static final UserFirestoreService instance = UserFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> saveUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UserModel.fromFirestore(snapshot.data()!);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return UserModel.fromFirestore(data);
    });
  }

  Stream<List<UserModel>> watchAvailableUsers() {
    return _users
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final uid = (data['uid'] ?? '') as String;
        return UserModel.fromFirestore({
          ...data,
          'uid': uid.isNotEmpty ? uid : doc.id,
        });
      }).toList();
    });
  }
}
