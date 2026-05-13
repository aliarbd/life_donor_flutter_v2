// ============================================================
// Donor Provider - Manages donor search and filtering
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/donor_model.dart';
import '../data/mock_data.dart';

// Donor state
class DonorState {
  final List<DonorModel> allDonors;
  final List<DonorModel> filteredDonors;
  final String? selectedBloodGroup;
  final String? selectedDistrict;
  final String? selectedThana;
  final String? selectedArea;
  final bool isLoading;

  const DonorState({
    this.allDonors = const [],
    this.filteredDonors = const [],
    this.selectedBloodGroup,
    this.selectedDistrict,
    this.selectedThana,
    this.selectedArea,
    this.isLoading = false,
  });

  DonorState copyWith({
    List<DonorModel>? allDonors,
    List<DonorModel>? filteredDonors,
    String? selectedBloodGroup,
    String? selectedDistrict,
    String? selectedThana,
    String? selectedArea,
    bool? isLoading,
    bool clearSelectedBloodGroup = false,
    bool clearSelectedDistrict = false,
    bool clearSelectedThana = false,
    bool clearSelectedArea = false,
  }) {
    return DonorState(
      allDonors: allDonors ?? this.allDonors,
      filteredDonors: filteredDonors ?? this.filteredDonors,
      selectedBloodGroup:
          clearSelectedBloodGroup ? null : (selectedBloodGroup ?? this.selectedBloodGroup),
      selectedDistrict:
          clearSelectedDistrict ? null : (selectedDistrict ?? this.selectedDistrict),
      selectedThana:
          clearSelectedThana ? null : (selectedThana ?? this.selectedThana),
      selectedArea:
          clearSelectedArea ? null : (selectedArea ?? this.selectedArea),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DonorNotifier extends StateNotifier<DonorState> {
  DonorNotifier() : super(const DonorState()) {
    loadDonors();
  }

  // Load mock donors
  Future<void> loadDonors() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = DonorState(
      allDonors: MockData.donors,
      filteredDonors: MockData.donors,
      isLoading: false,
    );
  }

  // Filter donors by blood group
  void filterByBloodGroup(String? bloodGroup) {
    state = state.copyWith(
      selectedBloodGroup: bloodGroup,
      clearSelectedBloodGroup: bloodGroup == null || bloodGroup.isEmpty,
    );
    _applyFilters();
  }

  void filterByDistrict(String? district) {
    state = state.copyWith(
      selectedDistrict: district,
      clearSelectedDistrict: district == null || district.isEmpty,
    );
    _applyFilters();
  }

  void filterByThana(String? thana) {
    state = state.copyWith(
      selectedThana: thana,
      clearSelectedThana: thana == null || thana.isEmpty,
    );
    _applyFilters();
  }

  void filterByArea(String? area) {
    state = state.copyWith(
      selectedArea: area,
      clearSelectedArea: area == null || area.isEmpty,
    );
    _applyFilters();
  }

  // Reset all filters
  void resetFilters() {
    state = state.copyWith(
      filteredDonors: state.allDonors,
      clearSelectedBloodGroup: true,
      clearSelectedDistrict: true,
      clearSelectedThana: true,
      clearSelectedArea: true,
    );
  }

  void _applyFilters() {
    List<DonorModel> filtered = state.allDonors;

    if (state.selectedBloodGroup != null && state.selectedBloodGroup!.isNotEmpty) {
      filtered = filtered.where((d) => d.bloodGroup == state.selectedBloodGroup).toList();
    }

    if (state.selectedDistrict != null && state.selectedDistrict!.isNotEmpty) {
      filtered = filtered.where((d) => d.district == state.selectedDistrict).toList();
    }

    if (state.selectedThana != null && state.selectedThana!.isNotEmpty) {
      filtered = filtered.where((d) => d.thana == state.selectedThana).toList();
    }

    if (state.selectedArea != null && state.selectedArea!.isNotEmpty) {
      filtered = filtered.where((d) => d.area == state.selectedArea).toList();
    }

    state = state.copyWith(filteredDonors: filtered);
  }
}

final donorProvider = StateNotifierProvider<DonorNotifier, DonorState>((ref) {
  return DonorNotifier();
});
