import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/api_service.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/gradient_button.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});
  @override
  ConsumerState<SymptomCheckerScreen> createState() => _SymptomCheckerState();
}

class _SymptomCheckerState extends ConsumerState<SymptomCheckerScreen> {
  final _symptomsCtrl = TextEditingController();
  String _selectedLang = 'en';
  bool _loading = false;
  bool _offlineMode = false;
  Map<String, dynamic>? _result;

  final _languages = {
    'en': 'English',
    'hi': 'हिंदी',
    'pa': 'ਪੰਜਾਬੀ',
    'ta': 'தமிழ்',
  };

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkSymptoms() async {
    if (_symptomsCtrl.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _result = null; _offlineMode = false; });

    final patientId = ref.read(authProvider)?.id ?? 'guest';
    try {
      final data = await ApiService().checkSymptoms(
        patientId, _symptomsCtrl.text.trim(), _selectedLang);
      setState(() {
        _result = data;
        _offlineMode = data['offline_mode'] == true;
      });
    } catch (_) {
      // If total failure, show offline warning
      setState(() {
        _offlineMode = true;
        _result = {
          'possible_conditions': ['Unable to analyze offline'],
          'severity': 'unknown',
          'immediate_advice': 'Please connect to the internet for a full AI analysis.',
          'see_doctor': true,
          'offline_mode': true,
        };
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _severityColor(String? severity) {
    switch (severity) {
      case 'severe': return AppColors.error;
      case 'moderate': return AppColors.warning;
      case 'mild': return AppColors.success;
      default: return AppColors.textHint;
    }
  }

  IconData _severityIcon(String? severity) {
    switch (severity) {
      case 'severe': return Icons.warning_amber_rounded;
      case 'moderate': return Icons.info_outline_rounded;
      default: return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Language selector
          Text('Language', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _selectedLang, isExpanded: true, style: AppTextStyles.bodyMedium,
              items: _languages.entries.map((e) => DropdownMenuItem(
                value: e.key, child: Text('${e.value} (${e.key})'))).toList(),
              onChanged: (v) => setState(() => _selectedLang = v!),
            )),
          ),
          const SizedBox(height: 20),

          // Symptom input
          Text('Describe Your Symptoms', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            controller: _symptomsCtrl,
            maxLines: 5,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Describe your symptoms in your language...',
              prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 70), child: Icon(Icons.medical_information_rounded, color: AppColors.primary)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 20),

          GradientButton(
            text: _loading ? 'Analyzing...' : 'Check Symptoms',
            icon: Icons.search_rounded,
            onPressed: _loading ? null : _checkSymptoms,
          ),

          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            Center(child: Text('AI is analyzing your symptoms...', style: AppTextStyles.caption)),
          ],

          // Offline warning
          if (_offlineMode) Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4))),
            child: Row(children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Limited offline diagnosis — connect for full AI analysis',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.orange[800]))),
            ]),
          ).animate().fadeIn(),

          // Results
          if (_result != null) ...[
            const SizedBox(height: 24),
            _buildResults(_result!).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          ],
        ]),
      ),
    );
  }

  Widget _buildResults(Map<String, dynamic> data) {
    final conditions = List<String>.from(data['possible_conditions'] ?? []);
    final severity = data['severity'] as String?;
    final advice = data['immediate_advice'] as String?;
    final seeDoctor = data['see_doctor'] == true;
    final scanId = data['scan_id'] as String?;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Conditions chips
      Text('Possible Conditions', style: AppTextStyles.heading4),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: conditions.map((c) => Chip(
        label: Text(c), backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
      )).toList()),

      const SizedBox(height: 16),

      // Severity badge
      if (severity != null) Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: _severityColor(severity).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _severityColor(severity).withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_severityIcon(severity), color: _severityColor(severity), size: 18),
          const SizedBox(width: 6),
          Text('${severity![0].toUpperCase()}${severity.substring(1)} severity',
            style: AppTextStyles.label.copyWith(color: _severityColor(severity))),
        ]),
      ),

      const SizedBox(height: 16),

      // Advice
      if (advice != null) Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.tips_and_updates_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text('Immediate Advice', style: AppTextStyles.bodyBold),
          ]),
          const SizedBox(height: 8),
          Text(advice, style: AppTextStyles.bodyMedium),
        ]),
      ),

      // Transfer to Doctor button
      if (seeDoctor) ...[
        const SizedBox(height: 16),
        GradientButton(
          text: 'Connect to a Doctor',
          icon: Icons.person_search_rounded,
          onPressed: () => Navigator.pop(context, scanId),
        ),
      ],
    ]);
  }
}
