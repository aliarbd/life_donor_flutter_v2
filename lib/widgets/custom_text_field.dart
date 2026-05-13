// ============================================================
// Custom Text Field - Floating label animated input
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int delay;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.delay = 0,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.darkCard : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            if (_isFocused)
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.16),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          cursorColor: AppColors.primaryRed,
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            filled: true,
            fillColor: isDark ? AppColors.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.primaryRed
                        : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            labelStyle: TextStyle(
              color: _isFocused
                  ? AppColors.primaryRed
                  : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
              fontWeight: _isFocused ? FontWeight.w500 : FontWeight.w400,
            ),
            floatingLabelStyle: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * widget.delay),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(
          begin: -0.05,
          end: 0,
          delay: Duration(milliseconds: 100 * widget.delay),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }
}
