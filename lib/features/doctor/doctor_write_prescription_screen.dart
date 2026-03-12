import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

class DoctorWritePrescriptionScreen extends StatefulWidget {
  const DoctorWritePrescriptionScreen({super.key});
  @override
  State<DoctorWritePrescriptionScreen> createState() => _State();
}

class _MedEntry {
  String name = '', dosage = '1', durationVal = '7', durationUnit = 'Days', instructions = '';
  bool morning = true, afternoon = false, night = true;
}

class _State extends State<DoctorWritePrescriptionScreen> {
  final _diagnosisCtrl = TextEditingController();
  final _testsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _followUpDate;
  final List<_MedEntry> _meds = [_MedEntry()];

  @override
  void dispose() { _diagnosisCtrl.dispose(); _testsCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Write Prescription')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _patientCard(),
            const SizedBox(height: 20),
            _label('Diagnosis *'),
            TextFormField(controller: _diagnosisCtrl, maxLines: 3, style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(hintText: 'Enter diagnosis...')),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Medicines', style: AppTextStyles.heading4),
              Text('${_meds.length} added', style: AppTextStyles.caption),
            ]),
            const SizedBox(height: 12),
            ..._meds.asMap().entries.map((e) => _medCard(e.value, e.key)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () { HapticFeedback.lightImpact(); setState(() => _meds.add(_MedEntry())); },
              icon: const Icon(Icons.add_rounded), label: const Text('Add Medicine'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
            const SizedBox(height: 20),
            _label('Tests Recommended'),
            TextFormField(controller: _testsCtrl, maxLines: 2, style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(hintText: 'CBC, Blood Sugar...')),
            const SizedBox(height: 20),
            _label('Follow-up Date'),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setState(() => _followUpDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(_followUpDate != null
                    ? '${_followUpDate!.day}/${_followUpDate!.month}/${_followUpDate!.year}'
                    : 'Select date',
                    style: _followUpDate != null ? AppTextStyles.bodyMedium
                      : AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            _label('Notes'),
            TextFormField(controller: _notesCtrl, maxLines: 3, style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(hintText: 'Special instructions...')),
            const SizedBox(height: 32),
            GradientButton(text: 'Save Prescription', icon: Icons.save_rounded, onPressed: () {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Prescription saved'), backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
              Navigator.pop(context);
            }),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _patientCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: Center(child: Text('RS', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Rajinder Singh', style: AppTextStyles.bodyBold),
        Text('45 yrs • Male • B+ • Nabha', style: AppTextStyles.caption.copyWith(fontSize: 13)),
      ])),
    ]),
  ).animate().fadeIn(duration: 300.ms);

  Widget _medCard(_MedEntry med, int i) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Medicine ${i + 1}', style: AppTextStyles.label), const Spacer(),
        if (_meds.length > 1) GestureDetector(onTap: () { HapticFeedback.lightImpact(); setState(() => _meds.removeAt(i)); },
          child: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 22)),
      ]),
      const SizedBox(height: 12),
      TextFormField(style: AppTextStyles.bodyMedium, decoration: const InputDecoration(hintText: 'Medicine name',
        prefixIcon: Icon(Icons.medication_rounded, color: AppColors.primary, size: 20)), onChanged: (v) => med.name = v),
      const SizedBox(height: 10),
      Row(children: [
        _chip('½', med.dosage == '½', () => setState(() => med.dosage = '½'), AppColors.primary),
        _chip('1', med.dosage == '1', () => setState(() => med.dosage = '1'), AppColors.primary),
        _chip('2', med.dosage == '2', () => setState(() => med.dosage = '2'), AppColors.primary),
        const SizedBox(width: 8), const Text('×'), const SizedBox(width: 8),
        _chip('M', med.morning, () => setState(() => med.morning = !med.morning), AppColors.accent),
        _chip('A', med.afternoon, () => setState(() => med.afternoon = !med.afternoon), AppColors.accent),
        _chip('N', med.night, () => setState(() => med.night = !med.night), AppColors.accent),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextFormField(style: AppTextStyles.bodyMedium, decoration: const InputDecoration(hintText: 'Duration'),
          keyboardType: TextInputType.number, onChanged: (v) => med.durationVal = v)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(
          color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: med.durationUnit, style: AppTextStyles.bodyMedium,
            items: ['Days', 'Weeks'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => med.durationUnit = v!)))),
      ]),
    ]),
  );

  Widget _chip(String text, bool sel, VoidCallback tap, Color color) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); tap(); },
    child: Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(color: sel ? color : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(text, style: AppTextStyles.labelSmall.copyWith(
        color: sel ? Colors.white : AppColors.textSecondary, fontSize: 13)))),
  );

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: AppTextStyles.label));
}
