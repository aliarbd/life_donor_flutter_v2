// ============================================================
// Donor Profile Screen
// - Own profile: shown after login on /home
// - Public profile: shown from donor search results
// ============================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/donor_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class DonorProfileScreen extends ConsumerWidget {
  final String? donorId;

  const DonorProfileScreen({super.key, this.donorId});

  bool get _isOwnProfile => donorId == null || donorId!.isEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final donor = _isOwnProfile
        ? null
        : MockData.donors.firstWhere(
            (d) => d.id == donorId,
            orElse: () => MockData.donors.first,
          );

    if (_isOwnProfile && user == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 64,
                    color:
                        isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No donor profile found',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please log in again to see your donor profile.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: _isOwnProfile
              ? _OwnProfileView(
                  user: user!,
                  isDark: isDark,
                  onEdit: () => _showEditProfileDialog(context, ref, user),
                )
              : _PublicProfileView(
                  donor: donor!,
                  isDark: isDark,
                ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final cityController = TextEditingController(text: user.location);
    final phoneController = TextEditingController(text: user.phone);
    String selectedBloodGroup = user.bloodGroup;
    String selectedDistrict =
        user.district.isNotEmpty ? user.district : AppConstants.districts.first;
    String selectedThana =
        user.thana.isNotEmpty ? user.thana : AppConstants.thanas.first;
    String selectedArea =
        user.area.isNotEmpty ? user.area : AppConstants.areas.first;
    bool isAvailable = user.isAvailable;
    Uint8List? pickedAvatarBytes = user.avatarBytes;
    final formKey = GlobalKey<FormState>();
    final imagePicker = ImagePicker();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCard
                  : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.lightText,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dialogField(
                          controller: nameController,
                          label: 'Full Name',
                          icon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          controller: cityController,
                          label: 'City',
                          icon: Icons.location_city_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your city';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogField(
                          controller: phoneController,
                          label: 'Phone',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Photo',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: _ProfileAvatar(
                                  emoji: '🩸',
                                  imageBytes: pickedAvatarBytes,
                                  imageUrl: user.avatarUrl,
                                  size: 74,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picked = await imagePicker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );
                                    if (picked == null) return;
                                    final bytes = await picked.readAsBytes();
                                    setDialogState(
                                        () => pickedAvatarBytes = bytes);
                                  },
                                  icon: const Icon(Icons.upload_rounded),
                                  label: Text(
                                    pickedAvatarBytes == null
                                        ? 'Upload Photo'
                                        : 'Change Photo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _dialogDropdown(
                          label: 'Blood Group',
                          value: selectedBloodGroup,
                          items: AppConstants.bloodGroups,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedBloodGroup = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogDropdown(
                          label: 'District',
                          value: selectedDistrict,
                          items: AppConstants.districts,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedDistrict = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogDropdown(
                          label: 'Thana',
                          value: selectedThana,
                          items: AppConstants.thanas,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedThana = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _dialogDropdown(
                          label: 'Area',
                          value: selectedArea,
                          items: AppConstants.areas,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedArea = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: isAvailable,
                          onChanged: (value) {
                            setDialogState(() => isAvailable = value);
                          },
                          title: Text(
                            'Available Status',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    ref.read(authProvider.notifier).updateProfile(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          location: cityController.text.trim(),
                          phone: phoneController.text.trim(),
                          avatarBytes: pickedAvatarBytes,
                          bloodGroup: selectedBloodGroup,
                          district: selectedDistrict,
                          thana: selectedThana,
                          area: selectedArea,
                          isAvailable: isAvailable,
                        );
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    phoneController.dispose();
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _dialogDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down_rounded),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _OwnProfileView extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final VoidCallback onEdit;

  const _OwnProfileView({
    required this.user,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.name.isNotEmpty ? user.name : 'Donor';
    final initials =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D';
    final phoneText = user.phone.isNotEmpty ? user.phone : 'No phone';
    final cityText = user.location.isNotEmpty ? user.location : 'Not set';
    final districtText = user.district.isNotEmpty ? user.district : 'Not set';
    final thanaText = user.thana.isNotEmpty ? user.thana : 'Not set';
    final areaText = user.area.isNotEmpty ? user.area : 'Not set';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.lightSubtext,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/settings'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.05, end: 0),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primaryRed.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _ProfileAvatar(
                        emoji: '🩸',
                        imageBytes: user.avatarBytes,
                        imageUrl: user.avatarUrl,
                        size: 62,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Donor Profile',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HeaderMiniBadge(
                                icon: Icons.bloodtype_rounded,
                                text: user.bloodGroup,
                              ),
                              _HeaderMiniBadge(
                                icon: user.isAvailable
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                text: user.isAvailable
                                    ? 'Available'
                                    : 'Unavailable',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DetailTile(
                      emoji: '📧',
                      label: 'Email',
                      value: user.email,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailTile(
                      emoji: '📱',
                      label: 'Phone',
                      value: phoneText,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailTile(
                      emoji: '🏙️',
                      label: 'City',
                      value: cityText,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailTile(
                      emoji: '🧭',
                      label: 'Area',
                      value: areaText,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _AddressBlock(
                district: districtText,
                thana: thanaText,
                area: areaText,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Profile'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: 500.ms)
            .slideY(begin: 0.08, end: 0),
        const SizedBox(height: 28),
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Search Donor',
                subtitle: 'Find nearby donors',
                icon: Icons.search_rounded,
                colors: const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                onTap: () => context.go('/find-donor'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Request Blood',
                subtitle: 'Send blood request',
                icon: Icons.bloodtype_rounded,
                colors: const [Color(0xFFFF4D4D), Color(0xFFFF0000)],
                onTap: () => context.go('/request-blood'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ActionCard(
          title: 'Nearby Camps',
          subtitle: 'Donation events around you',
          icon: Icons.local_hospital_rounded,
          colors: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          onTap: () => context.go('/map'),
          fullWidth: true,
        ),
      ],
    );
  }
}

class _PublicProfileView extends StatelessWidget {
  final DonorModel donor;
  final bool isDark;

  const _PublicProfileView({
    required this.donor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Donor Profile',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        Hero(
          tag: 'donor-avatar-${donor.id}',
          child: _ProfileAvatar(
            emoji: '🩸',
            imageUrl: donor.avatarUrl,
            fallbackText: donor.bloodGroup,
            size: 100,
          ),
        ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 16),
        Text(
          donor.name,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 4),
        Text(
          donor.location,
          style: TextStyle(
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            fontSize: 16,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _PublicChip(
              icon: Icons.bloodtype_rounded,
              text: donor.bloodGroup,
              isDark: isDark,
            ),
            _PublicChip(
              icon: donor.isAvailable
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              text: donor.isAvailable ? '🟢 Ready to help' : '🔴 Not available',
              isDark: isDark,
            ),
            _PublicChip(
              icon: Icons.place_rounded,
              text: donor.area,
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _infoTile(Icons.bloodtype_rounded, 'Blood Group', donor.bloodGroup,
            isDark, 0),
        _infoTile(
          Icons.calendar_today_rounded,
          'Last Donation',
          DateFormat('MMM dd, yyyy').format(donor.lastDonationDate),
          isDark,
          1,
        ),
        _infoTile(
            Icons.location_on_rounded, 'Location', donor.location, isDark, 2),
        _infoTile(
          Icons.straighten_rounded,
          'Distance',
          '${donor.distance} km away',
          isDark,
          3,
        ),
        _infoTile(Icons.phone_rounded, 'Phone', donor.phone, isDark, 4),
        _infoTile(
          Icons.check_circle_rounded,
          'Status',
          donor.isAvailable ? '🟢 Available' : '🔴 Unavailable',
          isDark,
          5,
        ),
        const SizedBox(height: 32),
        _PulseButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Request sent successfully!'),
                backgroundColor: AppColors.safeGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value, bool isDark, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRedLight, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 300 + (i * 80)), duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String emoji;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String? fallbackText;
  final double size;

  const _ProfileAvatar({
    required this.emoji,
    this.imageBytes,
    this.imageUrl,
    this.fallbackText,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: imageBytes != null
            ? Image.memory(imageBytes!, fit: BoxFit.cover)
            : (imageUrl != null && imageUrl!.isNotEmpty)
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _EmojiFallback(
                        emoji: emoji,
                        fallbackText: fallbackText,
                      );
                    },
                  )
                : _EmojiFallback(
                    emoji: emoji,
                    fallbackText: fallbackText,
                  ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: avatar,
    );
  }
}

class _EmojiFallback extends StatelessWidget {
  final String emoji;
  final String? fallbackText;

  const _EmojiFallback({
    required this.emoji,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        fallbackText ?? emoji,
        style: TextStyle(
          color: AppColors.primaryRed,
          fontSize: fallbackText == null ? 30 : 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderMiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderMiniBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool isDark;

  const _DetailTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final String district;
  final String thana;
  final String area;
  final bool isDark;

  const _AddressBlock({
    required this.district,
    required this.thana,
    required this.area,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Address',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AddressLine(label: 'District', value: district, isDark: isDark),
          const SizedBox(height: 8),
          _AddressLine(label: 'Thana', value: thana, isDark: isDark),
          const SizedBox(height: 8),
          _AddressLine(label: 'Area', value: area, isDark: isDark),
        ],
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _AddressLine({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryRedDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _PublicChip({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryRedLight),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: fullWidth ? 92 : 138,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: fullWidth ? 16 : 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.84),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PulseButton({required this.onPressed});

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final scale = 1.0 + (_ctrl.value * 0.05);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Request Blood Now',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
