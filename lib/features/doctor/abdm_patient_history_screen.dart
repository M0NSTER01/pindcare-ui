import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/abdm_service.dart';
import '../../data/models/abha_record_model.dart';
import '../../shared/widgets/gradient_button.dart';

class AbdmPatientHistoryScreen extends StatefulWidget {
  const AbdmPatientHistoryScreen({super.key});
  @override
  State<AbdmPatientHistoryScreen> createState() => _State();
}

class _State extends State<AbdmPatientHistoryScreen> {
  int _step = 0; // 0=search, 1=consent, 2=fetching, 3=records
  final _abhaCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  ABDMFetchResult? _result;
  String _recordFilter = 'All';

  @override
  void dispose() { _abhaCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _sendConsent() async {
    if (_abhaCtrl.text.trim().isEmpty) return;
    setState(() => _step = 1);
    await ABDMService.instance.sendConsentRequest(_abhaCtrl.text.trim(), _phoneCtrl.text.trim());
    setState(() => _step = 2);
    final result = await ABDMService.instance.fetchPatientRecords(_abhaCtrl.text.trim());
    setState(() { _result = result; _step = 3; });
  }

  List<AbhaRecordModel> get _filteredRecords {
    if (_result == null) return [];
    if (_recordFilter == 'All') return _result!.records;
    final typeMap = {'Diagnoses': 'condition', 'Prescriptions': 'medication', 'Lab Reports': 'diagnostic', 'Scans': 'imaging'};
    return _result!.records.where((r) => r.type == typeMap[_recordFilter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ABDM Patient History')),
      body: SafeArea(child: [_buildSearch, _buildConsent, _buildFetching, _buildRecords][_step]()),
    );
  }

  Widget _buildSearch() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text('Enter patient\'s ABHA ID or number to fetch their health records from ABDM network.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary))),
        ])).animate().fadeIn(duration: 300.ms),
      const SizedBox(height: 24),
      Text('ABHA ID / Number', style: AppTextStyles.label),
      const SizedBox(height: 8),
      TextFormField(controller: _abhaCtrl, style: AppTextStyles.bodyMedium,
        decoration: const InputDecoration(hintText: '12-3456-7890-1234 or name@abdm', prefixIcon: Icon(Icons.badge_rounded, color: AppColors.primary))),
      const SizedBox(height: 16),
      Text('Patient Phone (for consent)', style: AppTextStyles.label),
      const SizedBox(height: 8),
      TextFormField(controller: _phoneCtrl, style: AppTextStyles.bodyMedium, keyboardType: TextInputType.phone,
        decoration: const InputDecoration(hintText: '+91 98765 43210', prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary))),
      const SizedBox(height: 32),
      GradientButton(text: 'Send Consent Request', icon: Icons.send_rounded, onPressed: _sendConsent),
    ]),
  );

  Widget _buildConsent() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 100,
        decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: const Icon(Icons.mark_email_read_rounded, color: AppColors.secondary, size: 48))
        .animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
      const SizedBox(height: 24),
      Text('Consent Request Sent', style: AppTextStyles.heading3).animate().fadeIn(delay: 300.ms),
      const SizedBox(height: 8),
      Text('Waiting for patient to approve...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)).animate().fadeIn(delay: 400.ms),
      const SizedBox(height: 32),
      const CircularProgressIndicator(color: AppColors.primary),
    ]),
  );

  Widget _buildFetching() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 100,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: const Icon(Icons.cloud_download_rounded, color: AppColors.primary, size: 48))
        .animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
        .then().shimmer(duration: 1500.ms),
      const SizedBox(height: 24),
      Text('Fetching Records...', style: AppTextStyles.heading3).animate().fadeIn(delay: 300.ms),
      const SizedBox(height: 8),
      Text('Pulling data from ABDM network', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)).animate().fadeIn(delay: 400.ms),
      const SizedBox(height: 32),
      const CircularProgressIndicator(color: AppColors.primary),
    ]),
  );

  Widget _buildRecords() {
    if (_result == null) return const SizedBox.shrink();
    final filters = ['All', 'Diagnoses', 'Prescriptions', 'Lab Reports', 'Scans'];
    return Column(children: [
      // Patient info header
      Container(margin: const EdgeInsets.fromLTRB(16, 8, 16, 0), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text('SK', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_result!.patientName, style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
            Text('ABHA: ${_result!.abhaId}', style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
            Text('${_result!.gender} • ${_result!.bloodGroup} • DOB: ${_result!.dateOfBirth}',
              style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          ])),
        ])).animate().fadeIn(duration: 300.ms),
      const SizedBox(height: 12),
      // Filter tabs
      SizedBox(height: 40, child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i]; final sel = f == _recordFilter;
          return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(f), selected: sel,
            selectedColor: AppColors.primary.withValues(alpha: 0.15), checkmarkColor: AppColors.primary,
            labelStyle: AppTextStyles.labelSmall.copyWith(color: sel ? AppColors.primary : AppColors.textSecondary, fontSize: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: sel ? AppColors.primary : AppColors.divider)),
            onSelected: (_) => setState(() => _recordFilter = f)));
        })),
      const SizedBox(height: 8),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filteredRecords.length,
        itemBuilder: (_, i) => _recordCard(_filteredRecords[i], i))),
    ]);
  }

  Widget _recordCard(AbhaRecordModel record, int index) {
    final typeColor = record.type == 'condition' ? AppColors.error
      : record.type == 'medication' ? AppColors.accent
      : record.type == 'diagnostic' ? AppColors.primary
      : AppColors.secondary;
    final typeIcon = record.type == 'condition' ? Icons.medical_information_rounded
      : record.type == 'medication' ? Icons.medication_rounded
      : record.type == 'diagnostic' ? Icons.science_rounded
      : Icons.image_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(typeIcon, color: typeColor, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(record.typeLabel, style: AppTextStyles.caption.copyWith(color: typeColor, fontWeight: FontWeight.w700, fontSize: 11))),
            const SizedBox(height: 4),
            Text(record.summary, style: AppTextStyles.bodyBold.copyWith(fontSize: 14), maxLines: 2),
          ])),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.local_hospital_rounded, size: 14, color: AppColors.textHint),
          const SizedBox(width: 4),
          Expanded(child: Text(record.facilityName, style: AppTextStyles.caption.copyWith(fontSize: 12))),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text('${record.date.day}/${record.date.month}/${record.date.year}', style: AppTextStyles.caption.copyWith(fontSize: 12)),
          if (record.doctorName != null) ...[
            const SizedBox(width: 12),
            Icon(Icons.person_rounded, size: 14, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(record.doctorName!, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ],
        ]),
        if (record.details != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
            color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
            child: Text(record.details!, style: AppTextStyles.bodySmall.copyWith(fontSize: 13), maxLines: 4, overflow: TextOverflow.ellipsis)),
        ],
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100), duration: 300.ms);
  }
}
