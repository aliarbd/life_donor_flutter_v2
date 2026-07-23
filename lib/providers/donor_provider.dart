// ============================================================
// Donor Provider - Manages donor search and filtering
// ============================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/donor_model.dart';
import '../models/user_model.dart';
import '../services/user_firestore_service.dart';

// Donor state
class DonorState {
  final List<DonorModel> allDonors;
  final List<DonorModel> filteredDonors;
  final String? selectedBloodGroup;
  final String? selectedDistrict;
  final String? selectedThana;
  final String? selectedArea;
  final bool isLoading;
  final String? errorMessage;

  const DonorState({
    this.allDonors = const [],
    this.filteredDonors = const [],
    this.selectedBloodGroup,
    this.selectedDistrict,
    this.selectedThana,
    this.selectedArea,
    this.isLoading = false,
    this.errorMessage,
  });

  DonorState copyWith({
    List<DonorModel>? allDonors,
    List<DonorModel>? filteredDonors,
    String? selectedBloodGroup,
    String? selectedDistrict,
    String? selectedThana,
    String? selectedArea,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedBloodGroup = false,
    bool clearSelectedDistrict = false,
    bool clearSelectedThana = false,
    bool clearSelectedArea = false,
    bool clearError = false,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DonorNotifier extends StateNotifier<DonorState> {
  DonorNotifier()
      : _userFirestoreService = UserFirestoreService.instance,
        super(const DonorState()) {
    loadDonors();
  }

  final UserFirestoreService _userFirestoreService;
  StreamSubscription<List<UserModel>>? _donorsSubscription;

  // Load available donors from Firestore.
  Future<void> loadDonors() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _donorsSubscription?.cancel();
    _donorsSubscription = _userFirestoreService.watchAvailableUsers().listen(
      (users) {
        final donors = users.map(_userToDonor).toList();
        state = state.copyWith(
          allDonors: donors,
          isLoading: false,
          clearError: true,
        );
        _applyFilters();
      },
      onError: (_) {
        state = state.copyWith(
          allDonors: const [],
          filteredDonors: const [],
          isLoading: false,
          errorMessage: 'Unable to load donors. Please try again.',
        );
      },
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

  DonorModel _userToDonor(UserModel user) {
    final locationParts = [
      user.address,
      user.upazila,
      user.district,
    ].where((value) => value.trim().isNotEmpty).toList();

    return DonorModel(
      id: user.uid,
      name: user.name,
      bloodGroup: user.bloodGroup,
      avatarUrl: user.avatarUrl,
      location: locationParts.join(', '),
      city: user.district,
      district: user.district,
      thana: user.upazila,
      area: user.address,
      distance: 0.0,
      phone: user.phone,
      lastDonationDate:
          user.lastDonationDate ?? user.updatedAt ?? user.createdAt ?? DateTime(1970),
      isAvailable: user.isAvailable,
      latitude: user.latitude ?? 0.0,
      longitude: user.longitude ?? 0.0,
    );
  }

  @override
  void dispose() {
    _donorsSubscription?.cancel();
    super.dispose();
  }
}

final donorProvider = StateNotifierProvider<DonorNotifier, DonorState>((ref) {
  return DonorNotifier();
});
