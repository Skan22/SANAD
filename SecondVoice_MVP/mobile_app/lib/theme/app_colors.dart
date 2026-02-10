import 'package:flutter/material.dart';

/// Centralized color constants for Second Voice
/// High-contrast, accessibility-focused palette
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Brand Colors ──────────────────────────────────────
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color sunsetOrange = Color(0xFFFF6B35);

  // ── Surface / Background ──────────────────────────────
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceBorder = Color(0x1AFFFFFF); // white 10%

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x8AFFFFFF); // white54
  static const Color textTertiary = Color(0x61FFFFFF); // white38
  static const Color textSubtle = Color(0xB3FFFFFF);   // white70

  // ── Status ────────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B);
  static const Color recording = Colors.red;

  // ── Slider ────────────────────────────────────────────
  static const Color sliderOverlay = Color(0x2900D4FF);
}
