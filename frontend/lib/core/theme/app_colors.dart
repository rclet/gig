import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors for Bangladesh identity
  static const Color primary = Color(0xFF006A4E); // Bangladesh green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF004D36);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF6B35); // Vibrant orange
  static const Color secondaryLight = Color(0xFFFF8A65);
  static const Color secondaryDark = Color(0xFFE64A19);
  
  // Accent colors
  static const Color accent = Color(0xFF2196F3); // Blue for trust
  static const Color accentLight = Color(0xFF64B5F6);
  static const Color accentDark = Color(0xFF1976D2);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Outline colors
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineVariant = Color(0xFFF3F4F6);
  
  // Special effects
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  
  // Glassmorphism
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Job category colors
  static const Map<String, Color> categoryColors = {
    'development': Color(0xFF3B82F6),
    'design': Color(0xFFEF4444),
    'writing': Color(0xFF10B981),
    'marketing': Color(0xFFF59E0B),
    'business': Color(0xFF8B5CF6),
    'data': Color(0xFF06B6D4),
    'other': Color(0xFF6B7280),
  };
  
  // Status colors for projects/jobs
  static const Map<String, Color> statusColors = {
    'active': success,
    'pending': warning,
    'completed': info,
    'cancelled': error,
    'draft': textSecondary,
    'published': primary,
  };
}

extension AppColorsExtension on Color {
  /// Create a lighter shade of the color
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Create a darker shade of the color
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Create a more saturated version of the color
  Color saturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }
  
  /// Create a less saturated version of the color
  Color desaturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }
}