import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService._();

  static final FirebaseStorageService instance = FirebaseStorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage({
    required String uid,
    required Uint8List imageBytes,
  }) async {
    try {
      final ref = _storage.ref().child(
            'profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException {
      rethrow;
    }
  }
}
