import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/stock_freshness_badge.dart';

class PharmacyStockScreen extends ConsumerStatefulWidget {
  const PharmacyStockScreen({super.key});
  @override
  ConsumerState<PharmacyStockScreen> createState() => _PharmacyStockState();
}

class _PharmacyStockState extends ConsumerState<PharmacyStockScreen> {
  List<Map<String, dynamic>> _catalog = [];
  Map<String, Map<String, dynamic>> _stockState = {};
  bool _loading = true;
  bool _submitting = false;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    // Send heartbeat every 5 minutes while screen is active
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      ApiService().sendHeartbeat();
    });
    // Send initial heartbeat
    ApiService().sendHeartbeat();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService().getMedicineCatalog();
      final catalog = raw.map((m) => Map<String, dynamic>.from(m as Map)).toList();
      // Initialize stock state
      final state = <String, Map<String, dynamic>>{};
      for (final med in catalog) {
        final id = med['id'] as String? ?? '';
        state[id] = {'inStock': true, 'quantity': med['default_quantity'] ?? 0};
      }
      setState(() { _catalog = catalog; _stockState = state; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitStock() async {
    setState(() => _submitting = true);
    try {
      final items = _catalog.map((med) {
        final id = med['id'] as String? ?? '';
        return {
          'medicine_id': id,
          'in_stock': _stockState[id]?['inStock'] ?? false,
          'quantity': _stockState[id]?['quantity'] ?? 0,
        };
      }).toList();
      await ApiService().updatePharmacyStock(items);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Stock updated successfully'), backgroundColor: Colors.green),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update stock'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Update Stock'),
        actions: [
          Container(margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Live', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
            ])),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _catalog.length,
                itemBuilder: (_, i) => _medicineRow(_catalog[i], i),
              )),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
                child: _submitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _submitStock,
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: const Text('Submit Stock Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
              ),
            ]),
    );
  }

  Widget _medicineRow(Map<String, dynamic> med, int index) {
    final id = med['id'] as String? ?? '';
    final inStock = _stockState[id]?['inStock'] as bool? ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(med['name'] as String? ?? '', style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
          if (med['generic_name'] != null)
            Text(med['generic_name'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
        ])),
        Switch(value: inStock, activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _stockState[id]?['inStock'] = v)),
        const SizedBox(width: 8),
        SizedBox(width: 60, child: TextFormField(
          initialValue: (_stockState[id]?['quantity'] ?? 0).toString(),
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodySmall,
          decoration: InputDecoration(
            hintText: 'Qty', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          onChanged: (v) => _stockState[id]?['quantity'] = int.tryParse(v) ?? 0,
        )),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 40), duration: 250.ms);
  }
}
