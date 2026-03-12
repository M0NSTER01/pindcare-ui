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
import '../../data/models/family_member_model.dart';
import '../../shared/providers/active_member_provider.dart';
import '../../shared/providers/role_provider.dart';
import '../../shared/widgets/gradient_button.dart';

class AshaRegistrationScreen extends ConsumerStatefulWidget {
  const AshaRegistrationScreen({super.key});

  @override
  ConsumerState<AshaRegistrationScreen> createState() => _AshaRegistrationScreenState();
}

class _AshaRegistrationScreenState extends ConsumerState<AshaRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _ashaIdCtrl = TextEditingController();

  String _gender = 'Female';
  String _bloodGroup = 'B+';
  final Set<String> _chronicConditions = {};
  final List<FamilyMemberModel> _familyMembers = [];

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
    _ashaIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = const Uuid().v4();
    final user = UserModel(
      id: userId,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      role: 'asha',
      village: _villageCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      state: 'Punjab',
      bloodGroup: _bloodGroup,
      emergencyContactName: _emergencyNameCtrl.text.trim(),
      emergencyContact: _emergencyPhoneCtrl.text.trim(),
      chronicConditions: _chronicConditions.where((c) => c != 'None').toList(),
      allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
      ashaWorkerId: _ashaIdCtrl.text.trim().isEmpty ? null : _ashaIdCtrl.text.trim(),
    );

    await HiveService.put(HiveService.usersBox, user.id, user.toMap());

    // Save primary member (self)
    final primaryMember = FamilyMemberModel(
      id: userId,
      name: user.name,
      age: int.tryParse(_ageCtrl.text) ?? 30,
      gender: user.gender,
      relation: 'self',
      bloodGroup: user.bloodGroup,
      chronicConditions: user.chronicConditions,
      allergies: user.allergies,
    );
    await HiveService.put(HiveService.ashaMembersBox, primaryMember.id, primaryMember.toMap());

    // Save family members
    for (final member in _familyMembers) {
      await HiveService.put(HiveService.ashaMembersBox, member.id, member.toMap());
    }

    await HiveService.setUserRole('asha');
    await HiveService.setRegistrationComplete(true);
    await HiveService.setActiveMemberId(userId);
    ref.read(roleProvider.notifier).state = 'asha';
    ref.read(activeMemberProvider.notifier).switchMember(userId);

    if (mounted) context.go('/home');
  }

  void _showAddMemberSheet() {
    if (_familyMembers.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 family members allowed')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String gender = 'Female';
    String relation = 'Spouse';
    String bloodGroup = 'B+';
    final allergiesCtrl = TextEditingController();
    final conditions = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (ctx, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Add Family Member', style: AppTextStyles.heading3),
                      const SizedBox(height: 24),
                      _buildLabel('Name *'),
                      _buildSheetTextField(nameCtrl, 'Member name', Icons.person_rounded),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Age *'),
                                _buildSheetTextField(ageCtrl, 'Age', Icons.cake_rounded,
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
                                _buildSheetDropdown(gender, ['Male', 'Female', 'Other'],
                                    (v) => setSheetState(() => gender = v!)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Relation'),
                      _buildSheetDropdown(
                        relation,
                        ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'],
                        (v) => setSheetState(() => relation = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Blood Group'),
                      _buildSheetDropdown(
                        bloodGroup,
                        _bloodGroups,
                        (v) => setSheetState(() => bloodGroup = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Chronic Conditions'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _conditions.map((c) {
                          final selected = conditions.contains(c);
                          return FilterChip(
                            label: Text(c),
                            selected: selected,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.primary,
                            labelStyle: AppTextStyles.labelSmall.copyWith(
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            onSelected: (val) {
                              setSheetState(() {
                                if (c == 'None') {
                                  conditions.clear();
                                  if (val) conditions.add('None');
                                } else {
                                  conditions.remove('None');
                                  val ? conditions.add(c) : conditions.remove(c);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Allergies'),
                      _buildSheetTextField(allergiesCtrl, 'Known allergies', Icons.warning_amber_rounded),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: 'Add Member',
                        icon: Icons.person_add_rounded,
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty || ageCtrl.text.trim().isEmpty) {
                            return;
                          }
                          final member = FamilyMemberModel(
                            id: const Uuid().v4(),
                            name: nameCtrl.text.trim(),
                            age: int.tryParse(ageCtrl.text) ?? 0,
                            gender: gender,
                            relation: relation.toLowerCase(),
                            bloodGroup: bloodGroup,
                            chronicConditions:
                                conditions.where((c) => c != 'None').toList(),
                            allergies: allergiesCtrl.text.trim().isEmpty
                                ? null
                                : allergiesCtrl.text.trim(),
                          );
                          setState(() => _familyMembers.add(member));
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
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
        title: const Text('ASHA / Family Registration'),
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
                // Primary user info
                Text('Your Information', style: AppTextStyles.heading3)
                    .animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 16),

                _buildLabel('Full Name *'),
                _buildFormField(_nameCtrl, 'Your full name', Icons.person_rounded),
                const SizedBox(height: 16),

                _buildLabel('Phone *'),
                _buildFormField(_phoneCtrl, '+91 98765 43210', Icons.phone_rounded,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Age *'),
                          _buildFormField(_ageCtrl, 'Age', Icons.cake_rounded,
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
                          _buildDropdown(
                              _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v!)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Village / Town *'),
                _buildFormField(_villageCtrl, 'Village or town name', Icons.location_on_rounded),
                const SizedBox(height: 16),

                _buildLabel('District'),
                _buildFormField(_districtCtrl, 'District', Icons.map_rounded, required: false),
                const SizedBox(height: 16),

                _buildLabel('Blood Group'),
                _buildDropdown(_bloodGroup, _bloodGroups, (v) => setState(() => _bloodGroup = v!)),
                const SizedBox(height: 16),

                _buildLabel('Emergency Contact Name'),
                _buildFormField(_emergencyNameCtrl, 'Contact person', Icons.emergency_rounded,
                    required: false),
                const SizedBox(height: 16),

                _buildLabel('Emergency Contact Phone'),
                _buildFormField(_emergencyPhoneCtrl, 'Phone number', Icons.phone_in_talk_rounded,
                    keyboardType: TextInputType.phone, required: false),
                const SizedBox(height: 16),

                _buildLabel('ASHA Worker ID (Optional)'),
                _buildFormField(_ashaIdCtrl, 'Official ASHA ID', Icons.badge_rounded, required: false),
                const SizedBox(height: 16),

                _buildLabel('Chronic Conditions'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _conditions.map((c) {
                    final selected = _chronicConditions.contains(c);
                    return FilterChip(
                      label: Text(c),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      onSelected: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (c == 'None') {
                            _chronicConditions.clear();
                            if (val) _chronicConditions.add('None');
                          } else {
                            _chronicConditions.remove('None');
                            val ? _chronicConditions.add(c) : _chronicConditions.remove(c);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _buildLabel('Known Allergies'),
                _buildFormField(_allergiesCtrl, 'List any allergies', Icons.warning_amber_rounded,
                    required: false),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // Family Members Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Family Members', style: AppTextStyles.heading3),
                    Text('${_familyMembers.length}/10',
                        style: AppTextStyles.label.copyWith(color: AppColors.textHint)),
                  ],
                ),
                const SizedBox(height: 12),

                if (_familyMembers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.family_restroom_rounded,
                              size: 48, color: AppColors.textHint.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('No family members added yet',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _familyMembers.length,
                      itemBuilder: (context, index) {
                        final member = _familyMembers[index];
                        return Padding(
                          padding: EdgeInsets.only(right: index < _familyMembers.length - 1 ? 12 : 0),
                          child: GestureDetector(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Remove Member?'),
                                  content: Text('Remove ${member.name} from family?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() => _familyMembers.removeAt(index));
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Remove', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        member.initials,
                                        style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    member.name,
                                    style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w600, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      member.relation,
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10,
                                        color: AppColors.secondaryDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(
                                delay: Duration(milliseconds: index * 100), duration: 300.ms),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                // Add member button
                OutlinedButton.icon(
                  onPressed: _showAddMemberSheet,
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Add Family Member'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),

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

  Widget _buildFormField(
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

  Widget _buildSheetTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  Widget _buildSheetDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
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
