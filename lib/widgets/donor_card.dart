// ============================================================
// Donor Card - Reusable card for displaying donor info
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_theme.dart';
import '../models/donor_model.dart';

class DonorCard extends StatefulWidget {
  final DonorModel donor;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final int index;

  const DonorCard({
    super.key,
    required this.donor,
    required this.onTap,
    this.onCall,
    this.index = 0,
  });

  @override
  State<DonorCard> createState() => _DonorCardState();
}

class _DonorCardState extends State<DonorCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.lightSurface;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isPressed ? -4.0 : 0.0),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isPressed
                ? AppColors.primaryRedLight.withOpacity(0.45)
                : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.14 : 0.06),
              blurRadius: _isPressed ? 26 : 18,
              offset: Offset(0, _isPressed ? 10 : 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'donor-avatar-${widget.donor.id}',
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: widget.donor.avatarUrl != null &&
                              widget.donor.avatarUrl!.isNotEmpty
                          ? Image.network(
                              widget.donor.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _AvatarFallback(
                                bloodGroup: widget.donor.bloodGroup,
                              ),
                            )
                          : _AvatarFallback(bloodGroup: widget.donor.bloodGroup),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.donor.name,
                              style: TextStyle(
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _BloodBadge(bloodGroup: widget.donor.bloodGroup),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoLine(
                        icon: Icons.phone_rounded,
                        text: widget.donor.phone,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      _InfoLine(
                        icon: Icons.place_rounded,
                        text: '${widget.donor.area} · ${widget.donor.thana}',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                if (widget.onCall != null) ...[
                  const SizedBox(width: 8),
                  _CallButton(onTap: widget.onCall!),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniChip(
                  icon: Icons.map_rounded,
                  text: widget.donor.district,
                  color: AppColors.primaryRed.withOpacity(0.08),
                  textColor: AppColors.primaryRedDark,
                ),
                _MiniChip(
                  icon: Icons.location_city_rounded,
                  text: widget.donor.thana,
                  color: (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                  textColor: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                _MiniChip(
                  icon: Icons.place_rounded,
                  text: widget.donor.area,
                  color: AppColors.primaryRedLight.withOpacity(0.08),
                  textColor: AppColors.primaryRedLight,
                ),
                _MiniChip(
                  icon: widget.donor.isAvailable
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  text: widget.donor.isAvailable ? '🟢 Available' : '🔴 Unavailable',
                  color: widget.donor.isAvailable
                      ? AppColors.safeGreen.withOpacity(0.10)
                      : AppColors.urgentRed.withOpacity(0.10),
                  textColor: widget.donor.isAvailable
                      ? AppColors.safeGreen
                      : AppColors.urgentRed,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * widget.index),
          duration: const Duration(milliseconds: 450),
        )
        .slideY(
          begin: 0.08,
          end: 0,
          delay: Duration(milliseconds: 80 * widget.index),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String bloodGroup;

  const _AvatarFallback({required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        bloodGroup,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _BloodBadge extends StatelessWidget {
  final String bloodGroup;

  const _BloodBadge({required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        bloodGroup,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoLine({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              fontSize: 12.5,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;

  const _MiniChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.safeGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.phone_rounded,
            color: AppColors.safeGreen,
            size: 20,
          ),
        ),
      ),
    );
  }
}
