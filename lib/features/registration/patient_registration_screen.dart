import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/user_model.dart';
import '../../shared/providers/role_provider.dart';
import '../../shared/widgets/gradient_button.dart';

class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  ConsumerState<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends ConsumerState<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'B+';
  final Set<String> _chronicConditions = {};

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _conditions = ['Diabetes', 'Hypertension', 'Asthma', 'Heart Disease', 'None'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _villageCtrl.dispose();
    _districtCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      role: 'patient',
      village: _villageCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      state: 'Punjab',
      bloodGroup: _bloodGroup,
      emergencyContactName: _emergencyNameCtrl.text.trim(),
      emergencyContact: _emergencyPhoneCtrl.text.trim(),
      chronicConditions: _chronicConditions.where((c) => c != 'None').toList(),
      allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
    );

    await HiveService.put(HiveService.usersBox, user.id, user.toMap());
    await HiveService.setUserRole('patient');
    await HiveService.setRegistrationComplete(true);
    ref.read(roleProvider.notifier).state = 'patient';

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Patient Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo placeholder
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
                ).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
                const SizedBox(height: 8),
                Center(
                  child: Text('Add Photo (Optional)', style: AppTextStyles.caption),
                ),
                const SizedBox(height: 24),

                _buildLabel('Full Name'),
                _buildTextField(_nameCtrl, 'Enter your full name', Icons.person_rounded),
                const SizedBox(height: 16),

                _buildLabel('Phone Number'),
                _buildTextField(_phoneCtrl, '+91 98765 43210', Icons.phone_rounded,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Age'),
                          _buildTextField(_ageCtrl, 'Age', Icons.cake_rounded,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Gender'),
                          _buildDropdown(_gender, _genders, (v) => setState(() => _gender = v!)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Village / Town'),
                _buildTextField(_villageCtrl, 'Enter village or town name', Icons.location_on_rounded),
                const SizedBox(height: 16),

                _buildLabel('District'),
                _buildTextField(_districtCtrl, 'Enter district', Icons.map_rounded),
                const SizedBox(height: 16),

                _buildLabel('Blood Group'),
                _buildDropdown(_bloodGroup, _bloodGroups, (v) => setState(() => _bloodGroup = v!)),
                const SizedBox(height: 16),

                _buildLabel('Emergency Contact Name'),
                _buildTextField(_emergencyNameCtrl, 'Contact person name', Icons.emergency_rounded),
                const SizedBox(height: 16),

                _buildLabel('Emergency Contact Phone'),
                _buildTextField(_emergencyPhoneCtrl, '+91 98765 43210', Icons.phone_in_talk_rounded,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 24),

                _buildLabel('Chronic Conditions'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _conditions.map((condition) {
                    final selected = _chronicConditions.contains(condition);
                    return FilterChip(
                      label: Text(condition),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      onSelected: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (condition == 'None') {
                            _chronicConditions.clear();
                            if (val) _chronicConditions.add('None');
                          } else {
                            _chronicConditions.remove('None');
                            val
                                ? _chronicConditions.add(condition)
                                : _chronicConditions.remove(condition);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _buildLabel('Known Allergies'),
                _buildTextField(_allergiesCtrl, 'List any known allergies', Icons.warning_amber_rounded,
                    required: false),
                const SizedBox(height: 32),

                GradientButton(
                  text: 'Complete Registration',
                  icon: Icons.check_circle_rounded,
                  onPressed: _register,
                ),
                const SizedBox(height: 40),
              ],
            ),
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
