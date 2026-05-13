// ============================================================
// Donor Model - Represents a blood donor
// ============================================================

class DonorModel {
  final String id;
  final String name;
  final String bloodGroup;
  final String? avatarUrl;
  final String location;
  final String city;
  final String district;
  final String thana;
  final String area;
  final double distance; // in km
  final String phone;
  final DateTime lastDonationDate;
  final bool isAvailable;
  final double latitude;
  final double longitude;

  const DonorModel({
    required this.id,
    required this.name,
    required this.bloodGroup,
    this.avatarUrl,
    required this.location,
    required this.city,
    required this.district,
    required this.thana,
    required this.area,
    required this.distance,
    required this.phone,
    required this.lastDonationDate,
    this.isAvailable = true,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}
