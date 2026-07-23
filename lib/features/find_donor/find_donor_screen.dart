// ============================================================
// Find Donor Screen - Search & filter donors
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/donor_card.dart';
import '../../widgets/shimmer_loading.dart';

class FindDonorScreen extends ConsumerStatefulWidget {
  const FindDonorScreen({super.key});

  @override
  ConsumerState<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends ConsumerState<FindDonorScreen> {
  String? _selectedBloodGroup;
  String? _selectedDistrict;
  String? _selectedThana;
  String? _selectedArea;

  @override
  Widget build(BuildContext context) {
    final donorState = ref.watch(donorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF2F2),
                      Color(0xFFFFFAFA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.08 : 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find Donor',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                              Text(
                                'Filter by blood group, district, thana and area',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeaderChip(text: 'Fast search', isDark: isDark),
                        _HeaderChip(text: 'Live donor list', isDark: isDark),
                        _HeaderChip(text: 'Call in one tap', isDark: isDark),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.12 : 0.05),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Blood Group',
                            icon: Icons.bloodtype_rounded,
                            value: _selectedBloodGroup,
                            items: AppConstants.bloodGroups,
                            hint: 'All Blood Groups',
                            isDark: isDark,
                            onChanged: (value) {
                              setState(() => _selectedBloodGroup = value);
                              ref.read(donorProvider.notifier).filterByBloodGroup(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'District',
                            icon: Icons.map_rounded,
                            value: _selectedDistrict,
                            items: AppConstants.districts,
                            hint: 'All Districts',
                            isDark: isDark,
                            onChanged: (value) {
                              setState(() => _selectedDistrict = value);
                              ref.read(donorProvider.notifier).filterByDistrict(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Thana',
                            icon: Icons.location_city_rounded,
                            value: _selectedThana,
                            items: AppConstants.thanas,
                            hint: 'All Thanas',
                            isDark: isDark,
                            onChanged: (value) {
                              setState(() => _selectedThana = value);
                              ref.read(donorProvider.notifier).filterByThana(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Area',
                            icon: Icons.place_rounded,
                            value: _selectedArea,
                            items: AppConstants.areas,
                            hint: 'All Areas',
                            isDark: isDark,
                            onChanged: (value) {
                              setState(() => _selectedArea = value);
                              ref.read(donorProvider.notifier).filterByArea(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${donorState.filteredDonors.length} donors found',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 16),

              donorState.isLoading
                  ? const ShimmerLoading()
                  : donorState.errorMessage != null
                      ? Center(
                          child: Text(
                            donorState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            ),
                          ),
                        )
                  : donorState.filteredDonors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No donors found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                ),
                              ),
                            ],
                          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: donorState.filteredDonors.length,
                          itemBuilder: (context, i) {
                            final donor = donorState.filteredDonors[i];
                            return DonorCard(
                              donor: donor,
                              index: i,
                              onTap: () => context.push('/donor-profile/${donor.id}'),
                              onCall: () => _showCallDialog(
                                context,
                                donor.name,
                                donor.phone,
                                isDark,
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              fontSize: 14,
            ),
          ),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
          icon: Icon(Icons.arrow_drop_down, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  const SizedBox(width: 8),
                  Text(
                    'All $label',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String?>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _HeaderChip({
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.08),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBloodGroup = null;
      _selectedDistrict = null;
      _selectedThana = null;
      _selectedArea = null;
    });
    ref.read(donorProvider.notifier).resetFilters();
  }

  void _showCallDialog(BuildContext context, String name, String phone, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Call $name?',
          style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
        ),
        content: Text(
          phone,
          style: TextStyle(
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.safeGreen),
            child: const Text('Call', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
