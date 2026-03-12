import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            _header(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 24),
            _section('Clinic Information', [
              _infoTile(Icons.local_hospital_rounded, 'Hospital', 'Nabha Government Hospital'),
              _infoTile(Icons.location_on_rounded, 'Address', 'Hospital Road, Nabha, Patiala'),
              _infoTile(Icons.access_time_rounded, 'Hours', 'Mon-Sat: 9 AM - 5 PM'),
              _infoTile(Icons.currency_rupee_rounded, 'Fee', '₹200 per consultation'),
            ]),
            const SizedBox(height: 16),
            _section('Verification', [
              _verificationTile('Medical Degree', 'MBBS — Govt. Medical College, Patiala', true),
              _verificationTile('Registration', 'MCI-PB-12345', true),
            ]),
            const SizedBox(height: 16),
            _section('Settings', [
              _settingsTile(Icons.notifications_rounded, 'Notifications', true),
              _settingsTile(Icons.language_rounded, 'Language', false),
              _settingsTile(Icons.lock_rounded, 'Privacy', false),
              _settingsTile(Icons.help_rounded, 'Help & Support', false),
              _settingsTile(Icons.logout_rounded, 'Logout', false, isDestructive: true),
            ]),
            const SizedBox(height: 100),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0), padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Column(children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3)),
        child: Center(child: Text('AK', style: AppTextStyles.heading2.copyWith(color: Colors.white)))),
      const SizedBox(height: 12),
      Text('Dr. Amandeep Kaur', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Text('General Physician', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text('Verified', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ])),
      ]),
      const SizedBox(height: 12),
      Text('8 years experience • Hindi, English, Punjabi',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 13), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.star_rounded, color: AppColors.secondary, size: 18),
        const SizedBox(width: 4),
        Text('4.8 Rating', style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: 14)),
      ]),
    ]),
  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);

  Widget _statsRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      _statCard('124', 'Total\nPatients', AppColors.primary),
      const SizedBox(width: 10),
      _statCard('45', 'This\nMonth', AppColors.accent),
      const SizedBox(width: 10),
      _statCard('892', 'Total\nConsults', AppColors.secondary),
    ]),
  );

  Widget _statCard(String value, String label, Color color) => Expanded(
    child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(children: [
        Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11), textAlign: TextAlign.center),
      ])),
  );

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTextStyles.heading4),
      const SizedBox(height: 12),
      Container(decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(children: children)),
    ]),
  );

  Widget _infoTile(IconData icon, String label, String value) => ListTile(
    leading: Container(width: 40, height: 40, decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppColors.primary, size: 20)),
    title: Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
    subtitle: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)));

  Widget _verificationTile(String title, String subtitle, bool verified) => ListTile(
    leading: Container(width: 40, height: 40, decoration: BoxDecoration(
      color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(verified ? Icons.verified_rounded : Icons.pending_rounded,
        color: verified ? AppColors.success : AppColors.secondary, size: 20)),
    title: Text(title, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
    subtitle: Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 12)));

  Widget _settingsTile(IconData icon, String title, bool hasToggle, {bool isDestructive = false}) => ListTile(
    leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary, size: 22),
    title: Text(title, style: AppTextStyles.bodyMedium.copyWith(
      color: isDestructive ? AppColors.error : null, fontSize: 15)),
    trailing: hasToggle ? Switch(value: true, onChanged: (_) {},
      activeColor: AppColors.primary) : const Icon(Icons.chevron_right_rounded, color: AppColors.textHint));
}
