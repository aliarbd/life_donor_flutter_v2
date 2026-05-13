// ============================================================
// App Router - GoRouter navigation configuration
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/find_donor/find_donor_screen.dart';
import '../../features/request_blood/request_blood_screen.dart';
import '../../features/donor_profile/donor_profile_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/home/shell_screen.dart';

// Custom page transition with fade + slide
CustomTransitionPage<void> _buildPageTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _buildPageTransition(context, state, const SplashScreen()),
      ),

      // Landing page
      GoRoute(
        path: '/landing',
        pageBuilder: (context, state) =>
            _buildPageTransition(context, state, const LandingScreen()),
      ),

      // Auth
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) {
          final startInRegisterMode =
              state.uri.queryParameters['mode'] == 'register';
          return _buildPageTransition(
            context,
            state,
            AuthScreen(startInRegisterMode: startInRegisterMode),
          );
        },
      ),

      // Shell route for bottom nav bar
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildPageTransition(
                context, state, const DonorProfileScreen()),
          ),
          GoRoute(
            path: '/find-donor',
            pageBuilder: (context, state) =>
                _buildPageTransition(context, state, const FindDonorScreen()),
          ),
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) =>
                _buildPageTransition(context, state, const MapScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _buildPageTransition(context, state, const SettingsScreen()),
          ),
        ],
      ),

      // Full screen routes (no bottom nav)
      GoRoute(
        path: '/request-blood',
        pageBuilder: (context, state) =>
            _buildPageTransition(context, state, const RequestBloodScreen()),
      ),
      GoRoute(
        path: '/donor-profile/:id',
        pageBuilder: (context, state) {
          final donorId = state.pathParameters['id'] ?? '';
          return _buildPageTransition(
            context,
            state,
            DonorProfileScreen(donorId: donorId),
          );
        },
      ),
    ],
  );
});
