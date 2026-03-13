import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Persistent banner driven by real connectivity stream.
/// Shows only when device has no network connection.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final isOffline = results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange,
          child: Row(children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Offline Mode — Showing cached data',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
          ]),
        ).animate().slideY(begin: -1, duration: 400.ms, curve: Curves.easeOut);
      },
    );
  }
}
