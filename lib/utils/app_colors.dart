import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Accent / brand ─────────────────────────────────────────────────────────
  static const Color accent      = Color(0xFF4F46E5); // Indigo-600
  static const Color accentLight = Color(0xFF818CF8); // Indigo-400

  // ── Module accents ─────────────────────────────────────────────────────────
  static const Color employee = Color(0xFF4F46E5); // Indigo
  static const Color visitor  = Color(0xFF0891B2); // Cyan-600
  static const Color signOut  = Color(0xFFDC2626); // Red-600
  static const Color success  = Color(0xFF16A34A); // Green-600

  // ── Background orbs (used by AppBackground) ────────────────────────────────
  static const Color orb1 = Color(0xFF6366F1); // Indigo — top-left
  static const Color orb2 = Color(0xFF3B82F6); // Blue   — bottom-right
  static const Color orb3 = Color(0xFF06B6D4); // Cyan   — mid-right

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Color tint(Color c) => c.withAlpha(30);

  static List<BoxShadow> glassShadow() => [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> buttonShadow(Color c) => [
        BoxShadow(
          color: c.withAlpha(80),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}
