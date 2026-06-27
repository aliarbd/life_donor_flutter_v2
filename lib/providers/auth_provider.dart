import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_firestore_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isSessionReady;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isSessionReady = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isSessionReady,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isSessionReady: isSessionReady ?? this.isSessionReady,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : _authService = FirebaseAuthService.instance,
        _firestoreService = UserFirestoreService.instance,
        super(const AuthState()) {
    _authSubscription = _authService.authStateChanges().listen(_handleAuthUser);
  }

  final FirebaseAuthService _authService;
  final UserFirestoreService _firestoreService;
  StreamSubscription<User?>? _authSubscription;

  Future<void> _handleAuthUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        isSessionReady: true,
        clearError: state.errorMessage == null,
      );
      return;
    }

    await loadCurrentUser(uid: firebaseUser.uid);
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodGroup,
    required String gender,
    required String district,
    required String upazila,
    required String address,
    double? latitude,
    double? longitude,
    String photoUrl = '',
    bool isAvailable = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final validationError = _validateSignup(
      name: name,
      email: email,
      password: password,
      phone: phone,
      bloodGroup: bloodGroup,
      district: district,
      upazila: upazila,
      address: address,
    );
    if (validationError != null) {
      state = state.copyWith(isLoading: false, errorMessage: validationError);
      return false;
    }

    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to create account.',
        );
      }

      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        bloodGroup: bloodGroup,
        gender: gender,
        district: district,
        upazila: upazila,
        address: address,
        latitude: latitude,
        longitude: longitude,
        photoUrl: photoUrl,
        isAvailable: isAvailable,
        role: 'donor',
      );

      await _firestoreService.saveUser(user);
      await loadCurrentUser(uid: firebaseUser.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthException(e),
      );
      return false;
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFirestoreException(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

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
  }) {
    return signup(
      name: name,
      email: email,
      password: password,
      phone: phone,
      bloodGroup: bloodGroup,
      gender: 'Not specified',
      district: district,
      upazila: thana,
      address: [location, area].where((value) => value.trim().isNotEmpty).join(', '),
      photoUrl: avatarUrl,
      isAvailable: isAvailable,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final validationError = _validateLogin(email: email, password: password);
    if (validationError != null) {
      state = state.copyWith(isLoading: false, errorMessage: validationError);
      return false;
    }

    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Unable to sign in.',
        );
      }

      final loaded = await loadCurrentUser(uid: firebaseUser.uid);
      if (!loaded) {
        return false;
      }
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapAuthException(e),
      );
      return false;
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFirestoreException(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> loadCurrentUser({String? uid}) async {
    final currentUid = uid ?? _authService.currentUser?.uid;
    if (currentUid == null) {
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        isSessionReady: true,
        clearError: true,
      );
      return false;
    }

    try {
      final user = await _firestoreService.getUser(currentUid);
      if (user == null) {
        await _authService.signOut();
        state = state.copyWith(
          clearUser: true,
          isLoading: false,
          isSessionReady: true,
          errorMessage: 'User profile not found.',
        );
        return false;
      }

      state = state.copyWith(
        user: user,
        isLoading: false,
        isSessionReady: true,
        clearError: true,
      );
      return true;
    } on FirebaseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSessionReady: true,
        errorMessage: _mapFirestoreException(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isSessionReady: true,
        errorMessage: 'Unable to load user profile.',
      );
      return false;
    }
  }

  Future<void> updateProfile({
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
  }) async {
    final current = state.user;
    if (current == null) return;

    final updated = current.copyWith(
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
    );

    state = state.copyWith(user: updated, clearError: true);

    try {
      await _firestoreService.updateUser(updated.uid, {
        'name': updated.name,
        'email': updated.email,
        'phone': updated.phone,
        'bloodGroup': updated.bloodGroup,
        'gender': updated.gender,
        'district': updated.district,
        'upazila': updated.upazila,
        'address': updated.address,
        'latitude': updated.latitude,
        'longitude': updated.longitude,
        'photoUrl': updated.photoUrl,
        'isAvailable': updated.isAvailable,
        'role': updated.role,
      });
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Profile updated locally, but sync failed.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signOut();
      state = const AuthState(isSessionReady: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign out. Please try again.',
      );
    }
  }

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _mapFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Network error. Check your connection.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      default:
        return e.message ?? 'Database error. Please try again.';
    }
  }

  String? _validateSignup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodGroup,
    required String district,
    required String upazila,
    required String address,
  }) {
    if (name.trim().isEmpty) return 'Name is required.';
    if (!_isValidEmail(email)) return 'Please enter a valid email address.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (phone.trim().isEmpty) return 'Phone number is required.';
    if (bloodGroup.trim().isEmpty) return 'Blood group is required.';
    if (district.trim().isEmpty) return 'District is required.';
    if (upazila.trim().isEmpty) return 'Upazila is required.';
    if (address.trim().isEmpty) return 'Address is required.';
    return null;
  }

  String? _validateLogin({
    required String email,
    required String password,
  }) {
    if (!_isValidEmail(email)) return 'Please enter a valid email address.';
    if (password.trim().isEmpty) return 'Password is required.';
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
