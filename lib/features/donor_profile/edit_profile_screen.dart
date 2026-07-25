import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_storage_service.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedBloodGroup = AppConstants.bloodGroups.first;
  String _selectedGender = _genderOptions.first;
  String _selectedDistrict = AppConstants.districts.first;
  String _selectedUpazila = AppConstants.thanas.first;
  bool _isAvailable = true;
  String? _loadedUid;
  Uint8List? _previewImageBytes;
  String? _selectedImageUrl;
  bool _isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  static const List<String> _genderOptions = [
    'Not specified',
    'Male',
    'Female',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUser(UserModel user) {
    if (_loadedUid == user.uid) return;

    _loadedUid = user.uid;
    _nameController.text = user.name;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _selectedBloodGroup = user.bloodGroup.trim().isNotEmpty
        ? user.bloodGroup.trim()
        : AppConstants.bloodGroups.first;
    _selectedGender = _knownValue(_genderOptions, user.gender) ??
        (user.gender.trim().isNotEmpty
            ? user.gender.trim()
            : _genderOptions.first);
    _selectedDistrict = user.district.trim().isNotEmpty
        ? user.district.trim()
        : AppConstants.districts.first;
    _selectedUpazila = user.upazila.trim().isNotEmpty
        ? user.upazila.trim()
        : AppConstants.thanas.first;
    _isAvailable = user.isAvailable;
    _selectedImageUrl = user.avatarUrl;
  }

  String? _knownValue(List<String> items, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return items.contains(trimmed) ? trimmed : null;
  }

  List<String> _itemsWithCurrent(List<String> items, String value) {
    return items.contains(value) ? items : [...items, value];
  }

  Future<String?> _uploadSelectedImage(String uid) async {
    if (_previewImageBytes == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final uploadedUrl =
          await FirebaseStorageService.instance.uploadProfileImage(
        uid: uid,
        imageBytes: _previewImageBytes!,
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return null;

      setState(() => _selectedImageUrl = uploadedUrl);

      return uploadedUrl;
    } catch (_) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to upload profile image. Please try again.')),
      );
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    try {
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('invalid-image');
      }

      if (!mounted) return;
      setState(() {
        _previewImageBytes = bytes;
        _selectedImageUrl = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Selected image is invalid. Please try another image.')),
      );
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isUploadingImage) return;

    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not found.')),
      );
      return;
    }

    String? avatarUrlToSave = _selectedImageUrl ?? currentUser.avatarUrl;
    if (_previewImageBytes != null) {
      avatarUrlToSave = await _uploadSelectedImage(currentUser.uid);
      if (avatarUrlToSave == null) {
        return;
      }
    }

    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          bloodGroup: _selectedBloodGroup,
          gender: _selectedGender,
          district: _selectedDistrict,
          upazila: _selectedUpazila,
          address: _addressController.text.trim(),
          avatarUrl: avatarUrlToSave,
          isAvailable: _isAvailable,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      context.pop();
    } else {
      final message = ref.read(authProvider).errorMessage ??
          'Unable to update profile. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('User profile not found.')),
      );
    }

    _loadUser(user);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap:
                                _isUploadingImage ? null : _pickAndUploadImage,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryRed
                                        .withValues(alpha: 0.16),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white,
                                  child: _previewImageBytes != null
                                      ? Image.memory(
                                          _previewImageBytes!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        )
                                      : (_selectedImageUrl != null &&
                                              _selectedImageUrl!.isNotEmpty)
                                          ? Image.network(
                                              _selectedImageUrl!,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.person_rounded,
                                                size: 46,
                                                color: AppColors.primaryRed,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              size: 46,
                                              color: AppColors.primaryRed,
                                            ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryRed,
                              child: _isUploadingImage
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.camera_alt_rounded,
                                          size: 16, color: Colors.white),
                                      onPressed: _isUploadingImage
                                          ? null
                                          : _pickAndUploadImage,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the photo to change it',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.lightSubtext,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _ReadOnlyInfoTile(
                  label: 'Email',
                  value: user.email.isNotEmpty ? user.email : 'Not set',
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final phone = value.trim();
                    if (!RegExp(r'^\+?[0-9\s-]{10,15}$').hasMatch(phone)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _EditDropdown(
                  label: 'Blood Group',
                  icon: Icons.bloodtype_rounded,
                  value: _selectedBloodGroup,
                  items: _itemsWithCurrent(
                      AppConstants.bloodGroups, _selectedBloodGroup),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedBloodGroup = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _EditDropdown(
                  label: 'Gender',
                  icon: Icons.wc_rounded,
                  value: _selectedGender,
                  items: _genderOptions.contains(_selectedGender)
                      ? _genderOptions
                      : [..._genderOptions, _selectedGender],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedGender = value);
                  },
                ),
                const SizedBox(height: 16),
                _EditDropdown(
                  label: 'District',
                  icon: Icons.map_rounded,
                  value: _selectedDistrict,
                  items: _itemsWithCurrent(
                      AppConstants.districts, _selectedDistrict),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDistrict = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _EditDropdown(
                  label: 'Upazila',
                  icon: Icons.location_city_rounded,
                  value: _selectedUpazila,
                  items:
                      _itemsWithCurrent(AppConstants.thanas, _selectedUpazila),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedUpazila = value);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  prefixIcon: Icons.place_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _AvailabilityTile(
                  value: _isAvailable,
                  isDark: isDark,
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    authState.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.primaryRedLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AnimatedButton(
                  text: 'Save',
                  icon: Icons.save_rounded,
                  isLoading: authState.isLoading || _isUploadingImage,
                  onPressed: _isUploadingImage ? () {} : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _ReadOnlyInfoTile({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_rounded, color: AppColors.primaryRed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _EditDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.white,
      ),
      dropdownColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _AvailabilityTile({
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryRedLight,
        title: Text(
          'Available Status',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Text(
          value ? 'Available for donation' : 'Not available now',
          style: TextStyle(
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          ),
        ),
      ),
    );
  }
}
