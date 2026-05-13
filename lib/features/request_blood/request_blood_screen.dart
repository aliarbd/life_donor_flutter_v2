// Request Blood Screen
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animated_button.dart';

class RequestBloodScreen extends StatefulWidget {
  const RequestBloodScreen({super.key});
  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController();
  String _bloodGroup = 'O+';
  String _urgency = 'Normal';
  bool _isLoading = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    _hospitalCtrl.dispose();
    _unitsCtrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    _confetti.play();
    if (mounted) _showSuccess();
  }

  void _showSuccess() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 44),
          ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('Request Submitted!',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 8),
          Text('We\'ll notify nearby donors.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
          const SizedBox(height: 24),
          AnimatedButton(
              text: 'Back to Home',
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/home');
              }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(children: [
        SafeArea(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.arrow_back_rounded,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText))),
              const SizedBox(width: 16),
              Text('Request Blood',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.darkText : AppColors.lightText)),
            ]).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),
            Form(
                key: _formKey,
                child: Column(children: [
                  CustomTextField(
                      controller: _patientCtrl,
                      label: 'Patient Name',
                      prefixIcon: Icons.person_rounded,
                      delay: 1,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                      initialValue: _bloodGroup,
                      decoration: InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(Icons.bloodtype_rounded,
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.lightSubtext)),
                      dropdownColor:
                          isDark ? AppColors.darkCard : AppColors.lightSurface,
                      items: AppConstants.bloodGroups
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _bloodGroup = v!)),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _unitsCtrl,
                      label: 'Units Required',
                      prefixIcon: Icons.format_list_numbered_rounded,
                      keyboardType: TextInputType.number,
                      delay: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _hospitalCtrl,
                      label: 'Hospital Name',
                      prefixIcon: Icons.local_hospital_rounded,
                      delay: 4,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                      initialValue: _urgency,
                      decoration: InputDecoration(
                          labelText: 'Urgency Level',
                          prefixIcon: Icon(Icons.warning_rounded,
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.lightSubtext)),
                      dropdownColor:
                          isDark ? AppColors.darkCard : AppColors.lightSurface,
                      items: AppConstants.urgencyLevels
                          .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _urgency = v!)),
                  const SizedBox(height: 32),
                  AnimatedButton(
                      text: 'Submit Request',
                      isLoading: _isLoading,
                      icon: Icons.send_rounded,
                      onPressed: _submit),
                ])),
          ]),
        )),
        Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primaryRed,
                  AppColors.primaryRedLight,
                  Colors.white
                ])),
      ]),
    );
  }
}
