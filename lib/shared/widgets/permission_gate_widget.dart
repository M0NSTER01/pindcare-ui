import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/permission_service.dart';

class PermissionGateWidget extends StatelessWidget {
  final String permission; // camera, microphone, location, storage
  final Widget child;
  final String title;
  final String description;
  final IconData icon;

  const PermissionGateWidget({
    super.key,
    required this.permission,
    required this.child,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == true) return child;
        return _buildDeniedCard(context);
      },
    );
  }

  Future<bool> _checkPermission() async {
    switch (permission) {
      case 'camera':
        return PermissionService.instance.requestCameraPermission();
      case 'microphone':
        return PermissionService.instance.requestMicrophonePermission();
      case 'location':
        return PermissionService.instance.requestLocationPermission();
      case 'storage':
        return PermissionService.instance.requestStoragePermission();
      default:
        return false;
    }
  }

  Widget _buildDeniedCard(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.warning, size: 40),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.heading3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(description, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Now'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                await _checkPermission();
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              },
              child: const Text('Allow Access'),
            ),
          ]),
        ]),
      ),
    );
  }
}
