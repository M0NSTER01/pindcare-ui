import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/map_service.dart';
import '../../data/models/facility_model.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});
  @override
  State<OfflineMapScreen> createState() => _State();
}

class _State extends State<OfflineMapScreen> {
  List<FacilityModel> _facilities = [];
  String _filter = 'All';
  FacilityModel? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final facilities = await MapDataService.instance.loadNearbyFacilities();
    setState(() { _facilities = facilities; _loading = false; });
  }

  List<FacilityModel> get _filtered {
    if (_filter == 'All') return _facilities;
    final typeMap = {'Hospitals': 'hospital', 'Clinics': 'clinic', 'Pharmacies': 'pharmacy', 'Doctors': 'doctor_clinic'};
    return _facilities.where((f) => f.type == typeMap[_filter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nearby Healthcare')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            // Filters
            SizedBox(height: 44, child: ListView(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Hospitals', 'Clinics', 'Pharmacies', 'Doctors'].map((f) {
                final sel = f == _filter;
                return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
                  label: Text(f), selected: sel,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15), checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.labelSmall.copyWith(color: sel ? AppColors.primary : AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: sel ? AppColors.primary : AppColors.divider)),
                  onSelected: (_) => setState(() => _filter = f)));
              }).toList())),
            const SizedBox(height: 8),
            // Map placeholder
            Container(height: 240, margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider)),
              child: Stack(children: [
                Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.map_rounded, size: 48, color: AppColors.textHint.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Offline Map View', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  Text('${_filtered.length} facilities nearby', style: AppTextStyles.caption),
                ])),
                // Patient location marker
                Positioned(top: 100, left: 120, child: Container(width: 16, height: 16,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8)]))),
                // Distance circle
                Positioned(top: 60, left: 80, child: Container(width: 96, height: 96,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                    color: AppColors.primary.withValues(alpha: 0.05)))),
                // Markers
                ..._filtered.take(5).toList().asMap().entries.map((e) => Positioned(
                  top: 40.0 + (e.key * 35.0), left: 60.0 + (e.key * 40.0),
                  child: Container(padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: _typeColor(e.value.type), shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                    child: Icon(_typeIcon(e.value.type), color: Colors.white, size: 12)))),
              ])),
            const SizedBox(height: 12),
            // Facility list
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filtered.length,
              itemBuilder: (_, i) => _facilityCard(_filtered[i], i))),
          ]),
    );
  }

  Widget _facilityCard(FacilityModel facility, int index) {
    final color = _typeColor(facility.type);
    return GestureDetector(
      onTap: () => setState(() => _selected = facility),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(18),
          border: _selected?.id == facility.id ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(facility.typeIcon, style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(facility.name, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
            Text(facility.address, style: AppTextStyles.caption.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: facility.isOpen ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
                child: Text(facility.isOpen ? 'Open' : 'Closed',
                  style: AppTextStyles.caption.copyWith(color: facility.isOpen ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Icon(Icons.directions_walk_rounded, size: 12, color: AppColors.textHint),
              const SizedBox(width: 2),
              Text('${facility.distance} km', style: AppTextStyles.caption.copyWith(fontSize: 11)),
            ]),
          ])),
          Column(children: [
            GestureDetector(onTap: () { HapticFeedback.mediumImpact(); },
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_rounded, color: AppColors.primary, size: 18))),
            const SizedBox(height: 6),
            GestureDetector(onTap: () { HapticFeedback.lightImpact(); },
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.phone_rounded, color: AppColors.accent, size: 18))),
          ]),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 60), duration: 300.ms);
  }

  Color _typeColor(String type) => type == 'hospital' ? AppColors.error
    : type == 'clinic' ? AppColors.primary
    : type == 'pharmacy' ? AppColors.accent
    : AppColors.secondary;

  IconData _typeIcon(String type) => type == 'hospital' ? Icons.local_hospital_rounded
    : type == 'clinic' ? Icons.medical_services_rounded
    : type == 'pharmacy' ? Icons.local_pharmacy_rounded
    : Icons.person_rounded;
}
