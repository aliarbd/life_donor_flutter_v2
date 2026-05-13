import 'dart:typed_data';

// ============================================================
// User Model
// ============================================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String bloodGroup;
  final String location;
  final String district;
  final String thana;
  final String area;
  final String phone;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final DateTime? lastDonationDate;
  final bool isAvailable;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.bloodGroup,
    required this.location,
    this.district = '',
    this.thana = '',
    this.area = '',
    this.phone = '',
    this.avatarUrl,
    this.avatarBytes,
    this.lastDonationDate,
    this.isAvailable = true,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? bloodGroup,
    String? location,
    String? district,
    String? thana,
    String? area,
    String? phone,
    String? avatarUrl,
    Uint8List? avatarBytes,
    DateTime? lastDonationDate,
    bool? isAvailable,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      location: location ?? this.location,
      district: district ?? this.district,
      thana: thana ?? this.thana,
      area: area ?? this.area,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
