import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/doctor_model.dart';
import '../../shared/providers/role_provider.dart';
import '../../shared/widgets/gradient_button.dart';

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends ConsumerState<DoctorRegistrationScreen> {
  int _currentStep = 0;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  // Step 1
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _gender = 'Male';
  String? _dob;

  // Step 2
  final _regNumberCtrl = TextEditingController();
  String _specialization = 'General Physician';
  final _experienceCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _clinicAddressCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '200');

  // Step 3
  bool _degreeCertUploaded = false;
  bool _regCertUploaded = false;
  bool _submitted = false;

  final List<String> _specializations = [
    'General Physician', 'Dermatologist', 'Pediatrician', 'Orthopedic',
    'Gynecologist', 'Cardiologist', 'ENT Specialist', 'Ophthalmologist',
    'Neurologist', 'Psychiatrist', 'Dentist', 'Surgeon', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _regNumberCtrl.dispose();
    _experienceCtrl.dispose();
    _hospitalCtrl.dispose();
    _clinicAddressCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _submit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final doctor = DoctorModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      dateOfBirth: _dob,
      gender: _gender,
      registrationNumber: _regNumberCtrl.text.trim(),
      specialization: _specialization,
      yearsOfExperience: int.tryParse(_experienceCtrl.text) ?? 0,
      hospitalName: _hospitalCtrl.text.trim().isEmpty ? null : _hospitalCtrl.text.trim(),
      clinicAddress: _clinicAddressCtrl.text.trim().isEmpty ? null : _clinicAddressCtrl.text.trim(),
      consultationFee: double.tryParse(_feeCtrl.text) ?? 200,
      verificationStatus: 'pending',
    );

    await HiveService.put(HiveService.doctorsBox, doctor.id, doctor.toMap());
    await HiveService.setUserRole('doctor');
    await HiveService.setRegistrationComplete(true);
    ref.read(roleProvider.notifier).state = 'doctor';

    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildPendingScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prevStep,
        ),
        title: const Text('Doctor Registration'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            _buildStepIndicator(),
            const SizedBox(height: 16),
            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: [_buildStep1, _buildStep2, _buildStep3][_currentStep](),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24),
              child: GradientButton(
                text: _currentStep == 2 ? 'Submit for Verification' : 'Continue',
                icon: _currentStep == 2 ? Icons.verified_rounded : Icons.arrow_forward_rounded,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _currentStep;
          final isCurrent = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: i < _currentStep
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${i + 1}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive ? Colors.white : AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < _currentStep ? AppColors.primary : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTextStyles.heading3)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Text('Tell us about yourself', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('Full Name *'),
          _buildTextField(_nameCtrl, 'Dr. Full Name', Icons.person_rounded),
          const SizedBox(height: 16),
          _buildLabel('Phone *'),
          _buildTextField(_phoneCtrl, '+91 98765 43210', Icons.phone_rounded,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildLabel('Email'),
          _buildTextField(_emailCtrl, 'doctor@email.com', Icons.email_rounded,
              required: false, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Date of Birth'),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1990),
                          firstDate: DateTime(1940),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _dob = '${date.day}/${date.month}/${date.year}');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _dob ?? 'Select DOB',
                              style: _dob != null
                                  ? AppTextStyles.bodyMedium
                                  : AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Gender'),
                    _buildDropdown(_gender, ['Male', 'Female', 'Other'],
                        (v) => setState(() => _gender = v!)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Information', style: AppTextStyles.heading3)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Text('Your medical credentials', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          _buildLabel('Medical Registration Number (MCI/State) *'),
          _buildTextField(_regNumberCtrl, 'e.g., MCI-12345', Icons.badge_rounded),
          const SizedBox(height: 16),
          _buildLabel('Specialization *'),
          _buildDropdown(
              _specialization, _specializations, (v) => setState(() => _specialization = v!)),
          const SizedBox(height: 16),
          _buildLabel('Years of Experience'),
          _buildTextField(_experienceCtrl, 'e.g., 5', Icons.work_history_rounded,
              required: false, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildLabel('Hospital / Clinic Name'),
          _buildTextField(_hospitalCtrl, 'Hospital or clinic name', Icons.local_hospital_rounded,
              required: false),
          const SizedBox(height: 16),
          _buildLabel('Clinic Address'),
          _buildTextField(_clinicAddressCtrl, 'Full clinic address', Icons.location_on_rounded,
              required: false),
          const SizedBox(height: 16),
          _buildLabel('Consultation Fee (₹)'),
          _buildTextField(_feeCtrl, '200', Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification Documents', style: AppTextStyles.heading3)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Text('Upload your credentials for verification', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          _buildUploadCard(
            'Medical Degree Certificate',
            'Upload your MBBS/MD/MS certificate',
            Icons.school_rounded,
            _degreeCertUploaded,
            () => setState(() => _degreeCertUploaded = true),
          ),
          const SizedBox(height: 16),
          _buildUploadCard(
            'Registration Certificate',
            'Upload your MCI/State registration',
            Icons.verified_user_rounded,
            _regCertUploaded,
            () => setState(() => _regCertUploaded = true),
          ),
          const SizedBox(height: 24),
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Verification takes 24-48 hours. You can start exploring the app while we verify your credentials.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUploadCard(
      String title, String subtitle, IconData icon, bool uploaded, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: uploaded
              ? AppColors.successLight
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: uploaded ? AppColors.success : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: uploaded
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                uploaded ? Icons.check_circle_rounded : icon,
                color: uploaded ? AppColors.success : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(
                    uploaded ? 'Document uploaded ✓' : subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: uploaded ? AppColors.success : null,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: uploaded ? AppColors.success : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: AppColors.secondary, size: 56),
              ).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text('Verification Pending', style: AppTextStyles.heading2, textAlign: TextAlign.center)
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              Text(
                'Your documents have been submitted. We will verify your credentials within 24-48 hours.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
              GradientButton(
                text: 'Explore App',
                icon: Icons.explore_rounded,
                onPressed: () => context.go('/doctor/dashboard'),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.label),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: AppTextStyles.bodyMedium,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
