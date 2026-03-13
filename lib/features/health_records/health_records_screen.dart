import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/health_record_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/sync_service.dart';
import '../../shared/providers/auth_provider.dart';
import '../../config/api_config.dart';

class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});
  @override
  ConsumerState<HealthRecordsScreen> createState() => _HealthRecordsState();
}

class _HealthRecordsState extends ConsumerState<HealthRecordsScreen> {
  List<HealthRecordModel> _records = [];
  bool _loading = true;
  bool _fromCache = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);
    final patientId = ref.read(authProvider)?.id ?? '';

    try {
      final raw = await ApiService().getPatientRecords(patientId);
      final records = raw.map((m) =>
          HealthRecordModel.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      setState(() { _records = records; _loading = false; _fromCache = false; });
    } catch (_) {
      // Offline fallback
      final cached = await SyncService.getCached('health_records');
      if (cached != null) {
        final list = (cached as List).map((m) =>
            HealthRecordModel.fromMap(Map<String, dynamic>.from(m as Map))).toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        setState(() { _records = list; _loading = false; _fromCache = true; });
      } else {
        setState(() { _loading = false; _fromCache = true; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadRecords)],
      ),
      body: Column(children: [
        if (_fromCache) Container(
          color: Colors.orange, padding: const EdgeInsets.all(8),
          child: Row(children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text('Showing cached records', style: TextStyle(color: Colors.white)),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _records.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.folder_open_rounded, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text('No health records yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _records.length,
                      itemBuilder: (_, i) => _recordCard(_records[i], i),
                    ),
        ),
      ]),
    );
  }

  Widget _recordCard(HealthRecordModel record, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(record.doctorName, style: AppTextStyles.bodyBold.copyWith(fontSize: 14))),
              if (record.isEncrypted)
                const Icon(Icons.lock_rounded, size: 16, color: AppColors.textHint),
            ]),
            const SizedBox(height: 2),
            Text('${record.date.day}/${record.date.month}/${record.date.year}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(record.diagnosisSummary, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          maxLines: 2, overflow: TextOverflow.ellipsis),
        if (record.pdfUrl != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              // Opens download URL in browser; full download to device is future work
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('PDF: ${ApiConfig.baseHost}${record.pdfUrl}'),
              ));
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Download PDF'),
          ),
        ],
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 60), duration: 300.ms);
  }
}
