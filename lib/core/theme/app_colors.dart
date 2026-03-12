import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF0A6E4F);
  static const Color primaryLight = Color(0xFF1A8E6F);
  static const Color primaryDark = Color(0xFF085E43);
  
  // Secondary
  static const Color secondary = Color(0xFFF5A623);
  static const Color secondaryLight = Color(0xFFFFBE4D);
  static const Color secondaryDark = Color(0xFFD4900F);
  
  // Accent
  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF33CFBB);
  static const Color accentDark = Color(0xFF009E89);
  
  // Backgrounds
  static const Color background = Color(0xFFF0F4F3);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8F0EE);
  
  // Status
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  
  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5C6B73);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF9CA3AF);
  
  // Misc
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x1A0A6E4F);
  static const Color overlay = Color(0x80000000);
  
  // Online Status
  static const Color online = Color(0xFF43A047);
  static const Color offline = Color(0xFFBDBDBD);
  static const Color busy = Color(0xFFFFA726);
  
  // Stock Status
  static const Color inStock = Color(0xFF43A047);
  static const Color outOfStock = Color(0xFFE53935);
  static const Color lowStock = Color(0xFFFFA726);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFFFFCC02)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFFF6659)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient offlineGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFFF6659)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
