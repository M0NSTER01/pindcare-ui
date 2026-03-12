import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class RecordDetailScreen extends StatelessWidget {
  final String recordType; // consultation, prescription, ai_scan, lab_report
  const RecordDetailScreen({super.key, required this.recordType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_titleForType(recordType)), actions: [
        IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
      ]),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20),
          child: _buildContent(),
        ),
      ),
    );
  }

  String _titleForType(String type) => type == 'consultation' ? 'Consultation Details'
    : type == 'prescription' ? 'Prescription Details'
    : type == 'ai_scan' ? 'AI Scan Report'
    : 'Lab Report';

  Widget _buildContent() {
    switch (recordType) {
      case 'consultation': return _consultationView();
      case 'prescription': return _prescriptionView();
      case 'ai_scan': return _aiScanView();
      case 'lab_report': return _labReportView();
      default: return _consultationView();
    }
  }

  Widget _consultationView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _infoCard([
      _infoRow(Icons.person_rounded, 'Doctor', 'Dr. Amandeep Kaur'),
      _infoRow(Icons.medical_services_rounded, 'Specialization', 'General Physician'),
      _infoRow(Icons.calendar_today_rounded, 'Date', '12 Mar 2024, 10:30 AM'),
      _infoRow(Icons.videocam_rounded, 'Type', 'Video Consultation'),
      _infoRow(Icons.timer_rounded, 'Duration', '15 minutes'),
    ]).animate().fadeIn(duration: 300.ms),
    const SizedBox(height: 16),
    _sectionCard('Symptoms', [
      _chipRow(['Persistent cough', 'Low fever', 'Body ache', 'Headache']),
    ]),
    const SizedBox(height: 16),
    _sectionCard('Diagnosis', [
      _textBlock('Upper Respiratory Tract Infection (URTI)\nMild viral infection. Expected recovery in 5-7 days with prescribed medication.'),
    ]),
    const SizedBox(height: 16),
    _sectionCard('Vitals Recorded', [
      _vitalRow('Temperature', '99.4°F', AppColors.warning),
      _vitalRow('Blood Pressure', '120/80 mmHg', AppColors.success),
      _vitalRow('Heart Rate', '82 bpm', AppColors.success),
      _vitalRow('SpO2', '97%', AppColors.success),
    ]),
    const SizedBox(height: 16),
    _sectionCard('Notes', [
      _textBlock('Patient advised to rest for 3 days. Increase fluid intake. Return if fever persists beyond 5 days. Avoid cold foods.'),
    ]),
  ]);

  Widget _prescriptionView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _infoCard([
      _infoRow(Icons.person_rounded, 'Doctor', 'Dr. Amandeep Kaur'),
      _infoRow(Icons.calendar_today_rounded, 'Date', '12 Mar 2024'),
      _infoRow(Icons.medical_services_rounded, 'Diagnosis', 'URTI'),
    ]).animate().fadeIn(duration: 300.ms),
    const SizedBox(height: 16),
    Text('Medicines', style: AppTextStyles.heading4),
    const SizedBox(height: 12),
    _medicineCard('Paracetamol 500mg', '1 tablet', 'Morning & Night', '5 Days', 'After meals'),
    _medicineCard('Amoxicillin 250mg', '1 capsule', 'Morning, Afternoon & Night', '7 Days', 'After meals'),
    _medicineCard('Cetirizine 10mg', '1 tablet', 'Night only', '5 Days', 'Before sleep'),
    const SizedBox(height: 16),
    _sectionCard('Tests Recommended', [_textBlock('CBC if symptoms persist after 5 days')]),
    const SizedBox(height: 16),
    _sectionCard('Follow-up', [
      _infoRow(Icons.calendar_today_rounded, 'Date', '19 Mar 2024'),
      _infoRow(Icons.info_outline_rounded, 'Note', 'Return if fever >101°F'),
    ]),
  ]);

  Widget _aiScanView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(height: 200, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.image_rounded, size: 48, color: AppColors.textHint.withValues(alpha: 0.5)),
        const SizedBox(height: 8), Text('Scan Image', style: AppTextStyles.caption)]))),
    const SizedBox(height: 16),
    _infoCard([
      _infoRow(Icons.calendar_today_rounded, 'Date', '10 Mar 2024'),
      _infoRow(Icons.camera_alt_rounded, 'Scan Type', 'Skin Analysis'),
    ]).animate().fadeIn(duration: 300.ms),
    const SizedBox(height: 16),
    _sectionCard('AI Analysis', [
      _infoRow(Icons.medical_information_rounded, 'Condition', 'Eczema (Atopic Dermatitis)'),
      _confidenceBar(0.85), _severityChip('Mild'),
    ]),
    const SizedBox(height: 16),
    _sectionCard('AI Reasoning', [
      _textBlock('The image shows a characteristic pattern of dry, inflamed, and itchy patches on the skin. The distribution and morphology are consistent with atopic dermatitis. Redness and mild scaling observed in the affected area.'),
    ]),
    const SizedBox(height: 16),
    _sectionCard('First Aid Steps', [
      _stepItem(1, 'Apply moisturizer (fragrance-free) to the affected area'),
      _stepItem(2, 'Avoid scratching — use cool compress if itchy'),
      _stepItem(3, 'Wear loose cotton clothing'),
      _stepItem(4, 'Consult a dermatologist for prescription treatment'),
    ]),
  ]);

  Widget _labReportView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _infoCard([
      _infoRow(Icons.science_rounded, 'Test', 'Complete Blood Count (CBC)'),
      _infoRow(Icons.local_hospital_rounded, 'Lab', 'City Lab & Diagnostics, Nabha'),
      _infoRow(Icons.calendar_today_rounded, 'Date', '8 Mar 2024'),
      _infoRow(Icons.person_rounded, 'Ordered by', 'Dr. Amandeep Kaur'),
    ]).animate().fadeIn(duration: 300.ms),
    const SizedBox(height: 16),
    Text('Results', style: AppTextStyles.heading4),
    const SizedBox(height: 12),
    _labResultRow('Hemoglobin', '12.5 g/dL', '12.0 - 16.0', true),
    _labResultRow('RBC Count', '4.5 M/µL', '4.0 - 5.5', true),
    _labResultRow('WBC Count', '7,200 /µL', '4,000 - 11,000', true),
    _labResultRow('Platelets', '2.5 L/µL', '1.5 - 4.0', true),
    _labResultRow('ESR', '12 mm/hr', '0 - 20', true),
    const SizedBox(height: 16),
    _sectionCard('Impression', [_textBlock('All values are within normal range. No abnormalities detected.')]),
  ]);

  // Helpers
  Widget _infoCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
    child: Column(children: children));

  Widget _sectionCard(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTextStyles.heading4), const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children))]);

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 10),
      SizedBox(width: 100, child: Text(label, style: AppTextStyles.caption.copyWith(fontSize: 13))),
      Expanded(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)))]));

  Widget _textBlock(String text) => Text(text, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, height: 1.6));

  Widget _chipRow(List<String> items) => Wrap(spacing: 8, runSpacing: 8,
    children: items.map((i) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Text(i, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)))).toList());

  Widget _vitalRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14))),
      Text(value, style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: color))]));

  Widget _medicineCard(String name, String dosage, String timing, String duration, String instructions) =>
    Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
        const SizedBox(height: 6),
        Row(children: [
          _miniTag('💊 $dosage'), const SizedBox(width: 8), _miniTag('🕐 $timing')]),
        const SizedBox(height: 4),
        Row(children: [
          _miniTag('📅 $duration'), const SizedBox(width: 8), _miniTag('ℹ️ $instructions')])]));

  Widget _miniTag(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: AppTextStyles.caption.copyWith(fontSize: 11)));

  Widget _confidenceBar(double value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Confidence: ${(value * 100).toInt()}%', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: value, backgroundColor: AppColors.surfaceVariant,
        color: value > 0.7 ? AppColors.success : AppColors.warning, minHeight: 6,
        borderRadius: BorderRadius.circular(3))]));

  Widget _severityChip(String severity) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: severity == 'Mild' ? AppColors.success.withValues(alpha: 0.1)
      : severity == 'Moderate' ? AppColors.warning.withValues(alpha: 0.1)
      : AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Text('Severity: $severity', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700,
      color: severity == 'Mild' ? AppColors.success : severity == 'Moderate' ? AppColors.warning : AppColors.error)));

  Widget _stepItem(int num, String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Center(child: Text('$num', style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)))]));

  Widget _labResultRow(String test, String value, String reference, bool normal) =>
    Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(
          color: normal ? AppColors.success : AppColors.error, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(test, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)),
          Text('Ref: $reference', style: AppTextStyles.caption.copyWith(fontSize: 11))])),
        Text(value, style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: normal ? AppColors.success : AppColors.error))]));
}
