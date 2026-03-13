import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// Displays stock freshness for pharmacy listings.
/// Shows green "Live Stock" chip or time-ago with orange/red colouring.
class StockFreshnessBadge extends StatelessWidget {
  final Map<String, dynamic> pharmacy;
  const StockFreshnessBadge({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final isLive = pharmacy['isLive'] == true || pharmacy['is_live'] == true;
    final minutesAgo = (pharmacy['minutesAgo'] ?? pharmacy['minutes_ago'] ?? 999) as int;

    if (isLive) {
      return Chip(
        label: Text('Live Stock', style: AppTextStyles.labelSmall.copyWith(color: Colors.green[800])),
        backgroundColor: Colors.green[50],
        avatar: const Icon(Icons.circle, size: 10, color: Colors.green),
        visualDensity: VisualDensity.compact,
      );
    }

    String label;
    if (minutesAgo < 60) {
      label = '${minutesAgo}m ago';
    } else if (minutesAgo < 1440) {
      label = '${(minutesAgo / 60).round()}h ago';
    } else {
      label = '${(minutesAgo / 1440).round()}d ago';
    }

    final isStale = minutesAgo > 1440;
    final color = isStale ? Colors.red : Colors.orange;

    return Chip(
      label: Text('Updated $label', style: AppTextStyles.labelSmall.copyWith(color: color[800])),
      backgroundColor: Color.fromRGBO(color.red, color.green, color.blue, 0.08),
      avatar: Icon(Icons.history_rounded, size: 14, color: color[600]),
      visualDensity: VisualDensity.compact,
    );
  }
}
