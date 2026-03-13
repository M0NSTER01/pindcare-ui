import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/api_service.dart';
import '../../shared/providers/asha_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/gradient_button.dart';

class ManagedPatientsScreen extends ConsumerStatefulWidget {
  const ManagedPatientsScreen({super.key});
  @override
  ConsumerState<ManagedPatientsScreen> createState() => _ManagedPatientsState();
}

class _ManagedPatientsState extends ConsumerState<ManagedPatientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ashaProvider.notifier).loadManagedPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ashaProvider);
    final selectedPatient = state.selectedPatient;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Patients')),
      body: Column(children: [
        // Agent mode banner
        if (selectedPatient != null) Container(
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Icon(Icons.person_pin_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Acting as: ${selectedPatient.name}',
              style: AppTextStyles.bodyBold.copyWith(color: Colors.white))),
            TextButton(
              onPressed: () => ref.read(ashaProvider.notifier).exitAgentMode(),
              child: const Text('Exit', style: TextStyle(color: Colors.white70)),
            ),
          ]),
        ),

        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.managedPatients.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text('No managed patients yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('Tap + to add a patient', style: AppTextStyles.caption),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.managedPatients.length,
                      itemBuilder: (_, i) => _patientCard(state.managedPatients[i], i),
                    ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Patient'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _patientCard(PatientModel patient, int index) {
    final isSelected = ref.watch(ashaProvider).selectedPatient?.id == patient.id;
    return GestureDetector(
      onTap: () => ref.read(ashaProvider.notifier).selectPatient(patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground, borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: Center(child: Text(patient.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase(),
              style: AppTextStyles.bodyBold.copyWith(color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
            Text('${patient.age} · ${patient.gender}', style: AppTextStyles.caption),
            Text(patient.village, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          ])),
          if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 60), duration: 300.ms);
  }

  void _showAddPatientDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String gender = 'Male';
    String blood = 'B+';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (_, setSheet) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: BoxDecoration(color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add Patient', style: AppTextStyles.heading4),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 12),
          TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_rounded))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: gender, decoration: const InputDecoration(labelText: 'Gender'),
            items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setSheet(() => gender = v!),
          ),
          const SizedBox(height: 20),
          GradientButton(text: 'Add Patient', icon: Icons.check_rounded, onPressed: () async {
            if (nameCtrl.text.trim().isEmpty) return;
            await ref.read(ashaProvider.notifier).addPatient({
              'name': nameCtrl.text.trim(),
              'age': int.tryParse(ageCtrl.text.trim()) ?? 0,
              'gender': gender,
            });
            if (ctx.mounted) Navigator.pop(ctx);
          }),
        ]),
      )));
  }
}
