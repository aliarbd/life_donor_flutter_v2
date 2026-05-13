// Settings Screen - Dark/Light mode toggle + profile
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Settings',
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText))
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),

            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ]),
              child: Row(children: [
                Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2)),
                    child: Center(
                        child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'D',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700)))),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(user?.name ?? 'Donor',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      Text(user?.email ?? '',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(user?.bloodGroup ?? 'O+',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600))),
                    ])),
              ]),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 28),

            // Theme toggle
            _settingsTile(isDark, Icons.dark_mode_rounded, 'Dark Mode',
                'Switch appearance',
                trailing: Switch.adaptive(
                    value: isDark,
                    activeColor: AppColors.primaryRedLight,
                    onChanged: (_) =>
                        ref.read(themeProvider.notifier).toggleTheme()),
                index: 0),

            _settingsTile(isDark, Icons.notifications_rounded, 'Notifications',
                'Manage alerts',
                index: 1),
            _settingsTile(
                isDark, Icons.lock_rounded, 'Privacy', 'Account security',
                index: 2),
            _settingsTile(isDark, Icons.help_rounded, 'Help & Support',
                'FAQs and contact',
                index: 3),
            _settingsTile(isDark, Icons.info_rounded, 'About', 'Version 1.0.0',
                index: 4),

            const SizedBox(height: 24),

            // Logout button
            GestureDetector(
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/landing');
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.urgentRed.withOpacity(0.5),
                        width: 1.5),
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.logout_rounded,
                          color: AppColors.urgentRed, size: 20),
                      SizedBox(width: 8),
                      Text('Logout',
                          style: TextStyle(
                              color: AppColors.urgentRed,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ])),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _settingsTile(
      bool isDark, IconData icon, String title, String subtitle,
      {Widget? trailing, int index = 0}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                blurRadius: 10)
          ]),
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryRedLight, size: 22)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? AppColors.darkText : AppColors.lightText)),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
        ])),
        trailing ??
            Icon(Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
      ]),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 300 + (index * 80)), duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
