import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String gender;
  final String district;
  final String upazila;
  final String address;
  final double? latitude;
  final double? longitude;
  final String photoUrl;
  final String profileImageUrl;
  final bool isAvailable;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Legacy UI-friendly fields kept for backward compatibility.
  final Uint8List? avatarBytes;
  final DateTime? lastDonationDate;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.gender,
    required this.district,
    required this.upazila,
    required this.address,
    this.latitude,
    this.longitude,
    this.photoUrl = '',
    this.profileImageUrl = '',
    this.isAvailable = true,
    this.role = 'donor',
    this.createdAt,
    this.updatedAt,
    this.avatarBytes,
    this.lastDonationDate,
  });

  String get id => uid;
  String get location => address;
  String get thana => upazila;
  String get area => address;
  String get avatarUrl =>
      profileImageUrl.isNotEmpty ? profileImageUrl : photoUrl;

  UserModel copyWith({
    String? uid,
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bloodGroup,
    String? gender,
    String? district,
    String? upazila,
    String? thana,
    String? address,
    String? location,
    String? area,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? avatarUrl,
    String? profileImageUrl,
    bool? isAvailable,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    Uint8List? avatarBytes,
    DateTime? lastDonationDate,
  }) {
    return UserModel(
      uid: uid ?? id ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      gender: gender ?? this.gender,
      district: district ?? this.district,
      upazila: upazila ?? thana ?? this.upazila,
      address: address ?? location ?? area ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? avatarUrl ?? this.photoUrl,
      profileImageUrl: profileImageUrl ?? avatarUrl ?? this.profileImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'gender': gender,
      'district': district,
      'upazila': upazila,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl.isNotEmpty ? photoUrl : profileImageUrl,
      'profileImageUrl':
          profileImageUrl.isNotEmpty ? profileImageUrl : photoUrl,
      'isAvailable': isAvailable,
      'role': role,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static UserModel fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: (data['uid'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      bloodGroup: (data['bloodGroup'] ?? '') as String,
      gender: (data['gender'] ?? '') as String,
      district: (data['district'] ?? '') as String,
      upazila: (data['upazila'] ?? '') as String,
      address: (data['address'] ?? '') as String,
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      photoUrl: (data['photoUrl'] ?? '') as String,
      profileImageUrl:
          (data['profileImageUrl'] ?? data['photoUrl'] ?? '') as String,
      isAvailable: (data['isAvailable'] ?? true) as bool,
      role: (data['role'] ?? 'donor') as String,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
