// ============================================================
// App Constants - Centralized constants for the app
// ============================================================

class AppConstants {
  static const String appName = 'Life Donor';
  static const String tagline = 'Save Lives, One Drop at a Time';

  // Blood groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  // Urgency levels
  static const List<String> urgencyLevels = [
    'Normal',
    'Urgent',
    'Critical',
  ];

  // Cities for mock data
  static const List<String> cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
  ];

  // Demo location selections used by the donor search/register flows
  static const List<String> districts = ['district1', 'district2', 'district3'];
  static const List<String> thanas = ['thana1', 'thana2', 'thana3'];
  static const List<String> areas = ['area1', 'area2', 'area3'];

  // Animation durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration shortAnim = Duration(milliseconds: 200);
  static const Duration mediumAnim = Duration(milliseconds: 400);
  static const Duration longAnim = Duration(milliseconds: 600);

  // Spacing
  static const double paddingXS = 4;
  static const double paddingSM = 8;
  static const double paddingMD = 16;
  static const double paddingLG = 24;
  static const double paddingXL = 32;
  static const double paddingXXL = 48;

  // Border radius
  static const double radiusSM = 8;
  static const double radiusMD = 16;
  static const double radiusLG = 20;
  static const double radiusXL = 24;
  static const double radiusXXL = 32;
}
