import 'package:flutter/material.dart';

/// Design tokens derived from Stitch "Executive Precision" theme for OmniDoc AI.
class AppColors {
  AppColors._();

  // Primary slate blues
  static const Color primary = Color(0xFF162839);
  static const Color primaryContainer = Color(0xFF2C3E50);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryFixedDim = Color(0xFFB5C8DF);

  // Mint green / emerald accents for AI triggers & active states
  static const Color secondary = Color(0xFF006D37);
  static const Color secondaryAccent = Color(0xFF27AE60);
  static const Color secondaryContainer = Color(0xFF7BF8A1);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF9F9FF);
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerHighest = Color(0xFFD8E3FB);

  // Typography & Text
  static const Color onSurface = Color(0xFF111C2D);
  static const Color onSurfaceVariant = Color(0xFF43474C);
  static const Color textMuted = Color(0xFF64748B);
  static const Color outline = Color(0xFF74777D);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Status & Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // Badge backgrounds for file types
  static const Color pdfBg = Color(0xFFFFE8E6);
  static const Color imageBg = Color(0xFFE2EDFD);
  static const Color audioBg = Color(0xFFE2F8EA);
  static const Color docBg = Color(0xFFEEF2F6);
}
