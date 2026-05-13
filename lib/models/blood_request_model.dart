// ============================================================
// Blood Request Model
// ============================================================

class BloodRequestModel {
  final String id;
  final String patientName;
  final String bloodGroup;
  final int unitsRequired;
  final String hospitalName;
  final String urgencyLevel; // Normal, Urgent, Critical
  final String location;
  final DateTime requestDate;
  final String status; // Pending, Fulfilled, Expired

  const BloodRequestModel({
    required this.id,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsRequired,
    required this.hospitalName,
    required this.urgencyLevel,
    required this.location,
    required this.requestDate,
    this.status = 'Pending',
  });
}
