// ============================================================
// Auth Provider - Manages authentication state
// ============================================================

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Login with mock authentication
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && password.length >= 6) {
      final user = UserModel(
        id: '1',
        name: email.split('@').first.replaceAll('.', ' '),
        email: email,
        bloodGroup: 'O+',
        avatarUrl: '',
        avatarBytes: null,
        location: 'Gazipur',
        district: 'district1',
        thana: 'thana1',
        area: 'area1',
        phone: '+91 98765 43210',
        lastDonationDate: DateTime(2026, 1, 15),
        isAvailable: true,
      );
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password (min 6 chars)',
      );
      return false;
    }
  }

  // Register with mock authentication
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String bloodGroup,
    required String location,
    required String district,
    required String thana,
    required String area,
    required String phone,
    required String avatarUrl,
    required bool isAvailable,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    await Future.delayed(const Duration(seconds: 2));

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        bloodGroup: bloodGroup,
        avatarUrl: avatarUrl,
        avatarBytes: null,
        location: location,
        district: district,
        thana: thana,
        area: area,
        phone: phone,
        isAvailable: isAvailable,
      );
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Please fill all fields correctly',
      );
      return false;
    }
  }

  // Update user profile
  void updateProfile({
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
    bool? isAvailable,
  }) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          name: name,
          email: email,
          bloodGroup: bloodGroup,
          location: location,
          district: district,
          thana: thana,
          area: area,
          phone: phone,
          avatarUrl: avatarUrl,
          avatarBytes: avatarBytes,
          isAvailable: isAvailable,
        ),
      );
    }
  }

  // Logout
  void logout() {
    state = const AuthState();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
