// ============================================================
// Auth Screen - Login / Register with glassmorphism & animations
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/custom_text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool startInRegisterMode;

  const AuthScreen({super.key, this.startInRegisterMode = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedBloodGroup = 'O+';
  String _selectedDistrict = 'district1';
  String _selectedThana = 'thana1';
  String _selectedArea = 'area1';
  bool _isAvailable = true;

  late AnimationController _tabAnimController;

  @override
  void initState() {
    super.initState();
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _isLogin = !widget.startInRegisterMode;
    if (!_isLogin) {
      _tabAnimController.value = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabAnimController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    if (_isLogin) {
      _tabAnimController.reverse();
    } else {
      _tabAnimController.forward();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    bool success;

    if (_isLogin) {
      success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authNotifier.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        bloodGroup: _selectedBloodGroup,
        location: _selectedDistrict,
        district: _selectedDistrict,
        thana: _selectedThana,
        area: _selectedArea,
        phone: _phoneController.text.trim(),
        avatarUrl: '',
        isAvailable: _isAvailable,
      );
    }

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppColors.lightBg.withOpacity(0.9),
              const Color(0xFFFFF7F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.06),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.primaryRed.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        _isLogin ? 'Welcome back, donor' : 'Join the donor community',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryRedDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primaryRed.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.14),
                        blurRadius: 26,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: AppColors.primaryRed,
                    size: 40,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: const Duration(milliseconds: 300)),

                const SizedBox(height: 16),

                // Title
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightText,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Auth toggle tabs
                _buildAuthTabs(),

                const SizedBox(height: 24),

                // Glass card form
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: Column(
                            children: [
                              // Name field (Register only)
                              if (!_isLogin) ...[
                                _sectionLabel('Account details'),
                                const SizedBox(height: 10),
                                _buildCompactRow(
                                  left: CustomTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    prefixIcon: Icons.person_rounded,
                                    delay: 1,
                                    validator: (val) {
                                      if (!_isLogin && (val == null || val.isEmpty)) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  right: CustomTextField(
                                    controller: _phoneController,
                                    label: 'Phone Number',
                                    prefixIcon: Icons.phone_rounded,
                                    keyboardType: TextInputType.phone,
                                    delay: 2,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      final phone = val.trim();
                                      final isValidPhone = RegExp(r'^\+?[0-9\s-]{10,15}$')
                                          .hasMatch(phone);
                                      if (!isValidPhone) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email
                              if (_isLogin) ...[
                                _sectionLabel('Sign in details'),
                                const SizedBox(height: 10),
                              ],
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                prefixIcon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                delay: 2,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!val.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                prefixIcon: Icons.lock_rounded,
                                obscureText: true,
                                delay: 3,
                                validator: (val) {
                                  if (val == null || val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              // Register extra fields
                              if (!_isLogin) ...[
                                const SizedBox(height: 16),
                                _sectionLabel('Donor profile'),
                                const SizedBox(height: 10),
                                _buildCompactRow(
                                  left: _buildBloodGroupDropdown(),
                                  right: _buildSelectionDropdown(
                                    label: 'District',
                                    icon: Icons.map_rounded,
                                    value: _selectedDistrict,
                                    items: AppConstants.districts,
                                    delay: 5,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _selectedDistrict = value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildCompactRow(
                                  left: _buildSelectionDropdown(
                                    label: 'Thana',
                                    icon: Icons.location_city_rounded,
                                    value: _selectedThana,
                                    items: AppConstants.thanas,
                                    delay: 6,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _selectedThana = value);
                                      }
                                    },
                                  ),
                                  right: _buildSelectionDropdown(
                                    label: 'Area',
                                    icon: Icons.place_rounded,
                                    value: _selectedArea,
                                    items: AppConstants.areas,
                                    delay: 7,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _selectedArea = value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildAvailabilityToggle(),
                              ],

                              const SizedBox(height: 8),

                              // Error message
                              if (authState.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    authState.error!,
                                    style: const TextStyle(
                                      color: AppColors.primaryRedLight,
                                      fontSize: 13,
                                    ),
                                  )
                                      .animate()
                                      .shake(duration: 400.ms)
                                      .fadeIn(),
                                ),

                              const SizedBox(height: 16),

                              // Submit button
                              AnimatedButton(
                                text: _isLogin ? 'Login' : 'Create Account',
                                isLoading: authState.isLoading,
                                icon: _isLogin
                                    ? Icons.login_rounded
                                    : Icons.person_add_rounded,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Toggle text
                GestureDetector(
                  onTap: _toggleAuthMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.poppins(
                          color: AppColors.lightText.withOpacity(0.82),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: _isLogin
                                ? "Don't have an account? "
                                : 'Already have an account? ',
                          ),
                          TextSpan(
                            text: _isLogin ? 'Register' : 'Login',
                            style: const TextStyle(
                              color: AppColors.primaryRedDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 16,
                child: _buildHomeButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRow({
    required Widget left,
    required Widget right,
  }) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildAuthTabs() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isLogin) _toggleAuthMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _isLogin ? AppColors.primaryRed : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isLogin
                      ? [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.25),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      color: _isLogin ? Colors.white : AppColors.lightText,
                      fontWeight: _isLogin ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isLogin) _toggleAuthMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: !_isLogin ? AppColors.primaryRed : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: !_isLogin
                      ? [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.25),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Register',
                    style: GoogleFonts.poppins(
                      color: !_isLogin ? Colors.white : AppColors.lightText,
                      fontWeight: !_isLogin ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: AppColors.lightText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildFieldShell(
      child: DropdownButtonFormField<String>(
        value: _selectedBloodGroup,
        decoration: InputDecoration(
          labelText: 'Blood Group',
          prefixIcon: Icon(
            Icons.bloodtype_rounded,
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
        ),
        dropdownColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
        items: AppConstants.bloodGroups.map((group) {
          return DropdownMenuItem(
            value: group,
            child: Text(
              group,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedBloodGroup = value);
        },
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: -0.05, end: 0);
  }

  Widget _buildSelectionDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildFieldShell(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
        ),
        dropdownColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (val) {
          if (!_isLogin && (val == null || val.isEmpty)) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * delay),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(
          begin: -0.05,
          end: 0,
          delay: Duration(milliseconds: 100 * delay),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }

  Widget _buildFieldShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAvailabilityToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SwitchListTile.adaptive(
        value: _isAvailable,
        onChanged: (value) => setState(() => _isAvailable = value),
        title: Text(
          'Available Status',
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _isAvailable ? 'Turned on' : 'Turned off',
          style: TextStyle(
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          ),
        ),
        activeColor: AppColors.primaryRedLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 1000),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(begin: -0.05, end: 0);
  }

  Widget _buildHomeButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/landing'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home_rounded,
                color: AppColors.primaryRed,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Home',
                style: GoogleFonts.poppins(
                  color: AppColors.lightText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }
}
