import 'package:flutter_test/flutter_test.dart';
import 'package:blood_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('uses profileImageUrl when present in Firestore data', () {
      final user = UserModel.fromFirestore({
        'uid': 'u1',
        'name': 'Test',
        'email': 'test@test.com',
        'phone': '123456789',
        'bloodGroup': 'O+',
        'gender': 'Male',
        'district': 'Dhaka',
        'upazila': 'Dhanmondi',
        'address': 'Road 1',
        'profileImageUrl': 'https://example.com/profile.png',
        'photoUrl': '',
      });

      expect(user.avatarUrl, 'https://example.com/profile.png');
    });
  });
}
