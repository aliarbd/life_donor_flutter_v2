// Map Screen - Mock map UI with animated pins
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int? _selectedPin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(20),
            child: Row(children: [
              Text('Nearby Donors', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                child: Text('${MockData.donors.length} nearby', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
            ]).animate().fadeIn(duration: 400.ms)),

          // Mock map area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1a2332) : const Color(0xFFe8f0fe),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
              ),
              child: Stack(children: [
                // Grid lines
                ...List.generate(6, (i) => Positioned(top: (i + 1) * 60.0, left: 0, right: 0,
                  child: Container(height: 1, color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.1)))),
                ...List.generate(5, (i) => Positioned(left: (i + 1) * 70.0, top: 0, bottom: 0,
                  child: Container(width: 1, color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.1)))),

                // Center "You" marker
                Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: const Color(0xFF0984E3).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFF0984E3), width: 2)),
                    child: const Icon(Icons.my_location_rounded, color: Color(0xFF0984E3), size: 22)),
                  const SizedBox(height: 4),
                  Text('You', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText)),
                ]).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.95, end: 1.05, duration: 1500.ms)),

                // Donor pins
                ..._buildPins(isDark),

                // Selected donor info overlay
                if (_selectedPin != null)
                  Positioned(bottom: 16, left: 16, right: 16,
                    child: _donorInfoCard(MockData.donors[_selectedPin!], isDark)),
              ]),
            ),
          ),

          // Legend
          Padding(padding: const EdgeInsets.all(20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _legend(const Color(0xFF0984E3), 'Your Location', isDark),
              _legend(AppColors.primaryRed, 'Donors', isDark),
              _legend(AppColors.safeGreen, 'Available', isDark),
            ]).animate().fadeIn(delay: 600.ms)),
        ]),
      ),
    );
  }

  List<Widget> _buildPins(bool isDark) {
    final positions = [
      const Offset(0.2, 0.25), const Offset(0.7, 0.15), const Offset(0.15, 0.6),
      const Offset(0.75, 0.45), const Offset(0.4, 0.75), const Offset(0.85, 0.7),
      const Offset(0.3, 0.4), const Offset(0.6, 0.6), const Offset(0.5, 0.2),
      const Offset(0.25, 0.85), const Offset(0.8, 0.3), const Offset(0.55, 0.5),
    ];
    return List.generate(MockData.donors.length.clamp(0, positions.length), (i) {
      final pos = positions[i];
      return Positioned.fill(
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            Positioned(
              left: pos.dx * constraints.maxWidth - 18,
              top: pos.dy * constraints.maxHeight - 18,
              child: GestureDetector(
                onTap: () => setState(() => _selectedPin = _selectedPin == i ? null : i),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [BoxShadow(color: AppColors.primaryRed.withOpacity(0.4), blurRadius: 8)],
                    border: Border.all(color: Colors.white, width: 2)),
                  child: Center(child: Text(MockData.donors[i].bloodGroup,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))),
              ).animate().scale(delay: Duration(milliseconds: 200 + (i * 80)),
                begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
            ),
          ]);
        }),
      );
    });
  }

  Widget _donorInfoCard(donor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)]),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(donor.bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(donor.name, style: TextStyle(fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText)),
          Text('${donor.distance} km away • ${donor.location}',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
        ])),
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.safeGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.phone_rounded, color: AppColors.safeGreen, size: 20)),
      ]),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _legend(Color color, String label, bool isDark) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
    ]);
  }
}
