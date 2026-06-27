import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  @override
  void initState() {
    super.initState();

    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut),
    );

    _navigateNext();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (!authState.isSessionReady) {
      _navigateNext();
      return;
    }

    context.go(authState.user != null ? '/home' : '/landing');
  }

  @override
  Widget build(BuildContext context) {
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
              AppColors.lightBg.withOpacity(0.92),
              const Color(0xFFFFF7F7),
            ],
          ),
        ),
        child: Stack(
          children: [
            ..._buildBackgroundCircles(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    listenable: _heartbeatAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartbeatAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.primaryRed.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.12),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.primaryRed,
                        size: 56,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: const Duration(milliseconds: 400)),
                  const SizedBox(height: 32),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText,
                      letterSpacing: 1.5,
                      ),
                  )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                      )
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Find help when it matters most',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRedDark,
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
                  const SizedBox(height: 12),
                  Text(
                    'Save Lives, One Drop at a Time',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: AppColors.lightSubtext,
                      letterSpacing: 0.8,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 800),
                        duration: const Duration(milliseconds: 600),
                      )
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: const Duration(milliseconds: 800),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryRed.withOpacity(0.6),
                          ),
                        )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scaleXY(
                              begin: 0.5,
                              end: 1.2,
                              delay: Duration(milliseconds: 200 * index),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                            )
                            .fadeIn(
                              delay:
                                  Duration(milliseconds: 1200 + (200 * index)),
                            );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -80,
        right: -80,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed.withOpacity(0.06),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
              begin: 0.8,
              end: 1.2,
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
            ),
      ),
      Positioned(
        bottom: -120,
        left: -60,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed.withOpacity(0.04),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
              begin: 1.0,
              end: 1.3,
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOut,
            ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: -40,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed.withOpacity(0.04),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
              begin: 0.9,
              end: 1.4,
              duration: const Duration(seconds: 2, milliseconds: 500),
              curve: Curves.easeInOut,
            ),
      ),
    ];
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
